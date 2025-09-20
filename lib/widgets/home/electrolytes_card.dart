// lib/widgets/home/electrolytes_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/hydration_provider.dart';
import '../../services/subscription_service.dart';
import '../../screens/paywall_screen.dart';

/// Карточка отображения электролитов на главном экране
/// Теперь с прогресс-барами и фиксированным цветом
class ElectrolytesCard extends StatelessWidget {
  const ElectrolytesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final subscription = context.watch<SubscriptionProvider>();
    final l10n = AppLocalizations.of(context);
    
    // Проверяем PRO статус
    if (!subscription.isPro) {
      return _buildProLockedCard(context, l10n);
    }
    
    // Остальной код для PRO пользователей
    final progress = provider.getProgress();
    
    final sodiumCurrent = (progress['sodium'] ?? 0).toInt();
    final sodiumGoal = provider.goals.sodium;
    final potassiumCurrent = (progress['potassium'] ?? 0).toInt();
    final potassiumGoal = provider.goals.potassium;
    final magnesiumCurrent = (progress['magnesium'] ?? 0).toInt();
    final magnesiumGoal = provider.goals.magnesium;
    
    // Расчёт общего процента для HRI Impact
    final totalPercent = _calculateTotalPercent(
      sodiumCurrent, sodiumGoal,
      potassiumCurrent, potassiumGoal,
      magnesiumCurrent, magnesiumGoal,
    );
    
    final hriImpact = _calculateHRIImpact(totalPercent);
    
    return Container(
      decoration: BoxDecoration(
        // ФИКСИРОВАННЫЙ цвет - всегда тёмно-синий градиент
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Верхняя секция с основной информацией и HRI Impact
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.battery_5_bar, // фиксированная иконка
                            color: Colors.white, 
                            size: 36
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${totalPercent.round()}%',
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 42, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.electrolytes,
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _getShortStatus(totalPercent),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9), 
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // HRI Impact блок - всегда показываем
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.hriRisk,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9), 
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hriImpact > 0 ? '+$hriImpact' : '$hriImpact',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 28, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        'pts',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8), 
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Разделитель
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0),
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ПРОГРЕСС-БАРЫ вместо круглых индикаторов
            _buildProgressBar(
              symbol: 'Na',
              label: l10n.sodium,
              current: sodiumCurrent,
              goal: sodiumGoal,
              color: const Color(0xFFFF6B6B),
            ),
            const SizedBox(height: 16),
            
            _buildProgressBar(
              symbol: 'K',
              label: l10n.potassium,
              current: potassiumCurrent,
              goal: potassiumGoal,
              color: const Color(0xFF4ECDC4),
            ),
            const SizedBox(height: 16),
            
            _buildProgressBar(
              symbol: 'Mg',
              label: l10n.magnesium,
              current: magnesiumCurrent,
              goal: magnesiumGoal,
              color: const Color(0xFF95E1D3),
            ),
            
            // Блок рекомендаций - всегда показываем
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline, // фиксированная иконка
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _getAdviceText(totalPercent, l10n),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Корректировки натрия
                  _buildAdjustmentRow(
                    icon: Icons.grain,
                    label: l10n.sodium,
                    value: _getSodiumAdjustment(sodiumCurrent, sodiumGoal),
                  ),
                  const SizedBox(height: 6),
                  // Корректировки воды
                  _buildAdjustmentRow(
                    icon: Icons.local_drink,
                    label: l10n.water,
                    value: _getWaterAdjustment(totalPercent),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // PRO-заблокированная карточка
  Widget _buildProLockedCard(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PaywallScreen(source: 'home_electrolytes_card'),
            fullscreenDialog: true,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade700,
              Colors.grey.shade800,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PRO иконка
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.amber,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Заголовок PRO
              Text(
                'PRO',
                style: TextStyle(
                  color: Colors.amber.shade600,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Название функции
              Text(
                l10n.electrolytes,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Описание
              Text(
                l10n.electrolyteTrackingPro,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 20),
              
              // Кнопка разблокировки
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade600, Colors.orange.shade600],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_open,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.unlock,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  // НОВЫЙ метод: прогресс-бар с химическим символом
  Widget _buildProgressBar({
    required String symbol,
    required String label,
    required int current,
    required int goal,
    required Color color,
  }) {
    final percent = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        // Химический символ в цветном квадрате
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Прогресс-бар с текстом
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и значения
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$current / $goal mg',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: percent,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation(color),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdjustmentRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  int _calculateHRIImpact(double totalPercent) {
    // Негативное влияние при низком уровне электролитов
    if (totalPercent < 20) return 15;  // Критически низкий
    if (totalPercent < 40) return 10;  // Очень низкий
    if (totalPercent < 60) return 5;   // Низкий
    if (totalPercent > 120) return 5;  // Переизбыток
    return 0;  // Норма
  }

  double _calculateTotalPercent(
    int sodiumCurrent, int sodiumGoal,
    int potassiumCurrent, int potassiumGoal,
    int magnesiumCurrent, int magnesiumGoal,
  ) {
    final sodiumPercent = sodiumGoal > 0 ? sodiumCurrent / sodiumGoal : 0.0;
    final potassiumPercent = potassiumGoal > 0 ? potassiumCurrent / potassiumGoal : 0.0;
    final magnesiumPercent = magnesiumGoal > 0 ? magnesiumCurrent / magnesiumGoal : 0.0;
    
    return ((sodiumPercent + potassiumPercent + magnesiumPercent) / 3 * 100)
        .clamp(0.0, 150.0);
  }

  // Упрощённые короткие статусы
  String _getShortStatus(double percent) {
    if (percent < 30) return 'Low';
    if (percent < 60) return 'Below target';
    if (percent < 90) return 'Good';
    return 'Excellent';
  }

  // Текст совета
  String _getAdviceText(double percent, AppLocalizations l10n) {
    if (percent < 30) {
      return l10n.takeElectrolytesMorning;
    } else if (percent < 60) {
      return l10n.dontForgetElectrolytes;
    } else if (percent < 90) {
      return l10n.maintainWaterBalance;
    } else {
      return l10n.greatBalance;
    }
  }

  // Корректировка натрия
  String _getSodiumAdjustment(int current, int goal) {
    if (current >= goal * 0.8) return 'Normal';
    final needed = goal - current;
    if (needed < 500) return '+$needed mg';
    if (needed < 1000) return '+500 mg';
    return '+1000 mg';
  }

  // Корректировка воды
  String _getWaterAdjustment(double percent) {
    if (percent < 30) return '+500 ml';
    if (percent < 60) return '+250 ml';
    return 'Normal';
  }
}