import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../providers/hydration_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart' as notif;
import '../services/subscription_service.dart';
import '../services/units_service.dart';
import '../services/consent_service.dart';
import '../screens/paywall_screen.dart';
import '../widgets/notification_debug_panel.dart';
import '../services/url_launcher_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _postCoffeeReminders = true;
  bool _heatWarnings = true;
  bool _postAlcoholReminders = false;
  String _morningTime = '07:00';
  String _eveningTime = '22:00';
  int _reminderFrequency = 4;
  
  Map<String, dynamic> _notificationStats = {};
  final bool _testNotificationScheduled = false;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadNotificationStats();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _postCoffeeReminders = prefs.getBool('postCoffeeReminders') ?? true;
      _heatWarnings = prefs.getBool('heatWarnings') ?? true;
      _postAlcoholReminders = prefs.getBool('postAlcoholReminder') ?? false;
      _morningTime = prefs.getString('morningTime') ?? '07:00';
      _eveningTime = prefs.getString('eveningTime') ?? '22:00';
      _reminderFrequency = prefs.getInt('reminderFrequency') ?? 4;
    });
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

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('postCoffeeReminders', _postCoffeeReminders);
    await prefs.setBool('heatWarnings', _heatWarnings);
    await prefs.setBool('postAlcoholReminder', _postAlcoholReminders);
    await prefs.setString('morningTime', _morningTime);
    await prefs.setString('eveningTime', _eveningTime);
    await prefs.setInt('reminderFrequency', _reminderFrequency);
    
    await prefs.setBool('remindersEnabled', _notificationsEnabled);
    await prefs.setString('quiet_hours_start', _eveningTime);
    await prefs.setString('quiet_hours_end', _morningTime);
    await prefs.setBool('quiet_hours_enabled', _notificationsEnabled);
    
    if (_notificationsEnabled) {
      await notif.NotificationService().scheduleSmartReminders();
    } else {
      await notif.NotificationService().cancelAllNotifications();
    }
    
    await _loadNotificationStats();
  }

  void _showPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PaywallScreen(
          showCloseButton: true,
          source: 'settings',
        ),
        fullscreenDialog: true,
      ),
    ).then((_) async {
      // Перезагружаем настройки и статистику уведомлений после возврата
      await _loadSettings();
      await _loadNotificationStats();
      
      // Принудительно обновляем UI чтобы отразить новый статус подписки
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Consumer3<HydrationProvider, SubscriptionProvider, UnitsService>(
          builder: (context, hydrationProvider, subscriptionProvider, unitsService, child) {
            final isPro = subscriptionProvider.isPro;
            final displayWeight = unitsService.formatWeight(hydrationProvider.weight);
            
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Text(
                      l10n.settingsTitle,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 350.ms),
                  ),
                
                // DEBUG PANELS
                if (kDebugMode) const NotificationDebugPanel(),
                if (kDebugMode) _buildUsercentricsDebugPanel(),
                
                  // Profile Section
                  _buildSectionTitle(l10n.profileSection),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildProfileTile(
                          l10n.weight,
                          displayWeight,
                          Icons.monitor_weight_outlined,
                          () => _showWeightDialog(hydrationProvider, unitsService, l10n),
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          l10n.dietMode,
                          _getDietModeText(hydrationProvider.dietMode, l10n),
                          Icons.restaurant_menu,
                          () => _showDietDialog(hydrationProvider, l10n),
                        ),
                        _buildDivider(),
                        _buildProfileTile(
                          l10n.activityLevel,
                          _getActivityText(hydrationProvider.activityLevel, l10n),
                          Icons.fitness_center,
                          () => _showActivityDialog(hydrationProvider, l10n),
                        ),
                        _buildDivider(),
                        ListTile(
                          leading: const Icon(Icons.straighten, color: Colors.blue),
                          title: Text(l10n.unitsSection),
                          subtitle: Text(
                            unitsService.isMetric ? l10n.metricSystem : l10n.imperialSystem,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              unitsService.isMetric ? l10n.metricUnits : l10n.imperialUnits,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                  
                  // Notifications Section
                  _buildSectionTitle(l10n.notificationsSection),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        if (!isPro && _notificationStats.isNotEmpty) ...[
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.notificationLimit,
                                        style: TextStyle(
                                          color: Colors.blue.shade900,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n.notificationUsage(
                                          _notificationStats['today_count'] ?? 0,
                                          4,
                                        ),
                                        style: TextStyle(
                                          color: Colors.blue.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: _showPaywall,
                                  child: const Text('PRO', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                          _buildDivider(),
                        ],
                        
                        _buildSwitchTile(
                          l10n.waterReminders,
                          l10n.waterRemindersDesc,
                          _notificationsEnabled,
                          (value) {
                            setState(() {
                              _notificationsEnabled = value;
                            });
                            _saveSettings();
                          },
                          isPro: false,
                        ),
                        
                        if (_notificationsEnabled) ...[
                          _buildDivider(),
                          _buildListTile(
                            l10n.reminderFrequency,
                            isPro ? l10n.unlimitedReminders : l10n.maxTimesPerDay(_reminderFrequency),
                            Icons.access_time,
                            () => isPro ? _showFrequencyDialog(l10n) : _showPaywall(),
                            isPro: !isPro,
                          ),
                          _buildDivider(),
                          _buildListTile(
                            l10n.startOfDay,
                            _morningTime,
                            Icons.wb_sunny_outlined,
                            () => _showTimePicker(true),
                            isPro: false,
                          ),
                          _buildDivider(),
                          _buildListTile(
                            l10n.endOfDay,
                            _eveningTime,
                            Icons.nightlight_outlined,
                            () => _showTimePicker(false),
                            isPro: false,
                          ),
                        ],
                        
                        _buildDivider(),
                        _buildSwitchTile(
                          l10n.postCoffeeReminders,
                          l10n.postCoffeeRemindersDesc,
                          _postCoffeeReminders && isPro,
                          isPro ? (value) {
                            setState(() {
                              _postCoffeeReminders = value;
                            });
                            _saveSettings();
                          } : (value) => _showPaywall(),
                          isPro: true,
                        ),
                        
                        _buildDivider(),
                        _buildSwitchTile(
                          l10n.heatWarnings,
                          l10n.heatWarningsDesc,
                          _heatWarnings && isPro,
                          isPro ? (value) {
                            setState(() {
                              _heatWarnings = value;
                            });
                            _saveSettings();
                          } : (value) => _showPaywall(),
                          isPro: true,
                        ),
                        
                        _buildDivider(),
                        _buildSwitchTile(
                          l10n.postAlcoholReminders,
                          l10n.postAlcoholRemindersDesc,
                          _postAlcoholReminders && isPro,
                          isPro ? (value) {
                            setState(() {
                              _postAlcoholReminders = value;
                            });
                            _saveSettings();
                          } : (value) => _showPaywall(),
                          isPro: true,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  
                  // PRO Features Section
                  if (!isPro) ...[
                    _buildSectionTitle(l10n.proFeaturesSection),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.1),
                            const Color(0xFFFFA500).withValues(alpha: 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                        ),
                      ),
                      child: InkWell(
                        onTap: _showPaywall,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.star,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          l10n.unlockPro,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          l10n.unlockProDesc,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                children: [
                                  _ProFeatureItem(icon: Icons.all_inclusive, text: l10n.noNotificationLimit),
                                  _ProFeatureItem(icon: Icons.coffee, text: l10n.postCoffeeReminders),
                                  _ProFeatureItem(icon: Icons.wb_sunny, text: l10n.heatWarnings),
                                  _ProFeatureItem(icon: Icons.local_bar, text: l10n.postAlcoholReminders),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 150.ms),
                  ],
                  
                  // About Section
                  _buildSectionTitle(l10n.aboutSection),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        _buildListTile(
                          l10n.version,
                          '2.0.0',
                          Icons.info_outline,
                          null,
                        ),
                        _buildDivider(),
                        _buildListTile(
                          l10n.rateApp,
                          '',
                          Icons.star_outline,
                          () async {
                            final success = await UrlLauncherService.openAppStore();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Ссылка на магазин скопирована' : 'Ошибка открытия магазина')),
                              );
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          l10n.share,
                          '',
                          Icons.share_outlined,
                          () async {
                            final success = await UrlLauncherService.shareApp();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(success ? 'Ссылка для шаринга скопирована' : 'Ошибка при шаринге')),
                              );
                            }
                          },
                        ),
                        _buildDivider(),
                        _buildListTile(
                          'Сайт компании',
                          'playcus.com',
                          Icons.language_outlined,
                          () async {
                            final success = await UrlLauncherService.openWebsite();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ссылка скопирована в буфер обмена')),
                              );
                            }
                          },
                        ),
                        _buildListTile(
                          'Поддержка',
                          'support@playcus.com',
                          Icons.support_agent_outlined,
                          () async {
                            final success = await UrlLauncherService.openSupportEmail();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Email скопирован в буфер обмена')),
                              );
                            }
                          },
                        ),
                        _buildListTile(
                          l10n.privacyPolicy,
                          'playcus.com/privacy-policy',
                          Icons.privacy_tip_outlined,
                          () async {
                            final success = await UrlLauncherService.openPrivacyPolicy();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ссылка скопирована в буфер обмена')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                  
                  // Reset Button
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: OutlinedButton(
                      onPressed: () => _showResetDialog(l10n),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.resetAllData),
                    ),
                  ),
                  
                  // Company Information
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playcus Ltd',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Thiseos 9, Flat/Office C1\nAglantzia, P.C. 2121\nNicosia, Cyprus',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email_outlined, size: 14, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              'support@playcus.com',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper Methods
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

  Widget _buildProfileTile(String title, String value, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Text(value),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildListTile(String title, String subtitle, IconData icon, VoidCallback? onTap, {bool isPro = false}) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        final hasAccess = !isPro || subscriptionProvider.isPro;
        
        return ListTile(
          leading: Icon(icon, color: hasAccess ? Colors.blue : Colors.grey),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: hasAccess ? null : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isPro && !subscriptionProvider.isPro) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
          subtitle: subtitle.isNotEmpty ? Text(
            subtitle,
            style: TextStyle(
              color: hasAccess ? null : Colors.grey.shade400,
            ),
          ) : null,
          trailing: onTap != null ? Icon(
            Icons.chevron_right,
            color: hasAccess ? null : Colors.grey.shade300,
          ) : null,
          onTap: onTap,
        );
      },
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged, {bool isPro = false}) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, _) {
        final hasAccess = !isPro || subscriptionProvider.isPro;
        
        return SwitchListTile(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: hasAccess ? null : Colors.grey.shade600,
                  ),
                ),
              ),
              if (isPro && !subscriptionProvider.isPro) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ],
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: hasAccess ? null : Colors.grey.shade400,
            ),
          ),
          value: value,
          onChanged: hasAccess ? onChanged : (value) => onChanged(false),
          activeThumbColor: Colors.blue,
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  String _getDietModeText(String mode, AppLocalizations l10n) {
    switch (mode) {
      case 'normal': return l10n.dietModeNormal;
      case 'keto': return l10n.dietModeKeto;
      case 'fasting': return l10n.dietModeFasting;
      default: return mode;
    }
  }

  String _getActivityText(String level, AppLocalizations l10n) {
    switch (level) {
      case 'low': return l10n.activityLow;
      case 'medium': return l10n.activityMedium;
      case 'high': return l10n.activityHigh;
      default: return level;
    }
  }

  // Dialog Methods
  void _showWeightDialog(HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    double tempWeight = provider.weight;
    double displayWeight = units.toDisplayWeight(tempWeight);
    final weightUnit = units.weightUnit;
    final minWeight = units.isImperial ? 88.0 : 40.0;
    final maxWeight = units.isImperial ? 330.0 : 150.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.changeWeight),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${displayWeight.round()} $weightUnit',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Slider(
                value: displayWeight,
                min: minWeight,
                max: maxWeight,
                divisions: (maxWeight - minWeight).round(),
                onChanged: (value) {
                  setDialogState(() {
                    displayWeight = value;
                    tempWeight = units.toKilograms(value);
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${minWeight.round()} $weightUnit', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Text('${maxWeight.round()} $weightUnit', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                provider.updateProfile(
                  weight: tempWeight,
                  dietMode: provider.dietMode,
                  activityLevel: provider.activityLevel,
                );
                Navigator.pop(context);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showDietDialog(HydrationProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dietMode),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.dietModeNormal),
              value: 'normal',
              groupValue: provider.dietMode,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: value!,
                  activityLevel: provider.activityLevel,
                );
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.dietModeKeto),
              value: 'keto',
              groupValue: provider.dietMode,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: value!,
                  activityLevel: provider.activityLevel,
                );
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.dietModeFasting),
              value: 'fasting',
              groupValue: provider.dietMode,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: value!,
                  activityLevel: provider.activityLevel,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDialog(HydrationProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.activityLevel),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(l10n.activityLow),
              subtitle: Text(l10n.activityLowDesc),
              value: 'low',
              groupValue: provider.activityLevel,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: provider.dietMode,
                  activityLevel: value!,
                );
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.activityMedium),
              subtitle: Text(l10n.activityMediumDesc),
              value: 'medium',
              groupValue: provider.activityLevel,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: provider.dietMode,
                  activityLevel: value!,
                );
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: Text(l10n.activityHigh),
              subtitle: Text(l10n.activityHighDesc),
              value: 'high',
              groupValue: provider.activityLevel,
              onChanged: (value) {
                provider.updateProfile(
                  weight: provider.weight,
                  dietMode: provider.dietMode,
                  activityLevel: value!,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFrequencyDialog(AppLocalizations l10n) {
    final subscriptionProvider = Provider.of<SubscriptionProvider>(context, listen: false);
    final isPro = subscriptionProvider.isPro;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reminderFrequency),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: (isPro ? [2, 3, 4, 6, 8, 12] : [2, 3, 4]).map((freq) => 
            RadioListTile<int>(
              title: Text(l10n.timesPerDay(freq)),
              subtitle: !isPro && freq > 4 ? const Text('PRO', style: TextStyle(color: Colors.orange)) : null,
              value: freq,
              groupValue: _reminderFrequency,
              onChanged: (freq <= 4 || isPro) ? (value) {
                setState(() {
                  _reminderFrequency = value!;
                });
                _saveSettings();
                Navigator.pop(context);
              } : null,
            ),
          ).toList(),
        ),
      ),
    );
  }

  void _showTimePicker(bool isMorning) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.parse(isMorning ? _morningTime.split(':')[0] : _eveningTime.split(':')[0]),
        minute: int.parse(isMorning ? _morningTime.split(':')[1] : _eveningTime.split(':')[1]),
      ),
    );
    
    if (picked != null) {
      final timeString = '${picked.hour.toString().padLeft(2, '0')}:'
                        '${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        if (isMorning) {
          _morningTime = timeString;
        } else {
          _eveningTime = timeString;
        }
      });
      _saveSettings();
    }
  }

  void _showResetDialog(AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.resetDataTitle),
        content: Text(l10n.resetDataMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (mounted) {
                Navigator.pop(context);
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
  }

  // Usercentrics Debug Panel
  Widget _buildUsercentricsDebugPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                '🧪 Usercentrics Debug',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final consentService = ConsentService();
                      await consentService.forceShowConsentBanner(context);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('Force Show Banner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final consentService = ConsentService();
                      await consentService.resetConsent();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Consent reset! Restart app to test.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Consent'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () async {
              try {
                final consentService = ConsentService();
                await consentService.showPrivacySettings(context);
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.settings, size: 16),
            label: const Text('Privacy Settings'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Settings ID: UxKlz-EOgB16Ne\nTemplate IDs: AppsFlyer, Firebase, AppLovin, Google Ads',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProFeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _ProFeatureItem({
    required this.icon,
    required this.text,
  });
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFD700)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// Notification Status Screen
class _NotificationStatusScreen extends StatefulWidget {
  final Map<String, dynamic> notificationStats;
  final List<PendingNotificationRequest> pendingNotifications;

