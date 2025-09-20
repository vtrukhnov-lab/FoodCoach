import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static final OpenFoodFactsService _instance = OpenFoodFactsService._internal();
  factory OpenFoodFactsService() => _instance;
  OpenFoodFactsService._internal();

  static OpenFoodFactsService get instance => _instance;

  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v0';

  Future<void> initialize() async {
    // Initialization logic if needed
  }

  /// Get product information by barcode
  Future<Map<String, dynamic>?> getProduct(String barcode) async {
    try {
      final url = '$_baseUrl/product/$barcode.json';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 1 && data['product'] != null) {
          return data['product'] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      print('Error fetching product: $e');
      return null;
    }
  }

  /// Search products by name
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final url = '$_baseUrl/cgi/search.pl?search_terms=$query&search_simple=1&action=process&json=1';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['products'] != null) {
          return List<Map<String, dynamic>>.from(data['products']);
        }
      }

      return [];
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }

  /// Get nutrition facts for a product
  Map<String, dynamic> getNutritionFacts(Map<String, dynamic> product, double weightInGrams) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Calculate nutrition per serving weight
    final factor = weightInGrams / 100; // OpenFoodFacts data is per 100g

    return {
      'calories': ((nutriments['energy-kcal_100g'] ?? 0) * factor).round(),
      'proteins': ((nutriments['proteins_100g'] ?? 0) * factor),
      'carbohydrates': ((nutriments['carbohydrates_100g'] ?? 0) * factor),
      'fats': ((nutriments['fat_100g'] ?? 0) * factor),
      'sugars': ((nutriments['sugars_100g'] ?? 0) * factor),
      'fiber': ((nutriments['fiber_100g'] ?? 0) * factor),
      'sodium': ((nutriments['sodium_100g'] ?? 0) * factor * 1000).round(), // Convert to mg
      'saturated_fats': ((nutriments['saturated-fat_100g'] ?? 0) * factor),
      'trans_fats': ((nutriments['trans-fat_100g'] ?? 0) * factor),
      'cholesterol': ((nutriments['cholesterol_100g'] ?? 0) * factor),
      'calcium': ((nutriments['calcium_100g'] ?? 0) * factor),
      'iron': ((nutriments['iron_100g'] ?? 0) * factor),
      'vitamin_c': ((nutriments['vitamin-c_100g'] ?? 0) * factor),
    };
  }

  /// Check if product contains allergens
  List<String> getAllergens(Map<String, dynamic> product) {
    final allergens = <String>[];

    // Check allergens tags
    final allergensTags = product['allergens_tags'] as List<dynamic>? ?? [];
    for (final tag in allergensTags) {
      final allergen = tag.toString().replaceFirst('en:', '');
      allergens.add(allergen);
    }

    return allergens;
  }

  /// Get product image URL
  String? getProductImageUrl(Map<String, dynamic> product) {
    // Try to get the front image first
    final images = product['images'] as Map<String, dynamic>? ?? {};

    if (images.containsKey('front_small_url')) {
      return images['front_small_url'] as String?;
    }

    if (images.containsKey('front_url')) {
      return images['front_url'] as String?;
    }

    // Fallback to selected images
    final selectedImages = product['selected_images'] as Map<String, dynamic>? ?? {};
    final frontImage = selectedImages['front'] as Map<String, dynamic>? ?? {};
    final display = frontImage['display'] as Map<String, dynamic>? ?? {};

    return display['en'] as String?;
  }

  /// Get product brand
  String? getProductBrand(Map<String, dynamic> product) {
    return product['brands'] as String? ?? product['brand'] as String?;
  }

  /// Get product categories
  List<String> getProductCategories(Map<String, dynamic> product) {
    final categories = <String>[];

    // Get categories from tags
    final categoriesTags = product['categories_tags'] as List<dynamic>? ?? [];
    for (final tag in categoriesTags) {
      final category = tag.toString().replaceFirst('en:', '');
      categories.add(category);
    }

    return categories;
  }

  /// Check if product is organic
  bool isOrganic(Map<String, dynamic> product) {
    final labels = product['labels_tags'] as List<dynamic>? ?? [];
    return labels.any((label) => label.toString().contains('organic'));
  }

  /// Check if product is vegetarian/vegan
  String? getDietaryInfo(Map<String, dynamic> product) {
    final labels = product['labels_tags'] as List<dynamic>? ?? [];

    if (labels.any((label) => label.toString().contains('vegan'))) {
      return 'vegan';
    }

    if (labels.any((label) => label.toString().contains('vegetarian'))) {
      return 'vegetarian';
    }

    return null;
  }

  /// Get Nova score (food processing level)
  int? getNovaScore(Map<String, dynamic> product) {
    final novaGroup = product['nova_group'];
    if (novaGroup != null) {
      return novaGroup as int;
    }
    return null;
  }

  /// Get Nutri-Score
  String? getNutriScore(Map<String, dynamic> product) {
    return product['nutriscore_grade'] as String?;
  }
}