import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';

// Firebase imports
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

// App imports
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/alcohol_log_screen.dart';
import 'screens/liquids_catalog_screen.dart';
import 'screens/electrolytes_screen.dart';
import 'screens/supplements_screen.dart';
import 'screens/hot_drinks_screen.dart';
import 'screens/sports_screen.dart';
import 'screens/main_shell.dart';
import 'screens/paywall_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/food_catalog_screen.dart';
import 'screens/openfood_catalog_screen.dart';

// Services
import 'services/notification_service.dart';
import 'services/subscription_service.dart';
import 'services/remote_config_service.dart';
import 'services/alcohol_service.dart';
import 'services/hri_service.dart';
import 'services/locale_service.dart';
import 'services/analytics_service.dart';
import 'services/units_service.dart';
import 'services/consent_service.dart';

// Providers
import 'providers/hydration_provider.dart';

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

// Helper function to load or create userId
Future<String> _loadOrCreateUserId() async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString('appsflyer_user_id');
  if (userId == null) {
    // Generate unique ID based on timestamp
    userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('appsflyer_user_id', userId);
  }
  return userId;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase only if not already initialized
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    // ignore: avoid_print
    print('Firebase initialization error: $e');
  }

  // Initialize core services
  await LocaleService.instance.initialize();
  await UnitsService.instance.init();
  await RemoteConfigService.instance.initialize();
  await SubscriptionService.instance.initialize();

  // Initialize Consent Service (Usercentrics) BEFORE Analytics
  final consentService = ConsentService();
  await consentService.initialize();

  // Get or create userId for AppsFlyer
  final userId = await _loadOrCreateUserId();

  // Initialize Analytics Service
  await AnalyticsService().init();

  // Setup Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Check if onboarding is completed
  final prefs = await SharedPreferences.getInstance();
  final onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;

  // Initialize notifications only if onboarding is completed
  if (onboardingCompleted) {
    await _initializeNotifications();
  }

  // Log app open event with AppsFlyer
  await AnalyticsService().log('app_open', {
    'app_version': '2.0.0',
    'locale': LocaleService.instance.currentLocale.toString(),
    'tz': DateTime.now().timeZoneName,
    'onboarding_completed': onboardingCompleted.toString(),  // преобразуем в строку
    'consent_given': consentService.hasConsent.toString(),
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HydrationProvider()),
        ChangeNotifierProvider(create: (context) => SubscriptionProvider()),
        ChangeNotifierProvider(create: (context) => AlcoholService()),
        ChangeNotifierProvider(create: (context) => HRIService()),
        ChangeNotifierProvider.value(value: LocaleService.instance),
        ChangeNotifierProvider.value(value: UnitsService.instance),
      ],
      child: const MyApp(),
    ),
  );
}

// Initialize notifications function
Future<void> _initializeNotifications() async {
  final messaging = FirebaseMessaging.instance;

  // Check if permission is already granted
  final settings = await messaging.getNotificationSettings();

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    // Permission granted, initialize notifications
    final fcmToken = await messaging.getToken();
    // ignore: avoid_print
    print('FCM Token: $fcmToken');

    // Static initialize()
    await NotificationService.initialize();

    // Log notification status to AppsFlyer
    await AnalyticsService().log('notification_status', {
      'enabled': true,
      'fcm_token_exists': fcmToken != null,
    });
  } else {
    // Log that notifications are disabled
    await AnalyticsService().log('notification_status', {
      'enabled': false,
      'fcm_token_exists': false,
    });
  }
}

// Public function for initializing notifications from onboarding
Future<bool> initializeNotificationsFromOnboarding() async {
  final messaging = FirebaseMessaging.instance;

  // Request permission
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized ||
      settings.authorizationStatus == AuthorizationStatus.provisional) {
    await _initializeNotifications();

    // Schedule smart reminders for the day
    await NotificationService().scheduleSmartReminders();

    // Log successful notification permission
    await AnalyticsService().log('notification_permission_granted', {
      'source': 'onboarding',
      'authorization_status': settings.authorizationStatus.name,
    });

    return true;
  }

  // Log denied notification permission
  await AnalyticsService().log('notification_permission_denied', {
    'source': 'onboarding',
    'authorization_status': settings.authorizationStatus.name,
  });

  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleService>(
      builder: (context, localeService, child) {
        return MaterialApp(
          title: 'FoodCoach',
          debugShowCheckedModeBanner: false,

          // Localization
          locale: localeService.currentLocale,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
            Locale('ru'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],

          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            fontFamily: 'SF Pro Display',
            splashFactory: InkRipple.splashFactory,
            highlightColor: Colors.transparent,
            splashColor: Colors.blue,
          ),

          home: const SplashScreen(),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/history': (context) => const HistoryScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/alcohol': (context) => const AlcoholLogScreen(),
            '/liquids': (context) => const LiquidsCatalogScreen(),
            '/electrolytes': (context) => const ElectrolytesScreen(),
            '/supplements': (context) => const SupplementsScreen(),
            '/hot_drinks': (context) => const HotDrinksScreen(),
            '/sports': (context) => const SportsScreen(),
            '/food': (context) => const FoodCatalogScreen(),
            '/openfood_catalog': (context) => const OpenFoodCatalogScreen(),
            '/main': (context) => const MainShell(),
            '/paywall': (context) => const PaywallScreen(source: 'app_route'),
            '/achievements': (context) => const AchievementsScreen(),
          },
        );
      },
    );
  }
}

