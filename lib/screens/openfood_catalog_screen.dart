// lib/screens/openfood_catalog_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/hydration_provider.dart';
import '../services/openfoodfacts_service.dart';
import '../models/food_intake.dart';
import '../widgets/common/weight_selection_dialog.dart';

class OpenFoodCatalogScreen extends StatefulWidget {
  const OpenFoodCatalogScreen({super.key});

  @override
  State<OpenFoodCatalogScreen> createState() => _OpenFoodCatalogScreenState();
}

class _OpenFoodCatalogScreenState extends State<OpenFoodCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final OpenFoodFactsService _service = OpenFoodFactsService();
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadTopProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTopProducts() async {
    setState(() {
      _isInitialLoading = true;
      _error = '';
    });

    try {
      print('Loading top products...');
      // Загружаем топ продукты с простым запросом
      final products = await _service.searchProducts('apple banana bread milk');
      print('Loaded ${products.length} top products');
      setState(() {
        _products = products;
        _isInitialLoading = false;
      });
    } catch (e) {
      print('Error loading top products: $e');
      setState(() {
        _error = 'Failed to load products: $e';
        _isInitialLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < 2) {
      if (query.isEmpty) {
        _loadTopProducts();
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      _searchProducts(query);
    });
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().length < 2) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('Searching for: $query');
      final products = await _service.searchProducts(query.trim());
      print('Found ${products.length} products for: $query');
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Search error for "$query": $e');
      setState(() {
        _error = 'Search failed: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.openFoodCatalog),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onSubmitted: _searchProducts,
                decoration: InputDecoration(
                  hintText: l10n.searchProducts,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _loadTopProducts();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator during search
          if (_isLoading)
            const LinearProgressIndicator(),

          // Results
          Expanded(
            child: _buildContent(l10n, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ThemeData theme) {
    if (_isInitialLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading top products...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTopProducts,
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noProductsFound,
              style: TextStyle(color: theme.colorScheme.outline),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(product, l10n, theme);
      },
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product, AppLocalizations l10n, ThemeData theme) {
    final name = product['product_name'] ?? 'Unknown Product';
    final brand = product['brands'] ?? '';
    final nutriments = product['nutriments'] ?? {};
    final calories = (nutriments['energy-kcal_100g'] ?? 0).round();
    final nutriscore = product['nutriscore_grade'] ?? '';
    final isOrganic = _service.isOrganic(product);

    // Получаем URL изображения через сервис
    final imageUrl = _service.getImageUrl(product);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _addProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Product Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.fastfood,
                              color: theme.colorScheme.outline,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.fastfood,
                        color: theme.colorScheme.outline,
                      ),
              ),

              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        brand,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Calories chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getCalorieColor(calories).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$calories kcal',
                            style: TextStyle(
                              color: _getCalorieColor(calories),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Nutri-Score
                        if (nutriscore.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getNutriscoreColor(nutriscore),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              nutriscore.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Organic badge
                        if (isOrganic)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BIO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Add button
              Icon(
                Icons.add_circle_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCalorieColor(int calories) {
    if (calories < 100) return Colors.green;
    if (calories < 300) return Colors.orange;
    return Colors.red;
  }

  Color _getNutriscoreColor(String grade) {
    switch (grade.toLowerCase()) {
      case 'a': return Colors.green.shade700;
      case 'b': return Colors.lightGreen;
      case 'c': return Colors.orange;
      case 'd': return Colors.deepOrange;
      case 'e': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _addProduct(Map<String, dynamic> product) async {
    final context = this.context;
    HapticFeedback.selectionClick();

    final weight = await showDialog<double>(
      context: context,
      builder: (context) => WeightSelectionDialog(
        productName: product['product_name'] ?? 'Product',
      ),
    );

    if (weight == null || !context.mounted) return;

    try {
      final provider = context.read<HydrationProvider>();
      final nutriments = product['nutriments'] ?? {};

      // Calculate nutrition based on weight
      final factor = weight / 100;
      final calories = ((nutriments['energy-kcal_100g'] ?? 0) * factor).round();
      final proteins = (nutriments['proteins_100g'] ?? 0) * factor;
      final carbs = (nutriments['carbohydrates_100g'] ?? 0) * factor;
      final fats = (nutriments['fat_100g'] ?? 0) * factor;
      final sugar = (nutriments['sugars_100g'] ?? 0) * factor;
      final sodium = ((nutriments['sodium_100g'] ?? 0) * factor * 1000).round(); // Convert to mg

      final foodIntake = FoodIntake(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        foodId: product['code'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        foodName: product['product_name'] ?? 'Unknown Product',
        weight: weight,
        calories: calories,
        waterContent: 0, // OpenFoodFacts doesn't provide water content
        sodium: sodium,
        potassium: 0, // Would need additional calculation
        magnesium: 0, // Would need additional calculation
        sugar: sugar,
        proteins: proteins,
        carbohydrates: carbs,
        fats: fats,
        hasCaffeine: false,
        emoji: '🛒',
      );

      provider.addFoodIntake(foodIntake);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added ${product['product_name'] ?? 'product'} (${weight.round()}g)',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}