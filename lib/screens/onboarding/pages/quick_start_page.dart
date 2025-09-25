// lib/screens/onboarding/pages/quick_start_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class QuickStartPage extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final VoidCallback? onBack;

  const QuickStartPage({
    super.key,
    required this.onComplete,
    required this.onSkip,
    this.onBack,
  });

  @override
  State<QuickStartPage> createState() => _QuickStartPageState();
}

class _QuickStartPageState extends State<QuickStartPage> {
  final _searchController = TextEditingController();
  int _currentStep = 0;
  String? _selectedFood;
  double _selectedPortion = 100;
  bool _isSearching = false;
  int _addedCalories = 0;

  final List<FoodItem> _popularBreakfasts = [
    FoodItem(
      name: 'Овсянка на молоке',
      calories: 88,
      protein: 3.2,
      carbs: 14.2,
      fats: 1.9,
      icon: '🥣',
    ),
    FoodItem(
      name: 'Яичница (2 яйца)',
      calories: 196,
      protein: 13.6,
      carbs: 0.6,
      fats: 15.3,
      icon: '🍳',
    ),
    FoodItem(
      name: 'Банан',
      calories: 89,
      protein: 1.1,
      carbs: 22.8,
      fats: 0.3,
      icon: '🍌',
    ),
    FoodItem(
      name: 'Тост с маслом',
      calories: 149,
      protein: 2.7,
      carbs: 13.3,
      fats: 9.8,
      icon: '🍞',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _isSearching = value.isNotEmpty;
    });

    if (value.isNotEmpty) {
      // Симуляция поиска
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && _searchController.text == value) {
          setState(() {
            _isSearching = false;
          });
        }
      });
    }
  }

  void _selectFood(FoodItem food) {
    setState(() {
      _selectedFood = food.name;
      _currentStep = 1;
    });
    HapticFeedback.lightImpact();
  }

  void _confirmPortion() {
    final selectedFoodItem = _popularBreakfasts.firstWhere(
      (food) => food.name == _selectedFood,
    );

    final calories = (selectedFoodItem.calories * (_selectedPortion / 100)).round();

    setState(() {
      _addedCalories = calories;
      _currentStep = 2;
    });

    HapticFeedback.lightImpact();

    // Показываем конфетти анимацию
    _showConfettiAnimation();
  }

  void _showConfettiAnimation() {
    // Анимация конфетти будет показана через 500мс
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Заголовок
              Text(
                'Попробуем добавить завтрак',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              Text(
                'Это займет 30 секунд',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              // Прогресс индикатор
              _buildProgressIndicator(),

              const SizedBox(height: 32),

              // Контент в зависимости от шага
              Expanded(
                child: _buildStepContent(),
              ),

              // Кнопка пропустить
              SafeArea(
                child: TextButton(
                  onPressed: widget.onSkip,
                  child: Text(
                    'Пропустить обучение',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: List.generate(3, (index) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 4,
                decoration: BoxDecoration(
                  color: index <= _currentStep
                      ? const Color(0xFF2EC5FF)
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ).animate(target: index <= _currentStep ? 1 : 0)
                .scaleX(duration: 300.ms),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Шаг ${_currentStep + 1} из 3',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSearchStep();
      case 1:
        return _buildPortionStep();
      case 2:
        return _buildCompleteStep();
      default:
        return _buildSearchStep();
    }
  }

  Widget _buildSearchStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Шаг 1: Поиск продукта',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 16),

        // Поле поиска
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Например: овсянка',
            prefixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2EC5FF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          onChanged: _onSearchChanged,
        ).animate().slideY(begin: 0.2, delay: 400.ms).fadeIn(delay: 400.ms),

        const SizedBox(height: 24),

        Text(
          'Популярные завтраки:',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 16),

        // Список популярных завтраков
        Expanded(
          child: ListView.builder(
            itemCount: _popularBreakfasts.length,
            itemBuilder: (context, index) {
              final food = _popularBreakfasts[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => _selectFood(food),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Center(
                            child: Text(
                              food.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${food.calories} ккал на 100г',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
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
                  ),
                ),
              ).animate()
                .slideX(begin: 0.3, delay: (600 + index * 100).ms)
                .fadeIn(delay: (600 + index * 100).ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPortionStep() {
    final selectedFoodItem = _popularBreakfasts.firstWhere(
      (food) => food.name == _selectedFood,
    );

    final calories = (selectedFoodItem.calories * (_selectedPortion / 100)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Шаг 2: Выберите порцию',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Выбранный продукт
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF2EC5FF).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Text(
                selectedFoodItem.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  selectedFoodItem.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: -0.2, delay: 200.ms).fadeIn(delay: 200.ms),

        const SizedBox(height: 32),

        // Слайдер количества
        Text(
          'Количество: ${_selectedPortion.round()}г',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 16),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF2EC5FF),
            inactiveTrackColor: const Color(0xFF2EC5FF).withValues(alpha: 0.2),
            thumbColor: const Color(0xFF2EC5FF),
            overlayColor: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 8,
          ),
          child: Slider(
            value: _selectedPortion,
            min: 50,
            max: 300,
            divisions: 25,
            onChanged: (value) {
              setState(() {
                _selectedPortion = value;
              });
              HapticFeedback.selectionClick();
            },
          ),
        ).animate().slideY(begin: 0.2, delay: 400.ms).fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        // Информация о калориях
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Калории:',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$calories ккал',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2EC5FF),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: 0.2, delay: 500.ms).fadeIn(delay: 500.ms),

        const Spacer(),

        // Кнопка подтверждения
        ElevatedButton(
          onPressed: _confirmPortion,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EC5FF),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Добавить в дневник',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().slideY(begin: 0.3, delay: 600.ms).fadeIn(delay: 600.ms),

        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCompleteStep() {
    return Column(
      children: [
        const Spacer(),

        // Анимация успеха
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFF27AE60).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Color(0xFF27AE60),
            size: 80,
          ),
        ).animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .then()
          .shimmer(duration: 1000.ms, color: const Color(0xFF27AE60).withValues(alpha: 0.3)),

        const SizedBox(height: 24),

        Text(
          'Отлично!',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF27AE60),
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 12),

        Text(
          'Вы добавили $_addedCalories ккал',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 16),

        Text(
          'Теперь вы знаете, как отслеживать питание.\nТак же легко можно добавить обед, ужин и перекусы!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.4,
          ),
        ).animate().fadeIn(delay: 500.ms),

        const Spacer(),

        ElevatedButton(
          onPressed: widget.onComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2EC5FF),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Перейти в приложение',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ).animate().slideY(begin: 0.3, delay: 700.ms).fadeIn(delay: 700.ms),

        const SizedBox(height: 20),
      ],
    );
  }
}

class FoodItem {
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final String icon;

  FoodItem({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.icon,
  });
}