// lib/widgets/quick_add_widget.dart
//
// PURPOSE: A grid of drink categories for navigation.
// This widget has been simplified to only show the main drink categories.
// The "Favorites" functionality has been moved to the MainProgressCard.

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class QuickAddWidget extends StatelessWidget {
  final Function() onUpdate;

  const QuickAddWidget({
    super.key,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            l10n.quickAdd,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        _buildCategoriesGrid(context, l10n),
      ],
    );
  }

  Widget _buildCategoriesGrid(BuildContext context, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.15,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        _buildCategoryTile(
            context: context,
            icon: Icons.water_drop,
            label: l10n.water,
            gradientColors: [Colors.blue.shade400, Colors.blue.shade600],
            routeName: '/liquids'),
        _buildCategoryTile(
            context: context,
            icon: Icons.bolt,
            label: l10n.electrolyte,
            gradientColors: [Colors.orange.shade400, Colors.orange.shade600],
            routeName: '/electrolytes'),
        _buildCategoryTile(
            context: context,
            icon: Icons.coffee,
            label: l10n.hotDrinks,
            gradientColors: [Colors.brown.shade400, Colors.brown.shade600],
            routeName: '/hot_drinks'),
        _buildCategoryTile(
            context: context,
            icon: Icons.medication,
            label: l10n.supplements,
            gradientColors: [Colors.purple.shade400, Colors.purple.shade600],
            routeName: '/supplements'),
        _buildCategoryTile(
            context: context,
            icon: Icons.sports_bar,
            label: l10n.alcohol,
            gradientColors: [Colors.red.shade500, Colors.red.shade700],
            routeName: '/alcohol'),
        _buildCategoryTile(
            context: context,
            icon: Icons.fitness_center,
            // ИСПРАВЛЕНО: Добавлена проверка на случай отсутствия ключа 'sports'
            label: l10n.sports ?? 'Sports',
            gradientColors: [Colors.teal.shade400, Colors.teal.shade600],
            routeName: '/sports'),
      ],
    );
  }

  Widget _buildCategoryTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
    required String routeName,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(context, routeName);
          if (result == true) {
            onUpdate();
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradientColors.first.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 42,
                color: Colors.white,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}