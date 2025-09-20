// lib/screens/onboarding/pages/diet_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/ion_character.dart';

class DietPage extends StatelessWidget {
  final bool isPracticingFasting;
  final String fastingSchedule;
  final String dietMode;
  final Function(bool) onFastingChanged;
  final Function(String) onFastingScheduleChanged;
  final Function(String) onDietModeChanged;

  const DietPage({
    super.key,
    required this.isPracticingFasting,
    required this.fastingSchedule,
    required this.dietMode,
    required this.onFastingChanged,
    required this.onFastingScheduleChanged,
    required this.onDietModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          const IonCharacter(size: 100, mood: IonMood.happy, showGlow: false)
            .animate().fadeIn(),
          
          const SizedBox(height: 20),
          
          Text(
            l10n.dietPageTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            l10n.dietPageSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
          
          const SizedBox(height: 24),
          
          _buildFastingOption(l10n),
          
          if (isPracticingFasting) ...[
            const SizedBox(height: 16),
            _buildFastingSchedules(l10n),
          ],
          
          const SizedBox(height: 16),
          
          _buildDietOption('normal', '🍽️', l10n.normalDiet, l10n.normalDietDesc, l10n),
          
          const SizedBox(height: 10),
          
          _buildDietOption('keto', '🥑', l10n.ketoDiet, l10n.ketoDietDesc, l10n),
        ],
      ),
    );
  }

  Widget _buildFastingOption(AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onFastingChanged(!isPracticingFasting);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isPracticingFasting 
            ? const Color(0xFF2EC5FF).withValues(alpha: 0.1)
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPracticingFasting 
              ? const Color(0xFF2EC5FF)
              : Colors.grey[300]!,
            width: isPracticingFasting ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPracticingFasting 
                    ? const Color(0xFF2EC5FF)
                    : Colors.grey[400]!,
                  width: 2,
                ),
                color: isPracticingFasting 
                  ? const Color(0xFF2EC5FF)
                  : Colors.transparent,
              ),
              child: isPracticingFasting
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.onboardingPracticeFasting,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPracticingFasting 
                        ? const Color(0xFF2EC5FF)
                        : Colors.black,
                    ),
                  ),
                  Text(
                    l10n.onboardingPracticeFastingDesc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(delay: 100.ms);
  }

  Widget _buildFastingSchedules(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2EC5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.fastingSchedule,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildFastingScheduleOption('16:8', l10n.fasting16_8, l10n.fasting16_8Desc),
          _buildFastingScheduleOption('OMAD', l10n.fastingOMAD, l10n.fastingOMADDesc),
          _buildFastingScheduleOption('ADF', l10n.fastingADF, l10n.fastingADFDesc),
        ],
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildFastingScheduleOption(String value, String title, String subtitle) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onFastingScheduleChanged(value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: fastingSchedule,
              onChanged: (val) => onFastingScheduleChanged(val!),
              activeColor: const Color(0xFF2EC5FF),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietOption(String value, String icon, String title, 
      String subtitle, AppLocalizations l10n) {
    final isSelected = dietMode == value && !isPracticingFasting;
    
    return GestureDetector(
      onTap: () {
        if (!isPracticingFasting) {
          HapticFeedback.lightImpact();
          onDietModeChanged(value);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF2EC5FF).withValues(alpha: 0.1)
            : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF2EC5FF)
              : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF2EC5FF) : Colors.black,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF2EC5FF), size: 22),
          ],
        ),
      ),
    ).animate().scale(delay: (value == 'normal' ? 200 : 300).ms);
  }
}