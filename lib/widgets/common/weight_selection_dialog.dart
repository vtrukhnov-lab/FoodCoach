import 'package:flutter/material.dart';

class WeightSelectionDialog extends StatefulWidget {
  final String productName;
  final double initialWeight;

  const WeightSelectionDialog({
    super.key,
    required this.productName,
    this.initialWeight = 100.0,
  });

  @override
  State<WeightSelectionDialog> createState() => _WeightSelectionDialogState();
}

class _WeightSelectionDialogState extends State<WeightSelectionDialog> {
  late double _selectedWeight;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedWeight = widget.initialWeight;
    _controller.text = _selectedWeight.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Укажите вес порции'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.productName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          const Text('Вес в граммах:'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffix: Text('г'),
                  ),
                  onChanged: (value) {
                    final weight = double.tryParse(value);
                    if (weight != null && weight > 0) {
                      setState(() {
                        _selectedWeight = weight;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Быстрый выбор:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [50, 100, 150, 200, 250, 300].map((weight) {
              return ActionChip(
                label: Text('${weight}г'),
                onPressed: () {
                  setState(() {
                    _selectedWeight = weight.toDouble();
                    _controller.text = weight.toString();
                  });
                },
                backgroundColor: _selectedWeight == weight
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Отмена'),
        ),
        ElevatedButton(
          onPressed: _selectedWeight > 0
              ? () => Navigator.of(context).pop(_selectedWeight)
              : null,
          child: const Text('Добавить'),
        ),
      ],
    );
  }
}