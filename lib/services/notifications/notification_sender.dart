// lib/services/notifications/notification_sender.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'notification_types.dart';
import 'notification_config.dart';
import '../notification_texts.dart';
import '../analytics_service.dart';
import 'helpers/timezone_helper.dart';
import 'helpers/notification_limits_helper.dart';

/// Класс для отправки и планирования уведомлений
class NotificationSender {
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFirestore _firestore;
  final NotificationLimitsHelper _limitsHelper;
  final AnalyticsService _analytics;
  
  // Кеш для отслеживания отправленных уведомлений
  final Map<NotificationType, int> _lastNotificationIds = {};
  final Set<int> _pendingNotificationIds = {};

  NotificationSender(
    this._localNotifications,
    this._firestore,
    this._limitsHelper,
    this._analytics,
  );

  /// Основной метод отправки уведомлений
  Future<void> sendNotification({
    required NotificationType type,
    required String title,
    required String body,
    DateTime? scheduledTime,
    Map<String, dynamic>? payload,
    bool skipChecks = false,
    bool silentIfQuiet = false,
  }) async {
    // Проверки и валидации
    if (!skipChecks) {
      final canSend = await _performChecks(type, scheduledTime, silentIfQuiet);
      if (!canSend) return;
    }

    // Отмена старых уведомлений того же типа (для singleton)
    if (type.isSingleton) {
      await _cancelOldNotificationOfType(type);
    }

    // Корректировка времени для тихих часов
    if (scheduledTime != null) {
      scheduledTime = await _adjustScheduledTime(scheduledTime, skipChecks, silentIfQuiet);
    }

    // Создание деталей уведомления
    final details = await _createNotificationDetails(type, title, body, scheduledTime, silentIfQuiet);
    
    // Генерация ID
    final notificationId = _generateNotificationId(type, when: scheduledTime);
    
    // Создание payload
    final mergedPayload = {
      'type': type.name,
      ...?payload, // ИСПРАВЛЕНО: правильный spread-оператор
    };
    final payloadStr = jsonEncode(mergedPayload);

    // Запоминаем ID для singleton типов
    if (type.isSingleton) {
      _lastNotificationIds[type] = notificationId;
    }

    try {
      if (scheduledTime == null) {
        // Отправляем сразу
        await _sendImmediateNotification(
          notificationId,
          title,
          body,
          details,
          payloadStr,
          type,
        );
      } else {
        // Планируем на будущее
        await _scheduleNotification(
          notificationId,
          title,
          body,
          details,
          payloadStr,
          scheduledTime,
          type,
        );
      }

      // Сохраняем в историю
      await _saveNotificationToHistory(type, title, body, scheduledTime);

    } catch (e) {
      print('❌ Error sending notification: $e');
      // Убираем вызов несуществующего метода
      print('Notification error: type=$type, error=$e');
    }
  }

  /// ИСПРАВЛЕНО: Новая схема генерации ID без потери информации о дне
  int _generateNotificationId(NotificationType type, {DateTime? when}) {
    final t = when ?? DateTime.now();
    final day = TimezoneHelper.dayOfYear(t);
    final minutesInDay = t.hour * 60 + t.minute;
    final fromYearStart = day * 1440 + minutesInDay; // 0..527039
    return type.index * 1_000_000 + fromYearStart; // ИСПРАВЛЕНО: увеличено пространство
  }

  /// Декодирование информации из ID уведомления
  static ({int typeIdx, int dayFromId, int hour, int minute}) decodeNotificationId(int id) {
    final typeIdx = id ~/ 1_000_000;
    final fromYearStart = id % 1_000_000;
    final dayFromId = fromYearStart ~/ 1440;
    final minutesInDay = fromYearStart % 1440;
    final hour = minutesInDay ~/ 60;
    final minute = minutesInDay % 60;
    
    return (
      typeIdx: typeIdx,
      dayFromId: dayFromId,
      hour: hour,
      minute: minute,
    );
  }

