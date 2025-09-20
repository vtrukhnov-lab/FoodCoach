// lib/screens/onboarding/pages/complete_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/ion_character.dart';
import '../../../services/units_service.dart';

class CompletePage extends StatelessWidget {
  final double weight;
  final String units;
  final String dietMode;
  final String fastingSchedule;
  final bool isPracticingFasting;
  final VoidCallback onContinue;
  final VoidCallback? onBack;

  const CompletePage({
    super.key,
    required this.weight,
    required this.units,
    required this.dietMode,
    required this.fastingSchedule,
    required this.isPracticingFasting,
    required this.onContinue,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const IonCharacter(
              size: 120,
              mood: IonMood.proud,
              showGlow: true,
            ).animate()
              .scale(duration: 500.ms, curve: Curves.elasticOut)
              .then()
              .shake(duration: 300.ms),
            
            const SizedBox(height: 30),
            
            Text(
              l10n.onboardingProfileReady,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ).animate().fadeIn(delay: 300.ms),
            
            const SizedBox(height: 16),
            
            _buildSummaryCard(l10n),
            
            const SizedBox(height: 24),
            
            Text(
              l10n.onboardingIonWillHelp,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.4),
            ).animate().fadeIn(delay: 700.ms),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (onBack != null)
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onBack!();
                  },
                  child: Text(
                    l10n.back,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                )
              else
                const SizedBox(width: 80),
              
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onContinue();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EC5FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.onboardingContinue, 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    final unitsService = UnitsService.instance;
    final waterNorm = unitsService.toDisplayVolume((30 * weight).toInt()).round();
    final waterUnit = unitsService.volumeUnitShort;
    
    final displayWeight = unitsService.formatWeight(weight, hideUnit: false);
    
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            Icons.water_drop,
            l10n.onboardingWaterNorm,
            '$waterNorm $waterUnit',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            Icons.monitor_weight,
            l10n.weight,
            displayWeight,
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            Icons.straighten,
            l10n.unitsSection,
            units == 'metric' ? l10n.metricSystem : l10n.imperialSystem,
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            Icons.restaurant,
            l10n.dietMode,
            _getDietModeText(l10n),
          ),
          if (isPracticingFasting && fastingSchedule != 'none') ...[
            const SizedBox(height: 10),
            _buildSummaryRow(
              Icons.schedule,
              l10n.fastingSchedule,
              fastingSchedule,
            ),
          ],
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, delay: 500.ms);
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF2EC5FF), size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2EC5FF),
          ),
        ),
      ],
    );
  }

  String _getDietModeText(AppLocalizations l10n) {
    if (isPracticingFasting) {
      return l10n.fastingDiet;
    }
    switch (dietMode) {
      case 'keto':
        return l10n.ketoDiet;
      case 'normal':
      default:
        return l10n.normalDiet;
    }
  }
}