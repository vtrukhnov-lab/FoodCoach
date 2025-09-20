import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/alcohol_intake.dart';
import '../services/alcohol_service.dart';

class AlcoholCheckinDialog extends StatefulWidget {
  const AlcoholCheckinDialog({super.key});
  
  static Future<void> show(BuildContext context) async {
    final alcoholService = Provider.of<AlcoholService>(context, listen: false);
    
    // Проверяем, был ли алкоголь вчера и нет ли уже чек-ина
    if (await alcoholService.hadAlcoholYesterday() && 
        alcoholService.todayCheckin == null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlcoholCheckinDialog(),
      );
    }
  }

  @override
  State<AlcoholCheckinDialog> createState() => _AlcoholCheckinDialogState();
}

class _AlcoholCheckinDialogState extends State<AlcoholCheckinDialog> {
  int _feelingScore = 3;
  bool _hadWater = false;
  bool _hadElectrolytes = false;
  
  final List<String> _emojis = ['😵', '😣', '😐', '🙂', '😊'];
  final List<String> _feelings = ['Ужасно', 'Плохо', 'Нормально', 'Хорошо', 'Отлично'];

  Future<void> _saveCheckin() async {
    final checkin = AlcoholCheckin(
      date: DateTime.now(),
      feelingScore: _feelingScore,
      hadWater: _hadWater,
      hadElectrolytes: _hadElectrolytes,
    );
    
    final alcoholService = Provider.of<AlcoholService>(context, listen: false);
    await alcoholService.saveCheckin(checkin);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Доброе утро! ☀️',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Как самочувствие после вчерашнего?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Шкала эмоций
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final isSelected = _feelingScore == index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _feelingScore = index + 1;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.primaryColor : Colors.grey[300]!,
                        width: 2,
                      ),
                      color: isSelected ? theme.primaryColor.withValues(alpha: 0.1) : null,
                    ),
                    child: Text(
                      _emojis[index],
                      style: TextStyle(
                        fontSize: isSelected ? 32 : 28,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _feelings[_feelingScore - 1],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Вопросы
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildQuestion(
                    'Выпили воду утром?',
                    _hadWater,
                    (value) => setState(() => _hadWater = value),
                  ),
                  const Divider(height: 20),
                  _buildQuestion(
                    'Приняли электролиты?',
                    _hadElectrolytes,
                    (value) => setState(() => _hadElectrolytes = value),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Рекомендации
            if (_feelingScore <= 3 || !_hadWater || !_hadElectrolytes)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Рекомендации на сегодня:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._getRecommendations().map((rec) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        rec,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Кнопка
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCheckin,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Готово',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuestion(String question, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          question,
          style: const TextStyle(fontSize: 14),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }
  
  List<String> _getRecommendations() {
    List<String> recommendations = [];
    
    if (_feelingScore <= 2) {
      recommendations.add('💧 Пейте больше воды сегодня (+20%)');
      recommendations.add('🧂 Добавьте электролиты к каждому приему');
      recommendations.add('☕ Ограничьте кофе одной чашкой');
    } else if (_feelingScore <= 3) {
      recommendations.add('💧 Увеличьте воду на 10%');
      recommendations.add('🧂 Не забывайте про электролиты');
    }
    
    if (!_hadWater) {
      recommendations.add('💧 Выпейте стакан воды прямо сейчас');
    }
    
    if (!_hadElectrolytes) {
      recommendations.add('🧂 Примите электролиты с утра');
    }
    
    return recommendations;
  }
}