  /// Выполнение всех проверок перед отправкой
  Future<bool> _performChecks(NotificationType type, DateTime? scheduledTime, bool silentIfQuiet) async {
    // Проверка дубликатов
    if (await _limitsHelper.isDuplicateNotification(type, null)) {
      print('🚫 Duplicate notification blocked: $type');
      return false;
    }

    // Только для немедленной отправки
    if (scheduledTime == null) {
      // Проверка базовых лимитов
      if (!await _limitsHelper.canSendNotification()) {
        print('⌛ Cannot send: daily limit or anti-spam');
        print('Notification error: type=$type, error=Daily limit or anti-spam');
        return false;
      }

      // Проверка PRO лимитов
      if (await _limitsHelper.isProUser()) {
        if (!await _limitsHelper.checkProDailyCap()) {
          print('⌛ PRO hard cap reached');
          print('Notification error: type=$type, error=PRO hard cap');
          return false;
        }
      }

      // Проверка тихих часов
      if (await _limitsHelper.isInQuietHours() && !silentIfQuiet) {
        print('🔇 Cannot send: quiet hours active');
        return false;
      }

      // Проверка режима поста
      if (!await _limitsHelper.shouldSendQuietFastingReminder()) {
        print('🥗 Cannot send: quiet fasting mode');
        return false;
      }
    }

    return true;
  }

  /// Корректировка запланированного времени
  Future<DateTime?> _adjustScheduledTime(DateTime scheduledTime, bool skipChecks, bool silentIfQuiet) async {
    if (scheduledTime.isBefore(DateTime.now())) {
      print('⚠️ Scheduled time in the past, sending immediately');
      return null;
    }
    
    if (!skipChecks && !silentIfQuiet) {
      return await _limitsHelper.adjustForQuietHours(scheduledTime);
    }
    
    return scheduledTime;
  }

  /// Создание деталей уведомления для Android и iOS
  Future<NotificationDetails> _createNotificationDetails(
    NotificationType type,
    String title,
    String body,
    DateTime? scheduledTime,
    bool silentIfQuiet,
  ) async {
    final currentLocale = NotificationTexts.currentLocale;
    
    // Определение канала и приоритета
    String channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.defaultChannelSuffix}_$currentLocale';
    Importance importance = Importance.high;
    Priority priority = Priority.high;

