import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/favorite_product.dart';
import '../services/recipe_ai_service.dart';
import '../providers/hydration_provider.dart';

class RecipeAnalysisScreen extends StatefulWidget {
  final List<FavoriteProduct> products;

  const RecipeAnalysisScreen({super.key, required this.products});

  @override
  State<RecipeAnalysisScreen> createState() => _RecipeAnalysisScreenState();
}

class _RecipeAnalysisScreenState extends State<RecipeAnalysisScreen> {
  final RecipeAIService _recipeService = RecipeAIService.instance;
  RecipeAnalysisResult? _analysisResult;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performAnalysis();
  }

  Future<void> _performAnalysis() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      final result = await _recipeService.analyzeAndGenerateRecipes(
        selectedProducts: widget.products,
        dietMode: provider.carbsDietMode.name,
        language: 'ru',
      );

      setState(() {
        _analysisResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Анализ и рецепты'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          if (!_isLoading && _analysisResult != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _performAnalysis,
              tooltip: 'Обновить анализ',
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState(theme)
              : _analysisResult != null
                  ? _buildAnalysisContent(theme)
                  : _buildEmptyState(theme),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Анализируем продукты и генерируем рецепты...',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'Это может занять несколько секунд',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              'Ошибка анализа',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Неизвестная ошибка',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _performAnalysis,
              child: const Text('Попробовать снова'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return const Center(
      child: Text('Нет данных для анализа'),
    );
  }

  Widget _buildAnalysisContent(ThemeData theme) {
    final result = _analysisResult!;
    final provider = Provider.of<HydrationProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Карточка выбранных продуктов
          _buildSelectedProductsCard(theme),

          const SizedBox(height: 16),

          // Карточка общего анализа питательности
          _buildNutritionAnalysisCard(theme, result.analysis),

          const SizedBox(height: 16),

          // Карточка информации о диете
          _buildDietInfoCard(theme, provider.dietMode),

          const SizedBox(height: 16),

          // Рецепты
          Text(
            'Рекомендованные рецепты',
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...result.recipes.map((recipe) => _buildRecipeCard(theme, recipe)),
        ],
      ),
    );
  }

  Widget _buildSelectedProductsCard(ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выбранные продукты',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.products.map((product) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: product.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.fastfood, size: 20);
                              },
                            ),
                          )
                        : const Icon(Icons.fastfood, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (product.brand != null)
                          Text(
                            product.brand!,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionAnalysisCard(ThemeData theme, ProductAnalysis analysis) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Общий анализ питательности',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Калории
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    'Общие калории',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${analysis.totalCalories.round()} ккал',
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Макронутриенты
            Row(
              children: [
                Expanded(
                  child: _buildMacroContainer(
                    'Белки',
                    '${analysis.totalProteins.toStringAsFixed(1)} г',
                    Colors.green,
                    theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroContainer(
                    'Углеводы',
                    '${analysis.totalCarbs.toStringAsFixed(1)} г',
                    Colors.orange,
                    theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMacroContainer(
                    'Жиры',
                    '${analysis.totalFats.toStringAsFixed(1)} г',
                    Colors.red,
                    theme,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietInfoCard(ThemeData theme, String dietMode) {
    String dietTitle;
    String dietDescription;
    Color dietColor;

    switch (dietMode) {
      case 'keto':
        dietTitle = 'Кето/Низкоуглеводная диета';
        dietDescription = 'Рецепты адаптированы под низкое содержание углеводов и высокое содержание жиров';
        dietColor = Colors.purple;
        break;
      case 'fasting':
        dietTitle = 'Интервальное голодание';
        dietDescription = 'Рецепты оптимизированы для периодов приема пищи';
        dietColor = Colors.blue;
        break;
      default:
        dietTitle = 'Обычное питание';
        dietDescription = 'Сбалансированные рецепты с разнообразными макронутриентами';
        dietColor = Colors.green;
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: dietColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    color: dietColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    dietTitle,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dietDescription,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(ThemeData theme, Recipe recipe) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок рецепта
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(recipe.difficulty).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recipe.difficulty,
                    style: TextStyle(
                      color: _getDifficultyColor(recipe.difficulty),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Описание
            Text(
              recipe.description,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // Время и теги
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  '${recipe.cookingTime} мин',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                if (recipe.tags.isNotEmpty) ...[
                  Icon(
                    Icons.local_offer,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      recipe.tags.take(3).join(', '),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Питательная ценность
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildSmallMacro('${recipe.nutrition.calories.round()} ккал', Colors.orange),
                  const SizedBox(width: 12),
                  _buildSmallMacro('Б: ${recipe.nutrition.proteins.toStringAsFixed(1)}', Colors.green),
                  const SizedBox(width: 12),
                  _buildSmallMacro('Ж: ${recipe.nutrition.fats.toStringAsFixed(1)}', Colors.red),
                  const SizedBox(width: 12),
                  _buildSmallMacro('У: ${recipe.nutrition.carbs.toStringAsFixed(1)}', Colors.blue),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Кнопка для просмотра полного рецепта
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _showFullRecipe(recipe),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.primaryColor,
                  side: BorderSide(color: theme.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Посмотреть рецепт'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroContainer(String label, String value, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMacro(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'легко':
      case 'easy':
        return Colors.green;
      case 'средне':
      case 'medium':
        return Colors.orange;
      case 'сложно':
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFullRecipe(Recipe recipe) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FullRecipeModal(recipe: recipe),
    );
  }
}

class _FullRecipeModal extends StatelessWidget {
  final Recipe recipe;

  const _FullRecipeModal({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    recipe.name,
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Ingredients
                  Text(
                    'Ингредиенты:',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontSize: 16)),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),

                  // Instructions
                  Text(
                    'Приготовление:',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...recipe.instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  )),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}