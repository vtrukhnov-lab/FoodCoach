import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/hydration_provider.dart';
import '../l10n/app_localizations.dart';

class DailyReportCard extends StatelessWidget {
  const DailyReportCard({super.key});
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Consumer<HydrationProvider>(
      builder: (context, provider, child) {
        final progress = provider.getProgress();
        final status = provider.getHydrationStatus(l10n);
        
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.blue.shade400,
                Colors.blue.shade600,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.dailyReportTitle.replaceAll('📊 ', ''), // Remove emoji if present
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          l10n.dateFormat(_getWeekday(l10n), DateTime.now().day, _getMonth(l10n)),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getStatusIcon(status, l10n),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Daily progress chart
              Container(
                height: 200,
                padding: const EdgeInsets.all(20),
                child: _buildDayProgressChart(provider),
              ),
              
              // Statistics
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatRow(
                      l10n.water,
                      '${progress['water']!.toInt()} / ${provider.goals.waterOpt} ${l10n.ml}',
                      progress['waterPercent']!,
                      Colors.white,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      l10n.sodium,
                      '${progress['sodium']!.toInt()} / ${provider.goals.sodium} ${l10n.mg}',
                      progress['sodiumPercent']!,
                      Colors.yellow.shade300,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      l10n.potassium,
                      '${progress['potassium']!.toInt()} / ${provider.goals.potassium} ${l10n.mg}',
                      progress['potassiumPercent']!,
                      Colors.purple.shade300,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      l10n.magnesium,
                      '${progress['magnesium']!.toInt()} / ${provider.goals.magnesium} ${l10n.mg}',
                      progress['magnesiumPercent']!,
                      Colors.pink.shade300,
                    ),
                  ],
                ),
              ),
              
              // Recommendations
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.yellow.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.tomorrowRecommendations,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getRecommendation(status, progress, l10n),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Share button
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Share report
                  },
                  icon: const Icon(Icons.share),
                  label: Text(l10n.shareResult),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue.shade600,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate()
          .fadeIn(duration: 500.ms)
          .slideY(begin: 0.1, end: 0);
      },
    );
  }
  
  Widget _buildDayProgressChart(HydrationProvider provider) {
    // Simulate daily data (by hours)
    final spots = <FlSpot>[];
    for (int i = 7; i <= 22; i++) {
      final progress = i <= DateTime.now().hour 
        ? (i - 7) / 15 * provider.getProgress()['waterPercent']!
        : 0.0;
      spots.add(FlSpot(i.toDouble(), progress));
    }
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                );
              },
              reservedSize: 35,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 3,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 3 == 1) {
                  return Text(
                    '${value.toInt()}:00',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 10,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              reservedSize: 25,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 7,
        maxX: 22,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.white,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatRow(String label, String value, double percent, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: _getPercentColor(percent),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${percent.toInt()}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getPercentColor(double percent) {
    if (percent >= 90) return Colors.green;
    if (percent >= 70) return Colors.yellow.shade700;
    if (percent >= 50) return Colors.orange;
    return Colors.red;
  }
  
  IconData _getStatusIcon(String status, AppLocalizations l10n) {
    // Compare with localized strings
    if (status == l10n.hydrationStatusNormal) {
      return Icons.check_circle;
    } else if (status == l10n.hydrationStatusDiluted) {
      return Icons.water_damage;
    } else if (status == l10n.hydrationStatusDehydrated) {
      return Icons.warning;
    } else if (status == l10n.hydrationStatusLowSalt) {
      return Icons.grain;
    } else {
      return Icons.info;
    }
  }
  
  String _getRecommendation(String status, Map<String, double> progress, AppLocalizations l10n) {
    if (status == l10n.hydrationStatusNormal && progress['waterPercent']! >= 90) {
      return l10n.recommendationExcellent;
    } else if (status == l10n.hydrationStatusDiluted) {
      return l10n.recommendationDiluted;
    } else if (status == l10n.hydrationStatusDehydrated) {
      return l10n.recommendationDehydrated;
    } else if (status == l10n.hydrationStatusLowSalt) {
      return l10n.recommendationLowSalt;
    } else {
      return l10n.recommendationGeneral;
    }
  }
  
  String _getWeekday(AppLocalizations l10n) {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1: return l10n.monday;
      case 2: return l10n.tuesday;
      case 3: return l10n.wednesday;
      case 4: return l10n.thursday;
      case 5: return l10n.friday;
      case 6: return l10n.saturday;
      case 7: return l10n.sunday;
      default: return l10n.monday;
    }
  }
  
  String _getMonth(AppLocalizations l10n) {
    final now = DateTime.now();
    switch (now.month) {
      case 1: return l10n.january;
      case 2: return l10n.february;
      case 3: return l10n.march;
      case 4: return l10n.april;
      case 5: return l10n.may;
      case 6: return l10n.june;
      case 7: return l10n.july;
      case 8: return l10n.august;
      case 9: return l10n.september;
      case 10: return l10n.october;
      case 11: return l10n.november;
      case 12: return l10n.december;
      default: return l10n.january;
    }
  }
}