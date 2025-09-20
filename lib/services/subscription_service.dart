import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'analytics_service.dart';
import 'appsflyer_service.dart';

/*
🧪 НАСТРОЙКА ТЕСТОВЫХ ПОКУПОК В GOOGLE PLAY CONSOLE:

1. Перейдите в Google Play Console → Ваше приложение → Testing → Closed testing
2. Создайте тестовую дорожку (например, "Internal Testing")
3. Добавьте тестовые аккаунты в список тестеров:
   - test@playcus.com
   - vtrukhnov.lab@gmail.com
   - qa@playcus.com
   - и другие из списка _testAccounts

4. В разделе "Monetization" → "Products" → "In-app products":
   - Создайте продукты подписки
   - Установите тестовые цены
   - Тестовые аккаунты смогут покупать бесплатно

5. В Release Management → Test tracks → Internal Testing:
   - Загрузите APK/AAB с этим кодом
   - Тестеры получат ссылку для установки

РЕЗУЛЬТАТ:
- Тестовые аккаунты: покупки БЕСПЛАТНО (но события аналитики логируются)
- Обычные пользователи: ПЛАТНЫЕ покупки
- Все события отслеживаются в Firebase/AppsFlyer
*/

class SubscriptionProduct {
  const SubscriptionProduct({
    required this.identifier,
    required this.title,
    required this.description,
    required this.priceText,
    required this.billingPeriod,
  });

  final String identifier;
  final String title;
  final String description;
  final String priceText;
  final Duration billingPeriod;
}

// Временные заглушки для типов RevenueCat
class StoreProduct {
  final String identifier;
  final String title;
  final String description;
  final double price;
  final String priceString;
  
  StoreProduct({
    required this.identifier,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
  });
}

class SubscriptionService {
  static SubscriptionService? _instance;
  static SubscriptionService get instance => _instance ??= SubscriptionService._();

  SubscriptionService._();

  static const _isProKey = 'is_pro';
  static const _proExpiresAtKey = 'pro_expires_at';

  // Google Play subscription product IDs
  static const String _yearlyProductId = 'hydracoach_pro_yearly';
  static const String _monthlyProductId = 'hydracoach_pro_monthly';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Список тестовых аккаунтов Google Play для бесплатного тестирования
  static const List<String> _testAccounts = [
    'test@playcus.com',
    'tester1@playcus.com',
    'tester2@playcus.com',
    'qa@playcus.com',
    'beta@playcus.com',
    'vtrukhnov.lab@gmail.com', // Основной разработчик
    // Добавьте свои тестовые аккаунты сюда
  ];

  // Дополнительные тестовые аккаунты, добавленные в рантайме
  static final List<String> _runtimeTestAccounts = [];

  final AnalyticsService _analytics = AnalyticsService();
  final AppsFlyerService _appsFlyer = AppsFlyerService();

  static const List<SubscriptionProduct> _defaultProducts = [
    SubscriptionProduct(
      identifier: 'hydracoach_pro_yearly',
      title: 'FoodCoach PRO — Годовая',
      description: 'Все PRO функции, включая продвинутые напоминания и алкогольные протоколы',
      priceText: '2 290 ₽ / год',
      billingPeriod: Duration(days: 365),
    ),
    SubscriptionProduct(
      identifier: 'hydracoach_pro_monthly',
      title: 'FoodCoach PRO — Месячная',
      description: 'Гибкий доступ к PRO функционалу с помесячной оплатой',
      priceText: '249 ₽ / месяц',
      billingPeriod: Duration(days: 30),
    ),
  ];

  bool _isInitialized = false;
  bool _isPro = false;
  List<ProductDetails> _products = [];

  bool get isPro => _isPro;
  bool get isInitialized => _isInitialized;
  List<ProductDetails> get products => _products;

  /// Проверяет, является ли текущий пользователь тестовым
  bool _isTestAccount() {
    // В релизе блокируем все тестовые покупки - только реальные платежи
    // TODO: В будущем добавить проверку email пользователя
    // final userEmail = getCurrentUserEmail();
    // return _testAccounts.contains(userEmail) || _runtimeTestAccounts.contains(userEmail);

    // Пока что в релизе никто не является тестовым пользователем
    return false;
  }

  /// Добавить тестовый аккаунт в рантайме (только для debug)
  static void addTestAccount(String email) {
    if (kDebugMode && !_runtimeTestAccounts.contains(email)) {
      _runtimeTestAccounts.add(email);
      print('🧪 Added test account: $email');
    }
  }

  /// Получить список всех тестовых аккаунтов
  static List<String> getTestAccounts() {
    return [..._testAccounts, ..._runtimeTestAccounts];
  }

  /// Инициализация подписки: подключение к Google Play и загрузка продуктов
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _restoreFromStorage();

