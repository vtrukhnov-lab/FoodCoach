import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../services/alcohol_service.dart';
import '../../services/history_service.dart';
import '../../services/remote_config_service.dart';
import '../../services/units_service.dart';
import '../../services/hri_service.dart';

// Класс для хранения данных за день
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
  final int foodCount;
  final int totalCalories;
  final double totalFoodSugar;
  final double totalFoodWater;
  final bool hasFood;

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
    this.foodCount = 0,
    this.totalCalories = 0,
    this.totalFoodSugar = 0.0,
    this.totalFoodWater = 0.0,
    this.hasFood = false,
  });
}

class WeeklyHistoryScreen extends StatefulWidget {
  const WeeklyHistoryScreen({super.key});

  @override
  State<WeeklyHistoryScreen> createState() => _WeeklyHistoryScreenState();
}

class _WeeklyHistoryScreenState extends State<WeeklyHistoryScreen> {
  Map<String, DailyData> weeklyData = {};
  bool isLoadingWeekData = false;
  
  late final HistoryService _historyService;
  late final RemoteConfigService _remoteConfig;
  late final UnitsService _unitsService;

  @override
  void initState() {
    super.initState();
    _historyService = HistoryService();
    _remoteConfig = RemoteConfigService.instance;
    _unitsService = UnitsService.instance;
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    if (isLoadingWeekData) return;

    setState(() => isLoadingWeekData = true);

    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final Map<String, DailyData> tempData = {};

      // Получаем понедельник текущей недели
      final now = DateTime.now();
      final monday = now.subtract(Duration(days: now.weekday - 1));
      
      // Загружаем данные за 7 дней начиная с понедельника
      for (int i = 0; i < 7; i++) {
        final date = monday.add(Duration(days: i));
        final dateKey = date.toIso8601String().split('T')[0];
        final isToday = _isSameDay(date, DateTime.now());
        final isFuture = date.isAfter(DateTime.now());
        
        // Пропускаем будущие дни
        if (isFuture && !isToday) continue;

        int waterGoal;
        if (isToday) {
          waterGoal = provider.goals.waterOpt;
        } else {
          waterGoal = (_remoteConfig.waterOptPerKg * provider.weight).round();
        }

        if (isToday) {
          // Данные текущего дня из provider
          final waterCurrent = provider.totalWaterToday.round();
          final waterPercent = waterGoal > 0 
              ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) 
              : 0.0;

          final hriService = Provider.of<HRIService>(context, listen: false);
          final workoutMinutes = hriService.todayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
          
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
            workoutCount: hriService.todayWorkouts.length,
            hasWorkouts: hriService.todayWorkouts.isNotEmpty,
            waterGoal: waterGoal,
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
            final waterCurrent = daySummary['water'] ?? 0;
            final waterPercent = waterGoal > 0 
                ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) 
                : 0.0;

            tempData[dateKey] = DailyData(
              date: date,
              water: waterCurrent,
              sodium: daySummary['sodium'] ?? 0,
              potassium: daySummary['potassium'] ?? 0,
              magnesium: daySummary['magnesium'] ?? 0,
              waterPercent: waterPercent,
              coffeeCount: daySummary['coffeeCount'] ?? 0,
              intakeCount: daySummary['intakeEvents'] ?? 0,
              alcoholSD: daySummary['alcoholSD'] ?? 0.0,
              workoutMinutes: daySummary['workoutMinutes'] ?? 0,
              workoutCount: daySummary['workoutCount'] ?? 0,
              hasWorkouts: daySummary['hasWorkouts'] ?? false,
              waterGoal: waterGoal,
              foodCount: daySummary['foodCount'] ?? 0,
              totalCalories: daySummary['totalCalories'] ?? 0,
              totalFoodSugar: daySummary['totalFoodSugar'] ?? 0.0,
              totalFoodWater: daySummary['totalFoodWater'] ?? 0.0,
              hasFood: daySummary['hasFood'] ?? false,
            );
          }
        }
      }

      if (mounted) {
        setState(() {
          weeklyData = tempData;
          isLoadingWeekData = false;
        });
      }
    } catch (e) {
      print('Error loading weekly data: $e');
      if (mounted) {
        setState(() => isLoadingWeekData = false);
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Сортировка данных начиная с понедельника и обеспечение 7 дней
  List<DailyData> _getSortedWeekData() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));

    final List<DailyData> result = [];

    // Создаем ровно 7 дней с понедельника по воскресенье
    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));
      final dateKey = date.toIso8601String().split('T')[0];

      if (weeklyData.containsKey(dateKey)) {
        result.add(weeklyData[dateKey]!);
      } else {
        // Создаем пустую запись для дней без данных
        final provider = Provider.of<HydrationProvider>(context, listen: false);
        final waterGoal = (_remoteConfig.waterOptPerKg * provider.weight).round();

        result.add(DailyData(
          date: date,
          water: 0,
          sodium: 0,
          potassium: 0,
          magnesium: 0,
          waterPercent: 0,
          coffeeCount: 0,
          intakeCount: 0,
          alcoholSD: 0,
          workoutMinutes: 0,
          workoutCount: 0,
          hasWorkouts: false,
          waterGoal: waterGoal,
          foodCount: 0,
          totalCalories: 0,
          totalFoodSugar: 0,
          totalFoodWater: 0,
          hasFood: false,
        ));
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (isLoadingWeekData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final alcoholService = Provider.of<AlcoholService>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [              
              // График воды
              _buildWaterChart(l10n).animate().fadeIn(),
              const SizedBox(height: 20),

              // График электролитов
              _buildElectrolytesChart(l10n).animate().fadeIn(delay: 50.ms),
              const SizedBox(height: 20),

              // График еды (если есть данные)
              if (_hasFoodData())
                _buildFoodChart(l10n).animate().fadeIn(delay: 75.ms),

              if (_hasFoodData())
                const SizedBox(height: 20),

              // График тренировок (если есть данные)
              if (_hasWorkoutData())
                _buildWorkoutsChart(l10n).animate().fadeIn(delay: 100.ms),
              
              if (_hasWorkoutData())
                const SizedBox(height: 20),

              // График алкоголя (если есть данные и не sober mode)
              if (!alcoholService.soberModeEnabled && _hasAlcoholData())
                _buildAlcoholChart(l10n).animate().fadeIn(delay: 150.ms),

              if (!alcoholService.soberModeEnabled && _hasAlcoholData())
                const SizedBox(height: 20),

              // Средние показатели
              _buildAverageStats(l10n).animate().slideY(delay: 200.ms),
              const SizedBox(height: 20),

              // Инсайты недели
              _buildWeeklyInsights(l10n).animate().scale(delay: 300.ms),
              
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaterChart(AppLocalizations l10n) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.waterConsumption,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildWaterLineChart(l10n)),
        ],
      ),
    );
  }

  Widget _buildWaterLineChart(AppLocalizations l10n) {
    final List<FlSpot> spots = [];
    final List<String> bottomTitles = [];
    
    final sortedData = _getSortedWeekData();

    for (int i = 0; i < sortedData.length; i++) {
      final d = sortedData[i];
      spots.add(FlSpot(i.toDouble(), d.waterPercent));
      bottomTitles.add(_getWeekdayShort(d.date, l10n));
    }

    if (spots.isEmpty) {
      return Center(child: Text(l10n.noData));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25.0,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.shade200,
            strokeWidth: 1,
            dashArray: value == 100.0 ? [5, 5] : null,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25.0,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < bottomTitles.length) {
                  return Text(
                    bottomTitles[index],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0.0,
        maxX: (spots.length - 1).toDouble(),
        minY: 0.0,
        maxY: 150.0,
        lineBarsData: [
          // Линия цели 100%
          LineChartBarData(
            spots: List.generate(
              spots.length,
              (i) => FlSpot(i.toDouble(), 100.0),
            ),
            isCurved: false,
            color: Colors.green.withValues(alpha: 0.3),
            barWidth: 1,
            isStrokeCapRound: false,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
          // Основная линия
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.blue,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.withValues(alpha: 0.3),
                  Colors.blue.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItems: (touchedBarSpots) {
              return touchedBarSpots
                  .map<LineTooltipItem?>((barSpot) {
                    if (barSpot.barIndex == 1 &&
                        barSpot.x.toInt() < sortedData.length) {
                      final d = sortedData[barSpot.x.toInt()];
                      return LineTooltipItem(
                        '${_unitsService.formatVolume(d.water)}\n${barSpot.y.toStringAsFixed(0)}%\nЦель: ${_unitsService.formatVolume(d.waterGoal)}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }
                    return null;
                  })
                  .whereType<LineTooltipItem>()
                  .toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildElectrolytesChart(AppLocalizations l10n) {
    return Container(
      height: 320,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.electrolytes,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildElectrolytesBarChart(l10n)),
          const SizedBox(height: 12),
          // Цветовая легенда электролитов
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildElectrolyteLegendItem('Na', Colors.orange, l10n.sodium),
              const SizedBox(width: 16),
              _buildElectrolyteLegendItem('K', Colors.purple, l10n.potassium),
              const SizedBox(width: 16),
              _buildElectrolyteLegendItem('Mg', Colors.pink, l10n.magnesium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElectrolytesBarChart(AppLocalizations l10n) {
    final List<BarChartGroupData> barGroups = [];
    final sortedData = _getSortedWeekData();

    final provider = Provider.of<HydrationProvider>(context, listen: false);

    for (int i = 0; i < sortedData.length; i++) {
      final d = sortedData[i];

      final naPct = ((d.sodium / (provider.goals.sodium == 0 ? 1 : provider.goals.sodium)) * 100)
          .clamp(0.0, 150.0).toDouble();

      final kPct = ((d.potassium / (provider.goals.potassium == 0 ? 1 : provider.goals.potassium)) * 100)
          .clamp(0.0, 150.0).toDouble();

      final mgPct = ((d.magnesium / (provider.goals.magnesium == 0 ? 1 : provider.goals.magnesium)) * 100)
          .clamp(0.0, 150.0).toDouble();

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: naPct,
              color: Colors.orange,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: kPct,
              color: Colors.purple,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
            BarChartRodData(
              toY: mgPct,
              color: Colors.pink,
              width: 8,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      );
    }

    if (barGroups.isEmpty) {
      return Center(child: Text(l10n.noData));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 150.0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < sortedData.length) {
                final d = sortedData[groupIndex];
                String label;
                int raw;
                switch (rodIndex) {
                  case 0:
                    label = 'Na';
                    raw = d.sodium;
                    break;
                  case 1:
                    label = 'K';
                    raw = d.potassium;
                    break;
                  case 2:
                    label = 'Mg';
                    raw = d.magnesium;
                    break;
                  default:
                    return null;
                }
                return BarTooltipItem(
                  '$label: $raw ${l10n.mg}\n${rod.toY.toStringAsFixed(0)}%',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25.0,
              getTitlesWidget: (value, meta) => Text(
                '${value.toInt()}%',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sortedData.length) {
                  return Text(
                    _getWeekdayShort(sortedData[idx].date, l10n),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25.0,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
      ),
    );
  }

  Widget _buildElectrolyteLegendItem(String symbol, Color color, String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$symbol ($name)',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildFoodChart(AppLocalizations l10n) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.foodIntake,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildFoodBarChart(l10n)),
        ],
      ),
    );
  }

  Widget _buildFoodBarChart(AppLocalizations l10n) {
    final List<BarChartGroupData> barGroups = [];
    final sortedData = _getSortedWeekData();

    for (int i = 0; i < sortedData.length; i++) {
      final d = sortedData[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: d.totalCalories.toDouble(),
              color: d.totalCalories > 0 ? Colors.green : Colors.grey.shade300,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (!_hasFoodData()) {
      return Center(child: Text(l10n.noFoodThisWeek));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_getMaxCaloriesValue() * 1.2),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < sortedData.length) {
                final d = sortedData[groupIndex];
                if (d.totalCalories > 0) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(0)} kcal\n${d.foodCount} ${l10n.meals}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sortedData.length) {
                  return Text(
                    _getWeekdayShort(sortedData[idx].date, l10n),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
      ),
    );
  }

  Widget _buildWorkoutsChart(AppLocalizations l10n) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.workouts,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildWorkoutsBarChart(l10n)),
        ],
      ),
    );
  }

  Widget _buildWorkoutsBarChart(AppLocalizations l10n) {
    final List<BarChartGroupData> barGroups = [];
    final sortedData = _getSortedWeekData();

    for (int i = 0; i < sortedData.length; i++) {
      final d = sortedData[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: d.workoutMinutes.toDouble(),
              color: d.workoutMinutes > 0 ? Colors.green : Colors.grey.shade300,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (!_hasWorkoutData()) {
      return Center(child: Text(l10n.noWorkoutsThisWeek));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_getMaxWorkoutMinutes() * 1.2),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < sortedData.length) {
                final d = sortedData[groupIndex];
                if (d.workoutMinutes > 0) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(0)} ${l10n.minutes}\n${d.workoutCount} ${l10n.workouts}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)}m',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sortedData.length) {
                  return Text(
                    _getWeekdayShort(sortedData[idx].date, l10n),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
      ),
    );
  }

  Widget _buildAlcoholChart(AppLocalizations l10n) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.alcoholWeek,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: _buildAlcoholBarChart(l10n)),
        ],
      ),
    );
  }

  Widget _buildAlcoholBarChart(AppLocalizations l10n) {
    final List<BarChartGroupData> barGroups = [];
    final sortedData = _getSortedWeekData();

    for (int i = 0; i < sortedData.length; i++) {
      final d = sortedData[i];
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: d.alcoholSD > 0 ? d.alcoholSD : 0,
              color: d.alcoholSD > 2 ? Colors.red.shade400 :
                     d.alcoholSD > 0 ? Colors.orange.shade400 : Colors.grey.shade300,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (!_hasAlcoholData()) {
      return Center(child: Text(l10n.noAlcoholThisWeek));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_getMaxAlcoholValue() * 1.2).clamp(2.0, 10.0),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => Colors.blueGrey.shade800,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < sortedData.length) {
                final d = sortedData[groupIndex];
                if (d.alcoholSD > 0) {
                  return BarTooltipItem(
                    '${rod.toY.toStringAsFixed(1)} SD',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
              }
              return null;
            },
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                '${value.toStringAsFixed(0)} SD',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10),
              ),
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < sortedData.length) {
                  return Text(
                    _getWeekdayShort(sortedData[idx].date, l10n),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
      ),
    );
  }

  Widget _buildAverageStats(AppLocalizations l10n) {
    if (weeklyData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Text(l10n.loadingData),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                l10n.weeklyAverages,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildStatsContent(l10n),
        ],
      ),
    );
  }

  Widget _buildStatsContent(AppLocalizations l10n) {
    final provider = Provider.of<HydrationProvider>(context, listen: false);

    double totalWater = 0;
    double totalSodium = 0;
    double totalPotassium = 0;
    double totalMagnesium = 0;
    int daysWithGoal = 0;
    double totalIntakes = 0;
    int totalWorkoutMinutes = 0;
    int daysWithWorkouts = 0;
    int totalCalories = 0;
    double totalFoodSugar = 0;
    double totalFoodWater = 0;
    int totalFoodCount = 0;
    int daysWithFood = 0;

    for (var d in weeklyData.values) {
      totalWater += d.water;
      totalSodium += d.sodium;
      totalPotassium += d.potassium;
      totalMagnesium += d.magnesium;
      totalIntakes += d.intakeCount;
      totalWorkoutMinutes += d.workoutMinutes;
      totalCalories += d.totalCalories;
      totalFoodSugar += d.totalFoodSugar;
      totalFoodWater += d.totalFoodWater;
      totalFoodCount += d.foodCount;
      if (d.waterPercent >= 90) daysWithGoal++;
      if (d.hasWorkouts) daysWithWorkouts++;
      if (d.hasFood) daysWithFood++;
    }

    final daysCount = weeklyData.isNotEmpty ? weeklyData.length : 1;

    return Column(
      children: [
        _buildStatRow(
          icon: '💧',
          label: l10n.waterPerDay,
          value: _unitsService.formatVolume((totalWater / daysCount).round()),
          target: _unitsService.formatVolume((_remoteConfig.waterOptPerKg * provider.weight).round()),
          color: Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          icon: '⚡',
          label: l10n.sodiumPerDay,
          value: '${(totalSodium / daysCount).round()} ${l10n.mg}',
          target: '${provider.goals.sodium} ${l10n.mg}',
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          icon: '💜',
          label: l10n.potassiumPerDay,
          value: '${(totalPotassium / daysCount).round()} ${l10n.mg}',
          target: '${provider.goals.potassium} ${l10n.mg}',
          color: Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildStatRow(
          icon: '💗',
          label: l10n.magnesiumPerDay,
          value: '${(totalMagnesium / daysCount).round()} ${l10n.mg}',
          target: '${provider.goals.magnesium} ${l10n.mg}',
          color: Colors.pink,
        ),

        if (_hasFoodData()) ...[
          const SizedBox(height: 12),
          _buildStatRow(
            icon: '🍽️',
            label: l10n.caloriesPerDay,
            value: '${(totalCalories / daysCount).round()} kcal',
            target: '$daysWithFood days with food',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatRow(
            icon: '🍯',
            label: l10n.sugarPerDay,
            value: '${(totalFoodSugar / daysCount).toStringAsFixed(1)}g',
            target: '${(totalFoodCount / daysCount).toStringAsFixed(1)} meals/day',
            color: Colors.amber,
          ),
        ],

        if (_hasWorkoutData()) ...[
          const SizedBox(height: 12),
          _buildStatRow(
            icon: '💪',
            label: l10n.workoutMinutesPerDay,
            value: '${(totalWorkoutMinutes / daysCount).round()} ${l10n.minutes}',
            target: '$daysWithWorkouts ${l10n.daysWithWorkouts}',
            color: Colors.green,
          ),
        ],
        
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.daysWithGoalAchieved,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: daysWithGoal >= 5
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$daysWithGoal ${l10n.fromDays(7)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: daysWithGoal >= 5
                      ? Colors.green.shade700
                      : Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.recordsPerDay,
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '≈ ${(totalIntakes / daysCount).round()}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    required String target,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Target',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            Text(
              target,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildWeeklyInsights(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade400, Colors.purple.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
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
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                l10n.weeklyInsights,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._buildInsightsList(l10n),
        ],
      ),
    );
  }

  List<Widget> _buildInsightsList(AppLocalizations l10n) {
    final insights = <Widget>[];

    if (weeklyData.isEmpty) {
      return [
        Text(l10n.insufficientDataForAnalysis,
            style: const TextStyle(color: Colors.white70))
      ];
    }

    final sorted = _getSortedWeekData();

    // Найти лучший день
    DailyData? bestDay;
    for (var d in sorted) {
      if (bestDay == null || d.waterPercent > bestDay.waterPercent) {
        bestDay = d;
      }
    }

    if (bestDay != null) {
      insights.add(_buildInsight(
        '🏆',
        l10n.bestDay,
        l10n.bestDayMessage(_getWeekdayFull(bestDay.date, l10n), bestDay.waterPercent.toInt()),
      ));
    }

    // Анализ выходных vs будни
    final weekend = sorted.where((d) => d.date.weekday == 6 || d.date.weekday == 7);
    final weekdays = sorted.where((d) => d.date.weekday < 6);

    if (weekend.isNotEmpty && weekdays.isNotEmpty) {
      final avgWeekend = weekend.map((d) => d.waterPercent).reduce((a, b) => a + b) / weekend.length;
      final avgWeekdays = weekdays.map((d) => d.waterPercent).reduce((a, b) => a + b) / weekdays.length;

      if ((avgWeekdays - avgWeekend).abs() > 15) {
        if (avgWeekdays > avgWeekend) {
          insights.add(_buildInsight(
            '📅',
            l10n.weekends,
            l10n.drinkLessOnWeekends((avgWeekdays - avgWeekend).toInt()),
          ));
        } else {
          insights.add(_buildInsight(
            '💼',
            l10n.weekdays,
            l10n.drinkLessOnWeekdays((avgWeekend - avgWeekdays).toInt()),
          ));
        }
      }
    }

    // Анализ тренировок
    if (_hasWorkoutData()) {
      final daysWithWorkouts = sorted.where((d) => d.hasWorkouts).toList();
      final daysWithoutWorkouts = sorted.where((d) => !d.hasWorkouts).toList();

      if (daysWithWorkouts.isNotEmpty && daysWithoutWorkouts.isNotEmpty) {
        final avgWithWorkouts = daysWithWorkouts.map((d) => d.waterPercent).reduce((a, b) => a + b) / daysWithWorkouts.length;
        final avgWithoutWorkouts = daysWithoutWorkouts.map((d) => d.waterPercent).reduce((a, b) => a + b) / daysWithoutWorkouts.length;

        if (avgWithWorkouts > avgWithoutWorkouts + 10) {
          insights.add(_buildInsight(
            '💪',
            l10n.workoutHydration,
            l10n.workoutHydrationMessage((avgWithWorkouts - avgWithoutWorkouts).toInt()),
          ));
        }
      }

      final totalWorkoutMinutes = sorted.fold(0, (sum, d) => sum + d.workoutMinutes);
      if (totalWorkoutMinutes > 0) {
        insights.add(_buildInsight(
          '🏃',
          l10n.weeklyActivity,
          l10n.weeklyActivityMessage(totalWorkoutMinutes, sorted.where((d) => d.hasWorkouts).length),
        ));
      }
    }

    // Анализ трендов
    if (sorted.length >= 3) {
      final firstHalf = sorted.take(3).map((d) => d.waterPercent).reduce((a, b) => a + b) / 3;
      final secondHalf = sorted.skip(sorted.length - 3).map((d) => d.waterPercent).reduce((a, b) => a + b) / 3;

      if (secondHalf > firstHalf + 10) {
        insights.add(_buildInsight(
          '📈',
          l10n.positiveTrend,
          l10n.positiveTrendMessage,
        ));
      } else if (firstHalf > secondHalf + 10) {
        insights.add(_buildInsight(
          '📉',
          l10n.decliningActivity,
          l10n.decliningActivityMessage,
        ));
      }
    }

    // Анализ электролитов
    int daysWithGoodSodium = 0;
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    for (var d in sorted) {
      if (d.sodium >= provider.goals.sodium * 0.7) {
        daysWithGoodSodium++;
      }
    }
    if (daysWithGoodSodium < 3) {
      insights.add(_buildInsight(
        '🧂',
        l10n.lowSalt,
        l10n.lowSaltMessage(daysWithGoodSodium),
      ));
    }

    // Анализ алкоголя
    if (_hasAlcoholData()) {
      int daysWithAlcohol = 0;
      for (var d in sorted) {
        if (d.alcoholSD > 0) daysWithAlcohol++;
      }
      if (daysWithAlcohol > 3) {
        insights.add(_buildInsight(
          '🍺',
          l10n.frequentAlcohol,
          l10n.frequentAlcoholMessage(daysWithAlcohol),
        ));
      }
    }

    return insights.isNotEmpty
        ? insights
        : [_buildInsight('✨', l10n.excellentWeek, l10n.continueMessage)];
  }

  Widget _buildInsight(String emoji, String title, String description) {
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
                emoji,
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
                  title,
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

  String _getWeekdayShort(DateTime date, AppLocalizations l10n) {
    // Используем короткие названия из локализации если есть
    switch (date.weekday) {
      case 1: return l10n.mondayShort ?? 'ПН';
      case 2: return l10n.tuesdayShort ?? 'ВТ';
      case 3: return l10n.wednesdayShort ?? 'СР';
      case 4: return l10n.thursdayShort ?? 'ЧТ';
      case 5: return l10n.fridayShort ?? 'ПТ';
      case 6: return l10n.saturdayShort ?? 'СБ';
      case 7: return l10n.sundayShort ?? 'ВС';
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

  bool _hasAlcoholData() => weeklyData.values.any((d) => d.alcoholSD > 0);

  bool _hasWorkoutData() => weeklyData.values.any((d) => d.hasWorkouts);
  bool _hasFoodData() => weeklyData.values.any((d) => d.hasFood);

  double _getMaxCaloriesValue() {
    double maxV = 0;
    for (var d in weeklyData.values) {
      if (d.totalCalories > maxV) maxV = d.totalCalories.toDouble();
    }
    return maxV > 0 ? maxV * 1.1 : 2000;
  }


  double _getMaxAlcoholValue() {
    double maxV = 0;
    for (var d in weeklyData.values) {
      if (d.alcoholSD > maxV) maxV = d.alcoholSD;
    }
    return maxV > 0 ? maxV : 5.0;
  }

  double _getMaxWorkoutMinutes() {
    double maxV = 0;
    for (var d in weeklyData.values) {
      if (d.workoutMinutes > maxV) maxV = d.workoutMinutes.toDouble();
    }
    return maxV > 0 ? maxV : 60.0;
  }
}