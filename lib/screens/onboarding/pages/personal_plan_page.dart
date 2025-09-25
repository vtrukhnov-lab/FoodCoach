// lib/screens/onboarding/pages/personal_plan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../../l10n/app_localizations.dart';

class PersonalPlanPage extends StatefulWidget {
  final String goal;
  final String gender;
  final int age;
  final double height;
  final double currentWeight;
  final double? targetWeight;
  final String activity;
  final VoidCallback onContinue;
  final VoidCallback onEditPlan;
  final VoidCallback? onBack;

  const PersonalPlanPage({
    super.key,
    required this.goal,
    required this.gender,
    required this.age,
    required this.height,
    required this.currentWeight,
    this.targetWeight,
    required this.activity,
    required this.onContinue,
    required this.onEditPlan,
    this.onBack,
  });

  @override
  State<PersonalPlanPage> createState() => _PersonalPlanPageState();
}

class _PersonalPlanPageState extends State<PersonalPlanPage> {
  late CalorieCalculation _calculation;

  @override
  void initState() {
    super.initState();
    _calculation = _calculateCalories();
  }

  CalorieCalculation _calculateCalories() {
    // Базовый метаболизм по формуле Миффлина-Сан Жеора
    double bmr;
    if (widget.gender == 'male') {
      bmr = 10 * widget.currentWeight + 6.25 * widget.height - 5 * widget.age + 5;
    } else {
      bmr = 10 * widget.currentWeight + 6.25 * widget.height - 5 * widget.age - 161;
    }

    // Коэффициент активности
    double activityMultiplier;
    switch (widget.activity) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'moderate':
        activityMultiplier = 1.375;
        break;
      case 'active':
        activityMultiplier = 1.55;
        break;
      default:
        activityMultiplier = 1.375;
    }

    // TDEE (Total Daily Energy Expenditure)
    double tdee = bmr * activityMultiplier;

    // Корректировка калорий в зависимости от цели
    double dailyCalories;
    int weeksToGoal = 12; // По умолчанию 12 недель

    switch (widget.goal) {
      case 'lose_weight':
        dailyCalories = tdee - 500; // Дефицит 500 ккал/день
        if (widget.targetWeight != null) {
          double weightToLose = widget.currentWeight - widget.targetWeight!;
          weeksToGoal = (weightToLose / 0.5).round(); // 0.5 кг в неделю
          weeksToGoal = math.max(4, math.min(52, weeksToGoal)); // От 4 до 52 недель
        }
        break;
      case 'gain_muscle':
        dailyCalories = tdee + 300; // Профицит 300 ккал/день
        if (widget.targetWeight != null) {
          double weightToGain = widget.targetWeight! - widget.currentWeight;
          weeksToGoal = (weightToGain / 0.25).round(); // 0.25 кг в неделю
          weeksToGoal = math.max(8, math.min(52, weeksToGoal)); // От 8 до 52 недель
        }
        break;
      case 'maintain_weight':
        dailyCalories = tdee;
        weeksToGoal = 12; // Поддержание веса
        break;
      case 'improve_nutrition':
        dailyCalories = tdee;
        weeksToGoal = 12; // Улучшение питания
        break;
      default:
        dailyCalories = tdee;
    }

    // Расчет БЖУ
    double proteins = dailyCalories * 0.25 / 4; // 25% от калорий, 4 ккал/г
    double fats = dailyCalories * 0.30 / 9; // 30% от калорий, 9 ккал/г
    double carbs = dailyCalories * 0.45 / 4; // 45% от калорий, 4 ккал/г