    // Проверяем доступность покупок
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      if (kDebugMode) {
        print('❌ In-app purchases not available');
      }
      _isInitialized = true;
      return;
    }

    // Настраиваем слушатель покупок
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        if (kDebugMode) {
          print('❌ Purchase stream error: $error');
        }
      },
    );

    // Загружаем продукты
    await _loadProducts();

    _isInitialized = true;

    if (kDebugMode) {
      print('✅ SubscriptionService initialized');
      print('🔒 PRO status: $_isPro');
      print('📦 Products loaded: ${_products.length}');
    }
  }

  Future<void> _restoreFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedIsPro = prefs.getBool(_isProKey) ?? false;
    final expiryIso = prefs.getString(_proExpiresAtKey);
    DateTime? expiry;

    if (expiryIso != null) {
      expiry = DateTime.tryParse(expiryIso);
    }

    if (storedIsPro && expiry != null) {
      if (DateTime.now().isBefore(expiry)) {
        _isPro = true;
        return;
      }

      // Подписка истекла — чистим флаги
      await prefs.remove(_isProKey);
      await prefs.remove(_proExpiresAtKey);
    }

    _isPro = storedIsPro && expiry == null;
  }

  /// Загрузка продуктов подписки из Google Play
  Future<void> _loadProducts() async {
    try {
      final Set<String> productIds = {_yearlyProductId, _monthlyProductId};
      final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        if (kDebugMode) {
          print('❌ Failed to load products: ${response.error}');
        }
        return;
      }

      _products = response.productDetails;

      if (kDebugMode) {
        print('📦 Loaded ${_products.length} products:');
        for (final product in _products) {
          print('   - ${product.id}: ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error loading products: $e');
      }
    }
  }

  /// Обработчик обновлений покупок
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  /// Обработка конкретной покупки
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    if (purchaseDetails.status == PurchaseStatus.purchased) {
      // Покупка успешна - активируем PRO
      final product = _products.firstWhere(
        (p) => p.id == purchaseDetails.productID,
        orElse: () => throw Exception('Product not found'),
      );

      Duration billingPeriod;
      if (purchaseDetails.productID == _yearlyProductId) {
        billingPeriod = const Duration(days: 365);
      } else {
        billingPeriod = const Duration(days: 30);
      }

      await _activatePro(billingPeriod);

      // Логируем аналитику
      await _analytics.logSubscriptionStarted(
        product: purchaseDetails.productID,
        price: double.tryParse(product.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0,
        currency: product.currencyCode,
        isTrial: false, // Для реальных покупок это всегда false
      );

      if (kDebugMode) {
        print('✅ Purchase completed: ${purchaseDetails.productID}');
      }
    } else if (purchaseDetails.status == PurchaseStatus.error) {
      if (kDebugMode) {
        print('❌ Purchase failed: ${purchaseDetails.error}');
      }
    }

    // Завершаем покупку для Android
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  /// Получение доступных продуктов подписки (мок-данные)
  Future<List<SubscriptionProduct>> getAvailableProducts() async {
    return List.unmodifiable(_defaultProducts);
  }

  /// Покупка подписки через Google Play Billing
  Future<bool> purchaseSubscription(String productId) async {
    if (!_isInitialized) {
      throw Exception('SubscriptionService not initialized');
    }

    // Проверяем, доступны ли покупки
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      throw Exception('In-app purchases not available');
    }

    // Находим продукт
    final ProductDetails? product = _products.where((p) => p.id == productId).firstOrNull;
    if (product == null) {
      throw Exception('Product not found: $productId');
    }

    try {
      if (kDebugMode) {
        print('🛍️ Starting purchase for: ${product.id}');
        print('💰 Price: ${product.price}');
      }

      // Создаем параметры покупки
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

      // Инициируем покупку
      final bool purchaseResult = await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);

      if (kDebugMode) {
        print('🔄 Purchase initiated: $purchaseResult');
      }

      return purchaseResult;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Purchase error: $e');
      }
      rethrow;
    }
  }

  /// Восстановление покупок через Google Play
  Future<bool> restorePurchases() async {
    if (!_isInitialized) {
      throw Exception('SubscriptionService not initialized');
    }

    try {
      if (kDebugMode) {
        print('🔄 Restoring purchases...');
      }

      // Восстанавливаем покупки через Google Play
      await _inAppPurchase.restorePurchases();

      // Также загружаем из локального хранилища
      await _restoreFromStorage();

      if (kDebugMode) {
        print('✅ Restore completed. PRO: $_isPro');
      }

      return _isPro;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Restore error: $e');
      }
      rethrow;
    }
  }

  /// Обновление статуса подписки
  Future<void> _activatePro(Duration billingPeriod) async {
    _isPro = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isProKey, true);
    final expiryDate = DateTime.now().add(billingPeriod);
    await prefs.setString(_proExpiresAtKey, expiryDate.toIso8601String());
  }

  /// Проверка доступности PRO функции
  bool hasProAccess() {
    return _isPro;
  }

  /// Проверка доступности конкретной функции
  bool hasFeatureAccess(String featureName) {
    const freeFeatures = {
      'basic_tracking',
      'weather_integration',
      'simple_reminders',
      'daily_report',
      'basic_history',
      'alcohol_log',
      'alcohol_harm_reduction',
      'alcohol_morning_checkin',
    };

    if (freeFeatures.contains(featureName)) {
      return true;
    }

    return _isPro;
  }

  Map<String, dynamic> getFreeLimitations() {
    return {
      'max_daily_reminders': 4,
      'history_days': 30,
      'export_available': false,
      'smart_reminders': false,
      'fasting_aware': false,
      'cloud_sync': false,
      'weekly_reports': false,
      'alcohol_pre_drink': false,
      'alcohol_recovery_plan': false,
      'alcohol_sober_calendar': false,
    };
  }

  Map<String, dynamic> getProFeatures() {
    return {
      'unlimited_reminders': true,
      'unlimited_history': true,
      'csv_export': true,
      'smart_reminders': true,
      'fasting_aware_mode': true,
      'cloud_sync': true,
      'weekly_reports': true,
      'contextual_reminders': true,
      'heat_protocols': true,
      'multi_device': true,
      'alcohol_pre_drink_protocol': true,
      'alcohol_recovery_plan': true,
      'alcohol_sober_calendar': true,
      'alcohol_extended_checkin': true,
    };
  }

  /// Мок получения customer info (для совместимости с существующим кодом)
  Future<Map<String, dynamic>> getCustomerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryIso = prefs.getString(_proExpiresAtKey);

    return {
      'isPro': _isPro,
      'expiresAt': expiryIso,
    };
  }

  /// Принудительное обнуление PRO статуса (удобно для тестов)
  Future<void> resetSubscription() async {
    _isPro = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_isProKey);
    await prefs.remove(_proExpiresAtKey);
  }

  /// Мок-покупка для тестирования — годовая подписка
  Future<void> mockPurchase() async {
    await purchaseSubscription(_yearlyProductId);
  }

  /// Очистка ресурсов
  void dispose() {
    _subscription.cancel();
  }

  /// Валидация покупки через AppsFlyer SDK Connector
  Future<void> _validatePurchaseWithAppsFlyer(SubscriptionProduct product) async {
    try {
      // Получаем цену из priceText (парсим "2 290 ₽ / год" -> 2290.0)
      final priceMatch = RegExp(r'(\d[\d\s]*\d|\d+)').firstMatch(product.priceText);
      final price = priceMatch != null
          ? double.tryParse(priceMatch.group(1)!.replaceAll(' ', '')) ?? 0.0
          : 0.0;

      final currency = product.priceText.contains('₽') ? 'RUB' : 'USD';

      if (kDebugMode) {
        print('💰 AppsFlyer IAP Validation for ${product.identifier}');
        print('   Price: $price $currency');
      }

      // Отправляем базовое событие покупки в AppsFlyer
      await _appsFlyer.logPurchase(
        product: product.identifier,
        revenue: price,
        currency: currency,
        orderId: 'mock_order_${DateTime.now().millisecondsSinceEpoch}',
        additionalParams: {
          'billing_period': product.billingPeriod.inDays.toString(),
          'product_title': product.title,
          'purchase_source': 'mock',
        },
      );

      // TODO: Когда будет реальный IAP, добавить платформо-специфичную валидацию:
      //
      // Android:
      // await _appsFlyer.validateAndLogAndroidPurchase(
      //   productId: product.identifier,
      //   purchaseToken: realPurchaseToken,
      //   price: price,
      //   currency: currency,
      // );
      //
      // iOS:
      // await _appsFlyer.validateAndLogIOSPurchase(
      //   productId: product.identifier,
      //   transactionId: realTransactionId,
      //   price: price,
      //   currency: currency,
      // );

    } catch (error) {
      if (kDebugMode) {
        print('❌ Ошибка валидации покупки через AppsFlyer: $error');
      }
    }
  }
}

