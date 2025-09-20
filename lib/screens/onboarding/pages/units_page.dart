// lib/screens/onboarding/pages/units_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/ion_character.dart';

class UnitsPage extends StatefulWidget {
  final String selectedUnits;
  final Function(String) onUnitsChanged;
  final VoidCallback onNext;

  const UnitsPage({
    super.key,
    required this.selectedUnits,
    required this.onUnitsChanged,
    required this.onNext,
  });

  @override
  State<UnitsPage> createState() => _UnitsPageState();
}

class _UnitsPageState extends State<UnitsPage> {
  late String _selectedUnits;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _selectedUnits = '';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      // Определяем дефолтную систему на основе локали
      final locale = Localizations.localeOf(context).languageCode;
      final defaultUnits = (locale == 'en') ? 'imperial' : 'metric';

      // Всегда устанавливаем дефолт на основе локали
      _selectedUnits = defaultUnits;
      // Уведомляем родительский компонент о выборе по умолчанию
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onUnitsChanged(defaultUnits);
      });

      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const IonCharacter(size: 100, mood: IonMood.happy, showGlow: false)
                    .animate().fadeIn(),

                  const SizedBox(height: 24),

                  Text(
                    l10n.onboardingUnitsTitle,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    l10n.onboardingUnitsSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),

                  const SizedBox(height: 30),

                  // Порядок зависит от локали
                  ...(_buildUnitOptions(l10n)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Next button at bottom
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              widget.onNext();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2EC5FF),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(56),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
            ),
            child: Text(
              l10n.next,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildUnitOptions(AppLocalizations l10n) {
    final locale = Localizations.localeOf(context).languageCode;
    final isEnglish = locale == 'en';

    final metricOption = _buildUnitOption(
      context,
      value: 'metric',
      emoji: '🌍',
      title: l10n.metricSystem,
      subtitle: l10n.metricUnits,
      delay: isEnglish ? 200 : 100,
    );

    final imperialOption = _buildUnitOption(
      context,
      value: 'imperial',
      emoji: '🇺🇸',
      title: l10n.imperialSystem,
      subtitle: l10n.imperialUnits,
      delay: isEnglish ? 100 : 200,
    );

    if (isEnglish) {
      // Для английского: Imperial первый, Metric второй
      return [
        imperialOption,
        const SizedBox(height: 14),
        metricOption,
      ];
    } else {
      // Для остальных: Metric первый, Imperial второй
      return [
        metricOption,
        const SizedBox(height: 14),
        imperialOption,
      ];
    }
  }

  Widget _buildUnitOption(
    BuildContext context, {
    required String value,
    required String emoji,
    required String title,
    required String subtitle,
    required int delay,
  }) {
    final isSelected = _selectedUnits == value;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _selectedUnits = value;
        });
        widget.onUnitsChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.all(18),
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
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF2EC5FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                        ? const Color(0xFF2EC5FF)
                        : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF2EC5FF), size: 26),
          ],
        ),
      ),
    ).animate().scale(delay: delay.ms);
  }
}