// lib/widgets/home/electrolyte_bar_display.dart
import 'package:flutter/material.dart';

class ElectrolyteBarDisplay extends StatelessWidget {
  final int sodiumCurrent;
  final int sodiumGoal;
  final int potassiumCurrent;
  final int potassiumGoal;
  final int magnesiumCurrent;
  final int magnesiumGoal;

  const ElectrolyteBarDisplay({
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
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Column(
        children: [
          _buildCompactBar("Na", sodiumCurrent, sodiumGoal, const Color(0xFFFF6B6B)),
          const SizedBox(height: 6),
          _buildCompactBar("K", potassiumCurrent, potassiumGoal, const Color(0xFF4ECDC4)),
          const SizedBox(height: 6),
          _buildCompactBar("Mg", magnesiumCurrent, magnesiumGoal, const Color(0xFF95E1D3)),
        ],
      ),
    );
  }

  Widget _buildCompactBar(String symbol, int current, int goal, Color color) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        // Химический символ в цветном квадрате
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Прогресс-бар
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Значения над баром
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '$current / $goal mg',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Сам прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}