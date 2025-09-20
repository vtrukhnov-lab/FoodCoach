// lib/widgets/home/smart_advice_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../providers/hydration_provider.dart';
import '../../services/alcohol_service.dart';
import '../../services/hri_service.dart';
import '../../services/units_service.dart';
import '../../l10n/app_localizations.dart';
import '../ion_character.dart';

class SmartAdviceCard extends StatelessWidget {
  const SmartAdviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HydrationProvider>(context, listen: false);
    final alcohol = Provider.of<AlcoholService>(context, listen: false);
    final hri = Provider.of<HRIService>(context, listen: false);
    final units = Provider.of<UnitsService>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    final advice = _getSmartAdvice(provider, alcohol, hri, units, l10n);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: advice['tone'] as Color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: advice['border'] as Color),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 65,
              height: 65,
              child: IonCharacter(
                size: 55,
                mood: advice['ionMood'] as IonMood,
                showGlow: false,
                showElectrolytes: false,
                hydrationLevel: advice['ionHydrationLevel'] as HydrationLevel,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    advice['title'] as String,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: advice['border'] as Color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    advice['body'] as String,
                    style: TextStyle(fontSize: 13.5, color: Colors.grey[800], height: 1.3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 450.ms),
    );
  }

  Map<String, dynamic> _getSmartAdvice(
    HydrationProvider provider,
    AlcoholService alcoholService,
    HRIService hriService,
    UnitsService units,
    AppLocalizations l10n,
  ) {
    // ========== HRI-INTEGRATED SMART ANALYSIS ==========
    final hriComponents = hriService.components;
    final currentHRI = hriService.currentHRI;

    // Find the highest risk component
    var highestComponent = '';
    var highestValue = 0.0;

    hriComponents.forEach((component, value) {
      if (value > highestValue && value > 2.0) { // Only consider significant factors
        highestValue = value;
        highestComponent = component;
      }
    });

    // CRITICAL: Handle severe overhydration first
    final waterRatio = provider.goals.waterOpt > 0 ? provider.totalWaterToday / provider.goals.waterOpt : 0.0;
    if (waterRatio > 2.0) {
      final volumeToShow = units.formatVolume(500);
      return {
        'title': l10n.adviceOverhydrationSevere,
        'body': 'Critical! Stop drinking. Add $volumeToShow with 800mg sodium. Could reduce HRI by ${highestValue.round()} points.',
        'tone': const Color(0xFFFFEBEE),
        'border': Colors.red.shade600,
        'ionMood': IonMood.worried,
        'ionHydrationLevel': HydrationLevel.high,
      };
    }

    // HRI-BASED PRIORITY RECOMMENDATIONS
    switch (highestComponent) {
      case 'water':
        return _getWaterAdvice(hriComponents['water']!, provider, units, l10n, waterRatio);

      case 'sodium':
        return _getSodiumAdvice(hriComponents['sodium']!, provider, units, l10n);

      case 'potassium':
        return _getPotassiumAdvice(hriComponents['potassium']!, provider, units, l10n);

      case 'magnesium':
        return _getMagnesiumAdvice(hriComponents['magnesium']!, provider, units, l10n);

      case 'workouts':
        return _getWorkoutAdvice(hriComponents['workouts']!, hriService, units, l10n);

      case 'dehydration':
        return _getDehydrationAdvice(hriComponents['dehydration']!, hriService, units, l10n);

      case 'caffeine':
        return _getCaffeineAdvice(hriComponents['caffeine']!, hriService, units, l10n);

      case 'alcohol':
        return _getAlcoholAdvice(hriComponents['alcohol']!, alcoholService, units, l10n);

      case 'sugar':
        return _getSugarAdvice(hriComponents['sugar']!, provider, units, l10n);

      case 'food':
        return _getFoodAdvice(hriComponents['food']!, provider, units, l10n);

      case 'timeSinceIntake':
        return _getTimeAdvice(hriComponents['timeSinceIntake']!, hriService, units, l10n);

      case 'morning':
        return _getMorningAdvice(hriComponents['morning']!, units, l10n);

      case 'heat':
        return _getHeatAdvice(hriComponents['heat']!, units, l10n);
    }

    // Perfect state
    if (currentHRI < 30) {
      final waterNeed = (provider.goals.waterOpt - provider.totalWaterToday).clamp(100, 500);
      final displayNeed = units.formatVolume(waterNeed.toInt(), hideUnit: true);
      return {
        'title': '🎯 Excellent hydration!',
        'body': 'HRI: ${currentHRI.round()}/100. Stay on track with ~$displayNeed ${units.volumeUnit} more.',
        'tone': Colors.green.shade50,
        'border': Colors.green.shade400,
        'ionMood': IonMood.happy,
        'ionHydrationLevel': HydrationLevel.perfect,
      };
    }

    // Default good state
    final waterNeed = (provider.goals.waterOpt - provider.totalWaterToday).clamp(200, 600);
    final displayNeed = units.formatVolume(waterNeed.toInt(), hideUnit: true);
    return {
      'title': '✅ Good balance',
      'body': 'HRI: ${currentHRI.round()}/100. Continue with ~$displayNeed ${units.volumeUnit} more.',
      'tone': Colors.green.shade50,
      'border': Colors.green.shade300,
      'ionMood': IonMood.happy,
      'ionHydrationLevel': HydrationLevel.perfect,
    };
  }

  // ========== COMPONENT-SPECIFIC ADVICE METHODS ==========

  Map<String, dynamic> _getWaterAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n, double waterRatio) {
    if (component > 30) {
      final volumeToShow = units.formatVolume(300);
      return {
        'title': '🚨 Severe dehydration',
        'body': 'Drink $volumeToShow immediately with salt. Could reduce HRI by ${component.round()} points.',
        'tone': Colors.red.shade50,
        'border': Colors.red.shade400,
        'ionMood': IonMood.worried,
        'ionHydrationLevel': HydrationLevel.low,
      };
    }

    if (component > 15) {
      final volumeToShow = units.formatVolume(400);
      return {
        'title': '💧 Dehydration risk',
        'body': 'Drink $volumeToShow now. Could reduce HRI by ${component.round()} points.',
        'tone': Colors.blue.shade50,
        'border': Colors.blue.shade400,
        'ionMood': IonMood.worried,
        'ionHydrationLevel': HydrationLevel.low,
      };
    }

    if (waterRatio > 1.3) {
      return {
        'title': '⚠️ Overhydration',
        'body': 'Slow down water intake. Add electrolytes instead. Could reduce HRI by ${component.round()} points.',
        'tone': Colors.orange.shade50,
        'border': Colors.orange.shade400,
        'ionMood': IonMood.thinking,
        'ionHydrationLevel': HydrationLevel.high,
      };
    }

    final volumeToShow = units.formatVolume(250);
    return {
      'title': '💧 Water needed',
      'body': 'Drink $volumeToShow soon. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.blue.shade50,
      'border': Colors.blue.shade300,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getSodiumAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    final sodiumNeed = (provider.goals.sodium - provider.totalSodiumToday).clamp(200, 1000);
    return {
      'title': '🧂 Low sodium',
      'body': 'Add ${sodiumNeed.round()}mg sodium (pinch of salt). Could reduce HRI by ${component.round()} points.',
      'tone': Colors.amber.shade50,
      'border': Colors.amber.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getPotassiumAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    return {
      'title': '🍌 Low potassium',
      'body': 'Eat banana, avocado, or coconut water. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.yellow.shade50,
      'border': Colors.yellow.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getMagnesiumAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    return {
      'title': '🥜 Low magnesium',
      'body': 'Eat nuts, seeds, or dark chocolate. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.brown.shade50,
      'border': Colors.brown.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getWorkoutAdvice(double component, HRIService hriService, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(500);
    return {
      'title': '🏃 Post-workout recovery',
      'body': 'Drink $volumeToShow with electrolytes to recover. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.purple.shade50,
      'border': Colors.purple.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }

  Map<String, dynamic> _getDehydrationAdvice(double component, HRIService hriService, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(400);
    return {
      'title': '🚰 Workout dehydration',
      'body': 'Compensate workout losses: $volumeToShow + salt. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.red.shade50,
      'border': Colors.red.shade400,
      'ionMood': IonMood.worried,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }

  Map<String, dynamic> _getCaffeineAdvice(double component, HRIService hriService, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(300);
    return {
      'title': '☕ High caffeine',
      'body': 'Drink extra $volumeToShow to counter caffeine. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.brown.shade50,
      'border': Colors.brown.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getAlcoholAdvice(double component, AlcoholService alcoholService, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(400);
    return {
      'title': '🍷 Alcohol recovery',
      'body': 'No more alcohol! Drink $volumeToShow slowly + salt. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.orange.shade50,
      'border': Colors.orange.shade400,
      'ionMood': IonMood.worried,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }

  Map<String, dynamic> _getSugarAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(300);
    return {
      'title': '🍭 High sugar intake',
      'body': 'Drink extra $volumeToShow to process sugar. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.pink.shade50,
      'border': Colors.pink.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getFoodAdvice(double component, HydrationProvider provider, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(300);
    return {
      'title': '🍟 Processed food',
      'body': 'High sodium/dry food detected. Drink $volumeToShow extra. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.orange.shade50,
      'border': Colors.orange.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.normal,
    };
  }

  Map<String, dynamic> _getTimeAdvice(double component, HRIService hriService, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(300);
    final hours = component ~/ 2; // Rough conversion
    return {
      'title': '⏰ Long time without water',
      'body': '${hours}h since last drink. Have $volumeToShow now. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.blue.shade50,
      'border': Colors.blue.shade400,
      'ionMood': IonMood.thinking,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }

  Map<String, dynamic> _getMorningAdvice(double component, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(400);
    return {
      'title': '🌅 Poor morning indicators',
      'body': 'Weight loss/dark urine detected. Drink $volumeToShow + salt. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.orange.shade50,
      'border': Colors.orange.shade400,
      'ionMood': IonMood.worried,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }

  Map<String, dynamic> _getHeatAdvice(double component, UnitsService units, AppLocalizations l10n) {
    final volumeToShow = units.formatVolume(400);
    return {
      'title': '🌡️ Hot weather',
      'body': 'High temperature detected. Drink $volumeToShow extra. Could reduce HRI by ${component.round()} points.',
      'tone': Colors.red.shade50,
      'border': Colors.red.shade400,
      'ionMood': IonMood.worried,
      'ionHydrationLevel': HydrationLevel.low,
    };
  }
}