  const _NotificationStatusScreen({
    required this.notificationStats,
    required this.pendingNotifications,
  });

  @override
  State<_NotificationStatusScreen> createState() => _NotificationStatusScreenState();
}

class _NotificationStatusScreenState extends State<_NotificationStatusScreen> {
  bool _showExpiredToo = false;
  String _filterType = 'all';
  String _sortBy = 'time';

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notification Status'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'refresh') {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => FutureBuilder(
                      future: notif.NotificationService().getPendingNotifications(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return _NotificationStatusScreen(
                          notificationStats: widget.notificationStats,
                          pendingNotifications: snapshot.data ?? [],
                        );
                      },
                    ),
                    fullscreenDialog: true,
                  ),
                );
              } else if (value == 'cancel_all') {
                _showCancelAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'cancel_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Cancel All', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.blue.shade600, size: 24),
                    const SizedBox(width: 12),
                    const Text(
                      'Statistics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'PRO Status',
                        value: widget.notificationStats['is_pro'] == true ? 'PRO' : 'FREE',
                        color: widget.notificationStats['is_pro'] == true ? Colors.green : Colors.orange,
                        icon: Icons.star,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Sent Today',
                        value: '${widget.notificationStats['today_count'] ?? 0}',
                        color: Colors.blue,
                        icon: Icons.send,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Scheduled',
                        value: '${filteredNotifications.length}',
                        color: Colors.purple,
                        icon: Icons.schedule,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Daily Limit',
                        value: widget.notificationStats['is_pro'] == true ? 'Unlimited' : '4',
                        color: Colors.grey,
                        icon: Icons.timer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filters & Sort',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                Wrap(
                  spacing: 8,
                  children: [
                    _FilterChip('All', 'all', _filterType),
                    _FilterChip('Water', 'water', _filterType),
                    _FilterChip('Coffee', 'coffee', _filterType),
                    _FilterChip('Alcohol', 'alcohol', _filterType),
                    _FilterChip('Heat', 'heat', _filterType),
                  ].map((chip) => FilterChip(
                    label: Text(chip.label),
                    selected: chip.value == _filterType,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _filterType = chip.value;
                        });
                      }
                    },
                  )).toList(),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Text('Sort by: ', style: TextStyle(fontWeight: FontWeight.w500)),
                    DropdownButton<String>(
                      value: _sortBy,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'time', child: Text('Time')),
                        DropdownMenuItem(value: 'type', child: Text('Type')),
                        DropdownMenuItem(value: 'id', child: Text('ID')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _sortBy = value;
                          });
                        }
                      },
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Checkbox(
                          value: _showExpiredToo,
                          onChanged: (value) {
                            setState(() {
                              _showExpiredToo = value ?? false;
                            });
                          },
                        ),
                        const Text('Show Past', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Notifications List
          Expanded(
            child: filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications scheduled',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _filterType == 'all' 
                              ? 'Try adding some water or coffee to trigger reminders'
                              : 'No notifications of this type found',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _NotificationCard(
                        notification: notification,
                        onCancel: () => _cancelNotification(notification.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<PendingNotificationRequest> _getFilteredNotifications() {
    var notifications = List<PendingNotificationRequest>.from(widget.pendingNotifications);
    
    if (!_showExpiredToo) {
      final now = DateTime.now();
      notifications = notifications.where((n) {
        try {
          final timeStr = n.payload;
          if (timeStr != null && timeStr.isNotEmpty) {
            final scheduleTime = DateTime.parse(timeStr);
            return scheduleTime.isAfter(now);
          }
        } catch (e) {
          // If parsing fails, show notification
        }
        return true;
      }).toList();
    }
    
    if (_filterType != 'all') {
      notifications = notifications.where((n) {
        final title = n.title?.toLowerCase() ?? '';
        final body = n.body?.toLowerCase() ?? '';
        
        switch (_filterType) {
          case 'water':
            return title.contains('water') || body.contains('water') || 
                   title.contains('hydrat') || body.contains('drink');
          case 'coffee':
            return title.contains('coffee') || body.contains('coffee') ||
                   title.contains('caffeine');
          case 'alcohol':
            return title.contains('alcohol') || body.contains('alcohol') ||
                   title.contains('recovery') || body.contains('hangover');
          case 'heat':
            return title.contains('heat') || body.contains('hot') ||
                   title.contains('temperature') || body.contains('weather');
          default:
            return true;
        }
      }).toList();
    }
    
    notifications.sort((a, b) {
      switch (_sortBy) {
        case 'time':
          try {
            final timeA = DateTime.parse(a.payload ?? '');
            final timeB = DateTime.parse(b.payload ?? '');
            return timeA.compareTo(timeB);
          } catch (e) {
            return a.id.compareTo(b.id);
          }
        case 'type':
          return (a.title ?? '').compareTo(b.title ?? '');
        case 'id':
        default:
          return a.id.compareTo(b.id);
      }
    });
    
    return notifications;
  }

  void _cancelNotification(int id) async {
    await notif.NotificationService().cancelNotification(id);
    
    final updatedList = await notif.NotificationService().getPendingNotifications();
    setState(() {
      widget.pendingNotifications.clear();
      widget.pendingNotifications.addAll(updatedList);
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Notification $id cancelled'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showCancelAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel All Notifications?'),
        content: Text('This will cancel all ${widget.pendingNotifications.length} scheduled notifications.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await notif.NotificationService().cancelAllNotifications();
              Navigator.pop(context);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All notifications cancelled'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel All'),
          ),
        ],
      ),
    );
  }
}

