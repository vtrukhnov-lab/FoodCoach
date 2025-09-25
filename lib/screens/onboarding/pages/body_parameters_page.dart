// lib/screens/onboarding/pages/body_parameters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';

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
  String? _selectedGender;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  bool get _shouldShowTargetWeight => widget.goal == 'lose_weight' || widget.goal == 'gain_muscle';

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.gender;
    if (widget.age != null) _ageController.text = widget.age.toString();
    if (widget.height != null) _heightController.text = widget.height.toString();
    if (widget.currentWeight != null) _currentWeightController.text = widget.currentWeight.toString();
    if (widget.targetWeight != null) _targetWeightController.text = widget.targetWeight.toString();
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
        (!_shouldShowTargetWeight || _targetWeightController.text.isNotEmpty);
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
    widget.onGenderChanged(gender);
    HapticFeedback.lightImpact();
  }

  void _onTextChanged() {
    setState(() {});

    if (_ageController.text.isNotEmpty) {
      final age = int.tryParse(_ageController.text);
      if (age != null) widget.onAgeChanged(age);
    }

    if (_heightController.text.isNotEmpty) {
      final height = double.tryParse(_heightController.text);
      if (height != null) widget.onHeightChanged(height);
    }

    if (_currentWeightController.text.isNotEmpty) {
      final weight = double.tryParse(_currentWeightController.text);
      if (weight != null) widget.onCurrentWeightChanged(weight);
    }

    if (_targetWeightController.text.isNotEmpty) {
      final weight = double.tryParse(_targetWeightController.text);
      if (weight != null) widget.onTargetWeightChanged(weight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Заголовок
          Text(
            l10n.onboardingBodyParamsTitle,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 8),

          Text(
            l10n.onboardingBodyParamsSubtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Выбор пола
                  _buildSectionTitle(l10n.onboardingGender),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildGenderButton(
                          l10n.onboardingMale,
                          'male',
                          Icons.male,
                          const Color(0xFF4A90E2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGenderButton(
                          l10n.onboardingFemale,
                          'female',
                          Icons.female,
                          const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Возраст
                  _buildNumberField(
                    label: l10n.onboardingAge,
                    controller: _ageController,
                    suffix: 'лет',
                    onChanged: _onTextChanged,
                  ),

                  const SizedBox(height: 24),

                  // Рост
                  _buildNumberField(
                    label: l10n.onboardingHeight,
                    controller: _heightController,
                    suffix: 'см',
                    onChanged: _onTextChanged,
                  ),

                  const SizedBox(height: 24),

                  // Текущий вес
                  _buildNumberField(
                    label: l10n.onboardingCurrentWeight,
                    controller: _currentWeightController,
                    suffix: 'кг',
                    onChanged: _onTextChanged,
                  ),

                  if (_shouldShowTargetWeight) ...[
                    const SizedBox(height: 24),
                    // Целевой вес
                    _buildNumberField(
                      label: l10n.onboardingTargetWeight,
                      controller: _targetWeightController,
                      suffix: 'кг',
                      onChanged: _onTextChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Кнопка "Далее"
          SafeArea(
            child: ElevatedButton(
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
              child: Text(
                l10n.onboardingNext,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildGenderButton(String title, String value, IconData icon, Color color) {
    final isSelected = _selectedGender == value;

    return GestureDetector(
      onTap: () => _selectGender(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
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
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String suffix,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            suffix: Text(
              suffix,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2EC5FF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}