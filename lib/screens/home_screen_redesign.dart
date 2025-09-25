import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/hydration_provider.dart';
import '../models/food_intake.dart';
import '../models/daily_goals.dart';

class HomeScreenRedesign extends StatefulWidget {
  const HomeScreenRedesign({super.key});

  @override
  State<HomeScreenRedesign> createState() => _HomeScreenRedesignState();
}

class _HomeScreenRedesignState extends State<HomeScreenRedesign> {
  int selectedDayIndex = DateTime.now().weekday - 1; // Current day selected

  @override
  void initState() {
    super.initState();
    // Set selected day to today
    final now = DateTime.now();
    final weekday = now.weekday;
    // Monday is 1, Sunday is 7 in DateTime
    // Our weekDays list starts with Monday at index 0
    selectedDayIndex = weekday == 7 ? 6 : weekday - 1;

  }

  // Calculate macronutrients from today's food intakes
  Map<String, double> _calculateMacros(HydrationProvider provider) {
    double proteins = 0;
    double carbs = 0;
    double fats = 0;

    for (var intake in provider.todayFoodIntakes) {
      proteins += intake.proteins;
      carbs += intake.carbohydrates;
      fats += intake.fats;
    }

    return {
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
    };
  }

  // Calculate goals based on daily calorie goal
  Map<String, double> _calculateMacroGoals(HydrationProvider provider) {
    final calorieGoal = provider.dailyCaloriesGoal.toDouble();

    // Standard macronutrient distribution:
    // Proteins: 25% of calories / 4 kcal per gram
    // Carbs: 50% of calories / 4 kcal per gram
    // Fats: 25% of calories / 9 kcal per gram

    return {
      'proteins': (calorieGoal * 0.25) / 4,
      'carbs': (calorieGoal * 0.50) / 4,
      'fats': (calorieGoal * 0.25) / 9,
    };
  }