class SubscriptionProvider extends ChangeNotifier {
  final SubscriptionService _subscriptionService = SubscriptionService.instance;

  bool get isPro => _subscriptionService.isPro;
  bool get isInitialized => _subscriptionService.isInitialized;

  List<SubscriptionProduct> _availableProducts = const [];
  List<SubscriptionProduct> get availableProducts => _availableProducts;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;

    await _subscriptionService.initialize();
    await loadProducts();

    _isLoading = false;

    await Future.microtask(notifyListeners);
  }

  Future<void> loadProducts() async {
    try {
      _availableProducts = await _subscriptionService.getAvailableProducts();
      if (!_isLoading) {
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка загрузки продуктов: $e');
      }
    }
  }

  Future<bool> purchaseSubscription(String productId) async {
    _isLoading = true;
    notifyListeners();

    final success = await _subscriptionService.purchaseSubscription(productId);

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<bool> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    final success = await _subscriptionService.restorePurchases();

    _isLoading = false;
    notifyListeners();

    return success;
  }

  Future<void> mockPurchase() async {
    _isLoading = true;
    notifyListeners();

    await _subscriptionService.mockPurchase();

    _isLoading = false;
    notifyListeners();

    if (kDebugMode) {
      print('✅ Mock purchase completed - PRO activated');
    }
  }

  bool hasFeatureAccess(String featureName) {
    return _subscriptionService.hasFeatureAccess(featureName);
  }

  Map<String, dynamic> getFreeLimitations() {
    return _subscriptionService.getFreeLimitations();
  }

  Map<String, dynamic> getProFeatures() {
    return _subscriptionService.getProFeatures();
  }
}
