// lib/services/notifications/fcm_handler.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'notification_types.dart';
import 'notification_config.dart';
import 'notification_sender.dart';
import '../analytics_service.dart';

/// Класс для обработки Firebase Cloud Messaging
class FCMHandler {
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final NotificationSender _notificationSender;
  final AnalyticsService _analytics;

  FCMHandler(
    this._messaging,
    this._firestore,
    this._notificationSender,
    this._analytics,
  );

  /// Инициализация FCM с обработчиками
  Future<void> initialize() async {
    print('FCM Handler initializing...');

    // Получение и сохранение начального токена
    await _initializeFCMToken();

    // Настройка обработчиков сообщений
    _setupMessageHandlers();

    // Подписка на топики
    await _subscribeToTopics();

    print('FCM Handler initialized');
  }

  /// Инициализация и сохранение FCM токена
  Future<void> _initializeFCMToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveFCMToken(token);
        print('FCM token obtained and saved');
      }

      // Обработка обновлений токена
      _messaging.onTokenRefresh.listen((newToken) {
        print('FCM token refreshed');
        _saveFCMToken(newToken);
      });

    } catch (e) {
      print('Error initializing FCM token: $e');
    }
  }

  /// Настройка обработчиков сообщений
  void _setupMessageHandlers() {
    // Сообщения в foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Открытие уведомления когда приложение в background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);

    // Обработка начального сообщения (если приложение открыто через уведомление)
    _handleInitialMessage();
  }

  /// Обработка начального сообщения
  Future<void> _handleInitialMessage() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        print('App opened from notification');
        _handleNotificationOpen(initialMessage);
      }
    } catch (e) {
      print('Error handling initial message: $e');
    }
  }

  /// Обработка сообщения в foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground FCM message received: ${message.messageId}');

    try {
      // Логируем получение - УБРАНО: вызов несуществующего метода
      print('FCM Message: ${message.messageId}, title: ${message.notification?.title}, hasData: ${message.data.isNotEmpty}');

      // Если есть notification - показываем как локальное уведомление
      if (message.notification != null) {
        await _showForegroundNotification(message);
      }

      // Обрабатываем data payload
      if (message.data.isNotEmpty) {
        await _processDataPayload(message.data);
      }

    } catch (e) {
      print('Error handling foreground message: $e');
      // УБРАНО: вызов _analytics.logFCMError
    }
  }

  /// Показ foreground уведомления как локального
  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'FoodCoach';
    final body = message.notification?.body ?? '';

    // Определяем тип из data или используем custom
    final typeStr = message.data['type'] ?? 'custom';
    NotificationType type;
    
    try {
      type = NotificationType.values.firstWhere((t) => t.name == typeStr);
    } catch (e) {
      type = NotificationType.custom;
    }

    await _notificationSender.sendNotification(
      type: type,
      title: title,
      body: body,
      payload: message.data,
      skipChecks: true, // FCM уведомления высокоприоритетные
    );

    print('Foreground notification shown: $title');
  }

  /// Обработка data payload
  Future<void> _processDataPayload(Map<String, dynamic> data) async {
    final action = data['action'] as String?;
    
    if (action != null) {
      print('Processing FCM data action: $action');
      
      // Обрабатываем специальные действия
      switch (action) {
        case 'update_goals':
          await _handleUpdateGoals(data);
          break;
        case 'sync_data':
          await _handleSyncData(data);
          break;
        case 'show_pro_offer':
          await _handleShowProOffer(data);
          break;
        default:
          // Стандартная обработка через основной процессор
          await _processNotificationAction(jsonEncode(data));
      }
    }
  }

  /// Обработка открытия уведомления
  Future<void> _handleNotificationOpen(RemoteMessage message) async {
    print('FCM notification opened: ${message.messageId}');

    try {
      // Логируем открытие - УБРАНО: вызов несуществующего метода
      print('Notification opened: type=${message.data['type'] ?? 'fcm'}, action=${message.data['action']}');

      // Обрабатываем действие
      if (message.data.isNotEmpty) {
        await _processNotificationAction(jsonEncode(message.data));
      }

    } catch (e) {
      print('Error handling notification open: $e');
    }
  }

  /// Основной процессор действий уведомлений
  static Future<void> _processNotificationAction(String? payload) async {
    if (payload == null) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final action = data['action'] as String?;

      print('Processing notification action: $action');

      // Здесь будет роутинг к соответствующим экранам
      // В зависимости от архитектуры приложения
      switch (action) {
        case 'drink_water':
          // Открыть главный экран
          break;
        case 'add_electrolytes':
          // Открыть экран добавления электролитов
          break;
        case 'show_report':
          // Открыть отчет
          break;
        case 'alcohol_recovery':
          // Открыть экран алкоголя
          break;
        case 'post_workout':
          // Открыть экран тренировки
          break;
        case 'morning_checkin':
          // Открыть утренний чек-ин
          break;
        case 'heat_warning':
          // Показать предупреждение о жаре
          break;
        default:
          print('Unknown action: $action');
      }

    } catch (e) {
      print('Error processing notification action: $e');
    }
  }

  /// Сохранение FCM токена
  Future<void> _saveFCMToken(String token) async {
    try {
      // Сохранение в SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(NotificationConfig.prefFcmToken, token);

      // Сохранение в Firestore для текущего пользователя
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'fcm_token': token,
          'platform': Platform.operatingSystem,
          'app_version': '1.0.0', // Можно получить из package_info
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        print('FCM token saved to Firestore for user: ${user.uid}');
      }

      // Обновляем устройства для push-кампаний
      await _updateDeviceInfo(token);

    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  /// Обновление информации об устройстве
  Future<void> _updateDeviceInfo(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final prefs = await SharedPreferences.getInstance();
      final isPro = prefs.getBool(NotificationConfig.prefIsPro) ?? false;
      final dietMode = prefs.getString(NotificationConfig.prefDietMode) ?? 'normal';

      await _firestore.collection('devices').doc(token).set({
        'user_id': user.uid,
        'platform': Platform.operatingSystem,
        'is_pro': isPro,
        'diet_mode': dietMode,
        'last_active': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

    } catch (e) {
      print('Error updating device info: $e');
    }
  }

  /// Подписка на топики
  Future<void> _subscribeToTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Подписка на общий топик
      await _messaging.subscribeToTopic('all_users');
      print('Subscribed to: all_users');

      // Подписка на топик по режиму диеты
      final dietMode = prefs.getString(NotificationConfig.prefDietMode) ?? 'normal';
      await _messaging.subscribeToTopic('${dietMode}_users');
      print('Subscribed to: ${dietMode}_users');

      // Подписка на топик по статусу PRO
      final isPro = prefs.getBool(NotificationConfig.prefIsPro) ?? false;
      final proTopic = isPro ? 'pro_users' : 'free_users';
      await _messaging.subscribeToTopic(proTopic);
      print('Subscribed to: $proTopic');

      // Подписка на топик по платформе
      final platformTopic = Platform.isIOS ? 'ios_users' : 'android_users';
      await _messaging.subscribeToTopic(platformTopic);
      print('Subscribed to: $platformTopic');

    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  /// Отписка от топиков (при смене настроек)
  Future<void> _unsubscribeFromTopics(List<String> topics) async {
    try {
      for (final topic in topics) {
        await _messaging.unsubscribeFromTopic(topic);
        print('Unsubscribed from: $topic');
      }
    } catch (e) {
      print('Error unsubscribing from topics: $e');
    }
  }

  /// Обновление подписок на топики при изменении настроек
  Future<void> updateTopicSubscriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Отписываемся от старых топиков диеты
      final oldDietTopics = ['normal_users', 'keto_users', 'fasting_users'];
      await _unsubscribeFromTopics(oldDietTopics);
      
      // Отписываемся от старых PRO топиков
      await _unsubscribeFromTopics(['pro_users', 'free_users']);
      
      // Подписываемся на новые
      await _subscribeToTopics();
      
    } catch (e) {
      print('Error updating topic subscriptions: $e');
    }
  }

  // ==================== СПЕЦИАЛЬНЫЕ ОБРАБОТЧИКИ DATA PAYLOAD ====================

  /// Обработка обновления целей
  Future<void> _handleUpdateGoals(Map<String, dynamic> data) async {
    print('Handling update goals from FCM');
    
    // Здесь можно обновить локальные цели из серверных данных
    // Или показать уведомление о том, что цели изменились
    
    try {
      final newWaterGoal = data['water_goal'] as int?;
      final newSodiumGoal = data['sodium_goal'] as int?;
      
      if (newWaterGoal != null || newSodiumGoal != null) {
        // Обновляем локальные цели
        // Можно отправить событие через EventBus или State Management
        print('New goals from server: water=$newWaterGoal, sodium=$newSodiumGoal');
      }
    } catch (e) {
      print('Error processing goal update: $e');
    }
  }

  /// Обработка синхронизации данных
  Future<void> _handleSyncData(Map<String, dynamic> data) async {
    print('Handling data sync from FCM');
    
    // Можно запустить фоновую синхронизацию
    try {
      final syncType = data['sync_type'] as String?;
      
      switch (syncType) {
        case 'full':
          // Полная синхронизация
          break;
        case 'incremental':
          // Инкрементальная синхронизация
          break;
        default:
          print('Unknown sync type: $syncType');
      }
    } catch (e) {
      print('Error processing data sync: $e');
    }
  }

  /// Обработка показа PRO предложения
  Future<void> _handleShowProOffer(Map<String, dynamic> data) async {
    print('Handling PRO offer from FCM');
    
    try {
      final offerType = data['offer_type'] as String?;
      final discount = data['discount'] as String?;
      
      // Показать PRO предложение с кастомными параметрами
      print('PRO offer: type=$offerType, discount=$discount');
      
      // Здесь можно показать специальный экран PRO с дисконтом
    } catch (e) {
      print('Error processing PRO offer: $e');
    }
  }

  // ==================== ОТЛАДКА И СТАТУС ====================

  /// Получение текущего FCM токена
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Проверка статуса разрешений
  Future<Map<String, dynamic>> getPermissionStatus() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      
      return {
        'authorization_status': settings.authorizationStatus.toString(),
        'alert': settings.alert.toString(),
        'badge': settings.badge.toString(),
        'sound': settings.sound.toString(),
        'announcement': settings.announcement.toString(),
        'car_play': settings.carPlay.toString(),
        'critical_alert': settings.criticalAlert.toString(),
      };
    } catch (e) {
      print('Error getting FCM permissions: $e');
      return {'error': e.toString()};
    }
  }

  /// Тестовая отправка данных на сервер
  Future<void> sendTestDataToServer() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await _firestore.collection('test_data').add({
        'user_id': user.uid,
        'platform': Platform.operatingSystem,
        'timestamp': FieldValue.serverTimestamp(),
        'test_type': 'fcm_handler_test',
      });

      print('Test data sent to server');
    } catch (e) {
      print('Error sending test data: $e');
    }
  }

  /// Очистка данных при выходе пользователя
  Future<void> cleanup() async {
    try {
      // Отписываемся от всех топиков
      final topics = [
        'all_users',
        'normal_users', 'keto_users', 'fasting_users',
        'pro_users', 'free_users',
        'ios_users', 'android_users',
      ];
      
      await _unsubscribeFromTopics(topics);
      
      // Удаляем токен из SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(NotificationConfig.prefFcmToken);
      
      print('FCM cleanup completed');
    } catch (e) {
      print('Error during FCM cleanup: $e');
    }
  }
}