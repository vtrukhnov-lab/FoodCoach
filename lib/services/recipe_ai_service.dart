import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/favorite_product.dart';

class RecipeAIService {
  static final RecipeAIService _instance = RecipeAIService._internal();
  factory RecipeAIService() => _instance;
  RecipeAIService._internal();

  static RecipeAIService get instance => _instance;

  // TODO: Вставить ваш API ключ здесь
  static const String _apiKey = 'YOUR_API_KEY_HERE';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  /// Анализирует продукты из избранного и генерирует рецепты
  Future<RecipeAnalysisResult> analyzeAndGenerateRecipes({
    required List<FavoriteProduct> selectedProducts,
    required String dietMode,
    String language = 'ru',
  }) async {
    try {
      final analysis = _analyzeProducts(selectedProducts);
      final recipes = await _generateRecipes(selectedProducts, dietMode, language);

      return RecipeAnalysisResult(
        analysis: analysis,
        recipes: recipes,
        totalCalories: analysis.totalCalories,
        totalProteins: analysis.totalProteins,
        totalCarbs: analysis.totalCarbs,
        totalFats: analysis.totalFats,
      );
    } catch (e) {
      throw Exception('Ошибка анализа продуктов: $e');
    }
  }

  /// Анализирует питательную ценность выбранных продуктов
  ProductAnalysis _analyzeProducts(List<FavoriteProduct> products) {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalCarbs = 0;
    double totalFats = 0;
    double totalFiber = 0;
    double totalSugar = 0;

    final productAnalyses = <SingleProductAnalysis>[];

    for (final product in products) {
      final nutriments = product.nutriments;

      // Рассчитываем на 100г продукта
      final calories = (nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0).toDouble();
      final proteins = (nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0).toDouble();
      final carbs = (nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0).toDouble();
      final fats = (nutriments['fat_100g'] ?? nutriments['fat'] ?? 0).toDouble();
      final fiber = (nutriments['fiber_100g'] ?? nutriments['fiber'] ?? 0).toDouble();
      final sugar = (nutriments['sugars_100g'] ?? nutriments['sugars'] ?? 0).toDouble();

      totalCalories += calories;
      totalProteins += proteins;
      totalCarbs += carbs;
      totalFats += fats;
      totalFiber += fiber;
      totalSugar += sugar;

      productAnalyses.add(SingleProductAnalysis(
        product: product,
        calories: calories,
        proteins: proteins,
        carbs: carbs,
        fats: fats,
        fiber: fiber,
        sugar: sugar,
      ));
    }

    return ProductAnalysis(
      products: productAnalyses,
      totalCalories: totalCalories,
      totalProteins: totalProteins,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
      totalFiber: totalFiber,
      totalSugar: totalSugar,
    );
  }

