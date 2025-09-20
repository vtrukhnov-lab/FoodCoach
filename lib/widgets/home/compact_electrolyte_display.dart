// lib/widgets/home/compact_electrolyte_display.dart
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class CompactElectrolyteDisplay extends StatelessWidget {
  final int sodiumCurrent;
  final int sodiumGoal;
  final int potassiumCurrent;
  final int potassiumGoal;
  final int magnesiumCurrent;
  final int magnesiumGoal;

  const CompactElectrolyteDisplay({
    super.key,
    required this.sodiumCurrent,
    required this.sodiumGoal,
    required this.potassiumCurrent,
    required this.potassiumGoal,
    required this.magnesiumCurrent,
    required this.magnesiumGoal,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildElectrolyteIndicator(
            name: l10n.sodium,
            current: sodiumCurrent,
            goal: sodiumGoal,
            color: Colors.orange,
          ),
          _buildElectrolyteIndicator(
            name: l10n.potassium,
            current: potassiumCurrent,
            goal: potassiumGoal,
            color: Colors.purple,
          ),
          _buildElectrolyteIndicator(
            name: l10n.magnesium,
            current: magnesiumCurrent,
            goal: magnesiumGoal,
            color: Colors.pink,
          ),
        ],
      ),
    );
  }

  Widget _buildElectrolyteIndicator({
    required String name,
    required int current,
    required int goal,
    required Color color,
  }) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: color.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$current / $goal mg',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}