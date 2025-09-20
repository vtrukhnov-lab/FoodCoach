import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart' as notif;

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // Статус пользователя
  bool _isPro = false;
  
  // Настройки уведомлений
  bool _postCoffeeReminders = true;
  bool _eveningReports = true;
  bool _heatWarnings = true;
  bool _postAlcoholReminders = true;
  
  // Время уведомлений
  TimeOfDay _morningTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _eveningTime = const TimeOfDay(hour: 21, minute: 0);
  
  // Частота напоминаний о воде
  int _reminderFrequency = 4;
  
  // Тихие часы (PRO)
  bool _quietHoursEnabled = false;
  TimeOfDay _quietStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietEnd = const TimeOfDay(hour: 7, minute: 0);
  
  // Статистика
  int _todayCount = 0;
  
  // Debug режим
  bool _showDebugPanel = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _isPro = prefs.getBool('is_pro') ?? false;
      _postCoffeeReminders = prefs.getBool('post_coffee_reminders') ?? true;
      _eveningReports = prefs.getBool('evening_reports') ?? true;
      _heatWarnings = prefs.getBool('heat_warnings') ?? true;
      _postAlcoholReminders = prefs.getBool('post_alcohol_reminders') ?? true;
      _reminderFrequency = prefs.getInt('reminder_frequency') ?? 4;
      _quietHoursEnabled = prefs.getBool('quiet_hours_enabled') ?? false;
      _todayCount = prefs.getInt('notification_count_today') ?? 0;
      
      // Загрузка времени
      final morningMinutes = prefs.getInt('morning_time') ?? 480; // 8:00
      _morningTime = TimeOfDay(hour: morningMinutes ~/ 60, minute: morningMinutes % 60);
      
      final eveningMinutes = prefs.getInt('evening_report_time') ?? 1260; // 21:00
      _eveningTime = TimeOfDay(hour: eveningMinutes ~/ 60, minute: eveningMinutes % 60);
      
      final quietStartMinutes = prefs.getInt('quiet_hours_start') ?? 1320; // 22:00
      _quietStart = TimeOfDay(hour: quietStartMinutes ~/ 60, minute: quietStartMinutes % 60);
      
      final quietEndMinutes = prefs.getInt('quiet_hours_end') ?? 420; // 7:00
      _quietEnd = TimeOfDay(hour: quietEndMinutes ~/ 60, minute: quietEndMinutes % 60);
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Сохраняем основные настройки
    await prefs.setBool('notificationsEnabled', true); // Всегда включены
    await prefs.setBool('water_reminders', true); // Всегда включены
    await prefs.setBool('post_coffee_reminders', _postCoffeeReminders);
    await prefs.setBool('evening_reports', _eveningReports);
    await prefs.setBool('heat_warnings', _heatWarnings);
    await prefs.setBool('post_alcohol_reminders', _postAlcoholReminders);
    await prefs.setInt('reminder_frequency', _reminderFrequency);
    await prefs.setBool('quiet_hours_enabled', _quietHoursEnabled);
    
    // Сохраняем время в минутах
    await prefs.setInt('morning_time', _morningTime.hour * 60 + _morningTime.minute);
    await prefs.setInt('evening_report_time', _eveningTime.hour * 60 + _eveningTime.minute);
    await prefs.setInt('quiet_hours_start', _quietStart.hour * 60 + _quietStart.minute);
    await prefs.setInt('quiet_hours_end', _quietEnd.hour * 60 + _quietEnd.minute);
    
    // Дублируем в строковом формате для NotificationService
    await prefs.setString('evening_report_time', 
      '${_eveningTime.hour.toString().padLeft(2, '0')}:${_eveningTime.minute.toString().padLeft(2, '0')}');
    await prefs.setString('quiet_hours_start', 
      '${_quietStart.hour.toString().padLeft(2, '0')}:${_quietStart.minute.toString().padLeft(2, '0')}');
    await prefs.setString('quiet_hours_end', 
      '${_quietEnd.hour.toString().padLeft(2, '0')}:${_quietEnd.minute.toString().padLeft(2, '0')}');
    
    // Перепланируем уведомления
    await _rescheduleNotifications();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _rescheduleNotifications() async {
    // Планируем умные напоминания (включая базовые о воде)
    await notif.NotificationService().scheduleSmartReminders();
    
    // Если включен вечерний отчёт, планируем его отдельно
    if (_eveningReports) {
      await notif.NotificationService().scheduleEveningReport();
    }
  }

  Future<void> _selectTime(BuildContext context, TimeOfDay initialTime, Function(TimeOfDay) onTimeSelected) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l10n.notificationsSection),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (kDebugMode)
            IconButton(
              icon: Icon(_showDebugPanel ? Icons.bug_report : Icons.bug_report_outlined),
              onPressed: () => setState(() => _showDebugPanel = !_showDebugPanel),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Секция: Базовые напоминания
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l10n.waterReminders,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              _buildBasicReminders(theme, l10n),
              
              // Секция: Частота напоминаний
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  l10n.reminderFrequency,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              _buildFrequencySettings(theme, l10n),
              
              // Секция: Дополнительные напоминания
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Additional Reminders',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              _buildAdditionalReminders(theme, l10n),
              
              // PRO функции или их разблокировка
              if (_isPro) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    l10n.smartReminders,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                _buildProReminders(theme, l10n),
                _buildQuietHours(theme, l10n),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    l10n.proFeaturesSection,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                _buildProPreview(theme, l10n),
              ],
              
              // Кнопка сохранения
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(l10n.save),
                ),
              ),
              
              // Debug панель
              if (_showDebugPanel && kDebugMode) _buildDebugPanel(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicReminders(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Утреннее напоминание
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.wb_sunny, color: Colors.amber, size: 20),
            ),
            title: Text(l10n.startOfDay),
            subtitle: const Text('First reminder of the day'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(_morningTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
              ],
            ),
            onTap: () => _selectTime(context, _morningTime, (time) {
              setState(() => _morningTime = time);
            }),
          ),
          const Divider(height: 1),
          // Вечерний отчёт
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.nightlight_round, color: Colors.indigo, size: 20),
            ),
            title: Text(l10n.dailyReportTitle),
            subtitle: Text(l10n.dailyReportBody),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_eveningReports)
                  Text(
                    _formatTime(_eveningTime),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                Switch(
                  value: _eveningReports,
                  onChanged: (value) => setState(() => _eveningReports = value),
                ),
              ],
            ),
            onTap: _eveningReports 
              ? () => _selectTime(context, _eveningTime, (time) {
                  setState(() => _eveningTime = time);
                })
              : null,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms);
  }

  Widget _buildFrequencySettings(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.timer, color: theme.colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Water reminders per day',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _isPro 
                        ? l10n.timesPerDay(_reminderFrequency)
                        : l10n.maxTimesPerDay(_reminderFrequency),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<int>(
                  value: _reminderFrequency,
                  underline: const SizedBox(),
                  isDense: true,
                  items: (_isPro ? [2, 4, 6, 8, 10] : [2, 3, 4]).map((times) {
                    return DropdownMenuItem(
                      value: times,
                      child: Text('$times'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _reminderFrequency = value);
                    }
                  },
                ),
              ),
            ],
          ),
          if (!_isPro)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notificationLimit,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          l10n.notificationUsage(_todayCount, 4),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildAdditionalReminders(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.brown.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.coffee, color: Colors.brown, size: 20),
            ),
            title: Text(l10n.postCoffeeReminders),
            subtitle: Text(l10n.postCoffeeRemindersDesc),
            value: _postCoffeeReminders,
            onChanged: (value) => setState(() => _postCoffeeReminders = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildProReminders(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.thermostat, color: Colors.orange, size: 20),
            ),
            title: Text(l10n.heatWarnings),
            subtitle: Text(l10n.heatWarningsDesc),
            value: _heatWarnings,
            onChanged: (value) => setState(() => _heatWarnings = value),
          ),
          const Divider(height: 1),
          SwitchListTile(
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.local_bar, color: Colors.purple, size: 20),
            ),
            title: Text(l10n.postAlcoholReminders),
            subtitle: Text(l10n.postAlcoholRemindersDesc),
            value: _postAlcoholReminders,
            onChanged: (value) => setState(() => _postAlcoholReminders = value),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildQuietHours(ThemeData theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (_quietHoursEnabled ? Colors.purple : Colors.grey).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.do_not_disturb,
                  color: _quietHoursEnabled ? Colors.purple : Colors.grey,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiet Hours',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      _quietHoursEnabled 
                        ? '${_formatTime(_quietStart)} - ${_formatTime(_quietEnd)}'
                        : 'No notifications during sleep',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _quietHoursEnabled,
                onChanged: (value) => setState(() => _quietHoursEnabled = value),
              ),
            ],
          ),
          if (_quietHoursEnabled) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, _quietStart, (time) {
                      setState(() => _quietStart = time);
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('From', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text(_formatTime(_quietStart), style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectTime(context, _quietEnd, (time) {
                      setState(() => _quietEnd = time);
                    }),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('To', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          Text(_formatTime(_quietEnd), style: const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildProPreview(ThemeData theme, AppLocalizations l10n) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.thermostat, color: Colors.orange, size: 20),
                ),
                title: Text(l10n.heatWarnings),
                subtitle: Text(l10n.heatWarningsDesc),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_bar, color: Colors.purple, size: 20),
                ),
                title: Text(l10n.postAlcoholReminders),
                subtitle: Text(l10n.postAlcoholRemindersDesc),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.all_inclusive, color: Colors.green, size: 20),
                ),
                title: Text(l10n.unlimitedReminders),
                subtitle: Text(l10n.noNotificationLimit),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PRO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/paywall'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  l10n.unlockPro,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDebugPanel(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.yellow.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Debug Panel (${_isPro ? "PRO" : "FREE"})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const Divider(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await notif.NotificationService().sendTestNotification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Test sent')),
                    );
                  }
                },
                icon: const Icon(Icons.send, size: 16),
                label: const Text('Test', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await notif.NotificationService().scheduleTestIn1Minute();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Scheduled in 1 min')),
                    );
                  }
                },
                icon: const Icon(Icons.schedule, size: 16),
                label: const Text('1 min', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await notif.NotificationService().printNotificationStatus();
                },
                icon: const Icon(Icons.info, size: 16),
                label: const Text('Status', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_pro', !_isPro);
                  _loadSettings();
                },
                icon: const Icon(Icons.star, size: 16),
                label: Text(_isPro ? 'FREE' : 'PRO', style: const TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}