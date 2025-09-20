// lib/screens/onboarding/pages/welcome_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/ion_character.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomePage({
    super.key,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const IonCharacter(
            size: 120,
            mood: IonMood.happy,
            showGlow: true,
          ).animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut)
            .then()
            .shimmer(duration: 2000.ms, color: const Color(0xFF8AF5A3).withValues(alpha: 0.2)),
          
          const SizedBox(height: 24),
          
          Text(
            l10n.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
          ).animate().fadeIn(delay: 300.ms),
          
          const SizedBox(height: 12),
          
          Text(
            l10n.onboardingWelcomeSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.3),
          ).animate().fadeIn(delay: 500.ms),
          
          const SizedBox(height: 24),
          
          ..._buildBenefitBullets(l10n),
          
          const SizedBox(height: 40),
          
          // Start button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onStart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EC5FF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(
              l10n.onboardingStartButton,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  List<Widget> _buildBenefitBullets(AppLocalizations l10n) {
    final bullets = [
      l10n.onboardingBullet1,
      l10n.onboardingBullet2,
      l10n.onboardingBullet3,
      l10n.onboardingBullet4,
    ];
    
    return bullets.asMap().entries.map((entry) {
      final index = entry.key;
      final text = entry.value;
      
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.check, size: 14, color: Color(0xFF2EC5FF)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, style: const TextStyle(fontSize: 14, height: 1.3)),
            ),
          ],
        ),
      ).animate()
        .slideX(begin: -0.2, end: 0, delay: (700 + index * 100).ms)
        .fadeIn(delay: (700 + index * 100).ms);
    }).toList();
  }
}