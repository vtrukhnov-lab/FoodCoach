import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_product.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_products';

  Future<List<FavoriteProduct>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson == null) return [];

      final List<dynamic> favoritesList = json.decode(favoritesJson);
      return favoritesList
          .map((json) => FavoriteProduct.fromJson(json))
          .toList();
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  Future<void> addFavorite(FavoriteProduct product) async {
    try {
      final favorites = await getFavorites();

      // Проверяем, не добавлен ли уже этот продукт
      if (!favorites.any((fav) => fav.id == product.id)) {
        favorites.add(product);
        await _saveFavorites(favorites);
      }
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  Future<void> removeFavorite(String productId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((fav) => fav.id == productId);
      await _saveFavorites(favorites);
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  Future<bool> isFavorite(String productId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((fav) => fav.id == productId);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  Future<void> _saveFavorites(List<FavoriteProduct> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        favorites.map((fav) => fav.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }
}