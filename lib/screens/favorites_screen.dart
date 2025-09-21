import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/favorite_product.dart';
import '../services/favorites_service.dart';
import '../services/openfoodfacts_service.dart';
import '../widgets/common/weight_selection_dialog.dart';
import '../providers/hydration_provider.dart';
import '../models/food_intake.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final OpenFoodFactsService _openFoodService = OpenFoodFactsService();
  List<FavoriteProduct> _favorites = [];
  Set<String> _selectedProducts = {};
  bool _isLoading = true;
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final favorites = await _favoritesService.getFavorites();
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
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
        title: Text(_isSelectionMode
          ? '${_selectedProducts.length} выбрано'
          : 'Избранное'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (_favorites.isNotEmpty && !_isSelectionMode)
            IconButton(
              icon: const Icon(Icons.auto_awesome),
              tooltip: 'Анализ и рецепты',
              onPressed: () {
                setState(() {
                  _isSelectionMode = true;
                });
              },
            ),
          if (_isSelectionMode) ...[
            TextButton(
              onPressed: _selectedProducts.isEmpty
                ? null
                : () => _analyzeSelectedProducts(),
              child: const Text('Анализ'),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _selectedProducts.clear();
                });
              },
            ),
          ]
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? _buildEmptyState(theme)
              : _buildFavoritesList(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: theme.colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'Пока нет избранных продуктов',
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Добавьте продукты в избранное из поиска\nили сканирования штрих-кодов',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.outline.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final product = _favorites[index];
        return _buildFavoriteCard(product, theme);
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteProduct product, ThemeData theme) {
    final calories = (product.nutriments['energy-kcal_100g'] ?? 0).round();
    final nutriscore = product.nutriments['nutriscore_grade'] ?? '';
    final isOrganic = _openFoodService.isOrganic(product.nutriments);
    final isSelected = _selectedProducts.contains(product.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _isSelectionMode
          ? _toggleProductSelection(product.id)
          : _addFavoriteProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: _isSelectionMode && isSelected
              ? Border.all(color: theme.primaryColor, width: 2)
              : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleProductSelection(product.id),
                    ),
                  ),
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
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl!,
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
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (product.brand != null && product.brand!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand!,
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

                // Actions (только в обычном режиме)
                if (!_isSelectionMode)
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _addFavoriteProduct(product),
                        icon: Icon(
                          Icons.add_circle_outline,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeFavorite(product),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
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

  Future<void> _addFavoriteProduct(FavoriteProduct product) async {
    final context = this.context;
    HapticFeedback.selectionClick();

    final result = await showDialog<WeightSelectionResult>(
      context: context,
      builder: (context) => WeightSelectionDialog(
        productName: product.name,
        productImage: product.imageUrl,
        productData: {
          'product_name': product.name,
          'brands': product.brand,
        },
      ),
    );

    if (result == null || !context.mounted) return;

    final weight = result.weight;

    try {
      final provider = context.read<HydrationProvider>();
      final nutriments = product.nutriments;

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
        foodId: product.id,
        foodName: product.name,
        weight: weight,
        calories: calories,
        waterContent: 0,
        sodium: sodium,
        potassium: 0,
        magnesium: 0,
        sugar: sugar,
        proteins: proteins,
        carbohydrates: carbs,
        fats: fats,
        hasCaffeine: false,
        emoji: '⭐',
      );

      provider.addFoodIntake(foodIntake);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Добавлено: ${product.name} (${weight.round()}г)'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка добавления продукта: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(FavoriteProduct product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из избранного?'),
        content: Text('Удалить "${product.name}" из избранного?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _favoritesService.removeFavorite(product.id);
        await _loadFavorites(); // Reload favorites list

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Удалено из избранного: ${product.name}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }

  void _toggleProductSelection(String productId) {
    setState(() {
      if (_selectedProducts.contains(productId)) {
        _selectedProducts.remove(productId);
      } else {
        _selectedProducts.add(productId);
      }
    });
  }

  void _analyzeSelectedProducts() {
    if (_selectedProducts.isEmpty) return;

    final selectedProductsList = _favorites
        .where((product) => _selectedProducts.contains(product.id))
        .toList();

    // Переходим к экрану анализа рецептов
    Navigator.pushNamed(
      context,
      '/recipe_analysis',
      arguments: {
        'products': selectedProductsList,
      },
    );
  }
}