// Обновленный класс SplashScreen для main.dart
// Замените существующий класс SplashScreen этим кодом

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isInitializing = false;
  final ConsentService _consentService = ConsentService();
  
  @override
  void initState() {
    super.initState();
    // КРИТИЧНО: Откладываем инициализацию до первого кадра
    // чтобы избежать setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeApp();
      }
    });
  }

  Future<void> _initializeApp() async {
    if (_isInitializing) return;
    _isInitializing = true;

    try {
      // Initialize subscription БЕЗ await в том же контексте
      final subscriptionProvider =
          Provider.of<SubscriptionProvider>(context, listen: false);
      
      // Выполняем инициализацию асинхронно
      await Future.microtask(() async {
        await subscriptionProvider.initialize();
      });

      // Initialize alcohol service
      final alcoholService = Provider.of<AlcoholService>(context, listen: false);
      await alcoholService.init();

      // Check onboarding
      final prefs = await SharedPreferences.getInstance();
      
      // ОТЛАДКА: Выводим текущее состояние онбординга
      final completed = prefs.getBool('onboardingCompleted') ?? false;
      print('🔍 DEBUG: onboardingCompleted = $completed');
      
      // ВРЕМЕННО: Для тестирования - раскомментируйте эту строку чтобы сбросить онбординг
      // await prefs.setBool('onboardingCompleted', false);
      // print('⚠️ DEBUG: Onboarding reset to false for testing');
      
      // Log user properties to AppsFlyer
      final dietMode = prefs.getString('diet_mode') ?? 'normal';
      await AnalyticsService().log('user_properties', {
        'pro_status': subscriptionProvider.isPro,
        'diet_mode': dietMode,
        'onboarding_completed': completed,
      });

      if (!mounted) return;

      // Log splash screen completion
      await AnalyticsService().log('splash_screen_completed', {
        'destination': completed ? 'main_shell' : 'onboarding',
      });
      
      print('🚀 DEBUG: Navigating to ${completed ? "MainShell" : "OnboardingScreen"}');

      // Navigate to the appropriate screen
      Widget targetScreen = completed ? const MainShell() : const OnboardingScreen();

      // Check if we need to show consent banner
      if (completed && await _consentService.shouldShowConsentBanner()) {
        // Navigate first, then show consent banner after a small delay
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => targetScreen),
          (route) => false,
        );
        
        // Show consent banner after navigation
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await _showConsentBanner();
          }
        }
      } else {
        // Just navigate normally
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => targetScreen),
          (route) => false,
        );
      }
    } catch (e) {
      print('❌ ERROR during initialization: $e');
      print('Stack trace: ${StackTrace.current}');
      
      // Log initialization error
      await AnalyticsService().log('splash_screen_error', {
        'error': e.toString(),
      });
      
      // В случае ошибки проверяем онбординг еще раз
      try {
        final prefs = await SharedPreferences.getInstance();
        final completed = prefs.getBool('onboardingCompleted') ?? false;
        print('🔄 DEBUG: After error, onboardingCompleted = $completed');
        
        if (mounted) {
          // Если онбординг не пройден - показываем его даже после ошибки
          Widget fallbackScreen = completed ? const MainShell() : const OnboardingScreen();
          
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => fallbackScreen),
            (route) => false,
          );
        }
      } catch (fallbackError) {
        print('❌ CRITICAL: Fallback navigation failed: $fallbackError');
        // В крайнем случае показываем MainShell
        if (mounted) {
          await Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        }
      }
    }
  }

  // Show consent banner
  Future<void> _showConsentBanner() async {
    try {
      await _consentService.showConsentBanner(context);
      
      // Log consent banner shown
      await AnalyticsService().log('consent_banner_shown', {
        'location': 'app_start',
      });
      
      // After consent is given/denied, check if AppsFlyer needs to be enabled
      await AnalyticsService().checkAndEnableAppsFlyer();
      
    } catch (e) {
      print('Error showing consent banner: $e');
      
      // Log consent banner error
      await AnalyticsService().log('consent_banner_error', {
        'error': e.toString(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💧', style: TextStyle(fontSize: 80))
                .animate()
                .scale(duration: 500.ms)
                .then()
                .shake(delay: 500.ms),
            const SizedBox(height: 20),
            const Text(
              'FoodCoach',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 20),
            Consumer<SubscriptionProvider>(
              builder: (context, subscription, child) {
                // Показываем индикатор загрузки
                return const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}