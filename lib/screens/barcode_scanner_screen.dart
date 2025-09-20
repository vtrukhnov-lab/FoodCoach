import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../services/openfoodfacts_service.dart';
import '../widgets/common/weight_selection_dialog.dart';
import '../providers/hydration_provider.dart';
import '../models/food_intake.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Сканировать продукт'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
                  case TorchState.off:
                    return const Icon(Icons.flash_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flash_on, color: Colors.yellow);
                }
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                return const Icon(Icons.camera_front);
              },
            ),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _processBarcode(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          // Overlay with scanning area
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: Container(),
          ),
          // Instructions
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Наведите камеру на штрих-код продукта',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final product = await OpenFoodFactsService.instance.getProduct(barcode);

      if (product != null && mounted) {
        // Show weight selection dialog
        final weight = await showDialog<double>(
          context: context,
          builder: (context) => WeightSelectionDialog(
            productName: product['product_name'] ?? 'Неизвестный продукт',
          ),
        );

        if (weight != null && mounted) {
          // Calculate nutrition per selected weight
          final calories = ((product['nutriments']?['energy-kcal_100g'] ?? 0) * weight / 100).round();
          final proteins = ((product['nutriments']?['proteins_100g'] ?? 0) * weight / 100);
          final carbs = ((product['nutriments']?['carbohydrates_100g'] ?? 0) * weight / 100);
          final fats = ((product['nutriments']?['fat_100g'] ?? 0) * weight / 100);
          final sodium = ((product['nutriments']?['sodium_100g'] ?? 0) * weight / 100 * 1000).round(); // Convert to mg
          final sugar = ((product['nutriments']?['sugars_100g'] ?? 0) * weight / 100);

          // Create food intake
          final foodIntake = FoodIntake(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            foodId: barcode,
            foodName: product['product_name'] ?? 'Неизвестный продукт',
            weight: weight,
            calories: calories,
            waterContent: 0, // Food water content is usually not available in OpenFoodFacts
            sodium: sodium,
            potassium: 0, // Usually not available
            magnesium: 0, // Usually not available
            sugar: sugar,
            proteins: proteins,
            carbohydrates: carbs,
            fats: fats,
          );

          // Add to provider
          final hydrationProvider = Provider.of<HydrationProvider>(context, listen: false);
          hydrationProvider.addFoodIntake(foodIntake);

          // Show success and return
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Добавлено: ${foodIntake.foodName}'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Продукт не найден в базе данных'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final scanAreaSize = size.width * 0.7;
    final scanAreaLeft = centerX - scanAreaSize / 2;
    final scanAreaTop = centerY - scanAreaSize / 2;

    // Draw overlay with transparent scanning area
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw scanning area border
    final borderPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      Rect.fromLTWH(scanAreaLeft, scanAreaTop, scanAreaSize, scanAreaSize),
      borderPaint,
    );

    // Draw corner indicators
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    const cornerLength = 30.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      Offset(scanAreaLeft, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}