  /// Генерирует рецепты через AI API
  Future<List<Recipe>> _generateRecipes(
    List<FavoriteProduct> products,
    String dietMode,
    String language,
  ) async {
    try {
      final prompt = _buildPrompt(products, dietMode, language);

      final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': _getSystemPrompt(dietMode, language),
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 2000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return _parseRecipesFromResponse(content);
    } else if (response.statusCode == 429) {
      throw Exception('Превышен лимит запросов к AI. Попробуйте позже (через несколько минут)');
    } else if (response.statusCode == 401) {
      throw Exception('Неверный API ключ. Проверьте настройки');
    } else {
      throw Exception('Ошибка AI API: ${response.statusCode}. ${response.body}');
    }
    } catch (e) {
      print('AI API Error: $e');
      // Возвращаем fallback рецепты при любой ошибке API
      return _generateFallbackRecipes(products, dietMode);
    }
  }

  /// Генерирует fallback рецепты при ошибках API
  List<Recipe> _generateFallbackRecipes(List<FavoriteProduct> products, String dietMode) {
    final recipes = <Recipe>[];

    // Анализируем типы продуктов
    final hasVegetables = products.any((p) =>
      p.name.toLowerCase().contains('овощ') ||
      p.name.toLowerCase().contains('салат') ||
      p.name.toLowerCase().contains('капуст') ||
      p.name.toLowerCase().contains('морков') ||
      p.name.toLowerCase().contains('огурец'));

    final hasProteins = products.any((p) =>
      p.name.toLowerCase().contains('мясо') ||
      p.name.toLowerCase().contains('курица') ||
      p.name.toLowerCase().contains('рыба') ||
      p.name.toLowerCase().contains('яйц') ||
      p.name.toLowerCase().contains('творог'));

    final hasDairy = products.any((p) =>
      p.name.toLowerCase().contains('молоко') ||
      p.name.toLowerCase().contains('сыр') ||
      p.name.toLowerCase().contains('йогурт') ||
      p.name.toLowerCase().contains('кефир'));

    final hasGrains = products.any((p) =>
      p.name.toLowerCase().contains('хлеб') ||
      p.name.toLowerCase().contains('крупа') ||
      p.name.toLowerCase().contains('рис') ||
      p.name.toLowerCase().contains('макарон'));

    // Генерируем рецепты на основе анализа
    if (dietMode == 'keto') {
      if (hasProteins && hasVegetables) {
        recipes.add(_createKetoMeatVeggieRecipe(products));
      }
      if (hasDairy) {
        recipes.add(_createKetoCheeseRecipe(products));
      }
      recipes.add(_createKetoSaladRecipe(products));
    } else {
      if (hasProteins && hasVegetables) {
        recipes.add(_createBalancedMainDishRecipe(products));
      }
      if (hasGrains) {
        recipes.add(_createGrainBasedRecipe(products));
      }
      recipes.add(_createQuickMixRecipe(products));
    }

    return recipes.take(3).toList();
  }

  Recipe _createKetoMeatVeggieRecipe(List<FavoriteProduct> products) {
    final proteins = products.where((p) =>
      p.name.toLowerCase().contains('мясо') ||
      p.name.toLowerCase().contains('курица') ||
      p.name.toLowerCase().contains('рыба')).toList();
    final veggies = products.where((p) =>
      p.name.toLowerCase().contains('овощ') ||
      p.name.toLowerCase().contains('салат')).toList();

    return Recipe(
      name: 'Кето-жаркое с ${proteins.isNotEmpty ? proteins.first.name.toLowerCase() : "белком"}',
      description: 'Сытное низкоуглеводное блюдо с высоким содержанием жиров',
      cookingTime: '25',
      difficulty: 'средне',
      ingredients: [
        ...products.map((p) => p.name),
        'оливковое масло',
        'чеснок',
        'специи',
        'соль'
      ],
      instructions: [
        'Разогреть масло в сковороде',
        'Обжарить ${proteins.isNotEmpty ? proteins.first.name.toLowerCase() : "белок"} до золотистой корочки',
        'Добавить ${veggies.isNotEmpty ? veggies.first.name.toLowerCase() : "овощи"} и тушить 10 минут',
        'Приправить специями и подавать горячим'
      ],
      nutrition: RecipeNutrition(calories: 320, proteins: 28, carbs: 6, fats: 22),
      tags: ['кето', 'белок', 'сытно', 'обед'],
    );
  }

  Recipe _createKetoCheeseRecipe(List<FavoriteProduct> products) {
    final dairy = products.where((p) =>
      p.name.toLowerCase().contains('сыр') ||
      p.name.toLowerCase().contains('творог')).toList();

    return Recipe(
      name: 'Запеканка с ${dairy.isNotEmpty ? dairy.first.name.toLowerCase() : "сыром"}',
      description: 'Нежная кето-запеканка без углеводов',
      cookingTime: '30',
      difficulty: 'легко',
      ingredients: [
        ...products.take(4).map((p) => p.name),
        'яйца',
        'сливки',
        'зелень'
      ],
      instructions: [
        'Смешать ${dairy.isNotEmpty ? dairy.first.name.toLowerCase() : "творог"} с яйцами',
        'Добавить остальные ингредиенты',
        'Запекать в духовке при 180°C 25 минут',
        'Подавать теплым'
      ],
      nutrition: RecipeNutrition(calories: 280, proteins: 18, carbs: 4, fats: 20),
      tags: ['кето', 'запеканка', 'завтрак', 'ужин'],
    );
  }

  Recipe _createKetoSaladRecipe(List<FavoriteProduct> products) {
    return Recipe(
      name: 'Кето-салат из избранного',
      description: 'Свежий салат с высоким содержанием полезных жиров',
      cookingTime: '15',
      difficulty: 'легко',
      ingredients: [
        ...products.take(5).map((p) => p.name),
        'авокадо',
        'оливковое масло',
        'лимонный сок',
        'орехи'
      ],
      instructions: [
        'Нарезать все ингредиенты',
        'Смешать в салатнице',
        'Заправить маслом и лимонным соком',
        'Посыпать орехами'
      ],
      nutrition: RecipeNutrition(calories: 250, proteins: 8, carbs: 5, fats: 22),
      tags: ['кето', 'салат', 'быстро', 'полезно'],
    );
  }

  Recipe _createBalancedMainDishRecipe(List<FavoriteProduct> products) {
    return Recipe(
      name: 'Сбалансированное рагу',
      description: 'Питательное блюдо с оптимальным соотношением БЖУ',
      cookingTime: '35',
      difficulty: 'средне',
      ingredients: [
        ...products.map((p) => p.name),
        'лук',
        'томаты',
        'бульон',
        'зелень'
      ],
      instructions: [
        'Обжарить лук до золотистого цвета',
        'Добавить основные ингредиенты',
        'Тушить в бульоне 20 минут',
        'Украсить зеленью перед подачей'
      ],
      nutrition: RecipeNutrition(calories: 220, proteins: 18, carbs: 25, fats: 8),
      tags: ['сбалансированно', 'обед', 'ужин', 'питательно'],
    );
  }

  Recipe _createGrainBasedRecipe(List<FavoriteProduct> products) {
    final grains = products.where((p) =>
      p.name.toLowerCase().contains('рис') ||
      p.name.toLowerCase().contains('крупа')).toList();

    return Recipe(
      name: 'Каша с добавками',
      description: 'Энергетическое блюдо на основе злаков',
      cookingTime: '20',
      difficulty: 'легко',
      ingredients: [
        ...products.map((p) => p.name),
        'вода или молоко',
        'соль',
        'масло'
      ],
      instructions: [
        'Варить ${grains.isNotEmpty ? grains.first.name.toLowerCase() : "крупу"} согласно инструкции',
        'Добавить остальные ингредиенты',
        'Перемешать и дать настояться',
        'Подавать горячим'
      ],
      nutrition: RecipeNutrition(calories: 180, proteins: 12, carbs: 28, fats: 5),
      tags: ['злаки', 'завтрак', 'энергия', 'быстро'],
    );
  }

  Recipe _createQuickMixRecipe(List<FavoriteProduct> products) {
    return Recipe(
      name: 'Быстрый микс из избранного',
      description: 'Простое и вкусное сочетание ваших продуктов',
      cookingTime: '10',
      difficulty: 'легко',
      ingredients: [
        ...products.take(6).map((p) => p.name),
        'специи',
        'лимон'
      ],
      instructions: [
        'Подготовить все ингредиенты',
        'Смешать в подходящей посуде',
        'Приправить по вкусу',
        'Подавать свежим'
      ],
      nutrition: RecipeNutrition(calories: 160, proteins: 10, carbs: 18, fats: 6),
      tags: ['быстро', 'легко', 'микс', 'универсально'],
    );
  }

  String _getSystemPrompt(String dietMode, String language) {
    final dietContext = _getDietContext(dietMode);

    if (language == 'ru') {
      return '''Ты - профессиональный шеф-повар и диетолог.
Твоя задача - создавать вкусные и полезные рецепты на основе предоставленных продуктов.

Контекст диеты: $dietContext

Отвечай ТОЛЬКО в формате JSON с массивом рецептов:
{
  "recipes": [
    {
      "name": "Название рецепта",
      "description": "Краткое описание",
      "cookingTime": "время приготовления в минутах",
      "difficulty": "легко/средне/сложно",
      "ingredients": ["ингредиент 1", "ингредиент 2"],
      "instructions": ["шаг 1", "шаг 2"],
      "nutrition": {
        "calories": 0,
        "proteins": 0,
        "carbs": 0,
        "fats": 0
      },
      "tags": ["тег1", "тег2"]
    }
  ]
}''';
    } else {
      return '''You are a professional chef and nutritionist.
Your task is to create delicious and healthy recipes based on the provided products.

Diet context: $dietContext

Respond ONLY in JSON format with recipe array:
{
  "recipes": [
    {
      "name": "Recipe name",
      "description": "Brief description",
      "cookingTime": "cooking time in minutes",
      "difficulty": "easy/medium/hard",
      "ingredients": ["ingredient 1", "ingredient 2"],
      "instructions": ["step 1", "step 2"],
      "nutrition": {
        "calories": 0,
        "proteins": 0,
        "carbs": 0,
        "fats": 0
      },
      "tags": ["tag1", "tag2"]
    }
  ]
}''';
    }
  }

  String _getDietContext(String dietMode) {
    switch (dietMode) {
      case 'keto':
        return 'Кето-диета: очень низкое содержание углеводов (менее 20г в день), высокое содержание жиров, умеренное белков. Избегай сахара, крахмала, круп.';
      case 'fasting':
        return 'Интервальное голодание: легкие, питательные блюда для периодов приема пищи. Сбалансированные макросы.';
      default:
        return 'Обычное сбалансированное питание: разнообразные блюда с оптимальным соотношением БЖУ.';
    }
  }

  String _buildPrompt(List<FavoriteProduct> products, String dietMode, String language) {
    // Детальная информация о продуктах
    final productDetails = products.map((p) {
      final nutriments = p.nutriments;
      final calories = (nutriments['energy-kcal_100g'] ?? 0).round();
      final proteins = (nutriments['proteins_100g'] ?? 0).toStringAsFixed(1);
      final carbs = (nutriments['carbohydrates_100g'] ?? 0).toStringAsFixed(1);
      final fats = (nutriments['fat_100g'] ?? 0).toStringAsFixed(1);

      return '''${p.name} ${p.brand ?? ''} - Калории: ${calories} ккал/100г, Белки: ${proteins}г, Углеводы: ${carbs}г, Жиры: ${fats}г''';
    }).join('\n');

    if (language == 'ru') {
      return '''Создай 3 РАЗНЫХ креативных рецепта используя эти продукты с их питательной ценностью:

$productDetails

Требования:
- Тип питания: ${_getDietModeText(dietMode)}
- ОБЯЗАТЕЛЬНО используй хотя бы 2-3 продукта из списка в каждом рецепте
- Добавь реалистичные дополнительные ингредиенты
- Рецепты должны быть РАЗНООБРАЗНЫМИ (не только салаты!)
- Один рецепт для завтрака, один для обеда, один для ужина
- Учитывай калорийность и БЖУ продуктов
- Укажи точное время приготовления в минутах
- Добавь конкретные пошаговые инструкции
- Используй разные способы приготовления (жарка, варка, запекание)''';
    } else {
      return '''Create 3 DIFFERENT creative recipes using these products with their nutritional values:

$productDetails

Requirements:
- Diet type: ${_getDietModeText(dietMode)}
- MUST use at least 2-3 products from the list in each recipe
- Add realistic additional ingredients
- Recipes should be DIVERSE (not just salads!)
- One recipe for breakfast, one for lunch, one for dinner
- Consider calories and macros of products
- Specify exact cooking time in minutes
- Add specific step-by-step instructions
- Use different cooking methods (frying, boiling, baking)''';
    }
  }

  String _getDietModeText(String mode) {
    switch (mode) {
      case 'keto': return 'кето/низкоуглеводная';
      case 'fasting': return 'интервальное голодание';
      default: return 'обычное питание';
    }
  }

  List<Recipe> _parseRecipesFromResponse(String response) {
    try {
      final cleanResponse = response.trim();
      final data = jsonDecode(cleanResponse);
      final recipesJson = data['recipes'] as List;

      return recipesJson.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      // Fallback для случаев когда AI не вернул корректный JSON
      return [
        Recipe(
          name: 'Ошибка генерации',
          description: 'Не удалось сгенерировать рецепт. Попробуйте еще раз.',
          cookingTime: '0',
          difficulty: 'легко',
          ingredients: [],
          instructions: [],
          nutrition: RecipeNutrition(calories: 0, proteins: 0, carbs: 0, fats: 0),
          tags: [],
        ),
      ];
    }
  }
}

