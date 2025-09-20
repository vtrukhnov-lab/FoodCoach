import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../models/alcohol_intake.dart';
import '../../services/alcohol_service.dart';
import '../../services/history_service.dart';
import '../../services/remote_config_service.dart';
import '../../services/units_service.dart';
import '../../services/hri_service.dart';

// Класс для хранения данных за день (расширенный)
class DailyData {
  final DateTime date;
  final int water;
  final int sodium;
  final int potassium;
  final int magnesium;
  final double waterPercent;
  final int coffeeCount;
  final int intakeCount;
  final double alcoholSD;
  final int workoutMinutes;
  final int workoutCount;
  final bool hasWorkouts;
  final int waterGoal;
  final int caffeineTotal; // NEW: Total caffeine mg
  final double sugarTotal; // NEW: Total sugar grams
  final int foodCount; // NEW: Number of food items
  final int totalCalories; // NEW: Total calories from food
  final double totalFoodSugar; // NEW: Sugar specifically from food
  final double totalFoodWater; // NEW: Water from food
  final bool hasFood; // NEW: Whether any food was logged

  DailyData({
    required this.date,
    required this.water,
    required this.sodium,
    required this.potassium,
    required this.magnesium,
    required this.waterPercent,
    required this.coffeeCount,
    required this.intakeCount,
    this.alcoholSD = 0,
    this.workoutMinutes = 0,
    this.workoutCount = 0,
    this.hasWorkouts = false,
    required this.waterGoal,
    this.caffeineTotal = 0,
    this.sugarTotal = 0,
    this.foodCount = 0,
    this.totalCalories = 0,
    this.totalFoodSugar = 0.0,
    this.totalFoodWater = 0.0,
    this.hasFood = false,
  });
}

class MonthlyHistoryScreen extends StatefulWidget {
  const MonthlyHistoryScreen({super.key});

  @override
  State<MonthlyHistoryScreen> createState() => _MonthlyHistoryScreenState();
}

class _MonthlyHistoryScreenState extends State<MonthlyHistoryScreen> {
  Map<String, DailyData> monthlyData = {};
  bool isLoadingMonthData = false;
  int soberStreakDays = 0;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDate; // Null означает что показываем весь месяц
  
  late final HistoryService _historyService;
  late final RemoteConfigService _remoteConfig;
  late final UnitsService _unitsService;

