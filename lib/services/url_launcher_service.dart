import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Сервис для открытия внешних ссылок и email
class UrlLauncherService {
  static const MethodChannel _channel = MethodChannel('hydracoach.url_launcher');

  /// Константы ссылок приложения
  static const String privacyPolicyUrl = 'https://www.playcus.com/privacy-policy';
  static const String websiteUrl = 'https://www.playcus.com';
  static const String supportEmail = 'support@playcus.com';
  static const String companyAddress = 'Thiseos 9, Flat/Office C1, Aglantzia, P.C. 2121, Nicosia, Cyprus';
  static const String dataSafetyGPUrl = 'https://docs.google.com/spreadsheets/d/1kPc5mX9z9Nm_7YDGTK1qkH-ZoQRdbXxQ00ICc6n2ipk/edit#gid=15532220';
  static const String dataSafetyIOSUrl = 'https://docs.google.com/spreadsheets/u/0/d/17QaT_AMP7UhtfrVNuZuznlrAyZvMDXlOpToA6-4Cpxg/htmlview#gid=1742509917';

  // Ссылки для магазинов приложений (будут обновлены после публикации)
  static const String googlePlayUrl = 'https://play.google.com/store/apps/details?id=com.playcus.hydracoach';
  static const String appStoreUrl = 'https://apps.apple.com/app/hydracoach/id123456789';
  static const String shareText = 'Check out FoodCoach - Smart hydration tracking app! 💧';

  /// Открыть веб-ссылку
  static Future<bool> openUrl(String url) async {
    try {
      if (kDebugMode) {
        print('🔗 Открываем ссылку: $url');
      }

      // Для Windows/Desktop - копируем в буфер обмена и показываем сообщение
      await Clipboard.setData(ClipboardData(text: url));

      if (kDebugMode) {
        print('📋 Ссылка скопирована в буфер обмена: $url');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка открытия ссылки: $e');
      }
      return false;
    }
  }

  /// Открыть email клиент
  static Future<bool> openEmail(String email, {String? subject}) async {
    final emailUrl = 'mailto:$email${subject != null ? '?subject=${Uri.encodeComponent(subject)}' : ''}';
    return await openUrl(emailUrl);
  }

  /// Быстрые методы для основных ссылок приложения
  static Future<bool> openPrivacyPolicy() => openUrl(privacyPolicyUrl);
  static Future<bool> openWebsite() => openUrl(websiteUrl);
  static Future<bool> openSupportEmail() => openEmail(supportEmail, subject: 'FoodCoach Support');
  static Future<bool> openDataSafetyGP() => openUrl(dataSafetyGPUrl);
  static Future<bool> openDataSafetyIOS() => openUrl(dataSafetyIOSUrl);

  /// Открыть страницу приложения в магазине
  static Future<bool> openAppStore() async {
    // В зависимости от платформы открываем соответствующий магазин
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await openUrl(appStoreUrl);
    } else {
      return await openUrl(googlePlayUrl);
    }
  }

  /// Поделиться приложением
  static Future<bool> shareApp() async {
    try {
      final shareUrl = defaultTargetPlatform == TargetPlatform.iOS ? appStoreUrl : googlePlayUrl;
      final fullShareText = '$shareText\n$shareUrl';

      // Копируем в буфер обмена
      await Clipboard.setData(ClipboardData(text: fullShareText));

      if (kDebugMode) {
        print('📋 Ссылка для шаринга скопирована: $fullShareText');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Ошибка при шаринге: $e');
      }
      return false;
    }
  }
}