// lib/screens/onboarding/pages/goal_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';

class GoalPage extends StatefulWidget {
  final String? selectedGoal;
  final Function(String) onGoalChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const GoalPage({
    super.key,
    this.selectedGoal,
    required this.onGoalChanged,
    required this.onNext,
    this.onBack,
  });

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  String? _selectedGoal;

  List<GoalOption> _getGoals(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      GoalOption(
        id: 'lose_weight',
        title: l10n.onboardingLoseWeight,
        description: l10n.onboardingLoseWeightDesc,
        icon: Icons.trending_down,
        color: const Color(0xFFFF6B6B),
      ),
      GoalOption(
        id: 'gain_muscle',
        title: l10n.onboardingGainMuscle,
        description: l10n.onboardingGainMuscleDesc,
        icon: Icons.fitness_center,
        color: const Color(0xFF4ECDC4),
      ),
      GoalOption(
        id: 'maintain_weight',
        title: l10n.onboardingMaintainWeight,
        description: l10n.onboardingMaintainWeightDesc,
        icon: Icons.balance,
        color: const Color(0xFF45B7D1),
      ),
      GoalOption(
        id: 'improve_nutrition',
        title: l10n.onboardingImproveNutrition,
        description: l10n.onboardingImproveNutritionDesc,
        icon: Icons.local_dining,
        color: const Color(0xFF96CEB4),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.selectedGoal;
  }

  void _selectGoal(String goalId) {
    setState(() {
      _selectedGoal = goalId;
    });
    widget.onGoalChanged(goalId);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final goals = _getGoals(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Заголовок
          Text(
            l10n.onboardingGoalTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            l10n.onboardingGoalSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          // Опции целей
          Expanded(
            child: ListView.builder(
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                final isSelected = _selectedGoal == goal.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: GestureDetector(
                    onTap: () => _selectGoal(goal.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? goal.color.withValues(alpha: 0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? goal.color
                              : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: goal.color.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
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
                      child: Row(
                        children: [
                          // Иконка
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? goal.color
                                  : Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              goal.icon,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Текст
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? goal.color
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  goal.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
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
                                  ? goal.color
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? goal.color
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

          // Кнопка "Далее"
          SafeArea(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _selectedGoal != null ? widget.onNext : null,
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
                    l10n.onboardingNext,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GoalOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  GoalOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}