  @override
  void initState() {
    super.initState();
    _historyService = HistoryService();
    _remoteConfig = RemoteConfigService.instance;
    _unitsService = UnitsService.instance;
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    if (isLoadingMonthData) return;
    setState(() => isLoadingMonthData = true);

    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      final Map<String, DailyData> tempData = {};

      final now = DateTime.now();
      final lastDay = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
      
      // Определяем последний день для подсчета статистики
      final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
      final lastDayForStats = isCurrentMonth ? now.day : lastDay.day;
      
      int currentSoberStreak = 0;

      for (int d = 1; d <= lastDay.day; d++) {
        final date = DateTime(_selectedMonth.year, _selectedMonth.month, d);
        final dateKey = date.toIso8601String().split('T')[0];
        final isToday = _isSameDay(date, now);
        
        // Пропускаем будущие даты для текущего месяца
        if (isCurrentMonth && d > now.day) {
          continue;
        }

        // Правильный расчет цели для каждого дня
        int waterGoal;
        if (isToday) {
          // Сегодня - используем динамическую цель с корректировками
          waterGoal = provider.goals.waterOpt;
        } else {
          // История - используем только базовую формулу
          waterGoal = (_remoteConfig.waterOptPerKg * provider.weight).round();
        }

        if (isToday) {
          // Данные текущего дня из provider
          final waterCurrent = provider.totalWaterToday.round();
          final waterPercent = waterGoal > 0 
              ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) 
              : 0.0;

          // Получаем данные о тренировках из HRIService
          final hriService = Provider.of<HRIService>(context, listen: false);
          final workoutMinutes = hriService.todayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
          final workoutCount = hriService.todayWorkouts.length;
          
          // Получаем данные о кофеине
          final caffeineTotal = hriService.getTodaysCaffeine();
          
          // Получаем данные о сахаре
          final sugarData = provider.getSugarIntakeData(context);
          
          tempData[dateKey] = DailyData(
            date: date,
            water: waterCurrent,
            sodium: provider.totalSodiumToday,
            potassium: provider.totalPotassiumToday,
            magnesium: provider.totalMagnesiumToday,
            waterPercent: waterPercent,
            coffeeCount: provider.coffeeCupsToday,
            intakeCount: provider.todayIntakes.length,
            alcoholSD: hriService.todayAlcoholSD,
            workoutMinutes: workoutMinutes,
            workoutCount: workoutCount,
            hasWorkouts: hriService.todayWorkouts.isNotEmpty,
            waterGoal: waterGoal,
            caffeineTotal: caffeineTotal,
            sugarTotal: sugarData.totalGrams,
            foodCount: provider.todayFoodIntakes.length,
            totalCalories: provider.totalCaloriesToday,
            totalFoodSugar: provider.totalSugarToday,
            totalFoodWater: provider.totalWaterFromFoodToday,
            hasFood: provider.todayFoodIntakes.isNotEmpty,
          );
        } else {
          // Исторические данные из HistoryService
          final daySummary = await _historyService.getDaySummary(date);
          
          if (daySummary.isNotEmpty) {
            final waterCurrent = (daySummary['water'] as num?)?.toInt() ?? 0;
            final waterPercent = waterGoal > 0 
                ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) 
                : 0.0;

            tempData[dateKey] = DailyData(
              date: date,
              water: (daySummary['water'] as num?)?.toInt() ?? 0,
              sodium: (daySummary['sodium'] as num?)?.toInt() ?? 0,
              potassium: (daySummary['potassium'] as num?)?.toInt() ?? 0,
              magnesium: (daySummary['magnesium'] as num?)?.toInt() ?? 0,
              waterPercent: waterPercent,
              coffeeCount: (daySummary['coffeeCount'] as num?)?.toInt() ?? 0,
              intakeCount: (daySummary['intakeEvents'] as num?)?.toInt() ?? 0,
              alcoholSD: (daySummary['alcoholSD'] as num?)?.toDouble() ?? 0.0,
              workoutMinutes: (daySummary['workoutMinutes'] as num?)?.toInt() ?? 0,
              workoutCount: (daySummary['workoutCount'] as num?)?.toInt() ?? 0,
              hasWorkouts: daySummary['hasWorkouts'] ?? false,
              waterGoal: waterGoal,
              caffeineTotal: (daySummary['caffeineTotal'] as num?)?.toInt() ?? 0,
              sugarTotal: (daySummary['totalFoodSugar'] as num?)?.toDouble() ?? 0.0,
              foodCount: (daySummary['foodCount'] as num?)?.toInt() ?? 0,
              totalCalories: (daySummary['totalCalories'] as num?)?.toInt() ?? 0,
              totalFoodSugar: (daySummary['totalFoodSugar'] as num?)?.toDouble() ?? 0.0,
              totalFoodWater: (daySummary['totalFoodWater'] as num?)?.toDouble() ?? 0.0,
              hasFood: daySummary['hasFood'] ?? false,
            );
          }
        }