    return CalorieCalculation(
      dailyCalories: dailyCalories.round(),
      proteins: proteins.round(),
      fats: fats.round(),
      carbs: carbs.round(),
      weeksToGoal: weeksToGoal,
      bmr: bmr.round(),
      tdee: tdee.round(),
    );
  }

  String _getGoalText() {
    switch (widget.goal) {
      case 'lose_weight':
        return 'Похудение';
      case 'gain_muscle':
        return 'Набор мышечной массы';
      case 'maintain_weight':
        return 'Поддержание веса';
      case 'improve_nutrition':
        return 'Улучшение питания';
      default:
        return 'Здоровое питание';
    }
  }

  String _getProgressText() {
    if (widget.goal == 'lose_weight' && widget.targetWeight != null) {
      double deficit = widget.currentWeight - widget.targetWeight!;
      return 'Достигнете цели через ${_calculation.weeksToGoal} недель\nПри дефиците 500 ккал/день';
    } else if (widget.goal == 'gain_muscle' && widget.targetWeight != null) {
      double surplus = widget.targetWeight! - widget.currentWeight;
      return 'Достигнете цели через ${_calculation.weeksToGoal} недель\nПри профиците 300 ккал/день';
    } else {
      return 'Следуйте плану для достижения цели\nРегулярность - ключ к успеху';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Заголовок
              Text(
                l10n.onboardingPlanTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 32),

              // Дневная норма калорий
              _buildCaloriesCard(),

              const SizedBox(height: 24),

              // Распределение БЖУ
              _buildMacrosCard(),

              const SizedBox(height: 24),

              // Прогноз
              _buildForecastCard(),

              const SizedBox(height: 24),

              // График прогресса (если есть целевой вес)
              if (widget.targetWeight != null) ...[
                _buildProgressChart(),
                const SizedBox(height: 32),
              ],

              const SizedBox(height: 20),

              // Кнопки
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.onContinue();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2EC5FF),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      l10n.onboardingStartNow,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: widget.onEditPlan,
                    child: Text(
                      l10n.onboardingEditPlan,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaloriesCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2EC5FF),
            const Color(0xFF36D1DC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EC5FF).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Дневная норма калорий',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_calculation.dailyCalories}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ккал',
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'в день',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 200.ms).fadeIn(delay: 200.ms);
  }

  Widget _buildMacrosCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Распределение БЖУ',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _buildMacroRow('Белки', _calculation.proteins, '25%', const Color(0xFFE74C3C)),
          const SizedBox(height: 16),
          _buildMacroRow('Жиры', _calculation.fats, '30%', const Color(0xFFF39C12)),
          const SizedBox(height: 16),
          _buildMacroRow('Углеводы', _calculation.carbs, '45%', const Color(0xFF2ECC71)),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 300.ms).fadeIn(delay: 300.ms);
  }

  Widget _buildMacroRow(String name, int grams, String percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${grams}г ($percentage)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage == '25%' ? 0.25 : percentage == '30%' ? 0.30 : 0.45,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildForecastCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8AF5A3).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8AF5A3).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              color: Color(0xFF27AE60),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGoalText(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getProgressText(),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 400.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildProgressChart() {
    if (widget.targetWeight == null) return const SizedBox.shrink();

    final double weightDiff = (widget.targetWeight! - widget.currentWeight).abs();
    final bool isLosing = widget.goal == 'lose_weight';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Прогноз изменения веса',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            height: 120,
            child: CustomPaint(
              size: Size(double.infinity, 120),
              painter: WeightProgressPainter(
                currentWeight: widget.currentWeight,
                targetWeight: widget.targetWeight!,
                weeks: _calculation.weeksToGoal,
                isLosing: isLosing,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Текущий',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${widget.currentWeight.toStringAsFixed(1)} кг',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Целевой',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    '${widget.targetWeight!.toStringAsFixed(1)} кг',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2EC5FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, delay: 500.ms).fadeIn(delay: 500.ms);
  }
}

class CalorieCalculation {
  final int dailyCalories;
  final int proteins;
  final int fats;
  final int carbs;
  final int weeksToGoal;
  final int bmr;
  final int tdee;

  CalorieCalculation({
    required this.dailyCalories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.weeksToGoal,
    required this.bmr,
    required this.tdee,
  });
}

class WeightProgressPainter extends CustomPainter {
  final double currentWeight;
  final double targetWeight;
  final int weeks;
  final bool isLosing;

  WeightProgressPainter({
    required this.currentWeight,
    required this.targetWeight,
    required this.weeks,
    required this.isLosing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2EC5FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Стартовая точка
    path.moveTo(0, size.height * 0.5);

    // Кривая прогресса
    final controlPoint1X = size.width * 0.3;
    final controlPoint1Y = isLosing ? size.height * 0.3 : size.height * 0.7;
    final controlPoint2X = size.width * 0.7;
    final controlPoint2Y = isLosing ? size.height * 0.8 : size.height * 0.2;
    final endX = size.width;
    final endY = isLosing ? size.height * 0.9 : size.height * 0.1;

    path.cubicTo(
      controlPoint1X, controlPoint1Y,
      controlPoint2X, controlPoint2Y,
      endX, endY,
    );

    canvas.drawPath(path, paint);

    // Точки начала и конца
    final circlePaint = Paint()
      ..color = const Color(0xFF2EC5FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(0, size.height * 0.5), 6, circlePaint);
    canvas.drawCircle(Offset(endX, endY), 6, circlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}