    // ИСПРАВЛЕНО: Добавлен недостающий case для NotificationPriority.high
    switch (type.priority) {
      case NotificationPriority.urgent:
        channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.urgentChannelSuffix}_$currentLocale';
        importance = Importance.max;
        priority = Priority.max;
        break;
      case NotificationPriority.high:
        channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.defaultChannelSuffix}_$currentLocale';
        importance = Importance.high;
        priority = Priority.high;
        break;
      case NotificationPriority.normal:
        channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.reportChannelSuffix}_$currentLocale';
        importance = Importance.defaultImportance;
        priority = Priority.defaultPriority;
        break;
      case NotificationPriority.low:
        channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.silentChannelSuffix}_$currentLocale';
        importance = Importance.low;
        priority = Priority.low;
        break;
    }

    // Проверка на тихий режим
    bool quietForThis = false;
    if (silentIfQuiet) {
      if (scheduledTime != null) {
        final prefs = await SharedPreferences.getInstance();
        final startStr = prefs.getString(NotificationConfig.prefQuietHoursStart) ?? NotificationConfig.defaultQuietHoursStart;
        final endStr = prefs.getString(NotificationConfig.prefQuietHoursEnd) ?? NotificationConfig.defaultQuietHoursEnd;
        quietForThis = _limitsHelper.isInQuietHoursAt(scheduledTime, startStr, endStr) && await _limitsHelper.isProUser();
      } else {
        quietForThis = await _limitsHelper.isInQuietHours();
      }
    }

    if (quietForThis) {
      channelId = '${NotificationConfig.channelPrefix}_${NotificationConfig.silentChannelSuffix}_$currentLocale';
      importance = Importance.low;
      priority = Priority.low;
    }

    // Android детали
    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      importance: importance,
      priority: priority,
      ticker: 'FoodCoach',
      icon: '@mipmap/ic_launcher',
      color: const Color.fromARGB(255, 33, 150, 243),
      enableVibration: !channelId.contains('report') && !channelId.contains('silent'),
      playSound: !channelId.contains('silent'),
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'FoodCoach',
      ),
    );

    // iOS детали
    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: !quietForThis,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
  }

  /// Получение локализованного имени канала
  String _getChannelName(String channelId) {
    if (channelId.contains('urgent')) {
      return NotificationTexts.channelNameUrgent;
    } else if (channelId.contains('report')) {
      return NotificationTexts.channelNameReport;
    } else if (channelId.contains('silent')) {
      return NotificationTexts.channelNameSilent;
    } else {
      return NotificationTexts.channelNameDefault;
    }
  }

  /// Отправка немедленного уведомления
  Future<void> _sendImmediateNotification(
    int notificationId,
    String title,
    String body,
    NotificationDetails details,
    String payloadStr,
    NotificationType type,
  ) async {
    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: payloadStr,
    );

    // Обновление счетчиков и кеша
    await _limitsHelper.incrementNotificationCount();
    await _limitsHelper.saveLastNotificationTime();
    await _limitsHelper.incrementProCount();

    print('📬 Notification sent: $title');

    // Убираем вызов несуществующего метода аналитики
    print('Notification sent: type=$type, scheduled=false');
  }

  /// Планирование уведомления на будущее
  Future<void> _scheduleNotification(
    int notificationId,
    String title,
    String body,
    NotificationDetails details,
    String payloadStr,
    DateTime scheduledTime,
    NotificationType type,
  ) async {
    final tzScheduledTime = TimezoneHelper.toTZDateTime(scheduledTime);

    await _localNotifications.zonedSchedule(
      notificationId,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payloadStr,
    );

    _pendingNotificationIds.add(notificationId);

    print('📅 Notification scheduled for ${scheduledTime.hour}:${scheduledTime.minute.toString().padLeft(2, '0')}: $title');

    // Убираем вызов несуществующего метода аналитики
    print('Notification scheduled: type=$type, delay=${scheduledTime.difference(DateTime.now()).inMinutes}min');
  }

  /// Отмена старого уведомления того же типа
  Future<void> _cancelOldNotificationOfType(NotificationType type) async {
    final oldId = _lastNotificationIds[type];
    if (oldId != null && _pendingNotificationIds.contains(oldId)) {
      await _localNotifications.cancel(oldId);
      _pendingNotificationIds.remove(oldId);
      print('🚫 Cancelled old notification of type $type (ID: $oldId)');
    }
  }

  /// Сохранение уведомления в историю Firestore
  Future<void> _saveNotificationToHistory(
    NotificationType type,
    String title,
    String body,
    DateTime? scheduledTime,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notification_history')
          .add({
        'type': type.toString(),
        'scheduled_time': scheduledTime?.toIso8601String(),
        'sent_at': FieldValue.serverTimestamp(),
        // ИСПРАВЛЕНО: Убираем title/body для приватности согласно задачам
      });
    } catch (e) {
      print('⚠️ Error saving notification history: $e');
    }
  }

  /// Геттеры для доступа к внутреннему состоянию
  Set<int> get pendingNotificationIds => _pendingNotificationIds;
  Map<NotificationType, int> get lastNotificationIds => _lastNotificationIds;

  /// Метод для обновления внутреннего состояния
  void updatePendingIds(Set<int> ids) {
    _pendingNotificationIds.clear();
    _pendingNotificationIds.addAll(ids);
  }

  /// ПУБЛИЧНЫЙ метод генерации ID для использования в других компонентах
  int generateNotificationId(NotificationType type, {DateTime? when}) {
    return _generateNotificationId(type, when: when);
  }

  /// ПУБЛИЧНЫЙ доступ к FlutterLocalNotificationsPlugin для других компонентов
  FlutterLocalNotificationsPlugin get localNotifications => _localNotifications;
}