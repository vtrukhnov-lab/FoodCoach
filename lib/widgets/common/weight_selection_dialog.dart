import 'package:flutter/material.dart';

enum MeasurementUnit {
  grams('г', 'граммы'),
  ml('мл', 'миллилитры'),
  portions('шт', 'порции');

  const MeasurementUnit(this.symbol, this.name);
  final String symbol;
  final String name;
}

class WeightSelectionResult {
  final double amount;
  final MeasurementUnit unit;
  final bool addToFavorites;

  WeightSelectionResult({
    required this.amount,
    required this.unit,
    this.addToFavorites = false,
  });

  // Для обратной совместимости
  double get weight => unit == MeasurementUnit.grams ? amount : amount * 100;
}

class WeightSelectionDialog extends StatefulWidget {
  final String productName;
  final String? productImage;
  final Map<String, dynamic>? productData;
  final double initialWeight;

  const WeightSelectionDialog({
    super.key,
    required this.productName,
    this.productImage,
    this.productData,
    this.initialWeight = 100.0,
  });

  @override
  State<WeightSelectionDialog> createState() => _WeightSelectionDialogState();
}

class _WeightSelectionDialogState extends State<WeightSelectionDialog> {
  late double _selectedAmount;
  MeasurementUnit _selectedUnit = MeasurementUnit.grams;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedAmount = widget.initialWeight;
    _controller.text = _selectedAmount.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateAmount(double amount) {
    setState(() {
      _selectedAmount = amount;
      _controller.text = amount.toStringAsFixed(0);
    });
  }

  Map<String, double> _calculateNutrition() {
    if (widget.productData == null) {
      return {'calories': 0, 'proteins': 0, 'carbs': 0, 'fats': 0};
    }

    final nutriments = widget.productData!['nutriments'] as Map<String, dynamic>? ?? {};
    final weightInGrams = _selectedUnit == MeasurementUnit.grams
        ? _selectedAmount
        : _selectedAmount * 100; // Приблизительный расчет для мл и порций

    final factor = weightInGrams / 100;

    return {
      'calories': ((nutriments['energy-kcal_100g'] ?? 0) * factor),
      'proteins': ((nutriments['proteins_100g'] ?? 0) * factor),
      'carbs': ((nutriments['carbohydrates_100g'] ?? 0) * factor),
      'fats': ((nutriments['fat_100g'] ?? 0) * factor),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final nutrition = _calculateNutrition();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFF8F9FA),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header с крестиком
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // Скроллабельный контент
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Фото и название продукта
                      Row(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey[200],
                            ),
                            child: widget.productImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      widget.productImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            color: Colors.grey[300],
                                          ),
                                          child: const Icon(Icons.fastfood, size: 40),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(Icons.fastfood, size: 40),
                                  ),
                          ),
                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.productName,
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (widget.productData?['brands'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.productData!['brands'],
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Единицы измерения
                      Text(
                        'Единица измерения',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: MeasurementUnit.values.map((unit) {
                          final isSelected = _selectedUnit == unit;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedUnit = unit;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  unit.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : theme.primaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 32),

                      // Количество
                      Row(
                        children: [
                          Text(
                            'Количество',
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_selectedAmount.toStringAsFixed(0)} ${_selectedUnit.symbol}',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Слайдер
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: theme.primaryColor,
                          inactiveTrackColor: theme.primaryColor.withValues(alpha: 0.3),
                          thumbColor: theme.primaryColor,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
                          overlayColor: theme.primaryColor.withValues(alpha: 0.2),
                          trackHeight: 8,
                        ),
                        child: Slider(
                          value: _selectedAmount,
                          min: _selectedUnit == MeasurementUnit.portions ? 1 : 10,
                          max: _selectedUnit == MeasurementUnit.portions ? 10 : 1000,
                          divisions: _selectedUnit == MeasurementUnit.portions ? 9 : 99,
                          onChanged: _updateAmount,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Поле ввода
                      TextField(
                        controller: _controller,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          labelText: 'Введите количество',
                          labelStyle: const TextStyle(fontSize: 16),
                          suffix: Text(_selectedUnit.symbol, style: const TextStyle(fontSize: 16)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: theme.primaryColor, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        onChanged: (value) {
                          final amount = double.tryParse(value);
                          if (amount != null && amount > 0) {
                            final maxAmount = _selectedUnit == MeasurementUnit.portions ? 10 : 1000;
                            setState(() {
                              _selectedAmount = amount.clamp(1, maxAmount.toDouble());
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 32),

                      // Питательная ценность
                      Text(
                        'Питательная ценность',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Калории - крупно
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Калории',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${nutrition['calories']?.round() ?? 0} ккал',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Макронутриенты в ряд
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Белки',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${nutrition['proteins']?.toStringAsFixed(1) ?? '0'} г',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Углеводы',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${nutrition['carbs']?.toStringAsFixed(1) ?? '0'} г',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Жиры',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${nutrition['fats']?.toStringAsFixed(1) ?? '0'} г',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Кнопки
                      Column(
                        children: [
                          // Главная кнопка - Добавить
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _selectedAmount > 0
                                  ? () => Navigator.of(context).pop(
                                        WeightSelectionResult(
                                          amount: _selectedAmount,
                                          unit: _selectedUnit,
                                          addToFavorites: false,
                                        ),
                                      )
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'Добавить продукт',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Вторичная кнопка - В избранное
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton.icon(
                              onPressed: _selectedAmount > 0
                                  ? () => Navigator.of(context).pop(
                                        WeightSelectionResult(
                                          amount: _selectedAmount,
                                          unit: _selectedUnit,
                                          addToFavorites: true,
                                        ),
                                      )
                                  : null,
                              icon: const Icon(Icons.favorite_outline, color: Colors.pink, size: 20),
                              label: const Text(
                                'Сохранить в избранное',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.pink,
                                side: const BorderSide(color: Colors.pink, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}