// Модели данных

class RecipeAnalysisResult {
  final ProductAnalysis analysis;
  final List<Recipe> recipes;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;

  RecipeAnalysisResult({
    required this.analysis,
    required this.recipes,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
  });
}

class ProductAnalysis {
  final List<SingleProductAnalysis> products;
  final double totalCalories;
  final double totalProteins;
  final double totalCarbs;
  final double totalFats;
  final double totalFiber;
  final double totalSugar;

  ProductAnalysis({
    required this.products,
    required this.totalCalories,
    required this.totalProteins,
    required this.totalCarbs,
    required this.totalFats,
    required this.totalFiber,
    required this.totalSugar,
  });
}

class SingleProductAnalysis {
  final FavoriteProduct product;
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;
  final double fiber;
  final double sugar;

  SingleProductAnalysis({
    required this.product,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.sugar,
  });
}

class Recipe {
  final String name;
  final String description;
  final String cookingTime;
  final String difficulty;
  final List<String> ingredients;
  final List<String> instructions;
  final RecipeNutrition nutrition;
  final List<String> tags;

  Recipe({
    required this.name,
    required this.description,
    required this.cookingTime,
    required this.difficulty,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    required this.tags,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      cookingTime: json['cookingTime']?.toString() ?? '0',
      difficulty: json['difficulty'] ?? 'легко',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      nutrition: RecipeNutrition.fromJson(json['nutrition'] ?? {}),
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}

class RecipeNutrition {
  final double calories;
  final double proteins;
  final double carbs;
  final double fats;

  RecipeNutrition({
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.fats,
  });

  factory RecipeNutrition.fromJson(Map<String, dynamic> json) {
    return RecipeNutrition(
      calories: (json['calories'] ?? 0).toDouble(),
      proteins: (json['proteins'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fats: (json['fats'] ?? 0).toDouble(),
    );
  }
}