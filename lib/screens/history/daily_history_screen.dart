// lib/screens/history/daily_history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../services/history_service.dart';
import '../../services/hri_service.dart';
import '../../services/alcohol_service.dart';
import '../../services/units_service.dart';
import '../../services/feature_gate_service.dart';
import '../../services/remote_config_service.dart';
import '../../models/intake.dart';
import '../../models/alcohol_intake.dart';
import '../../models/food_intake.dart';

class DailyHistoryScreen extends StatefulWidget {
  const DailyHistoryScreen({super.key});

  @override
  State<DailyHistoryScreen> createState() => _DailyHistoryScreenState();
}

class _DailyHistoryScreenState extends State<DailyHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'all';
  bool _isLoading = false;

  // Данные текущего дня
  List<Intake> _intakes = [];
  List<AlcoholIntake> _alcoholIntakes = [];
  List<FoodIntake> _foodIntakes = [];
  List<Map<String, dynamic>> _caffeineIntakes = [];
  List<Workout> _workouts = [];
  Map<String, dynamic> _daySummary = {};

  // Сервисы
  late final HistoryService _historyService;
  late final UnitsService _unitsService;
  late final FeatureGateService _featureGateService;

 @override
  void initState() {
    super.initState();
    
    // Инициализация сервисов
    _historyService = HistoryService();
    _unitsService = UnitsService.instance;
    _featureGateService = FeatureGateService.instance;
    
    // Загрузка начальных данных
    _loadDayData();
    
    // Подписка на изменения провайдера
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = Provider.of<HydrationProvider>(context, listen: false);
        provider.addListener(_onProviderChanged);
      }
    });
  }
  
   void _onProviderChanged() {
    if (_isToday() && mounted) {
      print('Provider changed, reloading today data');
      _loadDayData();
    }
  }
  
  @override
  void dispose() {
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    provider.removeListener(_onProviderChanged);
    super.dispose();
  }

 Future<void> _loadDayData() async {
    if (_isLoading) return;
    
    print('=== LOADING DAY DATA ===');
    print('Date: $_selectedDate');
    print('Is today: ${_isToday()}');
    
    setState(() => _isLoading = true);

    try {
      if (_isToday()) {
        // Для сегодняшнего дня берем данные из провайдера
        final provider = Provider.of<HydrationProvider>(context, listen: false);
        final alcoholService = Provider.of<AlcoholService>(context, listen: false);
        final hriService = Provider.of<HRIService>(context, listen: false);
        
        setState(() {
          _intakes = provider.todayIntakes;
          _alcoholIntakes = alcoholService.todayIntakes;
          _foodIntakes = provider.todayFoodIntakes;
          _caffeineIntakes = hriService.todayCaffeineIntakes.map((c) => {
            'timestamp': c.timestamp.millisecondsSinceEpoch,
            'amount': c.caffeineMg,
            'source': c.source,
          }).toList();
          _workouts = hriService.todayWorkouts;
          _daySummary = {}; // Для сегодня не нужно
          _isLoading = false;
        });
        
        print('Today data from providers:');
        print('Intakes: ${_intakes.length}');
        print('Caffeine: ${_caffeineIntakes.length}');
      } else {
        // Для прошлых дней загружаем из истории
        final results = await Future.wait([
          _historyService.getIntakesForDate(_selectedDate),
          _historyService.getAlcoholForDate(_selectedDate),
          _historyService.getFoodForDate(_selectedDate),
          _historyService.getCaffeineForDate(_selectedDate),
          _historyService.getWorkoutsForDate(_selectedDate),
          _historyService.getDaySummary(_selectedDate),
        ]);
        
        print('Historical data loaded:');
        print('Intakes: ${(results[0] as List).length}');
        
        if (mounted) {
          setState(() {
            _intakes = results[0] as List<Intake>;
            _alcoholIntakes = results[1] as List<AlcoholIntake>;
            _foodIntakes = results[2] as List<FoodIntake>;
            _caffeineIntakes = results[3] as List<Map<String, dynamic>>;
            _workouts = results[4] as List<Workout>;
            _daySummary = results[5] as Map<String, dynamic>;
            _isLoading = false;
          });
        }
      }
      print('========================');
    } catch (e) {
      print('ERROR loading day data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to load day data: $e');
      }
    }
  }

  void _changeDate(DateTime newDate) {
    if (newDate.isAfter(DateTime.now())) return;
    
    final yearAgo = DateTime.now().subtract(const Duration(days: 365));
    if (newDate.isBefore(yearAgo)) return;
    
    if (_isSameDay(newDate, _selectedDate)) return;

    setState(() => _selectedDate = newDate);
    _loadDayData();
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  bool _canGoForward() {
    final now = DateTime.now();
    return !_isSameDay(_selectedDate, now);
  }

  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showUndoSnackBar(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: AppLocalizations.of(context).undo,
          textColor: Colors.white,
          onPressed: onUndo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer4<HydrationProvider, HRIService, AlcoholService, UnitsService>(
      builder: (context, hydrationProvider, hriService, alcoholService, unitsService, child) {
        return Scaffold(
          // Полностью убираем AppBar
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDateSelector(l10n),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (!_isLoading) ...[
                    _buildDayOverviewCard(l10n, hydrationProvider, hriService, alcoholService),
                    const SizedBox(height: 20),
                    _buildFilters(l10n, alcoholService),
                    const SizedBox(height: 20),
                    _buildEventsList(l10n, hydrationProvider, alcoholService),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(AppLocalizations l10n) {
    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final newDate = _selectedDate.subtract(const Duration(days: 1));
              final yearAgo = DateTime.now().subtract(const Duration(days: 365));
              if (newDate.isAfter(yearAgo)) {
                HapticFeedback.lightImpact();
                _changeDate(newDate);
              }
            },
          ),

          GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                locale: Localizations.localeOf(context),
              );
              if (picked != null) {
                _changeDate(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(_selectedDate, l10n),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _canGoForward() ? () {
              HapticFeedback.lightImpact();
              _changeDate(_selectedDate.add(const Duration(days: 1)));
            } : null,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildDayOverviewCard(AppLocalizations l10n, HydrationProvider provider, 
                              HRIService hriService, AlcoholService alcoholService) {
    // Получение данных в зависимости от дня
    int waterCurrent = 0;
    int waterGoal = 2000;
    double waterPercent = 0.0;
    String hydrationStatus = l10n.noDataForDay;
    double hri = 0.0;
    String hriStatus = '--';
    int totalEvents = 0;
    int workoutCount = 0;
    double alcoholSD = 0.0;
    int workoutMinutes = 0;
    bool hasAlcohol = false;
    bool hasWorkouts = false;

      if (_isToday()) {
      // Данные текущего дня - используем динамические цели с корректировками
      waterCurrent = provider.totalWaterToday.round();
      waterGoal = provider.goals.waterOpt; // С учетом погоды/тренировок/алкоголя
      waterPercent = waterGoal > 0 ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) : 0.0;
      hydrationStatus = provider.getHydrationStatus(l10n);
      hri = hriService.currentHRI;
      hriStatus = hriService.hriStatus;
      totalEvents = provider.todayIntakes.length;
      workoutCount = hriService.todayWorkouts.length;
      alcoholSD = hriService.todayAlcoholSD;
      workoutMinutes = hriService.todayWorkouts.fold(0, (sum, w) => sum + w.durationMinutes);
      hasAlcohol = alcoholSD > 0;
      hasWorkouts = workoutCount > 0;
    } else {
      // Исторические данные - используем базовую цель без корректировок
      if (_daySummary.isNotEmpty) {
        waterCurrent = _daySummary['water'] ?? 0;
        
        // ИСПРАВЛЕНО: базовая цель только от веса, без сегодняшних корректировок
        final remoteConfig = RemoteConfigService.instance;
        waterGoal = (remoteConfig.waterOptPerKg * provider.weight).round();
        
        waterPercent = waterGoal > 0 ? (waterCurrent / waterGoal * 100).clamp(0.0, 200.0) : 0.0;
        
        if (_daySummary['hri'] != null) {
          hri = _daySummary['hri'];
          hriStatus = _daySummary['hriStatus'] ?? '--';
          
          if (waterPercent >= 80) {
            hydrationStatus = l10n.hydrationStatusNormal;
          } else if (waterPercent >= 50) {
            hydrationStatus = l10n.hydrationStatusDehydrated;
          } else {
            hydrationStatus = l10n.hydrationStatusLowSalt;
          }
        } else {
          hri = 0.0;
          hriStatus = '--';
          hydrationStatus = l10n.noDataForDay;
        }
        
        totalEvents = _daySummary['intakeEvents'] ?? 0;
        workoutCount = _daySummary['workoutCount'] ?? 0;
        alcoholSD = _daySummary['alcoholSD'] ?? 0.0;
        workoutMinutes = _daySummary['workoutMinutes'] ?? 0;
        hasAlcohol = _daySummary['hasAlcohol'] ?? false;
        hasWorkouts = _daySummary['hasWorkouts'] ?? false;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: Colors.blue.shade700, size: 24),
              const SizedBox(width: 8),
              Text(
                l10n.dayOverview,
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Прогресс воды
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        l10n.water,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${waterPercent.round()}%',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              
              // Прогресс-бар
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (waterPercent / 100).clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getProgressColor(waterPercent),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              
              Text(
                '${_unitsService.formatVolume(waterCurrent)} / ${_unitsService.formatVolume(waterGoal)}',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Статус гидратации и HRI
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getHRIColor(hri.round()),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    hri > 0 ? hri.round().toString() : '--',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hydrationStatus,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hri > 0) 
                      Text(
                        'HRI: $hriStatus',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Счетчик событий и дополнительные индикаторы
          _buildEventCounters(l10n, totalEvents, workoutCount, alcoholSD, workoutMinutes, 
                             hasAlcohol, hasWorkouts, alcoholService),
        ],
      ),
    ).animate().slideY(delay: 100.ms);
  }

  Widget _buildEventCounters(AppLocalizations l10n, int totalEvents, int workoutCount, 
                           double alcoholSD, int workoutMinutes, bool hasAlcohol, 
                           bool hasWorkouts, AlcoholService alcoholService) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Основные события
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.list_alt, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                _buildEventsCountText(l10n, totalEvents, workoutCount),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // Индикатор алкоголя
        if (hasAlcohol && !alcoholService.soberModeEnabled)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_bar, color: Colors.orange.shade700, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${alcoholSD.toStringAsFixed(1)} SD',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        
        // Индикатор спорта
        if (hasWorkouts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, color: Colors.green.shade700, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${workoutMinutes}m',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _buildEventsCountText(AppLocalizations l10n, int totalEvents, int workoutCount) {
    if (totalEvents == 0 && workoutCount == 0) {
      return l10n.noRecordsThisDay;
    }
    
    List<String> parts = [];
    
    if (totalEvents > 0) {
      parts.add('$totalEvents records');
    }
    
    if (workoutCount > 0) {
      parts.add('$workoutCount workouts');
    }
    
    return parts.join(' • ');
  }

  Widget _buildFilters(AppLocalizations l10n, AlcoholService alcoholService) {
    final filters = [
      {'key': 'all', 'label': l10n.all, 'icon': Icons.list},
      {'key': 'water', 'label': l10n.water, 'icon': Icons.water_drop},
      {'key': 'electrolyte', 'label': l10n.electrolyte, 'icon': Icons.bolt},
      {'key': 'coffee', 'label': l10n.coffee, 'icon': Icons.coffee},
    ];
    
    if (_foodIntakes.isNotEmpty) {
      filters.add({'key': 'food', 'label': l10n.food, 'icon': Icons.restaurant});
    }

    if (_workouts.isNotEmpty) {
      filters.add({'key': 'workout', 'label': l10n.todaysWorkouts, 'icon': Icons.fitness_center});
    }

    if (_alcoholIntakes.isNotEmpty && !alcoholService.soberModeEnabled) {
      filters.add({'key': 'alcohol', 'label': l10n.alcohol, 'icon': Icons.local_bar});
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: _buildFilterChip(
            filter['label'] as String, 
            filter['key'] as String, 
            filter['icon'] as IconData,
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, IconData icon) {
    final isSelected = _selectedFilter == value;
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedFilter = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.blue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(AppLocalizations l10n, HydrationProvider provider, 
                         AlcoholService alcoholService) {
    final filteredEvents = _getFilteredEvents(alcoholService);
    
    if (filteredEvents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                _getEmptyStateIcon(),
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                _getEmptyStateMessage(l10n),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: filteredEvents.length,
        separatorBuilder: (context, index) => Divider(
          color: Colors.grey.shade200,
          height: 1,
          indent: 16,
          endIndent: 16,
        ),
        itemBuilder: (context, index) {
          final event = filteredEvents[index];
          return _buildEventItem(event, l10n, provider, alcoholService, index);
        },
      ),
    );
  }

  Widget _buildEventItem(Map<String, dynamic> event, AppLocalizations l10n,
                        HydrationProvider provider, AlcoholService alcoholService, int index) {
    final type = event['type'] as String;
    
    Widget content;
    
    switch (type) {
      case 'intake':
        content = _buildIntakeItem(event['data'] as Intake, l10n, provider);
        break;
      case 'food':
        content = _buildFoodItem(event['data'] as FoodIntake, l10n);
        break;
      case 'alcohol':
        content = _buildAlcoholItem(event['data'] as AlcoholIntake, l10n, alcoholService);
        break;
      case 'caffeine':
        content = _buildCaffeineItem(event['data'] as Map<String, dynamic>, l10n);
        break;
      case 'workout':
        content = _buildWorkoutItem(event['data'] as Workout, l10n);
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return content.animate().fadeIn(delay: Duration(milliseconds: 50 * index.clamp(0, 10)));
  }

  Widget _buildIntakeItem(Intake intake, AppLocalizations l10n, HydrationProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getIntakeTypeColor(intake.type).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: intake.emoji != null
                ? Text(
                    intake.emoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : Icon(
                    _getIntakeTypeIcon(intake.type),
                    color: _getIntakeTypeColor(intake.type),
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intake.name ?? _getIntakeTypeName(intake.type, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _unitsService.formatVolume(intake.volume),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (intake.totalElectrolytes > 0) 
                  Text(
                    'Na: ${intake.sodium}${l10n.mg}, K: ${intake.potassium}${l10n.mg}, Mg: ${intake.magnesium}${l10n.mg}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                intake.formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (_isToday()) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteIntake(intake, provider, l10n),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlcoholItem(AlcoholIntake intake, AppLocalizations l10n, AlcoholService alcoholService) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: intake.emoji != null
                ? Text(
                    intake.emoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : Icon(
                    intake.type.icon,
                    color: Colors.orange,
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intake.name ?? intake.type.getLabel(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_unitsService.formatVolume(intake.volumeMl.round())}, ${intake.abv}%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${intake.standardDrinks.toStringAsFixed(1)} SD',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                intake.formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (_isToday()) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  color: Colors.red.shade400,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _deleteAlcohol(intake, alcoholService, l10n),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(FoodIntake food, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: food.emoji != null
                ? Text(
                    food.emoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : const Icon(
                    Icons.restaurant,
                    color: Colors.green,
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.foodName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${food.weight.toStringAsFixed(0)} g',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${food.calories} kcal',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                food.formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCaffeineItem(Map<String, dynamic> intake, AppLocalizations l10n) {
    final timestamp = DateTime.fromMillisecondsSinceEpoch(intake['timestamp']);
    final amount = intake['amount'] as num;
    final source = intake['source'] as String;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.brown.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.coffee,
                color: Colors.brown,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source == 'coffee' ? l10n.coffee : l10n.caffeine,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${amount.toStringAsFixed(0)} ${l10n.mg} ${l10n.caffeine}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('HH:mm').format(timestamp),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              
              // Кнопка удаления для кофеина пока не реализована
              if (_isToday())
                const SizedBox(height: 48), // Пустое место вместо кнопки для выравнивания
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutItem(Workout workout, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: workout.emoji != null
                ? Text(
                    workout.emoji!,
                    style: const TextStyle(fontSize: 24),
                  )
                : const Icon(
                    Icons.fitness_center,
                    color: Colors.green,
                    size: 24,
                  ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name ?? _getWorkoutTypeName(workout.type, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${workout.durationMinutes} ${l10n.minutes}, ${l10n.intensity} ${workout.intensity}/5',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                if (workout.waterLossMl > 0)
                  Text(
                    '-${_unitsService.formatVolume(workout.waterLossMl)} ${l10n.sweatLoss}',
                    style: TextStyle(
                      color: Colors.blue.shade600,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),

          Text(
            DateFormat('HH:mm').format(workout.timestamp),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteIntake(Intake intake, HydrationProvider provider, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordMessage(
          _getIntakeTypeName(intake.type, l10n),
          intake.volume,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final deletedIntake = intake;
      
      provider.removeIntake(intake.id);
      
      setState(() {
        _intakes.removeWhere((i) => i.id == intake.id);
      });

      _showUndoSnackBar(
        l10n.itemDeleted(_getIntakeTypeName(intake.type, l10n)),
        () {
          provider.addIntake(
            deletedIntake.type,
            deletedIntake.volume,
            sodium: deletedIntake.sodium,
            potassium: deletedIntake.potassium,
            magnesium: deletedIntake.magnesium,
            showAchievement: false,
            source: 'history_undo',
          );
          _loadDayData();
        },
      );
    }
  }

  Future<void> _deleteAlcohol(AlcoholIntake intake, AlcoholService alcoholService, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordMessage(
          intake.type.getLabel(context),
          intake.volumeMl.toInt(),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await alcoholService.removeIntake(intake.id);
      
      setState(() {
        _alcoholIntakes.removeWhere((i) => i.id == intake.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordDeleted),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _deleteFood(FoodIntake food, HydrationProvider provider, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordMessage(
          food.foodName,
          food.weight.toInt(),
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      provider.removeFoodIntake(food.id);

      setState(() {
        _foodIntakes.removeWhere((f) => f.id == food.id);
      });

      _showUndoSnackBar(
        l10n.itemDeleted(food.foodName),
        () {
          provider.addFoodIntake(food);
          _loadDayData();
        },
      );
    }
  }

  Future<void> _deleteWorkout(Workout workout, HRIService hriService, AppLocalizations l10n) async {
    HapticFeedback.mediumImpact();

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecord),
        content: Text(l10n.deleteRecordMessage(
          workout.name ?? _getWorkoutTypeName(workout.type, l10n),
          workout.durationMinutes,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await hriService.removeWorkout(workout.id);

      setState(() {
        _workouts.removeWhere((w) => w.id == workout.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.recordDeleted),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  List<Map<String, dynamic>> _getFilteredEvents(AlcoholService alcoholService) {
    List<Map<String, dynamic>> events = [];

    if (_selectedFilter == 'all' || _selectedFilter != 'alcohol' && _selectedFilter != 'workout') {
      for (final intake in _intakes) {
        if (_selectedFilter == 'all' || intake.type == _selectedFilter) {
          events.add({
            'type': 'intake',
            'timestamp': intake.timestamp,
            'data': intake,
          });
        }
      }
    }

    // Add food intakes
    if (_selectedFilter == 'all' || _selectedFilter == 'food') {
      for (final food in _foodIntakes) {
        events.add({
          'type': 'food',
          'timestamp': food.timestamp,
          'data': food,
        });
      }
    }

    if (!alcoholService.soberModeEnabled && (_selectedFilter == 'all' || _selectedFilter == 'alcohol')) {
      for (final alcohol in _alcoholIntakes) {
        events.add({
          'type': 'alcohol',
          'timestamp': alcohol.timestamp,
          'data': alcohol,
        });
      }
    }

    if (_selectedFilter == 'all' || _selectedFilter == 'workout') {
      for (final workout in _workouts) {
        events.add({
          'type': 'workout',
          'timestamp': workout.timestamp,
          'data': workout,
        });
      }
    }

    events.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    
    return events;
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    
    if (_isSameDay(date, now)) {
      return l10n.today;
    } else if (_isSameDay(date, yesterday)) {
      return l10n.yesterday;
    }
    
    final locale = Localizations.localeOf(context).toString();
    final formatter = DateFormat.MMMMd(locale);
    return formatter.format(date);
  }

  Color _getProgressColor(double percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getHRIColor(int hri) {
    if (hri <= 30) return Colors.green;
    if (hri <= 60) return Colors.orange;
    return Colors.red;
  }

  Color _getIntakeTypeColor(String type) {
  switch (type) {
    case 'water': 
      return Colors.blue;
    case 'electrolyte': 
      return Colors.orange;
    case 'broth': 
      return Colors.amber;
    case 'coffee': 
      return Colors.brown;
    case 'supplement':
    case 'supplement_minerals':
    case 'supplement_vitamins':
    case 'supplement_other':
      return Colors.purple;
    case 'vitamin':
      return Colors.green;
    default:
      if (type.startsWith('supplement_')) {
        return Colors.purple;
      }
      return Colors.grey;
  }
}

  IconData _getIntakeTypeIcon(String type) {
  switch (type) {
    case 'water': 
      return Icons.water_drop;
    case 'electrolyte': 
      return Icons.bolt;
    case 'broth': 
      return Icons.soup_kitchen;
    case 'coffee': 
      return Icons.coffee;
    case 'supplement':
    case 'supplement_minerals':
    case 'supplement_vitamins':
    case 'supplement_other':
      return Icons.medication;
    case 'vitamin':
      return Icons.medication_liquid;
    default:
      if (type.startsWith('supplement_')) {
        return Icons.medication;
      }
      return Icons.local_drink;
  }
}

  String _getIntakeTypeName(String type, AppLocalizations l10n) {
  switch (type) {
    case 'water': 
      return l10n.water;
    case 'electrolyte': 
      return l10n.electrolyte;
    case 'broth': 
      return l10n.broth;
    case 'coffee': 
      return l10n.coffee;
    case 'supplement':
    case 'supplement_minerals':
    case 'supplement_vitamins':
    case 'supplement_other':
      return l10n.supplements;
    case 'vitamin':
      return l10n.vitamins;
    default:
      if (type.startsWith('supplement_')) {
        return l10n.supplements;
      }
      return l10n.drink;
  }
}

  String _getWorkoutTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'cardio': return 'Cardio';
      case 'strength': return 'Strength';
      case 'yoga': return 'Yoga';
      case 'running': return l10n.running;
      case 'cycling': return l10n.cycling;
      case 'sauna': return l10n.sauna;
      default: return 'Workout';
    }
  }

  IconData _getEmptyStateIcon() {
    switch (_selectedFilter) {
      case 'water': return Icons.water_drop_outlined;
      case 'electrolyte': return Icons.bolt;
      case 'coffee': return Icons.coffee_outlined;
      case 'food': return Icons.restaurant_outlined;
      case 'alcohol': return Icons.local_bar_outlined;
      case 'workout': return Icons.fitness_center_outlined;
      default: return Icons.history_outlined;
    }
  }

  String _getEmptyStateMessage(AppLocalizations l10n) {
    if (_isToday()) {
      switch (_selectedFilter) {
        case 'water': return l10n.noRecordsToday;
        case 'electrolyte': return l10n.noRecordsToday;
        case 'coffee': return l10n.noRecordsToday;
        case 'food': return l10n.noRecordsToday;
        case 'alcohol': return l10n.noAlcoholToday;
        case 'workout': return l10n.noRecordsToday;
        default: return l10n.noRecordsToday;
      }
    } else {
      switch (_selectedFilter) {
        case 'water': return l10n.noRecordsThisDay;
        case 'electrolyte': return l10n.noRecordsThisDay;
        case 'coffee': return l10n.noRecordsThisDay;
        case 'food': return l10n.noRecordsThisDay;
        case 'alcohol': return l10n.noRecordsThisDay;
        case 'workout': return l10n.noRecordsThisDay;
        default: return l10n.noRecordsThisDay;
      }
    }
  }
}