  // Generate week days with real dates
  List<Map<String, dynamic>> _generateWeekDays() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final days = ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      return {
        'day': days[index],
        'date': date.day.toString(),
        'fullDate': date,
        'calories': null, // TODO: Add historical calories data
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final provider = Provider.of<HydrationProvider>(context);
    final weekDays = _generateWeekDays();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWeekCalendar(context, weekDays),
                    SizedBox(height: screenHeight * 0.025),
                    _buildCaloriesCard(context, provider),
                    SizedBox(height: screenHeight * 0.025),
                    _buildMacronutrientsSection(context, provider),
                    SizedBox(height: screenHeight * 0.025),
                    _buildShowAllIndicators(context),
                    SizedBox(height: screenHeight * 0.025),
                    _buildWaterCard(context, provider),
                    SizedBox(height: screenHeight * 0.038),
                    _buildRecentMealsSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.012,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Add data button (left side)
          GestureDetector(
            onTap: () {
              // Показываем меню добавления
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => _AddDataMenuSheet(),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: screenWidth * 0.055,
                  height: screenWidth * 0.055,
                  decoration: BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: screenWidth * 0.04,
                  ),
                ),
                SizedBox(width: screenWidth * 0.018),
                Text(
                  'Add data',
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF2D2D2D),
                    fontFamily: 'Rubik',
                  ),
                ),
              ],
            ),
          ),
          // Day counter (right side)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.007
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(screenWidth * 0.038),
            ),
            child: Text(
              'Day 3',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Color(0xFF2D2D2D),
                fontFamily: 'Rubik',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCalendar(BuildContext context, List<Map<String, dynamic>> weekDays) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      height: screenHeight * 0.095,  // 9.5% of screen height
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 12) / 7; // Divide by 7 days with small gaps
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(weekDays.length, (index) {
          final day = weekDays[index];
          final isSelected = index == selectedDayIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedDayIndex = index;
              });
            },
            child: Container(
              width: itemWidth,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFF5F5F5) : Colors.transparent,
                borderRadius: BorderRadius.circular(screenWidth * 0.04),
                border: isSelected
                    ? Border.all(color: const Color(0xFFE6E6E6))
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day['day'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,  // 2.5% of screen width
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF838383),
                      fontFamily: 'Rubik',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.005),
                  Text(
                    day['date'],
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,  // 5% of screen width
                      color: isSelected
                          ? const Color(0xFF2D2D2D)
                          : const Color(0xFFCACACA),
                      fontFamily: 'Rubik',
                    ),
                  ),
                  if (day['calories'] != null) ...[
                    SizedBox(height: screenHeight * 0.0025),
                    Text(
                      '${day['calories']}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.025,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFCACACA),
                        fontFamily: 'Rubik',
                      ),
                    ),
                  ],
                  if (isSelected)
                    Container(
                      margin: EdgeInsets.only(top: screenHeight * 0.0025),
                      width: screenWidth * 0.02,
                      height: screenWidth * 0.02,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2D2D2D),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
          );
        },
      ),
    );
  }

  Widget _buildCaloriesCard(BuildContext context, HydrationProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate calories
    final todayCalories = provider.totalCaloriesToday;
    final calorieGoal = provider.dailyCaloriesGoal;
    final caloriesLeft = calorieGoal - todayCalories;
    final caloriesAdded = 200; // TODO: последний добавленный прием пищи
    final progress = todayCalories.toDouble() / calorieGoal.toDouble();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      height: screenHeight * 0.19,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenHeight * 0.005),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left side - Calories text
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: screenWidth * 0.1),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$todayCalories',
                        style: TextStyle(
                          fontSize: screenWidth * 0.115,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF2D2D2D),
                          fontFamily: 'Rubik',
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.015),
                      Text(
                        'kcal',
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF666666),
                          fontFamily: 'Rubik',
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Row(
                    children: [
                      Text(
                        caloriesLeft >= 0 ? 'Calories left' : 'Overeaten',
                        style: TextStyle(
                          fontSize: screenWidth * 0.033,
                          color: caloriesLeft >= 0 ? Color(0xFF2D2D2D) : Color(0xFFEF5350),
                          fontFamily: 'Rubik',
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.025),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenHeight * 0.004,
                        ),
                        decoration: BoxDecoration(
                          color: caloriesLeft >= 0
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(screenWidth * 0.25),
                        ),
                        child: Text(
                          caloriesLeft >= 0
                            ? '+$caloriesLeft'
                            : '${caloriesLeft.abs()}',  // Показываем положительное число при перерасходе
                          style: TextStyle(
                            fontSize: screenWidth * 0.033,
                            color: caloriesLeft >= 0
                              ? Color(0xFF2D2D2D)
                              : Color(0xFFEF5350),
                            fontWeight: caloriesLeft < 0 ? FontWeight.w600 : FontWeight.w400,
                            fontFamily: 'Rubik',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Right side - Circular progress for macronutrients
          // В Figma: круги находятся в позиции x="270" y="234" с размером 120x120
          // Это примерно на правой стороне карточки
          Container(
            width: screenWidth * 0.3,
            height: screenWidth * 0.3,
            margin: EdgeInsets.only(right: screenWidth * 0.075),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = constraints.maxWidth;
                return CustomPaint(
                  painter: MacronutrientsCirclePainter(
                    proteinProgress: progress.clamp(0.0, 1.0),  // Используем общий прогресс калорий
                    carbsProgress: progress.clamp(0.0, 1.0) * 0.8,    // Немного меньше для визуального эффекта
                    fatProgress: progress.clamp(0.0, 1.0) * 0.6,      // Еще меньше для визуального эффекта
                  ),
                  child: Center(
                    // Иконка огня из загрузок
                    child: SvgPicture.asset(
                      'assets/icons/fire_flame.svg',
                      width: size * 0.25,  // 25% от размера контейнера
                      height: size * 0.25,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacronutrientsSection(BuildContext context, HydrationProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Получаем реальные данные о макронутриентах
    final macros = _calculateMacros(provider);
    final goals = _calculateMacroGoals(provider);

    // Форматируем данные для карточек
    final macroData = {
      'protein': {
        'value': macros['proteins']!.round(),
        'unit': 'g',
        'norm': goals['proteins']!.round(),
        'normUnit': 'g/day',
        'color': const Color(0xFFFFE4D6),
        'progressColor': const Color(0xFFFF6B6B),
      },
      'carbs': {
        'value': macros['carbs']!.round(),
        'unit': 'g',
        'norm': goals['carbs']!.round(),
        'normUnit': 'g/day',
        'color': const Color(0xFFFFF4E6),
        'progressColor': const Color(0xFFFFB74D),
      },
      'fat': {
        'value': macros['fats']!.round(),
        'unit': 'g',
        'norm': goals['fats']!.round(),
        'normUnit': 'g/day',
        'color': const Color(0xFFE8F5E9),
        'progressColor': const Color(0xFF66BB6A),
      },
    };
    return Container(
      height: screenHeight * 0.19,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Row(
        children: [
          _buildMacroCard(
            context,
            'Protein',
            macroData['protein']!,
            Icons.egg,
          ),
          SizedBox(width: screenWidth * 0.028),
          _buildMacroCard(
            context,
            'Carbs',
            macroData['carbs']!,
            Icons.bakery_dining,
          ),
          SizedBox(width: screenWidth * 0.028),
          _buildMacroCard(
            context,
            'Fat',
            macroData['fat']!,
            Icons.water_drop,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context, String title, Map<String, dynamic> data, IconData icon) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.03),
        decoration: BoxDecoration(
          color: data['color'],
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          border: Border.all(
            color: data['progressColor'].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
                fontFamily: 'Rubik',
              ),
            ),
            Text(
              '${data['value']}g eaten',
              style: TextStyle(
                fontSize: screenWidth * 0.028,
                color: Color(0xFF666666),
                fontFamily: 'Rubik',
              ),
            ),
            Flexible(
              child: Center(
                child: SizedBox(
                  width: screenWidth * 0.175,
                  height: screenWidth * 0.175,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(screenWidth * 0.175, screenWidth * 0.175),
                      painter: MacroProgressPainter(
                        progress: data['value'] / data['norm'],
                        color: data['progressColor'],
                      ),
                    ),
                    Container(
                      width: screenWidth * 0.08,
                      height: screenWidth * 0.08,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          icon == Icons.egg ? 'assets/icons/protein_meat.svg' :
                          icon == Icons.bakery_dining ? 'assets/icons/carbs_bread.svg' :
                          'assets/icons/fat_oil.svg',
                          width: screenWidth * 0.05,
                          height: screenWidth * 0.05,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ),
            SizedBox(height: screenHeight * 0.005),
            Center(
              child: Text(
                'Target: ${data['norm']}g',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF666666),
                  fontFamily: 'Rubik',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowAllIndicators(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show all indicators functionality
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Show all indicators',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF2D2D2D),
                fontFamily: 'Rubik',
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF2D2D2D),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(BuildContext context, HydrationProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 74,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE3F2FD),
            const Color(0xFFBBDEFB),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/water_bottle.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${provider.todayIntakes.fold(0, (sum, intake) => sum + intake.volume)} ml',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    fontFamily: 'Rubik',
                  ),
                ),
                const Text(
                  'Water',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF2D2D2D),
                    fontFamily: 'Rubik',
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              width: 2,
              height: 12,
              color: const Color(0xFF90CAF9),
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            GestureDetector(
              onTap: () async {
                // TODO: Реализовать уменьшение воды
                setState(() {});
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  size: 16,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 2,
              height: 12,
              color: const Color(0xFF90CAF9),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                provider.addIntake('water', 250);
                setState(() {});
              },
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Color(0xFF2D2D2D),
                ),
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () {
                // Settings for water
              },
              child: const Icon(
                Icons.settings,
                size: 16,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMealsSection(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent meal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D2D2D),
              fontFamily: 'Rubik',
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'You haven\'t added any meals',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                      fontFamily: 'Rubik',
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Text(
                    'Take a quick photo now to start tracking\nwhat you eat today',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Color(0xFF2D2D2D),
                      fontFamily: 'Rubik',
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Custom painter for metabolism icon from Figma
class MetabolismIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Иконка метаболизма как в Figma - стилизованное пламя
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Градиент от желтого к оранжевому
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFFD54F),  // Желтый вверху
        const Color(0xFFFFA726),  // Оранжевый внизу
      ],
    );

    paint.shader = gradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    final path = Path();

    // Рисуем точную форму пламени как в Figma (пропорционально)
    // Основное пламя
    path.moveTo(size.width * 0.5, size.height * 0.05);  // Верхняя точка

    // Левая сторона пламени
    path.cubicTo(
      size.width * 0.35, size.height * 0.15,
      size.width * 0.25, size.height * 0.30,
      size.width * 0.3, size.height * 0.50,
    );
    path.cubicTo(
      size.width * 0.32, size.height * 0.65,
      size.width * 0.35, size.height * 0.80,
      size.width * 0.45, size.height * 0.95,
    );

    // Нижняя точка
    path.lineTo(size.width * 0.5, size.height * 0.98);

    // Правая сторона пламени
    path.lineTo(size.width * 0.55, size.height * 0.95);
    path.cubicTo(
      size.width * 0.65, size.height * 0.80,
      size.width * 0.68, size.height * 0.65,
      size.width * 0.7, size.height * 0.50,
    );
    path.cubicTo(
      size.width * 0.75, size.height * 0.30,
      size.width * 0.65, size.height * 0.15,
      size.width * 0.5, size.height * 0.05,
    );

    path.close();
    canvas.drawPath(path, paint);

    // Добавляем внутреннюю светлую часть
    final innerPaint = Paint()
      ..color = const Color(0xFFFFECB3).withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final innerPath = Path();

    innerPath.moveTo(size.width * 0.5, size.height * 0.35);
    innerPath.cubicTo(
      size.width * 0.42, size.height * 0.45,
      size.width * 0.40, size.height * 0.60,
      size.width * 0.45, size.height * 0.75,
    );
    innerPath.lineTo(size.width * 0.5, size.height * 0.80);
    innerPath.lineTo(size.width * 0.55, size.height * 0.75);
    innerPath.cubicTo(
      size.width * 0.60, size.height * 0.60,
      size.width * 0.58, size.height * 0.45,
      size.width * 0.5, size.height * 0.35,
    );

    innerPath.close();
    canvas.drawPath(innerPath, innerPaint);

    // Маленькие языки пламени по бокам
    final sideFlamePaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;

    // Левый язычок
    final leftFlame = Path();
    leftFlame.moveTo(size.width * 0.25, size.height * 0.55);
    leftFlame.cubicTo(
      size.width * 0.15, size.height * 0.50,
      size.width * 0.13, size.height * 0.45,
      size.width * 0.17, size.height * 0.40,
    );
    leftFlame.cubicTo(
      size.width * 0.20, size.height * 0.42,
      size.width * 0.23, size.height * 0.48,
      size.width * 0.25, size.height * 0.55,
    );
    leftFlame.close();
    canvas.drawPath(leftFlame, sideFlamePaint);

    // Правый язычок
    final rightFlame = Path();
    rightFlame.moveTo(size.width * 0.75, size.height * 0.55);
    rightFlame.cubicTo(
      size.width * 0.85, size.height * 0.50,
      size.width * 0.87, size.height * 0.45,
      size.width * 0.83, size.height * 0.40,
    );
    rightFlame.cubicTo(
      size.width * 0.80, size.height * 0.42,
      size.width * 0.77, size.height * 0.48,
      size.width * 0.75, size.height * 0.55,
    );
    rightFlame.close();
    canvas.drawPath(rightFlame, sideFlamePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for macronutrients circles in main card
class MacronutrientsCirclePainter extends CustomPainter {
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  MacronutrientsCirclePainter({
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Пропорции из Figma с учетом отступов
    // Толщина линий
    final strokeWidth = size.width * 0.083;  // 8.3% от ширины (10px для 120px)

    // Пропорция отступа между кругами
    final gap = size.width * 0.025;  // 2.5% от ширины (3px для 120px)

    // Радиусы с учетом толщины линии и отступов
    final outerRadius = size.width * 0.45;  // Внешний круг
    final middleRadius = outerRadius - strokeWidth - gap;  // Средний круг
    final innerRadius = middleRadius - strokeWidth - gap;  // Внутренний круг

    // Фоновые круги (светло-серые)
    final backgroundPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Рисуем фоны для трех кругов
    canvas.drawCircle(center, outerRadius, backgroundPaint);
    canvas.drawCircle(center, middleRadius, backgroundPaint);
    canvas.drawCircle(center, innerRadius, backgroundPaint);

    // Начальный угол (сверху)
    const startAngle = -math.pi / 2;

    // 1. Внешний круг - БЕЛКИ (красный)
    if (proteinProgress > 0) {
      final proteinPaint = Paint()
        ..color = const Color(0xFFEF5350)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final proteinSweep = 2 * math.pi * proteinProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle,
        proteinSweep,
        false,
        proteinPaint,
      );
    }

    // 2. Средний круг - УГЛЕВОДЫ (оранжевый)
    if (carbsProgress > 0) {
      final carbsPaint = Paint()
        ..color = const Color(0xFFFFB74D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final carbsSweep = 2 * math.pi * carbsProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: middleRadius),
        startAngle,
        carbsSweep,
        false,
        carbsPaint,
      );
    }

    // 3. Внутренний круг - ЖИРЫ (салатовый)
    if (fatProgress > 0) {
      final fatPaint = Paint()
        ..color = const Color(0xFF9CCC65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final fatSweep = 2 * math.pi * fatProgress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        fatSweep,
        false,
        fatPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for macronutrients circular progress
class MacroProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  MacroProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Add data menu sheet
class _AddDataMenuSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.05),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: screenHeight * 0.015),
            width: screenWidth * 0.12,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          // Title
          Text(
            'Quick Add',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D2D2D),
              fontFamily: 'Rubik',
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          // Options grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildMenuOption(
                      context: context,
                      icon: Icons.qr_code_scanner,
                      label: 'Scan Barcode',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/barcode_scanner');
                      },
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    _buildMenuOption(
                      context: context,
                      icon: Icons.search,
                      label: 'Search Food',
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/openfood_catalog');
                      },
                    ),
                  ],
                ),
                SizedBox(height: screenWidth * 0.04),
                Row(
                  children: [
                    _buildMenuOption(
                      context: context,
                      icon: Icons.favorite,
                      label: 'Favorites',
                      color: Colors.pink,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/favorites');
                      },
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    _buildMenuOption(
                      context: context,
                      icon: Icons.fitness_center,
                      label: 'Sports',
                      color: Colors.green,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/sports');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.04),
        ],
      ),
    );
  }

  Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.025),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.038,
                    fontWeight: FontWeight.w500,
                    color: color,
                    fontFamily: 'Rubik',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}