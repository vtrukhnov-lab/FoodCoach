import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenFoodFactsService {
  static final OpenFoodFactsService _instance = OpenFoodFactsService._internal();
  factory OpenFoodFactsService() => _instance;
  OpenFoodFactsService._internal();

  static OpenFoodFactsService get instance => _instance;

  static const String _baseUrlV3 = 'https://world.openfoodfacts.org/api/v3';
  static const String _baseUrlV0 = 'https://world.openfoodfacts.org';

  Future<void> initialize() async {
    // Initialization logic if needed
  }

  /// Get product information by barcode
  Future<Map<String, dynamic>?> getProduct(String barcode) async {
    try {
      final url = '$_baseUrlV0/api/v0/product/$barcode.json';

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

  /// Search products by name with multiple fallback methods
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (query.trim().isEmpty) return [];

    // Try V3 API first (preferred)
    final v3Results = await _searchV3(query);
    if (v3Results.isNotEmpty) {
      return v3Results.take(20).toList();
    }

    // Fallback to V0 API methods
    final v0Results = await _searchV0Fallbacks(query);
    return v0Results.take(20).toList();
  }

  /// V3 API search (preferred)
  Future<List<Map<String, dynamic>>> _searchV3(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final fields = 'code,product_name,brands,nutriments,images,nutriscore_grade,nova_group,labels_tags';
      final url = '$_baseUrlV3/search?q=$encodedQuery&page_size=20&fields=$fields';

      print('Trying V3 API: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['products'] != null) {
          final products = List<Map<String, dynamic>>.from(data['products']);
          print('V3 API returned ${products.length} products');
          return products;
        }
      } else {
        print('V3 API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('V3 API error: $e');
    }

    return [];
  }

  /// V0 API fallback methods
  Future<List<Map<String, dynamic>>> _searchV0Fallbacks(String query) async {
    final encodedQuery = Uri.encodeComponent(query);

    // Method 1: cgi/search.pl
    try {
      final url1 = '$_baseUrlV0/cgi/search.pl?search_terms=$encodedQuery&search_simple=1&action=process&json=1&page_size=20';
      print('Trying V0 Method 1: $url1');

      final response1 = await http.get(
        Uri.parse(url1),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
        },
      ).timeout(const Duration(seconds: 12));

      if (response1.statusCode == 200) {
        final data1 = json.decode(response1.body);
        if (data1['products'] != null) {
          final products = List<Map<String, dynamic>>.from(data1['products']);
          print('V0 Method 1 returned ${products.length} products');
          if (products.isNotEmpty) return products;
        }
      }
    } catch (e) {
      print('V0 Method 1 error: $e');
    }

    // Method 2: api/v0/search
    try {
      final url2 = '$_baseUrlV0/api/v0/search?search_terms=$encodedQuery&json=1&page_size=20';
      print('Trying V0 Method 2: $url2');

      final response2 = await http.get(
        Uri.parse(url2),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
        },
      ).timeout(const Duration(seconds: 12));

      if (response2.statusCode == 200) {
        final data2 = json.decode(response2.body);
        if (data2['products'] != null) {
          final products = List<Map<String, dynamic>>.from(data2['products']);
          print('V0 Method 2 returned ${products.length} products');
          if (products.isNotEmpty) return products;
        }
      }
    } catch (e) {
      print('V0 Method 2 error: $e');
    }

    // Method 3: simple search
    try {
      final url3 = '$_baseUrlV0/search?search_terms=$encodedQuery&json=1&page_size=20';
      print('Trying V0 Method 3: $url3');

      final response3 = await http.get(
        Uri.parse(url3),
        headers: {
          'User-Agent': 'FoodCoach - Flutter App',
        },
      ).timeout(const Duration(seconds: 12));

      if (response3.statusCode == 200) {
        final data3 = json.decode(response3.body);
        if (data3['products'] != null) {
          final products = List<Map<String, dynamic>>.from(data3['products']);
          print('V0 Method 3 returned ${products.length} products');
          return products;
        }
      }
    } catch (e) {
      print('V0 Method 3 error: $e');
    }

    print('All search methods failed for query: $query');
    return [];
  }

  /// Get nutrition facts for a product
  Map<String, dynamic> getNutritionFacts(Map<String, dynamic> product, double weightInGrams) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};

    // Calculate nutrition per serving weight
    final factor = weightInGrams / 100; // OpenFoodFacts data is per 100g

    return {
      'calories': ((nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0) * factor).round(),
      'proteins': ((nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0) * factor),
      'carbohydrates': ((nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0) * factor),
      'fats': ((nutriments['fat_100g'] ?? nutriments['fat'] ?? 0) * factor),
      'sugars': ((nutriments['sugars_100g'] ?? nutriments['sugars'] ?? 0) * factor),
      'fiber': ((nutriments['fiber_100g'] ?? nutriments['fiber'] ?? 0) * factor),
      'sodium': ((nutriments['sodium_100g'] ?? nutriments['sodium'] ?? 0) * factor * 1000).round(), // Convert to mg
      'saturated_fats': ((nutriments['saturated-fat_100g'] ?? nutriments['saturated-fat'] ?? 0) * factor),
      'trans_fats': ((nutriments['trans-fat_100g'] ?? nutriments['trans-fat'] ?? 0) * factor),
      'cholesterol': ((nutriments['cholesterol_100g'] ?? nutriments['cholesterol'] ?? 0) * factor),
      'calcium': ((nutriments['calcium_100g'] ?? nutriments['calcium'] ?? 0) * factor),
      'iron': ((nutriments['iron_100g'] ?? nutriments['iron'] ?? 0) * factor),
      'vitamin_c': ((nutriments['vitamin-c_100g'] ?? nutriments['vitamin-c'] ?? 0) * factor),
    };
  }

  /// Check if product contains allergens
  List<String> getAllergens(Map<String, dynamic> product) {
    final allergens = <String>[];

    // Check allergens tags
    final allergensTags = product['allergens_tags'] as List<dynamic>? ?? [];

    for (final tag in allergensTags) {
      final allergen = tag.toString().toLowerCase();
      if (allergen.contains('gluten')) allergens.add('Gluten');
      if (allergen.contains('milk')) allergens.add('Milk');
      if (allergen.contains('eggs')) allergens.add('Eggs');
      if (allergen.contains('fish')) allergens.add('Fish');
      if (allergen.contains('crustaceans')) allergens.add('Crustaceans');
      if (allergen.contains('tree-nuts')) allergens.add('Tree nuts');
      if (allergen.contains('peanuts')) allergens.add('Peanuts');
      if (allergen.contains('soybeans')) allergens.add('Soy');
      if (allergen.contains('celery')) allergens.add('Celery');
      if (allergen.contains('mustard')) allergens.add('Mustard');
      if (allergen.contains('sesame')) allergens.add('Sesame');
      if (allergen.contains('sulphur')) allergens.add('Sulphites');
      if (allergen.contains('lupin')) allergens.add('Lupin');
      if (allergen.contains('molluscs')) allergens.add('Molluscs');
    }

    return allergens.toSet().toList(); // Remove duplicates
  }

  /// Get product image URL
  String? getImageUrl(Map<String, dynamic> product) {
    final images = product['images'] as Map<String, dynamic>?;

    if (images != null) {
      // Try different image sizes
      final imageKeys = ['front', 'front_small', 'front_thumb'];

      for (final key in imageKeys) {
        final image = images[key] as Map<String, dynamic>?;
        if (image != null) {
          final displayUrl = image['display'] as String?;
          final url = image['url'] as String?;

          if (displayUrl?.isNotEmpty == true) return displayUrl;
          if (url?.isNotEmpty == true) return url;
        }
      }
    }

    // Fallback to image_url fields
    final imageUrl = product['image_url'] as String?;
    final imageSmallUrl = product['image_small_url'] as String?;
    final imageThumbUrl = product['image_thumb_url'] as String?;

    if (imageUrl?.isNotEmpty == true) return imageUrl;
    if (imageSmallUrl?.isNotEmpty == true) return imageSmallUrl;
    if (imageThumbUrl?.isNotEmpty == true) return imageThumbUrl;

    return null;
  }

  /// Get Nutri-Score grade
  String getNutriScore(Map<String, dynamic> product) {
    return (product['nutriscore_grade'] as String? ?? '').toUpperCase();
  }

  /// Check if product is organic
  bool isOrganic(Map<String, dynamic> product) {
    final labelsTags = product['labels_tags'] as List<dynamic>? ?? [];
    return labelsTags.any((tag) => tag.toString().toLowerCase().contains('organic'));
  }

  /// Get NOVA group (processing level)
  int getNovaGroup(Map<String, dynamic> product) {
    return product['nova_group'] as int? ?? 0;
  }
}