        // Подсчет серии трезвых дней
        if (!date.isAfter(now)) {
          final alcoholSD = tempData[dateKey]?.alcoholSD ?? 0.0;
          currentSoberStreak = (alcoholSD == 0) ? currentSoberStreak + 1 : 0;
        }
      }

      if (mounted) {
        setState(() {
          monthlyData = tempData;
          soberStreakDays = currentSoberStreak;
          isLoadingMonthData = false;
        });
      }
    } catch (e) {
      print('Error loading monthly data: $e');
      if (mounted) {
        setState(() => isLoadingMonthData = false);
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final alcoholService = Provider.of<AlcoholService>(context);
   

    if (isLoadingMonthData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Календарь-тепловая карта
              _buildCalendarCard(l10n).animate().fadeIn(),
              const SizedBox(height: 20),

              // Статистика алкоголя (если есть данные и не sober mode)
              if (!alcoholService.soberModeEnabled && _hasAlcoholData())
                _buildAlcoholStats(l10n).animate().fadeIn(delay: 100.ms),

              if (!alcoholService.soberModeEnabled && _hasAlcoholData())
                const SizedBox(height: 20),

              // NEW: Статистика кофе (если есть данные)
              if (_hasCaffeineData())
                _buildCaffeineStats(l10n).animate().fadeIn(delay: 150.ms),

              if (_hasCaffeineData())
                const SizedBox(height: 20),

              // NEW: Статистика сахара (если есть данные)
              if (_hasSugarData())
                _buildSugarStats(l10n).animate().fadeIn(delay: 200.ms),

              if (_hasSugarData())
                const SizedBox(height: 20),

              // NEW: Статистика еды (если есть данные)
              if (_hasFoodData())
                _buildFoodStats(l10n).animate().fadeIn(delay: 225.ms),

              if (_hasFoodData())
                const SizedBox(height: 20),

              // NEW: Статистика спорта (если есть данные)
              if (_hasWorkoutData())
                _buildWorkoutStats(l10n).animate().fadeIn(delay: 250.ms),

              if (_hasWorkoutData())
                const SizedBox(height: 20),

              // NEW: Статистика электролитов
              _buildElectrolytesStats(l10n).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 20),

              // Месячные инсайты
              _buildMonthlyInsights(l10n).animate().scale(delay: 400.ms),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Навигация по месяцам
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                    _selectedDate = null; // Сбрасываем выбранную дату
                  });
                  _loadMonthlyData();
                },
              ),
              Column(
                children: [
                  Text(
                    '${_getMonthName(_selectedMonth.month, l10n)} ${_selectedMonth.year}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (soberStreakDays > 0)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Text(
                        l10n.soberDaysRow(soberStreakDays),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _canGoForward() ? () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                    _selectedDate = null; // Сбрасываем выбранную дату
                  });
                  _loadMonthlyData();
                } : null,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Информация о выбранной дате
          if (_selectedDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, color: Colors.purple.shade600, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Статистика до ${_selectedDate!.day}.${_selectedDate!.month}.${_selectedDate!.year}',
                    style: TextStyle(
                      color: Colors.purple.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedDate = null),
                    child: Icon(Icons.close, color: Colors.purple.shade600, size: 16),
                  ),
                ],
              ),
            ),

          // Календарь-сетка
          _buildCalendarGrid(l10n),
          
          const SizedBox(height: 16),

          // Легенда
          _buildLegend(l10n),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(AppLocalizations l10n) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday;

    // Локализованные короткие дни недели
    final weekDays = [
      l10n.mondayShort ?? 'MON',
      l10n.tuesdayShort ?? 'TUE',
      l10n.wednesdayShort ?? 'WED',
      l10n.thursdayShort ?? 'THU',
      l10n.fridayShort ?? 'FRI',
      l10n.saturdayShort ?? 'SAT',
      l10n.sundayShort ?? 'SUN',
    ];

    return Column(
      children: [
        // Дни недели
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: weekDays
              .map(
                (d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),

        // Сетка календаря
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: (firstWeekday - 1) + lastDayOfMonth.day,
          itemBuilder: (context, index) {
            if (index < firstWeekday - 1) return const SizedBox.shrink();

            final day = index - (firstWeekday - 2);
            final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
            final dateKey = date.toIso8601String().split('T')[0];

            final dayData = monthlyData[dateKey];
            final progress = dayData?.waterPercent ?? 0;
            final alcoholSD = dayData?.alcoholSD ?? 0;

            return _buildDayCell(date, day, progress, alcoholSD, dayData, l10n, now);
          },
        ),
      ],
    );
  }

  Widget _buildDayCell(DateTime date, int day, double progress, double alcoholSD,
                      DailyData? dayData, AppLocalizations l10n, DateTime now) {
    final alcoholService = Provider.of<AlcoholService>(context, listen: false);

    // Определяем, должен ли день быть неактивным
    final bool isInactive = _selectedDate != null && date.isAfter(_selectedDate!) ||
                           _selectedDate == null && date.isAfter(now);

    if (isInactive) {
      // Неактивные даты (будущие или после выбранной даты)
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ),
      );
    }

    // Цвет фона от процента воды
    final bgColor = _getHeatmapColor(progress); 
    final textColor = progress > 70 ? Colors.white : Colors.black87;
    final alcLevel = _alcoholLevel(alcoholSD);

    // Проверяем, выбрана ли эта дата
    final bool isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (_selectedDate != null && _isSameDay(date, _selectedDate!)) {
            // Если кликнули на уже выбранную дату - сбрасываем выбор
            _selectedDate = null;
          } else {
            // Выбираем новую дату
            _selectedDate = date;
          }
        });
      },
      onLongPress: () {
        HapticFeedback.lightImpact();
        _showDayDetails(date, dayData, alcoholSD, l10n);
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.purple, width: 3)
              : _isSameDay(date, now)
                  ? Border.all(color: Colors.blue, width: 2)
                  : null,
        ),
        child: Stack(
          children: [
            // Число дня по центру
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Индикаторы алкоголя внизу
            if (alcLevel > 0 && !alcoholService.soberModeEnabled)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Center(
                  child: _alcoholGlyph(alcLevel, color: textColor.withValues(alpha: 0.8), size: 8),
                ),
              ),

            // Индикатор тренировок вверху
            if (dayData?.hasWorkouts == true)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(AppLocalizations l10n) {
    final alcoholService = Provider.of<AlcoholService>(context, listen: false);
    
    return Column(
      children: [
        // Легенда гидратации
        Text(
          l10n.hydration,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _buildLegendItem('0%', Colors.grey.shade200),
            _buildLegendItem('1-50%', Colors.red.shade200),
            _buildLegendItem('51-80%', Colors.orange.shade300),
            _buildLegendItem('81-99%', Colors.blue.shade400),
            _buildLegendItem('100%+', Colors.green.shade500),
          ],
        ),
        
        // Легенда алкоголя (если не sober mode)
        if (!alcoholService.soberModeEnabled && _hasAlcoholData()) ...[
          const SizedBox(height: 12),
          Text(
            l10n.alcohol,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_bar, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              const Text('1–2 SD', style: TextStyle(fontSize: 10)),
              const SizedBox(width: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_bar, size: 14, color: Colors.grey.shade700),
                  const SizedBox(width: 1),
                  Icon(Icons.local_bar, size: 14, color: Colors.grey.shade700),
                ],
              ),
              const SizedBox(width: 4),
              const Text('>2 SD', style: TextStyle(fontSize: 10)),
            ],
          ),
        ],
        
        // Легенда тренировок (если есть данные)
        if (_hasWorkoutData()) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(l10n.workouts, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAlcoholStats(AppLocalizations l10n) {
    double totalSD = 0;
    int daysWithAlcohol = 0;
    int soberDays = 0;

    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      
      final sd = data.alcoholSD;
      totalSD += sd;
      if (sd > 0) {
        daysWithAlcohol++;
      } else {
        soberDays++;
      }
    }
    
    final actualDaysInMonth = filteredData.length;
    final avgSD = daysWithAlcohol > 0 ? totalSD / daysWithAlcohol : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_bar, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                l10n.alcoholStatistics,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.totalSD,
                  totalSD.toStringAsFixed(1),
                  Colors.orange,
                  l10n.forMonth,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.daysWithAlcohol,
                  '$daysWithAlcohol',
                  Colors.red,
                  l10n.fromDays(actualDaysInMonth),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.soberDays,
                  '$soberDays',
                  Colors.green,
                  l10n.excellent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.averageSD,
                  avgSD.toStringAsFixed(1),
                  Colors.purple,
                  l10n.inDrinkingDays,
                ),
              ),
            ],
          ),
          
          if (soberStreakDays > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_fire_department, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.currentStreak(soberStreakDays),
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.keepItUp,
                          style: TextStyle(
                            color: Colors.green.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW: Caffeine/Coffee statistics widget
  Widget _buildCaffeineStats(AppLocalizations l10n) {
    int totalCaffeineMg = 0;
    int totalCoffeeCups = 0;
    int daysWithCoffee = 0;
    double maxDailyCaffeine = 0;
    
    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      
      if (data.coffeeCount > 0) {
        daysWithCoffee++;
        totalCoffeeCups += data.coffeeCount;
      }
      if (data.caffeineTotal > 0) {
        totalCaffeineMg += data.caffeineTotal;
        if (data.caffeineTotal > maxDailyCaffeine) {
          maxDailyCaffeine = data.caffeineTotal.toDouble();
        }
      }
    }
    
    final actualDaysInMonth = filteredData.length;
    final avgCaffeine = daysWithCoffee > 0 ? totalCaffeineMg ~/ daysWithCoffee : 0;
    final avgCupsPerDay = daysWithCoffee > 0 ? (totalCoffeeCups / daysWithCoffee).toStringAsFixed(1) : "0";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.brown.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.brown.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.coffee, color: Colors.brown),
              const SizedBox(width: 8),
              Text(
                l10n.caffeine,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.total,
                  '${(totalCaffeineMg / 1000).toStringAsFixed(1)}g',
                  Colors.brown,
                  '$totalCaffeineMg ${l10n.mg}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.cupsToday,
                  '$totalCoffeeCups',
                  Colors.orange,
                  '$avgCupsPerDay в день',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.activeDays,
                  '$daysWithCoffee',
                  Colors.amber,
                  l10n.fromDays(actualDaysInMonth),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Среднее/день',
                  '$avgCaffeine ${l10n.mg}',
                  Colors.deepOrange,
                  maxDailyCaffeine > 400 ? '⚠️ Высокое' : '✅ Норма',
                ),
              ),
            ],
          ),
          
          if (maxDailyCaffeine > 400) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Были дни с превышением безопасной дозы (400мг)',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW: Sugar statistics widget  
  Widget _buildSugarStats(AppLocalizations l10n) {
    double totalSugar = 0;
    int daysWithSugar = 0;
    int daysOverLimit = 0;
    double maxDailySugar = 0;
    
    final dailyLimit = 50.0; // WHO recommendation
    
    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      
      if (data.sugarTotal > 0) {
        daysWithSugar++;
        totalSugar += data.sugarTotal;
        if (data.sugarTotal > dailyLimit) {
          daysOverLimit++;
        }
        if (data.sugarTotal > maxDailySugar) {
          maxDailySugar = data.sugarTotal;
        }
      }
    }
    
    final avgSugar = daysWithSugar > 0 ? (totalSugar / daysWithSugar).toStringAsFixed(1) : "0";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.pink.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cake, color: Colors.pink),
              const SizedBox(width: 8),
              Text(
                'Сахар', // TODO: Add to localization
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.total,
                  '${totalSugar.toStringAsFixed(0)}g',
                  Colors.pink,
                  'За месяц',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Среднее',
                  '${avgSugar}g',
                  Colors.red,
                  'В день',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Дней с превышением',
                  '$daysOverLimit',
                  Colors.deepOrange,
                  'Лимит 50г/день',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Максимум',
                  '${maxDailySugar.toStringAsFixed(0)}g',
                  Colors.purple,
                  'В день',
                ),
              ),
            ],
          ),
          
          if (daysOverLimit > 7) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Частое превышение нормы сахара влияет на гидратацию',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // NEW: Food statistics widget
  Widget _buildFoodStats(AppLocalizations l10n) {
    int totalCalories = 0;
    double totalFoodSugar = 0;
    double totalFoodWater = 0;
    int totalFoodCount = 0;
    int daysWithFood = 0;
    int maxDailyCalories = 0;

    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      if (data.hasFood) {
        daysWithFood++;
        totalCalories += data.totalCalories;
        totalFoodSugar += data.totalFoodSugar;
        totalFoodWater += data.totalFoodWater;
        totalFoodCount += data.foodCount;

        if (data.totalCalories > maxDailyCalories) {
          maxDailyCalories = data.totalCalories;
        }
      }
    }

    final avgCaloriesPerDay = daysWithFood > 0 ? (totalCalories / daysWithFood).round() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.restaurant, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                l10n.foodStats,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildFoodStatCard(l10n.totalCalories, '$totalCalories kcal', Icons.assessment),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFoodStatCard(l10n.avgCaloriesPerDay, '$avgCaloriesPerDay kcal', Icons.trending_up),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildFoodStatCard(l10n.daysWithFood, '$daysWithFood', Icons.calendar_today),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFoodStatCard(l10n.avgMealsPerDay, '${(totalFoodCount / (daysWithFood > 0 ? daysWithFood : 1)).toStringAsFixed(1)}', Icons.restaurant_menu),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Workout statistics widget
  Widget _buildWorkoutStats(AppLocalizations l10n) {
    int totalMinutes = 0;
    int totalSessions = 0;
    int activeDays = 0;
    Map<String, int> workoutTypes = {};

    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      if (data.hasWorkouts) {
        activeDays++;
        totalMinutes += data.workoutMinutes;
        totalSessions += data.workoutCount;
      }
    }

    final actualDaysInMonth = filteredData.length;
    final avgMinutesPerSession = totalSessions > 0 ? totalMinutes ~/ totalSessions : 0;
    final totalHours = (totalMinutes / 60).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.green),
              const SizedBox(width: 8),
              Text(
                l10n.workouts,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.totalTime,
                  '$totalHours h',
                  Colors.green,
                  '$totalMinutes ${l10n.minutes}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.sessions,
                  '$totalSessions',
                  Colors.teal,
                  '$avgMinutesPerSession ${l10n.minutes}/session',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.activeDays,
                  '$activeDays',
                  Colors.blue,
                  l10n.fromDays(actualDaysInMonth),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.waterLoss,
                  '${(totalMinutes * 10).round()} ml',
                  Colors.cyan,
                  l10n.sweatLoss,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // NEW: Electrolytes statistics widget
  Widget _buildElectrolytesStats(AppLocalizations l10n) {
    int totalSodium = 0;
    int totalPotassium = 0;
    int totalMagnesium = 0;
    int daysWithGoodSodium = 0;
    int daysWithGoodPotassium = 0;
    int daysWithGoodMagnesium = 0;
    int perfectElectrolyteDays = 0;

    // Цели электролитов (базовые значения)
    final sodiumGoal = 2500;
    final potassiumGoal = 3000;
    final magnesiumGoal = 350;

    // Используем фильтрованные данные
    final filteredData = _getFilteredMonthlyData();

    for (final data in filteredData) {
      
      totalSodium += data.sodium;
      totalPotassium += data.potassium;
      totalMagnesium += data.magnesium;
      
      // Считаем дни с достижением целей (80-120% от цели считаем хорошим)
      if (data.sodium >= sodiumGoal * 0.8 && data.sodium <= sodiumGoal * 1.2) {
        daysWithGoodSodium++;
      }
      if (data.potassium >= potassiumGoal * 0.8 && data.potassium <= potassiumGoal * 1.2) {
        daysWithGoodPotassium++;
      }
      if (data.magnesium >= magnesiumGoal * 0.8 && data.magnesium <= magnesiumGoal * 1.2) {
        daysWithGoodMagnesium++;
      }
      
      // Идеальный день - все три электролита в норме
      if (data.sodium >= sodiumGoal * 0.8 && data.sodium <= sodiumGoal * 1.2 &&
          data.potassium >= potassiumGoal * 0.8 && data.potassium <= potassiumGoal * 1.2 &&
          data.magnesium >= magnesiumGoal * 0.8 && data.magnesium <= magnesiumGoal * 1.2) {
        perfectElectrolyteDays++;
      }
    }
    
    final actualDaysInMonth = filteredData.length;
    final daysCount = actualDaysInMonth > 0 ? actualDaysInMonth : 1;
    
    final avgSodium = totalSodium ~/ daysCount;
    final avgPotassium = totalPotassium ~/ daysCount;
    final avgMagnesium = totalMagnesium ~/ daysCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.teal),
              const SizedBox(width: 8),
              Text(
                l10n.electrolytes,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Натрий и Калий
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.sodium,
                  '$avgSodium ${l10n.mg}',
                  Colors.blue,
                  '$daysWithGoodSodium дней в норме',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.potassium,
                  '$avgPotassium ${l10n.mg}',
                  Colors.orange,
                  '$daysWithGoodPotassium дней в норме',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Магний и идеальные дни
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.magnesium,
                  '$avgMagnesium ${l10n.mg}',
                  Colors.purple,
                  '$daysWithGoodMagnesium дней в норме',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Баланс',
                  '$perfectElectrolyteDays дней',
                  Colors.green,
                  'Все в норме',
                ),
              ),
            ],
          ),
          
          // Предупреждение если мало дней с хорошими электролитами
          if (perfectElectrolyteDays < actualDaysInMonth * 0.3) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Электролитный баланс требует внимания',
                      style: TextStyle(
                        color: Colors.amber.shade800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // UPDATED: Monthly insights instead of weekly
  Widget _buildMonthlyInsights(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.insights,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Месячные инсайты', // TODO: Add to localization
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildMonthlyInsightsList(l10n),
        ],
      ),
    );
  }

  List<Widget> _buildMonthlyInsightsList(AppLocalizations l10n) {
    final insights = <Widget>[];

    if (monthlyData.isEmpty) {
      return [
        Text(l10n.insufficientDataForAnalysis, style: const TextStyle(color: Colors.white70))
      ];
    }

    final sorted = monthlyData.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Найти лучший день
    DailyData? bestDay;
    for (var d in sorted) {
      if (bestDay == null || d.waterPercent > bestDay.waterPercent) {
        bestDay = d;
      }
    }

    if (bestDay != null) {
      insights.add(_buildInsight(
        '🏆 ${l10n.bestDay}',
        l10n.bestDayMessage(_getWeekdayFull(bestDay.date, l10n), bestDay.waterPercent.toInt()),
      ));
    }

    // Анализ консистентности
    final daysAbove80 = sorted.where((d) => d.waterPercent >= 80).length;
    final consistencyPercent = (daysAbove80 / sorted.length * 100).round();
    
    if (consistencyPercent >= 80) {
      insights.add(_buildInsight(
        '⭐ Отличная консистентность',
        '$consistencyPercent% дней с хорошей гидратацией',
      ));
    } else if (consistencyPercent >= 60) {
      insights.add(_buildInsight(
        '📊 Хорошие результаты',
        'Стабильность в $consistencyPercent% дней',
      ));
    }

    // Анализ трендов по неделям
    if (sorted.length >= 14) {
      final firstWeek = sorted.take(7).map((d) => d.waterPercent).reduce((a, b) => a + b) / 7;
      final lastWeek = sorted.skip(sorted.length - 7).map((d) => d.waterPercent).reduce((a, b) => a + b) / 7;
      
      if (lastWeek > firstWeek + 10) {
        insights.add(_buildInsight(
          '📈 Положительный тренд',
          'Улучшение к концу месяца на ${(lastWeek - firstWeek).toInt()}%',
        ));
      }
    }

    // Анализ тренировок
    if (_hasWorkoutData()) {
      final daysWithWorkouts = sorted.where((d) => d.hasWorkouts).length;
      final workoutPercent = (daysWithWorkouts / sorted.length * 100).round();
      final totalMinutes = sorted.fold(0, (sum, d) => sum + d.workoutMinutes);
      
      insights.add(_buildInsight(
        '💪 Физическая активность',
        '$workoutPercent% дней с тренировками (${(totalMinutes/60).toStringAsFixed(1)}ч)',
      ));
    }

    // Анализ кофеина
    final totalCoffee = sorted.fold(0, (sum, d) => sum + d.coffeeCount);
    if (totalCoffee > 0) {
      final avgCoffee = (totalCoffee / sorted.length).toStringAsFixed(1);
      insights.add(_buildInsight(
        '☕ Потребление кофе',
        'В среднем $avgCoffee чашек/день',
      ));
    }

    // Анализ алкоголя и трезвости
    if (_hasAlcoholData()) {
      final daysWithAlcohol = sorted.where((d) => d.alcoholSD > 0).length;
      final soberPercent = ((sorted.length - daysWithAlcohol) / sorted.length * 100).round();
      
      if (soberPercent >= 80) {
        insights.add(_buildInsight(
          '🎯 Отличная трезвость',
          '$soberPercent% дней без алкоголя',
        ));
      }
    }

    return insights.isNotEmpty
        ? insights
        : [_buildInsight('✨ Отличный месяц', 'Продолжайте в том же духе!')];
  }

  Widget _buildInsight(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                title.split(' ').first,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.substring(title.indexOf(' ') + 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, MaterialColor color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color.shade800, fontSize: 20, fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: color.shade600, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildFoodStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Expanded(
              child: Text(label,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  void _showDayDetails(DateTime date, DailyData? data, double alcoholSD, AppLocalizations l10n) {
    final alcoholService = Provider.of<AlcoholService>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<List<AlcoholIntake>>(
          future: alcoholService.getIntakesForDate(date),
          builder: (context, snapshot) {
            final alcoholIntakes = snapshot.data ?? [];

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.all(20),
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Date header
                      Text(
                        '${date.day} ${_getMonthName(date.month, l10n)} ${date.year}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      
                      if (data != null) ...[
                        // HRI если есть данные
                        _buildDayDetailCard(
                          title: 'HRI (Hydration Risk Index)',
                          icon: Icons.warning_amber_rounded,
                          color: _getHRIColor(50), // TODO: Get actual HRI from data
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Индекс: 50', // TODO: Get actual HRI
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Статус: Умеренный риск',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Water intake
                        _buildDayDetailCard(
                          title: l10n.water,
                          icon: Icons.water_drop,
                          color: Colors.blue,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${_unitsService.formatVolume(data.water)} (${data.waterPercent.toInt()}%)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${l10n.goal}: ${_unitsService.formatVolume(data.waterGoal)}',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: (data.waterPercent / 100).clamp(0.0, 1.0),
                                backgroundColor: Colors.blue.shade100,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Electrolytes
                        _buildDayDetailCard(
                          title: l10n.electrolytes,
                          icon: Icons.bolt,
                          color: Colors.orange,
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.sodium,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      Text(
                                        '${data.sodium} ${l10n.mg}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.potassium,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      Text(
                                        '${data.potassium} ${l10n.mg}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.magnesium,
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                      ),
                                      Text(
                                        '${data.magnesium} ${l10n.mg}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Workouts if any
                        if (data.hasWorkouts) ...[
                          _buildDayDetailCard(
                            title: l10n.workouts,
                            icon: Icons.fitness_center,
                            color: Colors.green,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data.workoutCount} ${l10n.sessions}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${data.workoutMinutes} ${l10n.minutes}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Icon(
                                      Icons.local_fire_department,
                                      color: Colors.orange.shade400,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Caffeine if any
                        if (data.caffeineTotal > 0) ...[
                          _buildDayDetailCard(
                            title: l10n.caffeine,
                            icon: Icons.coffee,
                            color: Colors.brown,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data.caffeineTotal} ${l10n.mg}',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${data.coffeeCount} ${l10n.cupsToday}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    if (data.caffeineTotal > 400)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '⚠️ Высокое',
                                          style: TextStyle(
                                            color: Colors.orange.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Sugar if any
                        if (data.sugarTotal > 0) ...[
                          _buildDayDetailCard(
                            title: 'Сахар',
                            icon: Icons.cake,
                            color: Colors.pink,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${data.sugarTotal.toStringAsFixed(1)} г',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    if (data.sugarTotal > 50)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'Превышение',
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                if (data.sugarTotal > 25) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Лимит ВОЗ: 50г/день',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Alcohol if any
                        if (alcoholSD > 0 && !alcoholService.soberModeEnabled) ...[
                          _buildDayDetailCard(
                            title: l10n.alcohol,
                            icon: Icons.local_bar,
                            color: Colors.orange,
                            content: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.alcoholAmount(alcoholSD.toStringAsFixed(1)),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                ...alcoholIntakes.map(
                                  (intake) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Text(
                                          intake.formattedTime,
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(intake.type.icon, size: 16, color: Colors.orange),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            '${intake.type.getLabel(context)}: ${intake.volumeMl.toInt()} ${l10n.ml}, ${intake.abv}%',
                                            style: const TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Summary statistics
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Сводка дня',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '• Записей: ${data.intakeCount}',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              Text(
                                '• Достижение цели воды: ${data.waterPercent.toInt()}%',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                              ),
                              if (data.hasWorkouts)
                                Text(
                                  '• Тренировки: ${data.workoutCount} сессий',
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // No data for this day
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.info_outline, size: 48, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text(
                                  l10n.noDataForDay,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Helper method for day detail cards
  Widget _buildDayDetailCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  // Helper method to get HRI color
  Color _getHRIColor(double hri) {
    if (hri <= 30) return Colors.green;
    if (hri <= 60) return Colors.orange;
    return Colors.red;
  }

  void _exportToCsv() {
    HapticFeedback.mediumImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).csvExported),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Фильтрует данные до выбранной/текущей даты
  List<DailyData> _getFilteredMonthlyData() {
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    final limitDate = _selectedDate ?? (isCurrentMonth ? now : DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0));

    return monthlyData.values.where((data) => !data.date.isAfter(limitDate)).toList();
  }

  bool _canGoForward() {
    final now = DateTime.now();
    return !(_selectedMonth.month == now.month && _selectedMonth.year == now.year);
  }

  bool _hasAlcoholData() => monthlyData.values.any((d) => d.alcoholSD > 0);

  Future<void> _reloadTodayData() async {
    final now = DateTime.now();
    final isCurrentMonth = _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    
    if (!isCurrentMonth) return;
    
    final dateKey = now.toIso8601String().split('T')[0];
    
    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      final hriService = Provider.of<HRIService>(context, listen: false);
      
      final waterCurrent = provider.totalWaterToday.round();
      final waterGoal = provider.goals.waterOpt;
      final waterPercent = waterGoal > 0 
          ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) 
          : 0.0;
      
      monthlyData[dateKey] = DailyData(
        date: now,
        water: waterCurrent,
        sodium: provider.totalSodiumToday,
        potassium: provider.totalPotassiumToday,
        magnesium: provider.totalMagnesiumToday,
        waterPercent: waterPercent,
        coffeeCount: provider.coffeeCupsToday,
        intakeCount: provider.todayIntakes.length,
        alcoholSD: alcoholService.totalStandardDrinks,
        workoutMinutes: hriService.todayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes),
        workoutCount: hriService.todayWorkouts.length,
        hasWorkouts: hriService.todayWorkouts.isNotEmpty,
        waterGoal: waterGoal,
        caffeineTotal: hriService.getTodaysCaffeine(),
        sugarTotal: provider.getSugarIntakeData(context).totalGrams,
        foodCount: provider.todayFoodIntakes.length,
        totalCalories: provider.totalCaloriesToday,
        totalFoodSugar: provider.totalSugarToday,
        totalFoodWater: provider.totalWaterFromFoodToday,
        hasFood: provider.todayFoodIntakes.isNotEmpty,
      );
      
      if (mounted) setState(() {});
    } catch (e) {
      print('Error reloading today data: $e');
    }
  }

  bool _hasWorkoutData() => monthlyData.values.any((d) => d.hasWorkouts);
  
  bool _hasCaffeineData() => monthlyData.values.any((d) => d.caffeineTotal > 0 || d.coffeeCount > 0);
  
  bool _hasSugarData() => monthlyData.values.any((d) => d.sugarTotal > 0);

  bool _hasFoodData() => monthlyData.values.any((d) => d.hasFood);

  String _getMonthName(int month, AppLocalizations l10n) {
    switch (month) {
      case 1: return l10n.january;
      case 2: return l10n.february;
      case 3: return l10n.march;
      case 4: return l10n.april;
      case 5: return l10n.may;
      case 6: return l10n.june;
      case 7: return l10n.july;
      case 8: return l10n.august;
      case 9: return l10n.september;
      case 10: return l10n.october;
      case 11: return l10n.november;
      case 12: return l10n.december;
      default: return '';
    }
  }

  String _getWeekdayFull(DateTime date, AppLocalizations l10n) {
    switch (date.weekday) {
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      case 7: return l10n.sunday;
      default: return '';
    }
  }

  Color _getHeatmapColor(double progress) {
    if (progress == 0) return Colors.grey.shade200;
    if (progress < 50) return Colors.red.shade200;
    if (progress < 80) return Colors.orange.shade300;
    if (progress < 100) return Colors.blue.shade400;
    return Colors.green.shade500;
  }

  int _alcoholLevel(double sd) {
    if (sd <= 0) return 0;
    return sd > 2 ? 2 : 1;
  }

  Widget _alcoholGlyph(int count, {required Color color, double size = 14}) {
    final icon = Icons.local_bar;
    if (count <= 1) {
      return Icon(icon, size: size, color: color);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 1),
        Icon(icon, size: size, color: color),
      ],
    );
  }
}