// Supporting Classes
class _NotificationCard extends StatelessWidget {
  final PendingNotificationRequest notification;
  final VoidCallback onCancel;

  const _NotificationCard({
    required this.notification,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final scheduleTime = _parseScheduleTime();
    final isPast = scheduleTime != null && scheduleTime.isBefore(DateTime.now());
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPast ? Colors.red.shade200 : Colors.grey.shade200,
          width: isPast ? 2 : 1,
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
                  color: _getTypeColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID: ${notification.id}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _getTypeColor(),
                  ),
                ),
              ),
              if (isPast) ...[
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
                onPressed: onCancel,
                icon: const Icon(Icons.cancel, color: Colors.red, size: 20),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          if (notification.title != null && notification.title!.isNotEmpty) ...[
            Text(
              notification.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
          ],
          
          if (notification.body != null && notification.body!.isNotEmpty) ...[
            Text(
              notification.body!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
          ],
          
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
                        scheduleTime != null
                            ? _formatDateTime(scheduleTime)
                            : 'Time not available',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPast ? Colors.red.shade700 : Colors.blue.shade700,
                        ),
                      ),
                      if (scheduleTime != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          _getTimeFromNow(scheduleTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  DateTime? _parseScheduleTime() {
    try {
      if (notification.payload != null && notification.payload!.isNotEmpty) {
        return DateTime.parse(notification.payload!);
      }
    } catch (e) {
      // Parsing failed
    }
    return null;
  }

  Color _getTypeColor() {
    final title = notification.title?.toLowerCase() ?? '';
    final body = notification.body?.toLowerCase() ?? '';
    
    if (title.contains('coffee') || body.contains('coffee')) {
      return Colors.brown;
    } else if (title.contains('alcohol') || body.contains('recovery')) {
      return Colors.purple;
    } else if (title.contains('heat') || body.contains('hot')) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateStr;
    if (notificationDate == today) {
      dateStr = 'Today';
    } else if (notificationDate == tomorrow) {
      dateStr = 'Tomorrow';
    } else {
      dateStr = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
    
    final timeStr = '${dateTime.hour.toString().padLeft(2, '0')}:'
                   '${dateTime.minute.toString().padLeft(2, '0')}';
    
    return '$dateStr at $timeStr';
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip {
  final String label;
  final String value;
  final String currentValue;

  _FilterChip(this.label, this.value, this.currentValue);
}