// lib/screens/onboarding/pages/body_parameters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BodyParametersPage extends StatefulWidget {
  final String? gender;
  final int? age;
  final double? height;
  final double? currentWeight;
  final double? targetWeight;
  final String goal;
  final Function(String) onGenderChanged;
  final Function(int) onAgeChanged;
  final Function(double) onHeightChanged;
  final Function(double) onCurrentWeightChanged;
  final Function(double) onTargetWeightChanged;
  final VoidCallback onNext;
  final VoidCallback? onBack;

  const BodyParametersPage({
    super.key,
    this.gender,
    this.age,
    this.height,
    this.currentWeight,
    this.targetWeight,
    required this.goal,
    required this.onGenderChanged,
    required this.onAgeChanged,
    required this.onHeightChanged,
    required this.onCurrentWeightChanged,
    required this.onTargetWeightChanged,
    required this.onNext,
    this.onBack,
  });

  @override
  State<BodyParametersPage> createState() => _BodyParametersPageState();
}

class _BodyParametersPageState extends State<BodyParametersPage> {
  late TextEditingController _ageController;
  late TextEditingController _heightController;
  late TextEditingController _currentWeightController;
  late TextEditingController _targetWeightController;

  String? _selectedGender;
  bool _isMetric = true; // true для см/кг, false для футы/фунты

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender;

    _ageController = TextEditingController(
      text: widget.age?.toString() ?? '',
    );
    _heightController = TextEditingController(
      text: widget.height?.toString() ?? '',
    );
    _currentWeightController = TextEditingController(
      text: widget.currentWeight?.toString() ?? '',
    );
    _targetWeightController = TextEditingController(
      text: widget.targetWeight?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _currentWeightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedGender != null &&
        _ageController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _currentWeightController.text.isNotEmpty &&
        (_shouldShowTargetWeight ? _targetWeightController.text.isNotEmpty : true);
  }

  bool get _shouldShowTargetWeight {
    return widget.goal == 'lose_weight' || widget.goal == 'gain_muscle';
  }

  void _updateGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderChanged(gender);
    HapticFeedback.lightImpact();
  }

  void _toggleUnits() {
    setState(() {
      _isMetric = !_isMetric;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
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
                'Расскажите о себе',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 8),

              Text(
                'Для точного расчета калорий',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.3,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 32),

              // Пол
              _buildGenderSelector(),

              const SizedBox(height: 24),

              // Возраст
              _buildAgeField(),

              const SizedBox(height: 24),

              // Рост
              _buildHeightField(),

              const SizedBox(height: 24),

              // Текущий вес
              _buildCurrentWeightField(),

              // Целевой вес (если нужен)
              if (_shouldShowTargetWeight) ...[
                const SizedBox(height: 24),
                _buildTargetWeightField(),
              ],

              const SizedBox(height: 40),

              // Кнопка "Далее"
              ElevatedButton(
                onPressed: _isFormValid ? widget.onNext : null,
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
                child: const Text(
                  'Далее',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Пол',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _updateGender('male'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'male'
                        ? const Color(0xFF2EC5FF).withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'male'
                          ? const Color(0xFF2EC5FF)
                          : Colors.grey[300]!,
                      width: _selectedGender == 'male' ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Мужской',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == 'male'
                            ? const Color(0xFF2EC5FF)
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _updateGender('female'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'female'
                        ? const Color(0xFF2EC5FF).withValues(alpha: 0.1)
                        : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedGender == 'female'
                          ? const Color(0xFF2EC5FF)
                          : Colors.grey[300]!,
                      width: _selectedGender == 'female' ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Женский',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _selectedGender == 'female'
                            ? const Color(0xFF2EC5FF)
                            : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 300.ms).fadeIn(delay: 300.ms);
  }

  Widget _buildAgeField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Возраст',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _ageController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: InputDecoration(
            hintText: 'Полных лет',
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
          onChanged: (value) {
            final age = int.tryParse(value);
            if (age != null && age >= 14 && age <= 100) {
              widget.onAgeChanged(age);
            }
          },
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 400.ms).fadeIn(delay: 400.ms);
  }

  Widget _buildHeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Рост',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: _toggleUnits,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _isMetric ? 'см' : 'ft',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _heightController,
          keyboardType: TextInputType.numberWithOptions(decimal: !_isMetric),
          decoration: InputDecoration(
            hintText: _isMetric ? '170' : '5\'7"',
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
          onChanged: (value) {
            final height = double.tryParse(value);
            if (height != null) {
              widget.onHeightChanged(height);
            }
          },
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 500.ms).fadeIn(delay: 500.ms);
  }

  Widget _buildCurrentWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Текущий вес',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _isMetric ? 'кг' : 'lb',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _currentWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: _isMetric ? '70' : '154',
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
          onChanged: (value) {
            final weight = double.tryParse(value);
            if (weight != null) {
              widget.onCurrentWeightChanged(weight);
            }
          },
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 600.ms).fadeIn(delay: 600.ms);
  }

  Widget _buildTargetWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Целевой вес',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _isMetric ? 'кг' : 'lb',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _targetWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: _isMetric ? '65' : '143',
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
          onChanged: (value) {
            final weight = double.tryParse(value);
            if (weight != null) {
              widget.onTargetWeightChanged(weight);
            }
          },
        ),
      ],
    ).animate().slideX(begin: -0.2, delay: 700.ms).fadeIn(delay: 700.ms);
  }
}