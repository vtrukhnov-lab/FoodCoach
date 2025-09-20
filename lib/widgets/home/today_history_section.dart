// lib/widgets/home/today_history_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/hydration_provider.dart';
import '../../services/alcohol_service.dart';
import '../../services/units_service.dart';
import '../../models/intake.dart';
import '../../l10n/app_localizations.dart';

class TodayHistorySection extends StatelessWidget {
  const TodayHistorySection({super.key});

  static const int kMaxHistoryItems = 10;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HydrationProvider>(context);
    final alcohol = Provider.of<AlcoholService>(context);
    final units = Provider.of<UnitsService>(context);
    final l10n = AppLocalizations.of(context);

    // Показываем секцию, только если есть что показывать
    if (provider.todayIntakes.isEmpty && alcohol.todayIntakes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.todaysDrinks, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/history'),
                child: Text(l10n.allRecords),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: _getCombinedIntakes(provider, alcohol, units, l10n, context),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getCombinedIntakes(HydrationProvider provider, AlcoholService alcohol, UnitsService units, AppLocalizations l10n, BuildContext context) {
    final List<MapEntry<DateTime, Widget>> all = [];

    for (var intake in provider.todayIntakes) {
      all.add(MapEntry(intake.timestamp, _buildIntakeItem(intake, units, l10n)));
    }

    for (var intake in alcohol.todayIntakes) {
      all.add(MapEntry(intake.timestamp, _buildAlcoholItem(intake, units, l10n, context)));
    }

    all.sort((a, b) => b.key.compareTo(a.key));

    return all.take(kMaxHistoryItems).map((e) => e.value).toList();
  }

  Widget _buildIntakeItem(Intake intake, UnitsService units, AppLocalizations l10n) {
    final typeData = _getIntakeTypeData(intake.type, l10n);
    final displayVolume = units.formatVolume(intake.volume);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
      child: Row(
        children: [
          Text(intake.formattedTime, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Text('${typeData['icon']} ${typeData['name']}'),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(displayVolume, style: const TextStyle(fontWeight: FontWeight.w600)),
              if (intake.totalElectrolytes > 0)
                Text('Na: ${intake.sodium} K: ${intake.potassium} Mg: ${intake.magnesium}', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlcoholItem(dynamic intake, UnitsService units, AppLocalizations l10n, BuildContext context) {
    final displayVolume = units.formatVolume(intake.volumeMl.toInt());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: Colors.orange.shade50, border: Border(bottom: BorderSide(color: Colors.orange.shade200))),
      child: Row(
        children: [
          Text(intake.formattedTime, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(width: 16),
          Icon(intake.type.icon, color: Colors.orange.shade600, size: 20),
          const SizedBox(width: 8),
          Text(intake.type.getLabel(context)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('$displayVolume, ${intake.abv}%', style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(intake.formattedSD, style: TextStyle(fontSize: 12, color: Colors.red.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Map<String, String> _getIntakeTypeData(String type, AppLocalizations l10n) {
    switch (type) {
      case 'water': return {'icon': '💧', 'name': l10n.water};
      case 'electrolyte': return {'icon': '⚡', 'name': l10n.electrolyte};
      case 'broth': return {'icon': '🍲', 'name': l10n.broth};
      case 'coffee': return {'icon': '☕', 'name': l10n.coffee};
      case 'tea': return {'icon': '🍵', 'name': l10n.tea};
      default: return {'icon': '🥤', 'name': type};
    }
  }
}