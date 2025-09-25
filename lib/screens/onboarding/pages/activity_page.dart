// lib/screens/onboarding/pages/activity_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';

class ActivityPage extends StatefulWidget {
  final String? selectedActivity;
  final Function(String) onActivityChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const ActivityPage({
    super.key,
    this.selectedActivity,
    required this.onActivityChanged,
    required this.onNext,
    this.onBack,
  });

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  String? _selectedActivity;

  List<ActivityOption> _getActivities(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      ActivityOption(
        id: 'sedentary',
        title: l10n.onboardingSedentary,
        description: l10n.onboardingSedentaryDesc,
        examples: l10n.onboardingSedentaryExample,
        icon: Icons.chair,
        color: const Color(0xFF95A5A6),
        multiplier: 1.2,
      ),
      ActivityOption(
        id: 'moderate',
        title: l10n.onboardingModerate,
        description: l10n.onboardingModerateDesc,
        examples: l10n.onboardingModerateExample,
        icon: Icons.directions_walk,
        color: const Color(0xFF3498DB),
        multiplier: 1.375,
      ),
      ActivityOption(
        id: 'active',
        title: l10n.onboardingActive,
        description: l10n.onboardingActiveDesc,
        examples: l10n.onboardingActiveExample,
        icon: Icons.fitness_center,
        color: const Color(0xFFE74C3C),
        multiplier: 1.55,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedActivity = widget.selectedActivity;
  }

  void _selectActivity(String activityId) {
    setState(() {
      _selectedActivity = activityId;
    });
    widget.onActivityChanged(activityId);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final activities = _getActivities(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Заголовок
          Text(
            l10n.onboardingActivityTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            l10n.onboardingActivitySubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Опции активности
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                final isSelected = _selectedActivity == activity.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: GestureDetector(
                    onTap: () => _selectActivity(activity.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? activity.color.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? activity.color
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: activity.color.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                )
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Иконка
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activity.color
                                      : Colors.grey[100],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  activity.icon,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 28,
                                ),
                              ),

                              const SizedBox(width: 16),

                              // Основной текст
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activity.title,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected
                                            ? activity.color
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      activity.description,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Чекбокс
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? activity.color
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected
                                        ? activity.color
                                        : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Примеры
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activity.color.withValues(alpha: 0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 16,
                                  color: isSelected
                                      ? activity.color
                                      : Colors.grey[600],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activity.examples,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isSelected
                                          ? activity.color
                                          : Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate()
                    .slideX(
                      begin: 0.3,
                      end: 0,
                      delay: (300 + index * 100).ms,
                    )
                    .fadeIn(delay: (300 + index * 100).ms),
                );
              },
            ),
          ),

          // Кнопка "Рассчитать план"
          SafeArea(
            child: ElevatedButton(
              onPressed: _selectedActivity != null ? widget.onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2EC5FF),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: Text(
                l10n.onboardingCalculatePlan,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ActivityOption {
  final String id;
  final String title;
  final String description;
  final String examples;
  final IconData icon;
  final Color color;
  final double multiplier; // Коэффициент для расчета TDEE

  ActivityOption({
    required this.id,
    required this.title,
    required this.description,
    required this.examples,
    required this.icon,
    required this.color,
    required this.multiplier,
  });
}