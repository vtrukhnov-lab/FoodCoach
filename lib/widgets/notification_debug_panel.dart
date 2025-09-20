// lib/widgets/notification_debug_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../services/notification_service.dart' as notif;

/// Debug panel for testing notification system
/// IMPORTANT: Remove or disable in production builds!
class NotificationDebugPanel extends StatefulWidget {
  const NotificationDebugPanel({super.key});

  @override
  State<NotificationDebugPanel> createState() => _NotificationDebugPanelState();
}

class _NotificationDebugPanelState extends State<NotificationDebugPanel> {
  // State variables
  Map<String, dynamic> _notificationStats = {};
  bool _testNotificationScheduled = false;
  int _pendingCount = 0;
  List<PendingNotificationRequest> _pendingNotifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotificationStats();
    _loadPendingNotifications();
  }

  Future<void> _loadNotificationStats() async {
    final prefs = await SharedPreferences.getInstance();
    final isPro = prefs.getBool('is_pro') ?? false;
    final todayCount = prefs.getInt('notification_count_today') ?? 0;
    
    setState(() {
      _notificationStats = {
        'is_pro': isPro,
        'today_count': todayCount,
        'daily_limit': isPro ? -1 : 4,
        'remaining_today': isPro ? -1 : (4 - todayCount),
      };
    });
  }

  Future<void> _loadPendingNotifications() async {
    try {
      final pending = await notif.NotificationService().getPendingNotifications();
      setState(() {
        _pendingNotifications = pending;
        _pendingCount = pending.length;
      });
    } catch (e) {
      print('Error loading pending notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('🧪 DEBUG TESTING'),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple.shade300, width: 2),
          ),
          child: Column(
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),
              
              // Warning
              _buildWarning(),
              const SizedBox(height: 16),
              
              // Debug Info
              _buildDebugInfo(),
              const SizedBox(height: 16),
              
              // Basic Tests
              _buildBasicTests(),
              
              // Alcohol Testing Section
              const SizedBox(height: 16),
              _buildAlcoholTests(),
              
              // Smart & Heat Testing
              const SizedBox(height: 16),
              _buildSmartContextTests(),
              
              // System Status
              const SizedBox(height: 16),
              _buildSystemStatus(),
              
              // Today's Notifications
              const SizedBox(height: 16),
              _buildTodayNotifications(),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.bug_report, color: Colors.purple.shade700, size: 28),
        const SizedBox(width: 12),
        Text(
          'NOTIFICATION TESTING PANEL',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.purple.shade700,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'DEBUG',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.red.shade600, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Remove this entire panel before production release!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugInfo() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(yearStart).inDays + 1;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📊 DEBUG INFO:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text('Current Date: ${now.day}/${now.month}/${now.year}'),
          Text('Current Time: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'),
          Text('Day of Year: $currentDayOfYear'),
          Text('Total Pending: $_pendingCount notifications'),
        ],
      ),
    );
  }

  Widget _buildTodayNotifications() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(yearStart).inDays + 1;
    
    // Фильтруем уведомления на сегодня
    final todayNotifications = _pendingNotifications.where((notification) {
      final decoded = _decodeNotificationId(notification.id);
      return decoded['dayFromId'] == currentDayOfYear;
    }).toList();
    
    // Сортируем по времени
    todayNotifications.sort((a, b) {
      final decodedA = _decodeNotificationId(a.id);
      final decodedB = _decodeNotificationId(b.id);
      final timeA = decodedA['hour']! * 60 + decodedA['minute']!;
      final timeB = decodedB['hour']! * 60 + decodedB['minute']!;
      return timeA.compareTo(timeB);
    });
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📅 TODAY\'S NOTIFICATIONS:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${todayNotifications.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          if (todayNotifications.isEmpty) 
            Text(
              'No notifications scheduled for today',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            )
          else
            ...todayNotifications.map((notification) {
              final decoded = _decodeNotificationId(notification.id);
              final time = '${decoded['hour']!.toString().padLeft(2, '0')}:${decoded['minute']!.toString().padLeft(2, '0')}';
              final isPast = decoded['hour']! < now.hour || 
                            (decoded['hour']! == now.hour && decoded['minute']! < now.minute);
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      isPast ? Icons.check_circle : Icons.schedule,
                      size: 16,
                      color: isPast ? Colors.grey : Colors.green.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isPast ? Colors.grey : Colors.black,
                        decoration: isPast ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        notification.title ?? 'No title',
                        style: TextStyle(
                          fontSize: 12,
                          color: isPast ? Colors.grey : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildBasicTests() {
    return Column(
      children: [
        _buildDebugButton(
          'Send Test Now',
          'Sends immediately with timestamp',
          Icons.notifications_active,
          Colors.green,
          _sendTestNotification,
        ),
        
        const SizedBox(height: 8),
        _buildDebugButton(
          'Schedule Test (1 min)',
          _testNotificationScheduled 
            ? 'Scheduled ⏰ Will arrive at ${_getTestNotificationTime()}' 
            : 'Will arrive in 1 minute',
          Icons.schedule,
          Colors.blue,
          _testNotificationScheduled ? null : _scheduleTestNotification,
        ),
        
        const SizedBox(height: 8),
        _buildDebugButton(
          'Schedule Post-Coffee',
          'Test coffee reminder (45 min delay)',
          Icons.coffee,
          Colors.brown,
          _schedulePostCoffeeTest,
        ),
        
        const SizedBox(height: 8),
        _buildDebugButton(
          'Notification Status',
          'View all pending with detailed info',
          Icons.analytics,
          Colors.orange,
          _showEnhancedNotificationStatus,
        ),
        
        const SizedBox(height: 8),
        _buildDebugButton(
          'Cancel All Notifications',
          'Clear all scheduled ($_pendingCount pending)',
          Icons.delete_forever,
          Colors.red,
          () => _showCancelAllDialog(),
        ),
      ],
    );
  }

  Widget _buildAlcoholTests() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍺 Alcohol Testing:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _testAlcoholCounter(2),
                  icon: const Icon(Icons.local_bar, size: 16),
                  label: const Text('Counter (2)', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _testAlcoholRecovery(4),
                  icon: const Icon(Icons.healing, size: 16),
                  label: const Text('Recovery (4)', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _testMorningCheckIn,
              icon: const Icon(Icons.wb_sunny, size: 16),
              label: const Text('Morning Check-in'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartContextTests() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🧠 Smart & Context Tests:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _testSmartReminders,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Smart', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _testHeatWarning,
                  icon: const Icon(Icons.wb_sunny, size: 16),
                  label: const Text('Heat', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _testWorkoutReminder,
                  icon: const Icon(Icons.fitness_center, size: 16),
                  label: const Text('Workout', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '⚙️ System Status:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatusCard(
                  'PRO Status',
                  _notificationStats['is_pro'] == true ? 'PRO' : 'FREE',
                  _notificationStats['is_pro'] == true ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusCard(
                  'Today Sent',
                  '${_notificationStats['today_count'] ?? 0}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatusCard(
                  'Pending',
                  '$_pendingCount',
                  Colors.purple,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleProStatus,
                  icon: Icon(
                    _notificationStats['is_pro'] == true ? Icons.star : Icons.star_outline,
                    size: 16,
                  ),
                  label: const Text('Toggle PRO', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _notificationStats['is_pro'] == true ? Colors.green : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetNotificationCount,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Count', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugButton(
    String title, 
    String subtitle, 
    IconData icon, 
    Color color, 
    VoidCallback? onTap
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: ListTile(
        leading: Icon(icon, color: color, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: onTap != null 
            ? Icon(Icons.play_arrow, color: color)
            : Icon(Icons.check_circle, color: Colors.green        ),
        onTap: onTap != null ? () {
          HapticFeedback.lightImpact();
          onTap();
        } : null,
      ),
    );
  }

  // Helper method to decode notification ID
  Map<String, int> _decodeNotificationId(int id) {
    final typeIdx = id ~/ 1000000;
    final fromYearStart = id % 1000000;
    final dayFromId = fromYearStart ~/ 1440;
    final minutesInDay = fromYearStart % 1440;
    final hour = minutesInDay ~/ 60;
    final minute = minutesInDay % 60;
    
    return {
      'typeIdx': typeIdx,
      'dayFromId': dayFromId,
      'hour': hour,
      'minute': minute,
    };
  }

  // Test methods
  Future<void> _sendTestNotification() async {
    try {
      await notif.NotificationService().sendTestNotification();
      
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt('notification_count_today') ?? 0;
      await prefs.setInt('notification_count_today', currentCount + 1);
      await _loadNotificationStats();
      
      _showSuccessSnackBar('Test notification sent at ${DateTime.now().toString().substring(11, 19)}');
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _scheduleTestNotification() async {
    try {
      await notif.NotificationService().scheduleTestIn1Minute();
      setState(() {
        _testNotificationScheduled = true;
      });
      
      await _loadPendingNotifications();
      
      final arrivalTime = DateTime.now().add(const Duration(minutes: 1));
      final timeString = '${arrivalTime.hour.toString().padLeft(2, '0')}:${arrivalTime.minute.toString().padLeft(2, '0')}';
      
      _showSuccessSnackBar('Test notification scheduled for $timeString');
      
      Future.delayed(const Duration(minutes: 2), () {
        if (mounted) {
          setState(() {
            _testNotificationScheduled = false;
          });
        }
      });
    } catch (e) {
      _showErrorSnackBar('Scheduling error: $e');
    }
  }

  Future<void> _schedulePostCoffeeTest() async {
    try {
      await notif.NotificationService().schedulePostCoffeeReminder();
      await _loadPendingNotifications();
      _showSuccessSnackBar('Post-coffee reminder scheduled (45 min)');
    } catch (e) {
      _showErrorSnackBar('Post-coffee test error: $e');
    }
  }

  Future<void> _testAlcoholCounter(int drinks) async {
    try {
      await notif.NotificationService().scheduleAlcoholCounterReminder(drinks);
      await _loadPendingNotifications();
      _showSuccessSnackBar('Alcohol counter scheduled ($drinks drinks, 30 min)');
    } catch (e) {
      _showErrorSnackBar('Alcohol counter error: $e');
    }
  }

  Future<void> _testAlcoholRecovery(int drinks) async {
    try {
      await notif.NotificationService().scheduleAlcoholRecoveryPlan(drinks);
      await _loadPendingNotifications();
      _showSuccessSnackBar('Recovery plan scheduled ($drinks drinks, ${drinks <= 2 ? 6 : 12}h plan)');
    } catch (e) {
      _showErrorSnackBar('Recovery plan error: $e');
    }
  }

  Future<void> _testMorningCheckIn() async {
    try {
      await notif.NotificationService().scheduleMorningCheckIn();
      await _loadPendingNotifications();
      _showSuccessSnackBar('Morning check-in scheduled for tomorrow 7:05');
    } catch (e) {
      _showErrorSnackBar('Morning check-in error: $e');
    }
  }

  Future<void> _testSmartReminders() async {
    try {
      await notif.NotificationService().scheduleSmartReminders();
      await _loadPendingNotifications();
      _showSuccessSnackBar('Smart reminders scheduled (PRO feature)');
    } catch (e) {
      _showErrorSnackBar('Smart reminders error: $e');
    }
  }

  Future<void> _testHeatWarning() async {
    try {
      await notif.NotificationService().sendHeatWarning(35.5);
      await _loadNotificationStats();
      _showSuccessSnackBar('Heat warning sent (HI: 35.5°C)');
    } catch (e) {
      _showErrorSnackBar('Heat warning error: $e');
    }
  }

  Future<void> _testWorkoutReminder() async {
    try {
      final workoutEnd = DateTime.now().add(const Duration(minutes: 5));
      await notif.NotificationService().sendWorkoutReminder(workoutEndTime: workoutEnd);
      await _loadPendingNotifications();
      _showSuccessSnackBar('Post-workout reminder scheduled (+30 min)');
    } catch (e) {
      _showErrorSnackBar('Workout reminder error: $e');
    }
  }

  Future<void> _showEnhancedNotificationStatus() async {
    try {
      await notif.NotificationService().printNotificationStatus();
      final pending = await notif.NotificationService().getPendingNotifications();
      
      setState(() {
        _pendingCount = pending.length;
      });
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NotificationStatusScreen(
              notificationStats: _notificationStats,
              pendingNotifications: pending,
            ),
            fullscreenDialog: true,
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Status error: $e');
    }
  }

  Future<void> _resetNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notification_count_today', 0);
    await _loadNotificationStats();
    
    _showSuccessSnackBar('Notification count reset to 0');
  }

  Future<void> _toggleProStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final currentStatus = _notificationStats['is_pro'] == true;
    final newStatus = !currentStatus;
    
    await prefs.setBool('is_pro', newStatus);
    await _loadNotificationStats();
    
    _showSuccessSnackBar(
      newStatus 
        ? 'PRO status enabled - Unlimited notifications!' 
        : 'FREE status - Limited to 4/day (Current: ${_notificationStats['today_count'] ?? 0})'
    );
  }

  void _showCancelAllDialog() async {
    final pending = await notif.NotificationService().getPendingNotifications();
    
    if (pending.isEmpty) {
      _showInfoSnackBar('No notifications to cancel');
      return;
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Notifications?'),
        content: Text('This will cancel all ${pending.length} scheduled notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await notif.NotificationService().cancelAllNotifications();
              await _loadPendingNotifications();
              
              _showSuccessSnackBar('Cancelled ${pending.length} notifications');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _getTestNotificationTime() {
    if (!_testNotificationScheduled) return '';
    final time = DateTime.now().add(const Duration(minutes: 1));
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ $message'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ $message'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _showInfoSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

// Separate screen for detailed notification status
class NotificationStatusScreen extends StatefulWidget {
  final Map<String, dynamic> notificationStats;
  final List<PendingNotificationRequest> pendingNotifications;

  const NotificationStatusScreen({
    super.key,
    required this.notificationStats,
    required this.pendingNotifications,
  });

  @override
  State<NotificationStatusScreen> createState() => _NotificationStatusScreenState();
}

class _NotificationStatusScreenState extends State<NotificationStatusScreen> {
  String _filterType = 'all';
  
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(yearStart).inDays + 1;
    
    final filteredNotifications = _getFilteredNotifications();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notification Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _copyNotificationsList,
            icon: const Icon(Icons.copy),
            tooltip: 'Copy list to clipboard',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredNotifications.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(filteredNotifications.length, currentDayOfYear);
          }
          
          final notification = filteredNotifications[index - 1];
          return _buildNotificationCard(notification, currentDayOfYear);
        },
      ),
    );
  }
  
  Widget _buildHeader(int count, int currentDayOfYear) {
    final now = DateTime.now();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Debug info
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEBUG INFO:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                Text('Current Date: ${now.day}/${now.month}/${now.year}', style: const TextStyle(fontSize: 11)),
                Text('Day of Year: $currentDayOfYear', style: const TextStyle(fontSize: 11)),
                Text('Time Now: ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11)),
              ],
            ),
          ),
          
          Row(
            children: [
              Text(
                'Total Pending: $count',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: _filterType == 'all',
                onSelected: (_) => setState(() => _filterType = 'all'),
              ),
              FilterChip(
                label: const Text('Today'),
                selected: _filterType == 'today',
                onSelected: (_) => setState(() => _filterType = 'today'),
              ),
              FilterChip(
                label: const Text('Future'),
                selected: _filterType == 'future',
                onSelected: (_) => setState(() => _filterType = 'future'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationCard(PendingNotificationRequest notification, int currentDayOfYear) {
    // Декодируем информацию из ID
    final decoded = _decodeNotificationId(notification.id);
    final notificationDay = decoded['dayFromId']!;
    final isToday = notificationDay == currentDayOfYear;
    final isTomorrow = notificationDay == currentDayOfYear + 1;
    
    // Создаем DateTime для уведомления
    final yearStart = DateTime(DateTime.now().year, 1, 1);
    final scheduledDate = yearStart.add(Duration(days: notificationDay - 1));
    final scheduledDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      decoded['hour']!,
      decoded['minute']!,
    );
    
    final now = DateTime.now();
    final isPast = scheduledDateTime.isBefore(now);
    
    // Определяем метку дня
    String dayLabel;
    if (isToday) {
      dayLabel = 'TODAY';
    } else if (isTomorrow) {
      dayLabel = 'TOMORROW';
    } else {
      dayLabel = '${scheduledDate.day}/${scheduledDate.month}';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday 
            ? Colors.green.shade300
            : isPast 
              ? Colors.red.shade200 
              : Colors.grey.shade200,
          width: isToday ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isToday 
                    ? Colors.green.withValues(alpha: 0.1)
                    : _getTypeColor(notification).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isToday 
                      ? Colors.green.shade700
                      : _getTypeColor(notification),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Day $notificationDay | ID: ${notification.id}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              if (isPast && !isToday) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'EXPIRED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: () => _cancelNotification(notification.id),
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          if (notification.title != null) ...[
            const SizedBox(height: 8),
            Text(
              notification.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (notification.body != null) ...[
            const SizedBox(height: 4),
            Text(
              notification.body!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          
          // Добавляем информацию о времени
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  isPast ? Icons.history : Icons.schedule,
                  size: 16,
                  color: isPast ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${decoded['hour']!.toString().padLeft(2, '0')}:${decoded['minute']!.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? Colors.red.shade700 : Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getTimeFromNow(scheduledDateTime),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Вспомогательные методы
  Map<String, int> _decodeNotificationId(int id) {
    final typeIdx = id ~/ 1000000;
    final fromYearStart = id % 1000000;
    final dayFromId = fromYearStart ~/ 1440;
    final minutesInDay = fromYearStart % 1440;
    final hour = minutesInDay ~/ 60;
    final minute = minutesInDay % 60;
    
    return {
      'typeIdx': typeIdx,
      'dayFromId': dayFromId,
      'hour': hour,
      'minute': minute,
    };
  }
  
  String _getTimeFromNow(DateTime scheduleTime) {
    final now = DateTime.now();
    final difference = scheduleTime.difference(now);
    
    if (difference.isNegative) {
      final pastDifference = now.difference(scheduleTime);
      if (pastDifference.inMinutes < 60) {
        return '${pastDifference.inMinutes}m ago';
      } else if (pastDifference.inHours < 24) {
        return '${pastDifference.inHours}h ago';
      } else {
        return '${pastDifference.inDays}d ago';
      }
    } else {
      if (difference.inMinutes < 60) {
        return 'in ${difference.inMinutes}m';
      } else if (difference.inHours < 24) {
        return 'in ${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        return 'in ${difference.inDays}d ${difference.inHours % 24}h';
      }
    }
  }
  
  List<PendingNotificationRequest> _getFilteredNotifications() {
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(yearStart).inDays + 1;
    
    List<PendingNotificationRequest> filtered;
    
    if (_filterType == 'all') {
      filtered = widget.pendingNotifications;
    } else {
      filtered = widget.pendingNotifications.where((n) {
        final decoded = _decodeNotificationId(n.id);
        final notificationDay = decoded['dayFromId']!;
        
        switch (_filterType) {
          case 'today':
            return notificationDay == currentDayOfYear;
          case 'future':
            return notificationDay > currentDayOfYear;
          default:
            return true;
        }
      }).toList();
    }
    
    // Сортируем: сначала сегодняшние, потом завтрашние, потом остальные
    // Внутри каждого дня - по времени
    filtered.sort((a, b) {
      final decodedA = _decodeNotificationId(a.id);
      final decodedB = _decodeNotificationId(b.id);
      
      final dayA = decodedA['dayFromId']!;
      final dayB = decodedB['dayFromId']!;
      
      // Сначала сравниваем дни
      if (dayA != dayB) {
        // Сегодняшние идут первыми
        if (dayA == currentDayOfYear) return -1;
        if (dayB == currentDayOfYear) return 1;
        
        // Потом по возрастанию дней
        return dayA.compareTo(dayB);
      }
      
      // Если день одинаковый, сортируем по времени
      final timeA = decodedA['hour']! * 60 + decodedA['minute']!;
      final timeB = decodedB['hour']! * 60 + decodedB['minute']!;
      return timeA.compareTo(timeB);
    });
    
    return filtered;
  }
  
  Color _getTypeColor(PendingNotificationRequest notification) {
    final title = notification.title?.toLowerCase() ?? '';
    final body = notification.body?.toLowerCase() ?? '';
    
    if (title.contains('coffee') || body.contains('coffee')) {
      return Colors.brown;
    } else if (title.contains('alcohol') || body.contains('recovery')) {
      return Colors.purple;
    } else if (title.contains('test')) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
  
  Future<void> _cancelNotification(int id) async {
    await notif.NotificationService().cancelNotification(id);
    
    if (mounted) {
      setState(() {
        widget.pendingNotifications.removeWhere((n) => n.id == id);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification $id cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
  
  void _copyNotificationsList() {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final yearStart = DateTime(now.year, 1, 1);
    final currentDayOfYear = now.difference(yearStart).inDays + 1;
    
    buffer.writeln('=== NOTIFICATION DEBUG REPORT ===');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Current Day of Year: $currentDayOfYear');
    buffer.writeln('Total: ${widget.pendingNotifications.length}');
    buffer.writeln('PRO Status: ${widget.notificationStats['is_pro'] == true ? 'YES' : 'NO'}');
    buffer.writeln('Sent Today: ${widget.notificationStats['today_count'] ?? 0}');
    buffer.writeln('');
    buffer.writeln('=== SCHEDULED NOTIFICATIONS ===');
    
    for (int i = 0; i < widget.pendingNotifications.length; i++) {
      final notification = widget.pendingNotifications[i];
      final decoded = _decodeNotificationId(notification.id);
      final notificationDay = decoded['dayFromId']!;
      final isToday = notificationDay == currentDayOfYear;
      
      buffer.writeln('');
      buffer.writeln('[$i] ID: ${notification.id}');
      buffer.writeln('  Day: $notificationDay ${isToday ? "(TODAY)" : ""}');
      buffer.writeln('  Type Index: ${decoded['typeIdx']}');
      buffer.writeln('  Title: ${notification.title ?? 'N/A'}');
      buffer.writeln('  Body: ${notification.body ?? 'N/A'}');
      buffer.writeln('  Time: ${decoded['hour']}:${decoded['minute'].toString().padLeft(2, '0')}');
      
      if (notification.payload != null && notification.payload!.isNotEmpty) {
        buffer.writeln('  Payload: ${notification.payload}');
      }
    }
    
    buffer.writeln('');
    buffer.writeln('=== END REPORT ===');
    
    // Копирование в буфер обмена
    Clipboard.setData(ClipboardData(text: buffer.toString()));
    
    // Показываем подтверждение
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Copied ${widget.pendingNotifications.length} notifications to clipboard'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}