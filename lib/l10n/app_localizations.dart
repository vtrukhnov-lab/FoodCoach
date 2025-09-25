import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru'),
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'FoodCoach'**
  String get appTitle;

  /// Get PRO tooltip
  ///
  /// In en, this message translates to:
  /// **'Get PRO'**
  String get getPro;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// Date format pattern
  ///
  /// In en, this message translates to:
  /// **'{weekday}, {day} {month}'**
  String dateFormat(String weekday, int day, String month);

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @loadingWeather.
  ///
  /// In en, this message translates to:
  /// **'Loading weather...'**
  String get loadingWeather;

  /// No description provided for @heatIndex.
  ///
  /// In en, this message translates to:
  /// **'Heat Index'**
  String get heatIndex;

  /// No description provided for @humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String humidity(int value);

  /// No description provided for @water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get water;

  /// No description provided for @liquids.
  ///
  /// In en, this message translates to:
  /// **'Liquids'**
  String get liquids;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @potassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get potassium;

  /// No description provided for @magnesium.
  ///
  /// In en, this message translates to:
  /// **'Magnesium'**
  String get magnesium;

  /// No description provided for @electrolyte.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte'**
  String get electrolyte;

  /// No description provided for @broth.
  ///
  /// In en, this message translates to:
  /// **'Broth'**
  String get broth;

  /// No description provided for @coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get coffee;

  /// No description provided for @alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get alcohol;

  /// No description provided for @drink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get drink;

  /// No description provided for @ml.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get ml;

  /// No description provided for @mg.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get mg;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @valueWithUnit.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String valueWithUnit(int value, String unit);

  /// No description provided for @goalFormat.
  ///
  /// In en, this message translates to:
  /// **'{current}/{goal} {unit}'**
  String goalFormat(int current, int goal, String unit);

  /// No description provided for @heatAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Heat +{percent}%'**
  String heatAdjustment(int percent);

  /// No description provided for @alcoholAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Alcohol +{amount} ml'**
  String alcoholAdjustment(int amount);

  /// No description provided for @smartAdviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Tip for now'**
  String get smartAdviceTitle;

  /// No description provided for @smartAdviceDefault.
  ///
  /// In en, this message translates to:
  /// **'Maintain water and electrolyte balance.'**
  String get smartAdviceDefault;

  /// No description provided for @adviceOverhydrationSevere.
  ///
  /// In en, this message translates to:
  /// **'Water overload (>200% goal)'**
  String get adviceOverhydrationSevere;

  /// No description provided for @adviceOverhydrationSevereBody.
  ///
  /// In en, this message translates to:
  /// **'Pause 60-90 minutes. Add electrolytes: 300-500 ml with 500-1000 mg sodium.'**
  String get adviceOverhydrationSevereBody;

  /// No description provided for @adviceOverhydration.
  ///
  /// In en, this message translates to:
  /// **'Overhydration'**
  String get adviceOverhydration;

  /// No description provided for @adviceOverhydrationBody.
  ///
  /// In en, this message translates to:
  /// **'Pause water for 30-60 minutes and add ~500 mg sodium (electrolyte/broth).'**
  String get adviceOverhydrationBody;

  /// No description provided for @adviceAlcoholRecovery.
  ///
  /// In en, this message translates to:
  /// **'Alcohol: recovery'**
  String get adviceAlcoholRecovery;

  /// No description provided for @adviceAlcoholRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'No more alcohol today. Drink 300-500 ml water in small portions and add sodium.'**
  String get adviceAlcoholRecoveryBody;

  /// No description provided for @adviceLowSodium.
  ///
  /// In en, this message translates to:
  /// **'Low sodium'**
  String get adviceLowSodium;

  /// No description provided for @adviceLowSodiumBody.
  ///
  /// In en, this message translates to:
  /// **'Add ~{amount} mg sodium. Drink moderately.'**
  String adviceLowSodiumBody(int amount);

  /// No description provided for @adviceDehydration.
  ///
  /// In en, this message translates to:
  /// **'Under-hydrated'**
  String get adviceDehydration;

  /// No description provided for @adviceDehydrationBody.
  ///
  /// In en, this message translates to:
  /// **'Drink 300-500 ml {type}.'**
  String adviceDehydrationBody(String type);

  /// No description provided for @adviceHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High risk (HRI)'**
  String get adviceHighRisk;

  /// No description provided for @adviceHighRiskBody.
  ///
  /// In en, this message translates to:
  /// **'Urgently drink water with electrolytes (300-500 ml) and reduce activity.'**
  String get adviceHighRiskBody;

  /// No description provided for @adviceHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat and losses'**
  String get adviceHeat;

  /// No description provided for @adviceHeatBody.
  ///
  /// In en, this message translates to:
  /// **'Increase water by +5-8% and add 300-500 mg sodium.'**
  String get adviceHeatBody;

  /// No description provided for @adviceAllGood.
  ///
  /// In en, this message translates to:
  /// **'All on track'**
  String get adviceAllGood;

  /// No description provided for @adviceAllGoodBody.
  ///
  /// In en, this message translates to:
  /// **'Keep the pace. Target: ~{amount} ml more to goal.'**
  String adviceAllGoodBody(int amount);

  /// No description provided for @hydrationStatus.
  ///
  /// In en, this message translates to:
  /// **'Hydration Status'**
  String get hydrationStatus;

  /// No description provided for @hydrationStatusNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get hydrationStatusNormal;

  /// No description provided for @hydrationStatusDiluted.
  ///
  /// In en, this message translates to:
  /// **'Diluting'**
  String get hydrationStatusDiluted;

  /// No description provided for @hydrationStatusDehydrated.
  ///
  /// In en, this message translates to:
  /// **'Under-hydrated'**
  String get hydrationStatusDehydrated;

  /// No description provided for @hydrationStatusLowSalt.
  ///
  /// In en, this message translates to:
  /// **'Low salt'**
  String get hydrationStatusLowSalt;

  /// No description provided for @hydrationRiskIndex.
  ///
  /// In en, this message translates to:
  /// **'Hydration Risk Index'**
  String get hydrationRiskIndex;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @todaysDrinks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Drinks'**
  String get todaysDrinks;

  /// No description provided for @allRecords.
  ///
  /// In en, this message translates to:
  /// **'All records →'**
  String get allRecords;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'{item} deleted'**
  String itemDeleted(String item);

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @dailyReportReady.
  ///
  /// In en, this message translates to:
  /// **'Daily report ready!'**
  String get dailyReportReady;

  /// No description provided for @viewDayResults.
  ///
  /// In en, this message translates to:
  /// **'View day results'**
  String get viewDayResults;

  /// No description provided for @dailyReportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Daily report will be available in the next version'**
  String get dailyReportComingSoon;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettings;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileSection;

  /// Weight label
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// Diet mode selector title
  ///
  /// In en, this message translates to:
  /// **'Diet Mode'**
  String get dietMode;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @changeWeight.
  ///
  /// In en, this message translates to:
  /// **'Change Weight'**
  String get changeWeight;

  /// No description provided for @dietModeNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal Diet'**
  String get dietModeNormal;

  /// No description provided for @dietModeKeto.
  ///
  /// In en, this message translates to:
  /// **'Keto / Low-carb'**
  String get dietModeKeto;

  /// No description provided for @dietModeFasting.
  ///
  /// In en, this message translates to:
  /// **'Intermittent Fasting'**
  String get dietModeFasting;

  /// No description provided for @activityLow.
  ///
  /// In en, this message translates to:
  /// **'Low Activity'**
  String get activityLow;

  /// No description provided for @activityMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Activity'**
  String get activityMedium;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High Activity'**
  String get activityHigh;

  /// No description provided for @activityLowDesc.
  ///
  /// In en, this message translates to:
  /// **'Office work, little movement'**
  String get activityLowDesc;

  /// No description provided for @activityMediumDesc.
  ///
  /// In en, this message translates to:
  /// **'30-60 minutes of exercise per day'**
  String get activityMediumDesc;

  /// No description provided for @activityHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Workouts >1 hour'**
  String get activityHighDesc;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @notificationLimit.
  ///
  /// In en, this message translates to:
  /// **'Notification Limit (FREE)'**
  String get notificationLimit;

  /// No description provided for @notificationUsage.
  ///
  /// In en, this message translates to:
  /// **'Used: {used} of {limit}'**
  String notificationUsage(int used, int limit);

  /// No description provided for @waterReminders.
  ///
  /// In en, this message translates to:
  /// **'Water Reminders'**
  String get waterReminders;

  /// No description provided for @waterRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular reminders throughout the day'**
  String get waterRemindersDesc;

  /// No description provided for @reminderFrequency.
  ///
  /// In en, this message translates to:
  /// **'Reminder Frequency'**
  String get reminderFrequency;

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} times per day'**
  String timesPerDay(int count);

  /// No description provided for @maxTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'{count} times per day (max 4)'**
  String maxTimesPerDay(int count);

  /// No description provided for @unlimitedReminders.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimitedReminders;

  /// No description provided for @startOfDay.
  ///
  /// In en, this message translates to:
  /// **'Start of Day'**
  String get startOfDay;

  /// No description provided for @endOfDay.
  ///
  /// In en, this message translates to:
  /// **'End of Day'**
  String get endOfDay;

  /// No description provided for @postCoffeeReminders.
  ///
  /// In en, this message translates to:
  /// **'Post-Coffee Reminders'**
  String get postCoffeeReminders;

  /// No description provided for @postCoffeeRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Remind to drink water after 20 minutes'**
  String get postCoffeeRemindersDesc;

  /// No description provided for @heatWarnings.
  ///
  /// In en, this message translates to:
  /// **'Heat Warnings'**
  String get heatWarnings;

  /// No description provided for @heatWarningsDesc.
  ///
  /// In en, this message translates to:
  /// **'Notifications in high temperatures'**
  String get heatWarningsDesc;

  /// No description provided for @postAlcoholReminders.
  ///
  /// In en, this message translates to:
  /// **'Post-Alcohol Reminders'**
  String get postAlcoholReminders;

  /// No description provided for @postAlcoholRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Recovery plan for 6-12 hours'**
  String get postAlcoholRemindersDesc;

  /// No description provided for @proFeaturesSection.
  ///
  /// In en, this message translates to:
  /// **'PRO Features'**
  String get proFeaturesSection;

  /// Unlock PRO button text
  ///
  /// In en, this message translates to:
  /// **'Unlock PRO'**
  String get unlockPro;

  /// No description provided for @unlockProDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited notifications and smart reminders'**
  String get unlockProDesc;

  /// No description provided for @noNotificationLimit.
  ///
  /// In en, this message translates to:
  /// **'No notification limit'**
  String get noNotificationLimit;

  /// No description provided for @unitsSection.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get unitsSection;

  /// No description provided for @metricSystem.
  ///
  /// In en, this message translates to:
  /// **'Metric System'**
  String get metricSystem;

  /// No description provided for @metricUnits.
  ///
  /// In en, this message translates to:
  /// **'ml, kg, °C'**
  String get metricUnits;

  /// No description provided for @imperialSystem.
  ///
  /// In en, this message translates to:
  /// **'Imperial System'**
  String get imperialSystem;

  /// No description provided for @imperialUnits.
  ///
  /// In en, this message translates to:
  /// **'fl oz, lb, °F'**
  String get imperialUnits;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutSection;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @resetAllData.
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllData;

  /// No description provided for @resetDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset all data?'**
  String get resetDataTitle;

  /// No description provided for @resetDataMessage.
  ///
  /// In en, this message translates to:
  /// **'This will delete all history and restore settings to defaults.'**
  String get resetDataMessage;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to\nFoodCoach'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Smart water and electrolyte tracking\nfor keto, fasting and active life'**
  String get welcomeSubtitle;

  /// No description provided for @weightPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Your weight'**
  String get weightPageTitle;

  /// No description provided for @weightPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To calculate optimal water amount'**
  String get weightPageSubtitle;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightUnit(int weight);

  /// No description provided for @recommendedNorm.
  ///
  /// In en, this message translates to:
  /// **'Recommended norm: {min}-{max} ml of water per day'**
  String recommendedNorm(int min, int max);

  /// No description provided for @dietPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Diet Mode'**
  String get dietPageTitle;

  /// No description provided for @dietPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This affects electrolyte needs'**
  String get dietPageSubtitle;

  /// No description provided for @normalDiet.
  ///
  /// In en, this message translates to:
  /// **'Normal diet'**
  String get normalDiet;

  /// No description provided for @normalDietDesc.
  ///
  /// In en, this message translates to:
  /// **'Standard recommendations'**
  String get normalDietDesc;

  /// No description provided for @ketoDiet.
  ///
  /// In en, this message translates to:
  /// **'Keto / Low-carb'**
  String get ketoDiet;

  /// No description provided for @ketoDietDesc.
  ///
  /// In en, this message translates to:
  /// **'Increased salt needs'**
  String get ketoDietDesc;

  /// No description provided for @fastingDiet.
  ///
  /// In en, this message translates to:
  /// **'Intermittent Fasting'**
  String get fastingDiet;

  /// No description provided for @fastingDietDesc.
  ///
  /// In en, this message translates to:
  /// **'Special electrolyte regime'**
  String get fastingDietDesc;

  /// No description provided for @fastingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Fasting schedule:'**
  String get fastingSchedule;

  /// No description provided for @fasting16_8.
  ///
  /// In en, this message translates to:
  /// **'16:8'**
  String get fasting16_8;

  /// No description provided for @fasting16_8Desc.
  ///
  /// In en, this message translates to:
  /// **'Daily 8-hour window'**
  String get fasting16_8Desc;

  /// No description provided for @fastingOMAD.
  ///
  /// In en, this message translates to:
  /// **'OMAD'**
  String get fastingOMAD;

  /// No description provided for @fastingOMADDesc.
  ///
  /// In en, this message translates to:
  /// **'One meal a day'**
  String get fastingOMADDesc;

  /// No description provided for @fastingADF.
  ///
  /// In en, this message translates to:
  /// **'ADF'**
  String get fastingADF;

  /// No description provided for @fastingADFDesc.
  ///
  /// In en, this message translates to:
  /// **'Alternate day fasting'**
  String get fastingADFDesc;

  /// No description provided for @activityPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityPageTitle;

  /// No description provided for @activityPageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Affects water needs'**
  String get activityPageSubtitle;

  /// No description provided for @lowActivity.
  ///
  /// In en, this message translates to:
  /// **'Low activity'**
  String get lowActivity;

  /// No description provided for @lowActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Office work, little movement'**
  String get lowActivityDesc;

  /// No description provided for @lowActivityWater.
  ///
  /// In en, this message translates to:
  /// **'+0 ml water'**
  String get lowActivityWater;

  /// No description provided for @mediumActivity.
  ///
  /// In en, this message translates to:
  /// **'Medium activity'**
  String get mediumActivity;

  /// No description provided for @mediumActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'30-60 minutes of exercise per day'**
  String get mediumActivityDesc;

  /// No description provided for @mediumActivityWater.
  ///
  /// In en, this message translates to:
  /// **'+350-700 ml water'**
  String get mediumActivityWater;

  /// No description provided for @highActivity.
  ///
  /// In en, this message translates to:
  /// **'High activity'**
  String get highActivity;

  /// No description provided for @highActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Workouts >1 hour or physical labor'**
  String get highActivityDesc;

  /// No description provided for @highActivityWater.
  ///
  /// In en, this message translates to:
  /// **'+700-1200 ml water'**
  String get highActivityWater;

  /// No description provided for @activityAdjustmentNote.
  ///
  /// In en, this message translates to:
  /// **'We\'ll adjust goals based on your workouts'**
  String get activityAdjustmentNote;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get day;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noRecordsToday.
  ///
  /// In en, this message translates to:
  /// **'No records for today yet'**
  String get noRecordsToday;

  /// No description provided for @noRecordsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get noRecordsThisDay;

  /// No description provided for @loadingData.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loadingData;

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Delete record?'**
  String get deleteRecord;

  /// No description provided for @deleteRecordMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {type} {volume} ml?'**
  String deleteRecordMessage(String type, int volume);

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeleted;

  /// No description provided for @waterConsumption.
  ///
  /// In en, this message translates to:
  /// **'💧 Water consumption'**
  String get waterConsumption;

  /// No description provided for @alcoholWeek.
  ///
  /// In en, this message translates to:
  /// **'🍺 Alcohol this week'**
  String get alcoholWeek;

  /// No description provided for @electrolytes.
  ///
  /// In en, this message translates to:
  /// **'⚡ Electrolytes'**
  String get electrolytes;

  /// No description provided for @weeklyAverages.
  ///
  /// In en, this message translates to:
  /// **'📊 Weekly averages'**
  String get weeklyAverages;

  /// No description provided for @monthStatistics.
  ///
  /// In en, this message translates to:
  /// **'📊 Month statistics'**
  String get monthStatistics;

  /// No description provided for @alcoholStatistics.
  ///
  /// In en, this message translates to:
  /// **'🍺 Alcohol statistics'**
  String get alcoholStatistics;

  /// No description provided for @alcoholStatisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Alcohol statistics'**
  String get alcoholStatisticsTitle;

  /// No description provided for @weeklyInsights.
  ///
  /// In en, this message translates to:
  /// **'💡 Weekly insights'**
  String get weeklyInsights;

  /// No description provided for @waterPerDay.
  ///
  /// In en, this message translates to:
  /// **'Water per day'**
  String get waterPerDay;

  /// No description provided for @sodiumPerDay.
  ///
  /// In en, this message translates to:
  /// **'Sodium per day'**
  String get sodiumPerDay;

  /// No description provided for @potassiumPerDay.
  ///
  /// In en, this message translates to:
  /// **'Potassium per day'**
  String get potassiumPerDay;

  /// No description provided for @magnesiumPerDay.
  ///
  /// In en, this message translates to:
  /// **'Magnesium per day'**
  String get magnesiumPerDay;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @daysWithGoalAchieved.
  ///
  /// In en, this message translates to:
  /// **'✅ Days with goal achieved'**
  String get daysWithGoalAchieved;

  /// No description provided for @recordsPerDay.
  ///
  /// In en, this message translates to:
  /// **'📝 Records per day'**
  String get recordsPerDay;

  /// No description provided for @insufficientDataForAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Insufficient data for analysis'**
  String get insufficientDataForAnalysis;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get totalVolume;

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average {amount} ml/day'**
  String averagePerDay(int amount);

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active days'**
  String get activeDays;

  /// No description provided for @perfectDays.
  ///
  /// In en, this message translates to:
  /// **'Days with perfect goal: {count}'**
  String perfectDays(int count);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak: {days} days'**
  String currentStreak(int days);

  /// No description provided for @soberDaysRow.
  ///
  /// In en, this message translates to:
  /// **'Sober days in a row: {days}'**
  String soberDaysRow(int days);

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @waterAmount.
  ///
  /// In en, this message translates to:
  /// **'Water: {amount} ml ({percent}%)'**
  String waterAmount(int amount, int percent);

  /// No description provided for @alcoholAmount.
  ///
  /// In en, this message translates to:
  /// **'Alcohol: {amount} SD'**
  String alcoholAmount(String amount);

  /// No description provided for @totalSD.
  ///
  /// In en, this message translates to:
  /// **'Total SD'**
  String get totalSD;

  /// No description provided for @forMonth.
  ///
  /// In en, this message translates to:
  /// **'for month'**
  String get forMonth;

  /// No description provided for @daysWithAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Days with alcohol'**
  String get daysWithAlcohol;

  /// No description provided for @fromDays.
  ///
  /// In en, this message translates to:
  /// **'from {days}'**
  String fromDays(int days);

  /// No description provided for @soberDays.
  ///
  /// In en, this message translates to:
  /// **'Sober days'**
  String get soberDays;

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'excellent!'**
  String get excellent;

  /// No description provided for @averageSD.
  ///
  /// In en, this message translates to:
  /// **'Average SD'**
  String get averageSD;

  /// No description provided for @inDrinkingDays.
  ///
  /// In en, this message translates to:
  /// **'in drinking days'**
  String get inDrinkingDays;

  /// No description provided for @bestDay.
  ///
  /// In en, this message translates to:
  /// **'🏆 Best day'**
  String get bestDay;

  /// No description provided for @bestDayMessage.
  ///
  /// In en, this message translates to:
  /// **'{day} - {percent}% of goal'**
  String bestDayMessage(String day, int percent);

  /// No description provided for @weekends.
  ///
  /// In en, this message translates to:
  /// **'📅 Weekends'**
  String get weekends;

  /// No description provided for @weekdays.
  ///
  /// In en, this message translates to:
  /// **'📅 Weekdays'**
  String get weekdays;

  /// No description provided for @drinkLessOnWeekends.
  ///
  /// In en, this message translates to:
  /// **'You drink {percent}% less on weekends'**
  String drinkLessOnWeekends(int percent);

  /// No description provided for @drinkLessOnWeekdays.
  ///
  /// In en, this message translates to:
  /// **'You drink {percent}% less on weekdays'**
  String drinkLessOnWeekdays(int percent);

  /// No description provided for @positiveTrend.
  ///
  /// In en, this message translates to:
  /// **'📈 Positive trend'**
  String get positiveTrend;

  /// No description provided for @positiveTrendMessage.
  ///
  /// In en, this message translates to:
  /// **'Your hydration improves by the end of the week'**
  String get positiveTrendMessage;

  /// No description provided for @decliningActivity.
  ///
  /// In en, this message translates to:
  /// **'📉 Declining activity'**
  String get decliningActivity;

  /// No description provided for @decliningActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'Water consumption decreases by the end of the week'**
  String get decliningActivityMessage;

  /// No description provided for @lowSalt.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Low salt'**
  String get lowSalt;

  /// No description provided for @lowSaltMessage.
  ///
  /// In en, this message translates to:
  /// **'Only {days} days with normal sodium levels'**
  String lowSaltMessage(int days);

  /// No description provided for @frequentAlcohol.
  ///
  /// In en, this message translates to:
  /// **'🍺 Frequent consumption'**
  String get frequentAlcohol;

  /// No description provided for @frequentAlcoholMessage.
  ///
  /// In en, this message translates to:
  /// **'Alcohol {days} days out of 7 affects hydration'**
  String frequentAlcoholMessage(int days);

  /// No description provided for @excellentWeek.
  ///
  /// In en, this message translates to:
  /// **'✅ Excellent week'**
  String get excellentWeek;

  /// No description provided for @continueMessage.
  ///
  /// In en, this message translates to:
  /// **'Keep up the good work!'**
  String get continueMessage;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @addAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Add alcohol'**
  String get addAlcohol;

  /// No description provided for @minimumHarm.
  ///
  /// In en, this message translates to:
  /// **'Minimum harm'**
  String get minimumHarm;

  /// No description provided for @additionalWaterNeeded.
  ///
  /// In en, this message translates to:
  /// **'+{amount} ml water needed'**
  String additionalWaterNeeded(int amount);

  /// No description provided for @additionalSodiumNeeded.
  ///
  /// In en, this message translates to:
  /// **'+{amount} mg sodium to add'**
  String additionalSodiumNeeded(int amount);

  /// No description provided for @goToBedEarly.
  ///
  /// In en, this message translates to:
  /// **'Go to bed early'**
  String get goToBedEarly;

  /// No description provided for @todayConsumed.
  ///
  /// In en, this message translates to:
  /// **'Today consumed:'**
  String get todayConsumed;

  /// No description provided for @alcoholToday.
  ///
  /// In en, this message translates to:
  /// **'Alcohol today'**
  String get alcoholToday;

  /// No description provided for @beer.
  ///
  /// In en, this message translates to:
  /// **'Beer'**
  String get beer;

  /// No description provided for @wine.
  ///
  /// In en, this message translates to:
  /// **'Wine'**
  String get wine;

  /// No description provided for @spirits.
  ///
  /// In en, this message translates to:
  /// **'Spirits'**
  String get spirits;

  /// No description provided for @cocktail.
  ///
  /// In en, this message translates to:
  /// **'Cocktail'**
  String get cocktail;

  /// No description provided for @selectDrinkType.
  ///
  /// In en, this message translates to:
  /// **'Select drink type:'**
  String get selectDrinkType;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @enterVolume.
  ///
  /// In en, this message translates to:
  /// **'Enter volume in ml'**
  String get enterVolume;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength'**
  String get strength;

  /// No description provided for @standardDrinks.
  ///
  /// In en, this message translates to:
  /// **'Standard drinks:'**
  String get standardDrinks;

  /// No description provided for @additionalWater.
  ///
  /// In en, this message translates to:
  /// **'Add. water'**
  String get additionalWater;

  /// No description provided for @additionalSodium.
  ///
  /// In en, this message translates to:
  /// **'Add. sodium'**
  String get additionalSodium;

  /// No description provided for @hriRisk.
  ///
  /// In en, this message translates to:
  /// **'HRI risk'**
  String get hriRisk;

  /// No description provided for @enterValidVolume.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid volume'**
  String get enterValidVolume;

  /// No description provided for @weeklyHistory.
  ///
  /// In en, this message translates to:
  /// **'Weekly history'**
  String get weeklyHistory;

  /// No description provided for @weeklyHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Analyze weekly trends, get insights and recommendations'**
  String get weeklyHistoryDesc;

  /// No description provided for @monthlyHistory.
  ///
  /// In en, this message translates to:
  /// **'Monthly history'**
  String get monthlyHistory;

  /// No description provided for @monthlyHistoryDesc.
  ///
  /// In en, this message translates to:
  /// **'Long-term patterns, week comparisons and deep analytics'**
  String get monthlyHistoryDesc;

  /// No description provided for @proFunction.
  ///
  /// In en, this message translates to:
  /// **'PRO function'**
  String get proFunction;

  /// No description provided for @unlockProHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlock PRO'**
  String get unlockProHistory;

  /// No description provided for @unlimitedHistory.
  ///
  /// In en, this message translates to:
  /// **'Unlimited history'**
  String get unlimitedHistory;

  /// No description provided for @dataExportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export data to CSV'**
  String get dataExportCSV;

  /// No description provided for @detailedAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Detailed analytics'**
  String get detailedAnalytics;

  /// No description provided for @periodComparison.
  ///
  /// In en, this message translates to:
  /// **'Period comparison'**
  String get periodComparison;

  /// No description provided for @shareResult.
  ///
  /// In en, this message translates to:
  /// **'Share result'**
  String get shareResult;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @welcomeToPro.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PRO!'**
  String get welcomeToPro;

  /// No description provided for @allFeaturesUnlocked.
  ///
  /// In en, this message translates to:
  /// **'All features are unlocked'**
  String get allFeaturesUnlocked;

  /// No description provided for @testMode.
  ///
  /// In en, this message translates to:
  /// **'Test Mode: Using mock purchase'**
  String get testMode;

  /// No description provided for @proStatusNote.
  ///
  /// In en, this message translates to:
  /// **'PRO status will persist until app restart'**
  String get proStatusNote;

  /// No description provided for @startUsingPro.
  ///
  /// In en, this message translates to:
  /// **'Start using PRO'**
  String get startUsingPro;

  /// No description provided for @lifetimeAccess.
  ///
  /// In en, this message translates to:
  /// **'Lifetime access'**
  String get lifetimeAccess;

  /// No description provided for @bestValueAnnual.
  ///
  /// In en, this message translates to:
  /// **'Best value — Annual'**
  String get bestValueAnnual;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'one-time'**
  String get oneTime;

  /// No description provided for @perYear.
  ///
  /// In en, this message translates to:
  /// **'/year'**
  String get perYear;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @approximatelyPerMonth.
  ///
  /// In en, this message translates to:
  /// **'≈ {amount}/mo'**
  String approximatelyPerMonth(String amount);

  /// No description provided for @startFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Start 7-day free trial'**
  String get startFreeTrial;

  /// No description provided for @continueWithPrice.
  ///
  /// In en, this message translates to:
  /// **'Continue — {price}'**
  String continueWithPrice(String price);

  /// No description provided for @unlockForPrice.
  ///
  /// In en, this message translates to:
  /// **'Unlock for {price} (one-time)'**
  String unlockForPrice(String price);

  /// No description provided for @enableFreeTrial.
  ///
  /// In en, this message translates to:
  /// **'Enable 7-day free trial'**
  String get enableFreeTrial;

  /// No description provided for @noChargeToday.
  ///
  /// In en, this message translates to:
  /// **'No charge today. After 7 days, your subscription renews automatically unless canceled.'**
  String get noChargeToday;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'You can cancel anytime in Settings.'**
  String get cancelAnytime;

  /// No description provided for @everythingInPro.
  ///
  /// In en, this message translates to:
  /// **'Everything in PRO'**
  String get everythingInPro;

  /// No description provided for @smartReminders.
  ///
  /// In en, this message translates to:
  /// **'Smart reminders'**
  String get smartReminders;

  /// No description provided for @smartRemindersDesc.
  ///
  /// In en, this message translates to:
  /// **'Heat, workouts, fasting — no spam.'**
  String get smartRemindersDesc;

  /// No description provided for @weeklyReports.
  ///
  /// In en, this message translates to:
  /// **'Weekly reports'**
  String get weeklyReports;

  /// No description provided for @weeklyReportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Deep insights + CSV export.'**
  String get weeklyReportsDesc;

  /// No description provided for @healthIntegrations.
  ///
  /// In en, this message translates to:
  /// **'Health integrations'**
  String get healthIntegrations;

  /// No description provided for @healthIntegrationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Apple Health & Google Fit.'**
  String get healthIntegrationsDesc;

  /// No description provided for @alcoholProtocols.
  ///
  /// In en, this message translates to:
  /// **'Alcohol protocols'**
  String get alcoholProtocols;

  /// No description provided for @alcoholProtocolsDesc.
  ///
  /// In en, this message translates to:
  /// **'Pre-drink prep & recovery roadmap.'**
  String get alcoholProtocolsDesc;

  /// No description provided for @fullSync.
  ///
  /// In en, this message translates to:
  /// **'Full sync'**
  String get fullSync;

  /// No description provided for @fullSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlimited history across devices.'**
  String get fullSyncDesc;

  /// No description provided for @personalCalibrations.
  ///
  /// In en, this message translates to:
  /// **'Personal calibrations'**
  String get personalCalibrations;

  /// No description provided for @personalCalibrationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Sweat test, urine color scale.'**
  String get personalCalibrationsDesc;

  /// No description provided for @showAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Show all features'**
  String get showAllFeatures;

  /// No description provided for @showLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @proSubscriptionRestored.
  ///
  /// In en, this message translates to:
  /// **'PRO subscription restored!'**
  String get proSubscriptionRestored;

  /// No description provided for @noPurchasesToRestore.
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore'**
  String get noPurchasesToRestore;

  /// No description provided for @drinkMoreWaterToday.
  ///
  /// In en, this message translates to:
  /// **'Drink more water today (+20%)'**
  String get drinkMoreWaterToday;

  /// No description provided for @addElectrolytesToWater.
  ///
  /// In en, this message translates to:
  /// **'Add electrolytes to each water intake'**
  String get addElectrolytesToWater;

  /// No description provided for @limitCoffeeOneCup.
  ///
  /// In en, this message translates to:
  /// **'Limit coffee to one cup'**
  String get limitCoffeeOneCup;

  /// No description provided for @increaseWater10.
  ///
  /// In en, this message translates to:
  /// **'Increase water by 10%'**
  String get increaseWater10;

  /// No description provided for @dontForgetElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget electrolytes'**
  String get dontForgetElectrolytes;

  /// No description provided for @startDayWithWater.
  ///
  /// In en, this message translates to:
  /// **'Start your day with a glass of water'**
  String get startDayWithWater;

  /// No description provided for @dontForgetElectrolytesReminder.
  ///
  /// In en, this message translates to:
  /// **'⚡ Don\'t forget electrolytes'**
  String get dontForgetElectrolytesReminder;

  /// No description provided for @startDayWithWaterReminder.
  ///
  /// In en, this message translates to:
  /// **'Start your day with a glass of water for good wellbeing'**
  String get startDayWithWaterReminder;

  /// No description provided for @takeElectrolytesMorning.
  ///
  /// In en, this message translates to:
  /// **'Take electrolytes in the morning'**
  String get takeElectrolytesMorning;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseFailed(String error);

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailed(String error);

  /// No description provided for @trustedByUsers.
  ///
  /// In en, this message translates to:
  /// **'⭐️ 4.9 — trusted by 12,000 users'**
  String get trustedByUsers;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get bestValue;

  /// No description provided for @percentOff.
  ///
  /// In en, this message translates to:
  /// **'-{percent}% Best value'**
  String percentOff(int percent);

  /// No description provided for @weatherUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Weather unavailable'**
  String get weatherUnavailable;

  /// No description provided for @checkLocationPermissions.
  ///
  /// In en, this message translates to:
  /// **'Check location permissions and internet'**
  String get checkLocationPermissions;

  /// No description provided for @currentLocation.
  ///
  /// In en, this message translates to:
  /// **'Current location'**
  String get currentLocation;

  /// No description provided for @weatherClear.
  ///
  /// In en, this message translates to:
  /// **'clear'**
  String get weatherClear;

  /// No description provided for @weatherCloudy.
  ///
  /// In en, this message translates to:
  /// **'cloudy'**
  String get weatherCloudy;

  /// No description provided for @weatherOvercast.
  ///
  /// In en, this message translates to:
  /// **'overcast'**
  String get weatherOvercast;

  /// No description provided for @weatherRain.
  ///
  /// In en, this message translates to:
  /// **'rain'**
  String get weatherRain;

  /// No description provided for @weatherSnow.
  ///
  /// In en, this message translates to:
  /// **'snow'**
  String get weatherSnow;

  /// No description provided for @weatherStorm.
  ///
  /// In en, this message translates to:
  /// **'storm'**
  String get weatherStorm;

  /// No description provided for @weatherFog.
  ///
  /// In en, this message translates to:
  /// **'fog'**
  String get weatherFog;

  /// No description provided for @weatherDrizzle.
  ///
  /// In en, this message translates to:
  /// **'drizzle'**
  String get weatherDrizzle;

  /// No description provided for @weatherSunny.
  ///
  /// In en, this message translates to:
  /// **'sunny'**
  String get weatherSunny;

  /// No description provided for @heatWarningExtreme.
  ///
  /// In en, this message translates to:
  /// **'☀️ Extreme heat! Maximum hydration'**
  String get heatWarningExtreme;

  /// No description provided for @heatWarningVeryHot.
  ///
  /// In en, this message translates to:
  /// **'🌡️ Very hot! Risk of dehydration'**
  String get heatWarningVeryHot;

  /// No description provided for @heatWarningHot.
  ///
  /// In en, this message translates to:
  /// **'🔥 Hot! Drink more water'**
  String get heatWarningHot;

  /// No description provided for @heatWarningElevated.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Elevated temperature'**
  String get heatWarningElevated;

  /// No description provided for @heatWarningComfortable.
  ///
  /// In en, this message translates to:
  /// **'Comfortable temperature'**
  String get heatWarningComfortable;

  /// No description provided for @adjustmentWater.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% water'**
  String adjustmentWater(int percent);

  /// No description provided for @adjustmentSodium.
  ///
  /// In en, this message translates to:
  /// **'+{amount} mg sodium'**
  String adjustmentSodium(int amount);

  /// No description provided for @heatWarningCold.
  ///
  /// In en, this message translates to:
  /// **'❄️ Cold! Warm up and drink warm fluids'**
  String get heatWarningCold;

  /// Name of the notification channel
  ///
  /// In en, this message translates to:
  /// **'FoodCoach Reminders'**
  String get notificationChannelName;

  /// Description of the notification channel
  ///
  /// In en, this message translates to:
  /// **'Water and electrolyte reminders'**
  String get notificationChannelDescription;

  /// Name of the urgent notification channel
  ///
  /// In en, this message translates to:
  /// **'Urgent Reminders'**
  String get urgentNotificationChannelName;

  /// Description of the urgent notification channel
  ///
  /// In en, this message translates to:
  /// **'Important hydration notifications'**
  String get urgentNotificationChannelDescription;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'☀️ Good morning!'**
  String get goodMorning;

  /// No description provided for @timeToHydrate.
  ///
  /// In en, this message translates to:
  /// **'💧 Time to hydrate'**
  String get timeToHydrate;

  /// No description provided for @eveningHydration.
  ///
  /// In en, this message translates to:
  /// **'💧 Evening hydration'**
  String get eveningHydration;

  /// No description provided for @dailyReportTitle.
  ///
  /// In en, this message translates to:
  /// **' Daily report ready'**
  String get dailyReportTitle;

  /// No description provided for @dailyReportBody.
  ///
  /// In en, this message translates to:
  /// **'See how your hydration day went'**
  String get dailyReportBody;

  /// No description provided for @maintainWaterBalance.
  ///
  /// In en, this message translates to:
  /// **'Maintain water balance throughout the day'**
  String get maintainWaterBalance;

  /// No description provided for @electrolytesTime.
  ///
  /// In en, this message translates to:
  /// **'Time for electrolytes: add a pinch of salt to water'**
  String get electrolytesTime;

  /// No description provided for @catchUpHydration.
  ///
  /// In en, this message translates to:
  /// **'You\'ve drunk only {percent}% of daily norm. Time to catch up!'**
  String catchUpHydration(int percent);

  /// No description provided for @excellentProgress.
  ///
  /// In en, this message translates to:
  /// **'Excellent progress! A bit more to reach the goal'**
  String get excellentProgress;

  /// No description provided for @postCoffeeTitle.
  ///
  /// In en, this message translates to:
  /// **' After coffee'**
  String get postCoffeeTitle;

  /// No description provided for @postCoffeeBody.
  ///
  /// In en, this message translates to:
  /// **'Drink 250-300 ml water to restore balance'**
  String get postCoffeeBody;

  /// No description provided for @postWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **' After workout'**
  String get postWorkoutTitle;

  /// No description provided for @postWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Restore electrolytes: 500 ml water + pinch of salt'**
  String get postWorkoutBody;

  /// No description provided for @heatWarningPro.
  ///
  /// In en, this message translates to:
  /// **'🌡️ PRO Heat warning'**
  String get heatWarningPro;

  /// No description provided for @extremeHeatWarning.
  ///
  /// In en, this message translates to:
  /// **'Extreme heat! Increase water consumption by 15% and add 1g salt'**
  String get extremeHeatWarning;

  /// No description provided for @hotWeatherWarning.
  ///
  /// In en, this message translates to:
  /// **'Hot! Drink 10% more water and don\'t forget electrolytes'**
  String get hotWeatherWarning;

  /// No description provided for @warmWeatherWarning.
  ///
  /// In en, this message translates to:
  /// **'Warm weather. Monitor your hydration'**
  String get warmWeatherWarning;

  /// No description provided for @alcoholRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'🍺 Recovery time'**
  String get alcoholRecoveryTitle;

  /// No description provided for @alcoholRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Drink 300 ml water with a pinch of salt for balance'**
  String get alcoholRecoveryBody;

  /// No description provided for @continueHydration.
  ///
  /// In en, this message translates to:
  /// **'💧 Continue hydration'**
  String get continueHydration;

  /// No description provided for @alcoholRecoveryBody2.
  ///
  /// In en, this message translates to:
  /// **'Another 500 ml water will help you recover faster'**
  String get alcoholRecoveryBody2;

  /// No description provided for @morningRecoveryTitle.
  ///
  /// In en, this message translates to:
  /// **'☀️ Morning recovery'**
  String get morningRecoveryTitle;

  /// No description provided for @morningRecoveryBody.
  ///
  /// In en, this message translates to:
  /// **'Start the day with 500 ml water and electrolytes'**
  String get morningRecoveryBody;

  /// No description provided for @testNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'🧪 Test notification'**
  String get testNotificationTitle;

  /// No description provided for @testNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'If you see this - instant notifications work!'**
  String get testNotificationBody;

  /// No description provided for @scheduledTestTitle.
  ///
  /// In en, this message translates to:
  /// **'⏰ Scheduled test (1 min)'**
  String get scheduledTestTitle;

  /// No description provided for @scheduledTestBody.
  ///
  /// In en, this message translates to:
  /// **'This notification was scheduled 1 minute ago. Scheduling works!'**
  String get scheduledTestBody;

  /// No description provided for @notificationServiceInitialized.
  ///
  /// In en, this message translates to:
  /// **'✅ NotificationService initialized'**
  String get notificationServiceInitialized;

  /// No description provided for @localNotificationsInitialized.
  ///
  /// In en, this message translates to:
  /// **'✅ Local notifications initialized'**
  String get localNotificationsInitialized;

  /// No description provided for @androidChannelsCreated.
  ///
  /// In en, this message translates to:
  /// **'📢 Android notification channels created'**
  String get androidChannelsCreated;

  /// No description provided for @notificationsPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'📝 Notifications permission: {granted}'**
  String notificationsPermissionGranted(String granted);

  /// No description provided for @exactAlarmsPermissionGranted.
  ///
  /// In en, this message translates to:
  /// **'📝 Exact alarms permission: {granted}'**
  String exactAlarmsPermissionGranted(String granted);

  /// No description provided for @fcmPermissions.
  ///
  /// In en, this message translates to:
  /// **'📱 FCM permissions: {status}'**
  String fcmPermissions(String status);

  /// No description provided for @fcmTokenReceived.
  ///
  /// In en, this message translates to:
  /// **'🔑 FCM Token received'**
  String get fcmTokenReceived;

  /// No description provided for @fcmTokenSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ FCM Token saved to Firestore for user {userId}'**
  String fcmTokenSaved(String userId);

  /// No description provided for @topicSubscriptionComplete.
  ///
  /// In en, this message translates to:
  /// **'✅ Topic subscription complete'**
  String get topicSubscriptionComplete;

  /// No description provided for @foregroundMessage.
  ///
  /// In en, this message translates to:
  /// **'📨 Foreground message: {title}'**
  String foregroundMessage(String title);

  /// No description provided for @notificationOpened.
  ///
  /// In en, this message translates to:
  /// **'📱 Notification opened: {messageId}'**
  String notificationOpened(String messageId);

  /// No description provided for @dailyLimitReached.
  ///
  /// In en, this message translates to:
  /// **'⚠️ Daily notification limit reached (4/day for FREE)'**
  String get dailyLimitReached;

  /// No description provided for @schedulingError.
  ///
  /// In en, this message translates to:
  /// **'❌ Notification scheduling error: {error}'**
  String schedulingError(String error);

  /// No description provided for @showingImmediatelyAsFallback.
  ///
  /// In en, this message translates to:
  /// **'Showing notification immediately as fallback'**
  String get showingImmediatelyAsFallback;

  /// No description provided for @instantNotificationShown.
  ///
  /// In en, this message translates to:
  /// **'📬 Instant notification shown: {title}'**
  String instantNotificationShown(String title);

  /// No description provided for @smartRemindersScheduled.
  ///
  /// In en, this message translates to:
  /// **'🧠 Scheduling smart reminders...'**
  String get smartRemindersScheduled;

  /// No description provided for @smartRemindersComplete.
  ///
  /// In en, this message translates to:
  /// **'✅ Scheduled {count} reminders'**
  String smartRemindersComplete(int count);

  /// No description provided for @proPostCoffeeScheduled.
  ///
  /// In en, this message translates to:
  /// **'☕ PRO: Post-coffee reminder scheduled'**
  String get proPostCoffeeScheduled;

  /// No description provided for @postWorkoutScheduled.
  ///
  /// In en, this message translates to:
  /// **'💪 Post-workout reminder scheduled'**
  String get postWorkoutScheduled;

  /// No description provided for @proHeatWarningPro.
  ///
  /// In en, this message translates to:
  /// **'🌡️ PRO: Heat warning sent'**
  String get proHeatWarningPro;

  /// No description provided for @proAlcoholRecoveryPlan.
  ///
  /// In en, this message translates to:
  /// **'🍺 PRO: Alcohol recovery plan scheduled'**
  String get proAlcoholRecoveryPlan;

  /// No description provided for @eveningReportScheduled.
  ///
  /// In en, this message translates to:
  /// **'📊 Evening report scheduled for {day}.{month} at 21:00'**
  String eveningReportScheduled(int day, int month);

  /// No description provided for @notificationCancelled.
  ///
  /// In en, this message translates to:
  /// **'🚫 Notification {id} cancelled'**
  String notificationCancelled(int id);

  /// No description provided for @allNotificationsCancelled.
  ///
  /// In en, this message translates to:
  /// **'🗑️ All notifications cancelled'**
  String get allNotificationsCancelled;

  /// No description provided for @reminderSettingsSaved.
  ///
  /// In en, this message translates to:
  /// **'✅ Reminder settings saved'**
  String get reminderSettingsSaved;

  /// No description provided for @testNotificationScheduledFor.
  ///
  /// In en, this message translates to:
  /// **'⏰ Test notification scheduled for {time}'**
  String testNotificationScheduledFor(String time);

  /// No description provided for @tomorrowRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations for tomorrow'**
  String get tomorrowRecommendations;

  /// No description provided for @recommendationExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent work! Keep it up. Try to start the day with a glass of water and maintain even consumption.'**
  String get recommendationExcellent;

  /// No description provided for @recommendationDiluted.
  ///
  /// In en, this message translates to:
  /// **'You drink a lot of water but few electrolytes. Tomorrow add more salt or drink an electrolyte beverage. Try starting the day with salty broth.'**
  String get recommendationDiluted;

  /// No description provided for @recommendationDehydrated.
  ///
  /// In en, this message translates to:
  /// **'Not enough water today. Tomorrow set reminders every 2 hours. Keep a water bottle in sight.'**
  String get recommendationDehydrated;

  /// No description provided for @recommendationLowSalt.
  ///
  /// In en, this message translates to:
  /// **'Low sodium levels can cause fatigue. Add a pinch of salt to water or drink broth. Especially important on keto or fasting.'**
  String get recommendationLowSalt;

  /// No description provided for @recommendationGeneral.
  ///
  /// In en, this message translates to:
  /// **'Aim for balance between water and electrolytes. Drink evenly throughout the day and don\'t forget salt in heat.'**
  String get recommendationGeneral;

  /// No description provided for @category_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get category_water;

  /// No description provided for @category_hot_drinks.
  ///
  /// In en, this message translates to:
  /// **'Hot Drinks'**
  String get category_hot_drinks;

  /// No description provided for @category_juice.
  ///
  /// In en, this message translates to:
  /// **'Juices'**
  String get category_juice;

  /// No description provided for @category_sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get category_sports;

  /// No description provided for @category_dairy.
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get category_dairy;

  /// No description provided for @category_alcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get category_alcohol;

  /// No description provided for @category_supplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get category_supplements;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @drink_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get drink_water;

  /// No description provided for @drink_sparkling_water.
  ///
  /// In en, this message translates to:
  /// **'Sparkling Water'**
  String get drink_sparkling_water;

  /// No description provided for @drink_mineral_water.
  ///
  /// In en, this message translates to:
  /// **'Mineral Water'**
  String get drink_mineral_water;

  /// No description provided for @drink_coconut_water.
  ///
  /// In en, this message translates to:
  /// **'Coconut Water'**
  String get drink_coconut_water;

  /// No description provided for @drink_coffee.
  ///
  /// In en, this message translates to:
  /// **'Coffee'**
  String get drink_coffee;

  /// No description provided for @drink_espresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get drink_espresso;

  /// No description provided for @drink_americano.
  ///
  /// In en, this message translates to:
  /// **'Americano'**
  String get drink_americano;

  /// No description provided for @drink_cappuccino.
  ///
  /// In en, this message translates to:
  /// **'Cappuccino'**
  String get drink_cappuccino;

  /// No description provided for @drink_latte.
  ///
  /// In en, this message translates to:
  /// **'Latte'**
  String get drink_latte;

  /// No description provided for @drink_black_tea.
  ///
  /// In en, this message translates to:
  /// **'Black Tea'**
  String get drink_black_tea;

  /// No description provided for @drink_green_tea.
  ///
  /// In en, this message translates to:
  /// **'Green Tea'**
  String get drink_green_tea;

  /// No description provided for @drink_herbal_tea.
  ///
  /// In en, this message translates to:
  /// **'Herbal Tea'**
  String get drink_herbal_tea;

  /// No description provided for @drink_matcha.
  ///
  /// In en, this message translates to:
  /// **'Matcha'**
  String get drink_matcha;

  /// No description provided for @drink_hot_chocolate.
  ///
  /// In en, this message translates to:
  /// **'Hot Chocolate'**
  String get drink_hot_chocolate;

  /// No description provided for @drink_orange_juice.
  ///
  /// In en, this message translates to:
  /// **'Orange Juice'**
  String get drink_orange_juice;

  /// No description provided for @drink_apple_juice.
  ///
  /// In en, this message translates to:
  /// **'Apple Juice'**
  String get drink_apple_juice;

  /// No description provided for @drink_grapefruit_juice.
  ///
  /// In en, this message translates to:
  /// **'Grapefruit Juice'**
  String get drink_grapefruit_juice;

  /// No description provided for @drink_tomato_juice.
  ///
  /// In en, this message translates to:
  /// **'Tomato Juice'**
  String get drink_tomato_juice;

  /// No description provided for @drink_vegetable_juice.
  ///
  /// In en, this message translates to:
  /// **'Vegetable Juice'**
  String get drink_vegetable_juice;

  /// No description provided for @drink_smoothie.
  ///
  /// In en, this message translates to:
  /// **'Smoothie'**
  String get drink_smoothie;

  /// No description provided for @drink_lemonade.
  ///
  /// In en, this message translates to:
  /// **'Lemonade'**
  String get drink_lemonade;

  /// No description provided for @drink_isotonic.
  ///
  /// In en, this message translates to:
  /// **'Isotonic Drink'**
  String get drink_isotonic;

  /// No description provided for @drink_electrolyte.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte Drink'**
  String get drink_electrolyte;

  /// No description provided for @drink_protein_shake.
  ///
  /// In en, this message translates to:
  /// **'Protein Shake'**
  String get drink_protein_shake;

  /// No description provided for @drink_bcaa.
  ///
  /// In en, this message translates to:
  /// **'BCAA Drink'**
  String get drink_bcaa;

  /// No description provided for @drink_energy.
  ///
  /// In en, this message translates to:
  /// **'Energy Drink'**
  String get drink_energy;

  /// No description provided for @drink_milk.
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get drink_milk;

  /// No description provided for @drink_kefir.
  ///
  /// In en, this message translates to:
  /// **'Kefir'**
  String get drink_kefir;

  /// No description provided for @drink_yogurt.
  ///
  /// In en, this message translates to:
  /// **'Yogurt Drink'**
  String get drink_yogurt;

  /// No description provided for @drink_almond_milk.
  ///
  /// In en, this message translates to:
  /// **'Almond Milk'**
  String get drink_almond_milk;

  /// No description provided for @drink_soy_milk.
  ///
  /// In en, this message translates to:
  /// **'Soy Milk'**
  String get drink_soy_milk;

  /// No description provided for @drink_oat_milk.
  ///
  /// In en, this message translates to:
  /// **'Oat Milk'**
  String get drink_oat_milk;

  /// No description provided for @drink_beer_light.
  ///
  /// In en, this message translates to:
  /// **'Light Beer'**
  String get drink_beer_light;

  /// No description provided for @drink_beer_regular.
  ///
  /// In en, this message translates to:
  /// **'Regular Beer'**
  String get drink_beer_regular;

  /// No description provided for @drink_beer_strong.
  ///
  /// In en, this message translates to:
  /// **'Strong Beer'**
  String get drink_beer_strong;

  /// No description provided for @drink_wine_red.
  ///
  /// In en, this message translates to:
  /// **'Red Wine'**
  String get drink_wine_red;

  /// No description provided for @drink_wine_white.
  ///
  /// In en, this message translates to:
  /// **'White Wine'**
  String get drink_wine_white;

  /// No description provided for @drink_champagne.
  ///
  /// In en, this message translates to:
  /// **'Champagne'**
  String get drink_champagne;

  /// No description provided for @drink_vodka.
  ///
  /// In en, this message translates to:
  /// **'Vodka'**
  String get drink_vodka;

  /// No description provided for @drink_whiskey.
  ///
  /// In en, this message translates to:
  /// **'Whiskey'**
  String get drink_whiskey;

  /// No description provided for @drink_rum.
  ///
  /// In en, this message translates to:
  /// **'Rum'**
  String get drink_rum;

  /// No description provided for @drink_gin.
  ///
  /// In en, this message translates to:
  /// **'Gin'**
  String get drink_gin;

  /// No description provided for @drink_tequila.
  ///
  /// In en, this message translates to:
  /// **'Tequila'**
  String get drink_tequila;

  /// No description provided for @drink_mojito.
  ///
  /// In en, this message translates to:
  /// **'Mojito'**
  String get drink_mojito;

  /// No description provided for @drink_margarita.
  ///
  /// In en, this message translates to:
  /// **'Margarita'**
  String get drink_margarita;

  /// No description provided for @drink_kombucha.
  ///
  /// In en, this message translates to:
  /// **'Kombucha'**
  String get drink_kombucha;

  /// No description provided for @drink_kvass.
  ///
  /// In en, this message translates to:
  /// **'Kvass'**
  String get drink_kvass;

  /// No description provided for @drink_bone_broth.
  ///
  /// In en, this message translates to:
  /// **'Bone Broth'**
  String get drink_bone_broth;

  /// No description provided for @drink_vegetable_broth.
  ///
  /// In en, this message translates to:
  /// **'Vegetable Broth'**
  String get drink_vegetable_broth;

  /// No description provided for @drink_soda.
  ///
  /// In en, this message translates to:
  /// **'Soda'**
  String get drink_soda;

  /// No description provided for @drink_diet_soda.
  ///
  /// In en, this message translates to:
  /// **'Diet Soda'**
  String get drink_diet_soda;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @favoriteLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Favorites limit reached (3 for FREE, 20 for PRO)'**
  String get favoriteLimitReached;

  /// No description provided for @addFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add favorite'**
  String get addFavorite;

  /// No description provided for @hotAndSupplements.
  ///
  /// In en, this message translates to:
  /// **'Hot & Supplements'**
  String get hotAndSupplements;

  /// No description provided for @quickVolumes.
  ///
  /// In en, this message translates to:
  /// **'Quick volumes:'**
  String get quickVolumes;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type:'**
  String get type;

  /// No description provided for @regular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get regular;

  /// No description provided for @coconut.
  ///
  /// In en, this message translates to:
  /// **'Coconut'**
  String get coconut;

  /// No description provided for @sparkling.
  ///
  /// In en, this message translates to:
  /// **'Sparkling'**
  String get sparkling;

  /// No description provided for @mineral.
  ///
  /// In en, this message translates to:
  /// **'Mineral'**
  String get mineral;

  /// No description provided for @hotDrinks.
  ///
  /// In en, this message translates to:
  /// **'Hot Drinks'**
  String get hotDrinks;

  /// No description provided for @supplements.
  ///
  /// In en, this message translates to:
  /// **'Supplements'**
  String get supplements;

  /// No description provided for @tea.
  ///
  /// In en, this message translates to:
  /// **'Tea'**
  String get tea;

  /// No description provided for @salt.
  ///
  /// In en, this message translates to:
  /// **'Salt (1/4 tsp)'**
  String get salt;

  /// No description provided for @electrolyteMix.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte Mix'**
  String get electrolyteMix;

  /// No description provided for @boneBroth.
  ///
  /// In en, this message translates to:
  /// **'Bone Broth'**
  String get boneBroth;

  /// No description provided for @favoriteAssignmentComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Favorite assignment coming soon'**
  String get favoriteAssignmentComingSoon;

  /// No description provided for @longPressToEditComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Long press to edit - coming soon'**
  String get longPressToEditComingSoon;

  /// No description provided for @proSubscriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'PRO subscription required'**
  String get proSubscriptionRequired;

  /// Button to save current settings as favorite
  ///
  /// In en, this message translates to:
  /// **'Save to favorites'**
  String get saveToFavorites;

  /// Success message when saved to favorites
  ///
  /// In en, this message translates to:
  /// **'Saved to favorites'**
  String get savedToFavorites;

  /// Title for favorite slot selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select favorite slot'**
  String get selectFavoriteSlot;

  /// Favorite slot label
  ///
  /// In en, this message translates to:
  /// **'Slot'**
  String get slot;

  /// Label for empty favorite slot
  ///
  /// In en, this message translates to:
  /// **'Empty slot'**
  String get emptySlot;

  /// Message for locked PRO slots
  ///
  /// In en, this message translates to:
  /// **'Upgrade to PRO to unlock'**
  String get upgradeToUnlock;

  /// Option to change existing favorite
  ///
  /// In en, this message translates to:
  /// **'Change favorite'**
  String get changeFavorite;

  /// Option to remove favorite
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get removeFavorite;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Mineral water drink type
  ///
  /// In en, this message translates to:
  /// **'Mineral Water'**
  String get mineralWater;

  /// Coconut water drink type
  ///
  /// In en, this message translates to:
  /// **'Coconut Water'**
  String get coconutWater;

  /// Lemon water drink type
  ///
  /// In en, this message translates to:
  /// **'Lemon Water'**
  String get lemonWater;

  /// Green tea drink type
  ///
  /// In en, this message translates to:
  /// **'Green Tea'**
  String get greenTea;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @createFavoriteHint.
  ///
  /// In en, this message translates to:
  /// **'To add a favorite, go to any drink screen below and tap \'Save to favorites\' button after setting up your drink.'**
  String get createFavoriteHint;

  /// Sparkling water drink type
  ///
  /// In en, this message translates to:
  /// **'Sparkling Water'**
  String get sparklingWater;

  /// Cola drink type
  ///
  /// In en, this message translates to:
  /// **'Cola'**
  String get cola;

  /// Juice drink type
  ///
  /// In en, this message translates to:
  /// **'Juice'**
  String get juice;

  /// Energy drink type
  ///
  /// In en, this message translates to:
  /// **'Energy Drink'**
  String get energyDrink;

  /// Sports drink type
  ///
  /// In en, this message translates to:
  /// **'Sports Drink'**
  String get sportsDrink;

  /// Prompt to select electrolyte type
  ///
  /// In en, this message translates to:
  /// **'Select electrolyte type:'**
  String get selectElectrolyteType;

  /// Quarter teaspoon of salt
  ///
  /// In en, this message translates to:
  /// **'Salt (1/4 tsp)'**
  String get saltQuarterTsp;

  /// Pink Himalayan salt type
  ///
  /// In en, this message translates to:
  /// **'Pink Himalayan Salt'**
  String get pinkSalt;

  /// Sea salt type
  ///
  /// In en, this message translates to:
  /// **'Sea Salt'**
  String get seaSalt;

  /// Potassium citrate supplement
  ///
  /// In en, this message translates to:
  /// **'Potassium Citrate'**
  String get potassiumCitrate;

  /// Magnesium glycinate supplement
  ///
  /// In en, this message translates to:
  /// **'Magnesium Glycinate'**
  String get magnesiumGlycinate;

  /// Coconut water as electrolyte source
  ///
  /// In en, this message translates to:
  /// **'Coconut Water'**
  String get coconutWaterElectrolyte;

  /// Sports drink as electrolyte source
  ///
  /// In en, this message translates to:
  /// **'Sports Drink'**
  String get sportsDrinkElectrolyte;

  /// Label for electrolyte content display
  ///
  /// In en, this message translates to:
  /// **'Electrolyte content:'**
  String get electrolyteContent;

  /// Sodium content display
  ///
  /// In en, this message translates to:
  /// **'Sodium: {amount} mg'**
  String sodiumContent(int amount);

  /// Potassium content display
  ///
  /// In en, this message translates to:
  /// **'Potassium: {amount} mg'**
  String potassiumContent(int amount);

  /// Magnesium content display
  ///
  /// In en, this message translates to:
  /// **'Magnesium: {amount} mg'**
  String magnesiumContent(int amount);

  /// Servings label
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get servings;

  /// Prompt to enter number of servings
  ///
  /// In en, this message translates to:
  /// **'Enter servings'**
  String get enterServings;

  /// Unit for servings
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servingsUnit;

  /// Message when no electrolytes present
  ///
  /// In en, this message translates to:
  /// **'No electrolytes'**
  String get noElectrolytes;

  /// Error message for invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @lmntMix.
  ///
  /// In en, this message translates to:
  /// **'LMNT Mix'**
  String get lmntMix;

  /// No description provided for @pickleJuice.
  ///
  /// In en, this message translates to:
  /// **'Pickle Juice'**
  String get pickleJuice;

  /// No description provided for @tomatoSalt.
  ///
  /// In en, this message translates to:
  /// **'Tomato + Salt'**
  String get tomatoSalt;

  /// No description provided for @ketorade.
  ///
  /// In en, this message translates to:
  /// **'Ketorade'**
  String get ketorade;

  /// No description provided for @alkalineWater.
  ///
  /// In en, this message translates to:
  /// **'Alkaline Water'**
  String get alkalineWater;

  /// No description provided for @celticSalt.
  ///
  /// In en, this message translates to:
  /// **'Celtic Salt Water'**
  String get celticSalt;

  /// No description provided for @soleWater.
  ///
  /// In en, this message translates to:
  /// **'Sole Water'**
  String get soleWater;

  /// No description provided for @mineralDrops.
  ///
  /// In en, this message translates to:
  /// **'Mineral Drops'**
  String get mineralDrops;

  /// No description provided for @bakingSoda.
  ///
  /// In en, this message translates to:
  /// **'Baking Soda Water'**
  String get bakingSoda;

  /// No description provided for @creamTartar.
  ///
  /// In en, this message translates to:
  /// **'Cream of Tartar'**
  String get creamTartar;

  /// No description provided for @selectSupplementType.
  ///
  /// In en, this message translates to:
  /// **'Select supplement type:'**
  String get selectSupplementType;

  /// No description provided for @multivitamin.
  ///
  /// In en, this message translates to:
  /// **'Multivitamin'**
  String get multivitamin;

  /// No description provided for @magnesiumCitrate.
  ///
  /// In en, this message translates to:
  /// **'Magnesium Citrate'**
  String get magnesiumCitrate;

  /// No description provided for @magnesiumThreonate.
  ///
  /// In en, this message translates to:
  /// **'Magnesium L-Threonate'**
  String get magnesiumThreonate;

  /// No description provided for @calciumCitrate.
  ///
  /// In en, this message translates to:
  /// **'Calcium Citrate'**
  String get calciumCitrate;

  /// No description provided for @zincGlycinate.
  ///
  /// In en, this message translates to:
  /// **'Zinc Glycinate'**
  String get zincGlycinate;

  /// No description provided for @vitaminD3.
  ///
  /// In en, this message translates to:
  /// **'Vitamin D3'**
  String get vitaminD3;

  /// No description provided for @vitaminC.
  ///
  /// In en, this message translates to:
  /// **'Vitamin C'**
  String get vitaminC;

  /// No description provided for @bComplex.
  ///
  /// In en, this message translates to:
  /// **'B-Complex'**
  String get bComplex;

  /// No description provided for @omega3.
  ///
  /// In en, this message translates to:
  /// **'Omega-3'**
  String get omega3;

  /// No description provided for @ironBisglycinate.
  ///
  /// In en, this message translates to:
  /// **'Iron Bisglycinate'**
  String get ironBisglycinate;

  /// No description provided for @dosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage'**
  String get dosage;

  /// No description provided for @enterDosage.
  ///
  /// In en, this message translates to:
  /// **'Enter dosage'**
  String get enterDosage;

  /// No description provided for @noElectrolyteContent.
  ///
  /// In en, this message translates to:
  /// **'No electrolyte content'**
  String get noElectrolyteContent;

  /// No description provided for @blackTea.
  ///
  /// In en, this message translates to:
  /// **'Black Tea'**
  String get blackTea;

  /// No description provided for @herbalTea.
  ///
  /// In en, this message translates to:
  /// **'Herbal Tea'**
  String get herbalTea;

  /// No description provided for @espresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get espresso;

  /// No description provided for @cappuccino.
  ///
  /// In en, this message translates to:
  /// **'Cappuccino'**
  String get cappuccino;

  /// No description provided for @latte.
  ///
  /// In en, this message translates to:
  /// **'Latte'**
  String get latte;

  /// No description provided for @matcha.
  ///
  /// In en, this message translates to:
  /// **'Matcha'**
  String get matcha;

  /// No description provided for @hotChocolate.
  ///
  /// In en, this message translates to:
  /// **'Hot Chocolate'**
  String get hotChocolate;

  /// No description provided for @caffeine.
  ///
  /// In en, this message translates to:
  /// **'Caffeine'**
  String get caffeine;

  /// No description provided for @sports.
  ///
  /// In en, this message translates to:
  /// **'Sports'**
  String get sports;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @hiit.
  ///
  /// In en, this message translates to:
  /// **'HIIT'**
  String get hiit;

  /// No description provided for @crossfit.
  ///
  /// In en, this message translates to:
  /// **'CrossFit'**
  String get crossfit;

  /// No description provided for @boxing.
  ///
  /// In en, this message translates to:
  /// **'Boxing'**
  String get boxing;

  /// No description provided for @dancing.
  ///
  /// In en, this message translates to:
  /// **'Dancing'**
  String get dancing;

  /// No description provided for @tennis.
  ///
  /// In en, this message translates to:
  /// **'Tennis'**
  String get tennis;

  /// No description provided for @teamSports.
  ///
  /// In en, this message translates to:
  /// **'Team Sports'**
  String get teamSports;

  /// No description provided for @selectActivityType.
  ///
  /// In en, this message translates to:
  /// **'Select activity type:'**
  String get selectActivityType;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// No description provided for @enterDuration.
  ///
  /// In en, this message translates to:
  /// **'Enter duration'**
  String get enterDuration;

  /// No description provided for @lowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Low intensity'**
  String get lowIntensity;

  /// No description provided for @mediumIntensity.
  ///
  /// In en, this message translates to:
  /// **'Medium intensity'**
  String get mediumIntensity;

  /// No description provided for @highIntensity.
  ///
  /// In en, this message translates to:
  /// **'High intensity'**
  String get highIntensity;

  /// No description provided for @recommendedIntake.
  ///
  /// In en, this message translates to:
  /// **'Recommended intake:'**
  String get recommendedIntake;

  /// No description provided for @basedOnWeight.
  ///
  /// In en, this message translates to:
  /// **'Based on weight'**
  String get basedOnWeight;

  /// No description provided for @logActivity.
  ///
  /// In en, this message translates to:
  /// **'Log Activity'**
  String get logActivity;

  /// No description provided for @activityLogged.
  ///
  /// In en, this message translates to:
  /// **'Activity logged'**
  String get activityLogged;

  /// No description provided for @enterValidDuration.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid duration'**
  String get enterValidDuration;

  /// No description provided for @sauna.
  ///
  /// In en, this message translates to:
  /// **'Sauna'**
  String get sauna;

  /// No description provided for @veryHighIntensity.
  ///
  /// In en, this message translates to:
  /// **'Very high intensity'**
  String get veryHighIntensity;

  /// No description provided for @hriStatusExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get hriStatusExcellent;

  /// No description provided for @hriStatusGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get hriStatusGood;

  /// No description provided for @hriStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get hriStatusModerate;

  /// No description provided for @hriStatusHighRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get hriStatusHighRisk;

  /// No description provided for @hriStatusCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get hriStatusCritical;

  /// No description provided for @hriComponentWater.
  ///
  /// In en, this message translates to:
  /// **'Water balance'**
  String get hriComponentWater;

  /// No description provided for @hriComponentSodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium level'**
  String get hriComponentSodium;

  /// No description provided for @hriComponentPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium level'**
  String get hriComponentPotassium;

  /// No description provided for @hriComponentMagnesium.
  ///
  /// In en, this message translates to:
  /// **'Magnesium level'**
  String get hriComponentMagnesium;

  /// No description provided for @hriComponentHeat.
  ///
  /// In en, this message translates to:
  /// **'Heat stress'**
  String get hriComponentHeat;

  /// No description provided for @hriComponentWorkout.
  ///
  /// In en, this message translates to:
  /// **'Physical activity'**
  String get hriComponentWorkout;

  /// No description provided for @hriComponentCaffeine.
  ///
  /// In en, this message translates to:
  /// **'Caffeine impact'**
  String get hriComponentCaffeine;

  /// No description provided for @hriComponentAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol impact'**
  String get hriComponentAlcohol;

  /// No description provided for @hriComponentTime.
  ///
  /// In en, this message translates to:
  /// **'Time since intake'**
  String get hriComponentTime;

  /// No description provided for @hriComponentMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning factors'**
  String get hriComponentMorning;

  /// No description provided for @hriBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Risk factors breakdown'**
  String get hriBreakdownTitle;

  /// No description provided for @hriComponentValue.
  ///
  /// In en, this message translates to:
  /// **'{component}: {value}/{max} pts'**
  String hriComponentValue(Object component, Object max, Object value);

  /// No description provided for @fastingModeActive.
  ///
  /// In en, this message translates to:
  /// **'Fasting mode active'**
  String get fastingModeActive;

  /// No description provided for @fastingSuppressionNote.
  ///
  /// In en, this message translates to:
  /// **'Time factor suppressed during fasting'**
  String get fastingSuppressionNote;

  /// No description provided for @morningCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'Morning Check-in'**
  String get morningCheckInTitle;

  /// No description provided for @howAreYouFeeling.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling?'**
  String get howAreYouFeeling;

  /// No description provided for @feelingScale1.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get feelingScale1;

  /// No description provided for @feelingScale2.
  ///
  /// In en, this message translates to:
  /// **'Below average'**
  String get feelingScale2;

  /// No description provided for @feelingScale3.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get feelingScale3;

  /// No description provided for @feelingScale4.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get feelingScale4;

  /// No description provided for @feelingScale5.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get feelingScale5;

  /// No description provided for @weightChange.
  ///
  /// In en, this message translates to:
  /// **'Weight change from yesterday'**
  String get weightChange;

  /// No description provided for @urineColorScale.
  ///
  /// In en, this message translates to:
  /// **'Urine color (1-8 scale)'**
  String get urineColorScale;

  /// No description provided for @urineColor1.
  ///
  /// In en, this message translates to:
  /// **'1 - Very pale'**
  String get urineColor1;

  /// No description provided for @urineColor2.
  ///
  /// In en, this message translates to:
  /// **'2 - Pale'**
  String get urineColor2;

  /// No description provided for @urineColor3.
  ///
  /// In en, this message translates to:
  /// **'3 - Light yellow'**
  String get urineColor3;

  /// No description provided for @urineColor4.
  ///
  /// In en, this message translates to:
  /// **'4 - Yellow'**
  String get urineColor4;

  /// No description provided for @urineColor5.
  ///
  /// In en, this message translates to:
  /// **'5 - Dark yellow'**
  String get urineColor5;

  /// No description provided for @urineColor6.
  ///
  /// In en, this message translates to:
  /// **'6 - Amber'**
  String get urineColor6;

  /// No description provided for @urineColor7.
  ///
  /// In en, this message translates to:
  /// **'7 - Dark amber'**
  String get urineColor7;

  /// No description provided for @urineColor8.
  ///
  /// In en, this message translates to:
  /// **'8 - Brown'**
  String get urineColor8;

  /// No description provided for @alcoholWithDecay.
  ///
  /// In en, this message translates to:
  /// **'Alcohol impact (decaying)'**
  String get alcoholWithDecay;

  /// No description provided for @standardDrinksToday.
  ///
  /// In en, this message translates to:
  /// **'Standard drinks today: {count}'**
  String standardDrinksToday(Object count);

  /// No description provided for @activeCaffeineLevel.
  ///
  /// In en, this message translates to:
  /// **'Active caffeine: {amount} mg'**
  String activeCaffeineLevel(Object amount);

  /// No description provided for @hriDebugInfo.
  ///
  /// In en, this message translates to:
  /// **'HRI Debug Info'**
  String get hriDebugInfo;

  /// No description provided for @hriNormalized.
  ///
  /// In en, this message translates to:
  /// **'HRI (normalized): {value}/100'**
  String hriNormalized(Object value);

  /// No description provided for @fastingWindowActive.
  ///
  /// In en, this message translates to:
  /// **'Fasting window active'**
  String get fastingWindowActive;

  /// No description provided for @eatingWindowActive.
  ///
  /// In en, this message translates to:
  /// **'Eating window active'**
  String get eatingWindowActive;

  /// No description provided for @nextFastingWindow.
  ///
  /// In en, this message translates to:
  /// **'Next fasting: {time}'**
  String nextFastingWindow(Object time);

  /// No description provided for @nextEatingWindow.
  ///
  /// In en, this message translates to:
  /// **'Next eating: {time}'**
  String nextEatingWindow(Object time);

  /// Title for today's workouts section
  ///
  /// In en, this message translates to:
  /// **'Today\'s Workouts'**
  String get todaysWorkouts;

  /// Hours ago suffix
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// Main welcome title with ION
  ///
  /// In en, this message translates to:
  /// **'FoodCoach — smart hydration every day'**
  String get onboardingWelcomeTitle;

  /// Welcome subtitle
  ///
  /// In en, this message translates to:
  /// **'Drink smarter, not more\nThe app accounts for weather, electrolytes and your habits\nHelps maintain clear mind and stable energy'**
  String get onboardingWelcomeSubtitle;

  /// First benefit bullet
  ///
  /// In en, this message translates to:
  /// **'Personal water and salt norm based on weather and you'**
  String get onboardingBullet1;

  /// Second benefit bullet
  ///
  /// In en, this message translates to:
  /// **'\"What to do now\" tips instead of raw charts'**
  String get onboardingBullet2;

  /// Third benefit bullet
  ///
  /// In en, this message translates to:
  /// **'Alcohol in standard doses with safe limits'**
  String get onboardingBullet3;

  /// Fourth benefit bullet
  ///
  /// In en, this message translates to:
  /// **'Smart reminders without spam'**
  String get onboardingBullet4;

  /// Main start button on welcome screen
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStartButton;

  /// Link for existing users
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get onboardingHaveAccount;

  /// Fasting checkbox title
  ///
  /// In en, this message translates to:
  /// **'I practice intermittent fasting'**
  String get onboardingPracticeFasting;

  /// Fasting checkbox description
  ///
  /// In en, this message translates to:
  /// **'Special electrolyte regime for fasting windows'**
  String get onboardingPracticeFastingDesc;

  /// Completion screen title
  ///
  /// In en, this message translates to:
  /// **'Profile ready!'**
  String get onboardingProfileReady;

  /// Water norm label in summary
  ///
  /// In en, this message translates to:
  /// **'Water norm'**
  String get onboardingWaterNorm;

  /// ION helper text on completion
  ///
  /// In en, this message translates to:
  /// **'ION will help maintain balance every day'**
  String get onboardingIonWillHelp;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// Location permission title
  ///
  /// In en, this message translates to:
  /// **'Weather matters for hydration'**
  String get onboardingLocationTitle;

  /// Location permission subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'ll account for weather and humidity. This is more accurate than just a formula by weight'**
  String get onboardingLocationSubtitle;

  /// Weather example title
  ///
  /// In en, this message translates to:
  /// **'Hot today! +15% water'**
  String get onboardingWeatherExample;

  /// Weather example description
  ///
  /// In en, this message translates to:
  /// **'+500 mg sodium for heat'**
  String get onboardingWeatherExampleDesc;

  /// Enable permission button
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get onboardingEnablePermission;

  /// Skip permission button
  ///
  /// In en, this message translates to:
  /// **'Enable later'**
  String get onboardingEnableLater;

  /// Notification permission title
  ///
  /// In en, this message translates to:
  /// **'Smart reminders'**
  String get onboardingNotificationTitle;

  /// Notification permission subtitle
  ///
  /// In en, this message translates to:
  /// **'Short tips at the right moment. You can change frequency in one tap'**
  String get onboardingNotificationSubtitle;

  /// First notification example
  ///
  /// In en, this message translates to:
  /// **'Time to hydrate'**
  String get onboardingNotifExample1;

  /// Second notification example
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget electrolytes'**
  String get onboardingNotifExample2;

  /// Third notification example
  ///
  /// In en, this message translates to:
  /// **'Hot! Drink more water'**
  String get onboardingNotifExample3;

  /// PRO feature - sport recovery protocols
  ///
  /// In en, this message translates to:
  /// **'Sport recovery protocols'**
  String get sportRecoveryProtocols;

  /// PRO feature - expanded drinks and supplements catalog
  ///
  /// In en, this message translates to:
  /// **'All drinks & supplements'**
  String get allDrinksAndSupplements;

  /// Default notification channel name
  ///
  /// In en, this message translates to:
  /// **'Hydration Reminders'**
  String get notificationChannelDefault;

  /// Default notification channel description
  ///
  /// In en, this message translates to:
  /// **'Water and electrolyte reminders'**
  String get notificationChannelDefaultDesc;

  /// Urgent notification channel name
  ///
  /// In en, this message translates to:
  /// **'Important Notifications'**
  String get notificationChannelUrgent;

  /// Urgent notification channel description
  ///
  /// In en, this message translates to:
  /// **'Heat warnings and critical hydration alerts'**
  String get notificationChannelUrgentDesc;

  /// Report notification channel name
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get notificationChannelReport;

  /// Report notification channel description
  ///
  /// In en, this message translates to:
  /// **'Daily and weekly reports'**
  String get notificationChannelReportDesc;

  /// No description provided for @notificationWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'💧 Time to hydrate'**
  String get notificationWaterTitle;

  /// No description provided for @notificationWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to drink water'**
  String get notificationWaterBody;

  /// No description provided for @notificationPostCoffeeTitle.
  ///
  /// In en, this message translates to:
  /// **'☕ After coffee'**
  String get notificationPostCoffeeTitle;

  /// No description provided for @notificationPostCoffeeBody.
  ///
  /// In en, this message translates to:
  /// **'Drink 250-300 ml water to restore balance'**
  String get notificationPostCoffeeBody;

  /// No description provided for @notificationDailyReportTitle.
  ///
  /// In en, this message translates to:
  /// **'📊 Daily report ready'**
  String get notificationDailyReportTitle;

  /// No description provided for @notificationDailyReportBody.
  ///
  /// In en, this message translates to:
  /// **'See how your hydration day went'**
  String get notificationDailyReportBody;

  /// No description provided for @notificationAlcoholCounterTitle.
  ///
  /// In en, this message translates to:
  /// **'🍺 Recovery time'**
  String get notificationAlcoholCounterTitle;

  /// No description provided for @notificationAlcoholCounterBody.
  ///
  /// In en, this message translates to:
  /// **'Drink {ml} ml water with a pinch of salt'**
  String notificationAlcoholCounterBody(int ml);

  /// No description provided for @notificationHeatWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'🌡️ Heat warning'**
  String get notificationHeatWarningTitle;

  /// No description provided for @notificationHeatWarningExtremeBody.
  ///
  /// In en, this message translates to:
  /// **'Extreme heat! +15% water and +1g salt'**
  String get notificationHeatWarningExtremeBody;

  /// No description provided for @notificationHeatWarningHotBody.
  ///
  /// In en, this message translates to:
  /// **'Hot! +10% water and electrolytes'**
  String get notificationHeatWarningHotBody;

  /// No description provided for @notificationHeatWarningWarmBody.
  ///
  /// In en, this message translates to:
  /// **'Warm. Monitor your hydration'**
  String get notificationHeatWarningWarmBody;

  /// No description provided for @notificationWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'💪 Workout'**
  String get notificationWorkoutTitle;

  /// No description provided for @notificationWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget water and electrolytes'**
  String get notificationWorkoutBody;

  /// No description provided for @notificationPostWorkoutTitle.
  ///
  /// In en, this message translates to:
  /// **'💪 After workout'**
  String get notificationPostWorkoutTitle;

  /// No description provided for @notificationPostWorkoutBody.
  ///
  /// In en, this message translates to:
  /// **'500 ml water + electrolytes for recovery'**
  String get notificationPostWorkoutBody;

  /// No description provided for @notificationFastingElectrolyteTitle.
  ///
  /// In en, this message translates to:
  /// **'⚡ Electrolyte time'**
  String get notificationFastingElectrolyteTitle;

  /// No description provided for @notificationFastingElectrolyteBody.
  ///
  /// In en, this message translates to:
  /// **'Add a pinch of salt to water or drink broth'**
  String get notificationFastingElectrolyteBody;

  /// No description provided for @notificationAlcoholRecoveryStepTitle.
  ///
  /// In en, this message translates to:
  /// **'💧 Recovery {hours}h'**
  String notificationAlcoholRecoveryStepTitle(int hours);

  /// No description provided for @notificationAlcoholRecoveryStepBody.
  ///
  /// In en, this message translates to:
  /// **'Drink {ml} ml water'**
  String notificationAlcoholRecoveryStepBody(int ml);

  /// No description provided for @notificationAlcoholRecoveryMidBody.
  ///
  /// In en, this message translates to:
  /// **'Add electrolytes: Na/K/Mg'**
  String get notificationAlcoholRecoveryMidBody;

  /// No description provided for @notificationAlcoholRecoveryFinalBody.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow morning - control check-in'**
  String get notificationAlcoholRecoveryFinalBody;

  /// No description provided for @notificationMorningCheckInTitle.
  ///
  /// In en, this message translates to:
  /// **'☀️ Morning check-in'**
  String get notificationMorningCheckInTitle;

  /// No description provided for @notificationMorningCheckInBody.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling? Rate your condition and get a plan for the day'**
  String get notificationMorningCheckInBody;

  /// No description provided for @notificationMorningWaterBody.
  ///
  /// In en, this message translates to:
  /// **'Start your day with a glass of water'**
  String get notificationMorningWaterBody;

  /// No description provided for @notificationLowProgressBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ve drunk only {percent}% of the norm. Time to catch up!'**
  String notificationLowProgressBody(int percent);

  /// No description provided for @notificationGoodProgressBody.
  ///
  /// In en, this message translates to:
  /// **'Excellent progress! Keep going'**
  String get notificationGoodProgressBody;

  /// No description provided for @notificationMaintainBalanceBody.
  ///
  /// In en, this message translates to:
  /// **'Maintain water balance'**
  String get notificationMaintainBalanceBody;

  /// No description provided for @notificationTestTitle.
  ///
  /// In en, this message translates to:
  /// **'🧪 Test notification'**
  String get notificationTestTitle;

  /// No description provided for @notificationTestBody.
  ///
  /// In en, this message translates to:
  /// **'If you see this - notifications work!'**
  String get notificationTestBody;

  /// No description provided for @notificationTestScheduledTitle.
  ///
  /// In en, this message translates to:
  /// **'⏰ Scheduled test'**
  String get notificationTestScheduledTitle;

  /// No description provided for @notificationTestScheduledBody.
  ///
  /// In en, this message translates to:
  /// **'This notification was scheduled 1 minute ago'**
  String get notificationTestScheduledBody;

  /// Units selection page title
  ///
  /// In en, this message translates to:
  /// **'Choose your units'**
  String get onboardingUnitsTitle;

  /// Units selection warning
  ///
  /// In en, this message translates to:
  /// **'You can\'t change this later'**
  String get onboardingUnitsSubtitle;

  /// Permanent choice warning for units
  ///
  /// In en, this message translates to:
  /// **'This choice is permanent and cannot be changed later'**
  String get onboardingUnitsWarning;

  /// No description provided for @oz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get oz;

  /// No description provided for @fl_oz.
  ///
  /// In en, this message translates to:
  /// **'fl oz'**
  String get fl_oz;

  /// No description provided for @gallons.
  ///
  /// In en, this message translates to:
  /// **'gallons'**
  String get gallons;

  /// No description provided for @lb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get lb;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @wind.
  ///
  /// In en, this message translates to:
  /// **'Wind'**
  String get wind;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @highHeatIndexWarning.
  ///
  /// In en, this message translates to:
  /// **'High heat index! Increase your water intake'**
  String get highHeatIndexWarning;

  /// No description provided for @weatherCondition.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get weatherCondition;

  /// No description provided for @feelsLike.
  ///
  /// In en, this message translates to:
  /// **'Feels Like'**
  String get feelsLike;

  /// No description provided for @humidityLabel.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get humidityLabel;

  /// No description provided for @waterNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get waterNormal;

  /// No description provided for @sodiumNormal.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get sodiumNormal;

  /// No description provided for @addedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Added successfully'**
  String get addedSuccessfully;

  /// No description provided for @sugarIntake.
  ///
  /// In en, this message translates to:
  /// **'Sugar Intake'**
  String get sugarIntake;

  /// No description provided for @sugarToday.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sugar consumption'**
  String get sugarToday;

  /// No description provided for @totalSugar.
  ///
  /// In en, this message translates to:
  /// **'Total Sugar'**
  String get totalSugar;

  /// No description provided for @dailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get dailyLimit;

  /// No description provided for @addedSugar.
  ///
  /// In en, this message translates to:
  /// **'Added Sugar'**
  String get addedSugar;

  /// No description provided for @naturalSugar.
  ///
  /// In en, this message translates to:
  /// **'Natural Sugar'**
  String get naturalSugar;

  /// No description provided for @hiddenSugar.
  ///
  /// In en, this message translates to:
  /// **'Hidden Sugar'**
  String get hiddenSugar;

  /// No description provided for @sugarFromDrinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get sugarFromDrinks;

  /// No description provided for @sugarFromFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get sugarFromFood;

  /// No description provided for @sugarFromSnacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get sugarFromSnacks;

  /// No description provided for @sugarNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get sugarNormal;

  /// No description provided for @sugarModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get sugarModerate;

  /// No description provided for @sugarHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get sugarHigh;

  /// No description provided for @sugarCritical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get sugarCritical;

  /// No description provided for @sugarRecommendationNormal.
  ///
  /// In en, this message translates to:
  /// **'Great job! Your sugar intake is within healthy limits'**
  String get sugarRecommendationNormal;

  /// No description provided for @sugarRecommendationModerate.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing sweet drinks and snacks'**
  String get sugarRecommendationModerate;

  /// No description provided for @sugarRecommendationHigh.
  ///
  /// In en, this message translates to:
  /// **'High sugar intake! Limit sweet drinks and desserts'**
  String get sugarRecommendationHigh;

  /// No description provided for @sugarRecommendationCritical.
  ///
  /// In en, this message translates to:
  /// **'Very high sugar! Avoid sugary drinks and sweets today'**
  String get sugarRecommendationCritical;

  /// No description provided for @noSugarIntake.
  ///
  /// In en, this message translates to:
  /// **'No sugar tracked today'**
  String get noSugarIntake;

  /// No description provided for @hriImpact.
  ///
  /// In en, this message translates to:
  /// **'HRI Impact'**
  String get hriImpact;

  /// No description provided for @hri_component_sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get hri_component_sugar;

  /// No description provided for @hri_sugar_description.
  ///
  /// In en, this message translates to:
  /// **'High sugar intake affects hydration and overall health'**
  String get hri_sugar_description;

  /// No description provided for @tip_reduce_sweet_drinks.
  ///
  /// In en, this message translates to:
  /// **'Replace sweet drinks with water or unsweetened tea'**
  String get tip_reduce_sweet_drinks;

  /// No description provided for @tip_avoid_added_sugar.
  ///
  /// In en, this message translates to:
  /// **'Check labels and avoid products with added sugars'**
  String get tip_avoid_added_sugar;

  /// No description provided for @tip_check_labels.
  ///
  /// In en, this message translates to:
  /// **'Be aware of hidden sugars in sauces and processed foods'**
  String get tip_check_labels;

  /// No description provided for @tip_replace_soda.
  ///
  /// In en, this message translates to:
  /// **'Replace soda with sparkling water and lemon'**
  String get tip_replace_soda;

  /// No description provided for @sugarSources.
  ///
  /// In en, this message translates to:
  /// **'Sugar Sources'**
  String get sugarSources;

  /// No description provided for @drinks.
  ///
  /// In en, this message translates to:
  /// **'Drinks'**
  String get drinks;

  /// No description provided for @food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get food;

  /// No description provided for @snacks.
  ///
  /// In en, this message translates to:
  /// **'Snacks'**
  String get snacks;

  /// No description provided for @recommendedLimit.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommendedLimit;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// No description provided for @drinkLightBeer.
  ///
  /// In en, this message translates to:
  /// **'Light Beer'**
  String get drinkLightBeer;

  /// No description provided for @drinkLager.
  ///
  /// In en, this message translates to:
  /// **'Lager'**
  String get drinkLager;

  /// No description provided for @drinkIPA.
  ///
  /// In en, this message translates to:
  /// **'IPA'**
  String get drinkIPA;

  /// No description provided for @drinkStout.
  ///
  /// In en, this message translates to:
  /// **'Stout'**
  String get drinkStout;

  /// No description provided for @drinkWheatBeer.
  ///
  /// In en, this message translates to:
  /// **'Wheat Beer'**
  String get drinkWheatBeer;

  /// No description provided for @drinkCraftBeer.
  ///
  /// In en, this message translates to:
  /// **'Craft Beer'**
  String get drinkCraftBeer;

  /// No description provided for @drinkNonAlcoholic.
  ///
  /// In en, this message translates to:
  /// **'Non-Alcoholic'**
  String get drinkNonAlcoholic;

  /// No description provided for @drinkRadler.
  ///
  /// In en, this message translates to:
  /// **'Radler'**
  String get drinkRadler;

  /// No description provided for @drinkPilsner.
  ///
  /// In en, this message translates to:
  /// **'Pilsner'**
  String get drinkPilsner;

  /// No description provided for @drinkRedWine.
  ///
  /// In en, this message translates to:
  /// **'Red Wine'**
  String get drinkRedWine;

  /// No description provided for @drinkWhiteWine.
  ///
  /// In en, this message translates to:
  /// **'White Wine'**
  String get drinkWhiteWine;

  /// No description provided for @drinkProsecco.
  ///
  /// In en, this message translates to:
  /// **'Prosecco'**
  String get drinkProsecco;

  /// No description provided for @drinkPort.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get drinkPort;

  /// No description provided for @drinkRose.
  ///
  /// In en, this message translates to:
  /// **'Rosé'**
  String get drinkRose;

  /// No description provided for @drinkDessertWine.
  ///
  /// In en, this message translates to:
  /// **'Dessert Wine'**
  String get drinkDessertWine;

  /// No description provided for @drinkSangria.
  ///
  /// In en, this message translates to:
  /// **'Sangria'**
  String get drinkSangria;

  /// No description provided for @drinkSherry.
  ///
  /// In en, this message translates to:
  /// **'Sherry'**
  String get drinkSherry;

  /// No description provided for @drinkVodkaShot.
  ///
  /// In en, this message translates to:
  /// **'Vodka Shot'**
  String get drinkVodkaShot;

  /// No description provided for @drinkCognac.
  ///
  /// In en, this message translates to:
  /// **'Cognac'**
  String get drinkCognac;

  /// No description provided for @drinkLiqueur.
  ///
  /// In en, this message translates to:
  /// **'Liqueur'**
  String get drinkLiqueur;

  /// No description provided for @drinkAbsinthe.
  ///
  /// In en, this message translates to:
  /// **'Absinthe'**
  String get drinkAbsinthe;

  /// No description provided for @drinkBrandy.
  ///
  /// In en, this message translates to:
  /// **'Brandy'**
  String get drinkBrandy;

  /// No description provided for @drinkLongIsland.
  ///
  /// In en, this message translates to:
  /// **'Long Island'**
  String get drinkLongIsland;

  /// No description provided for @drinkGinTonic.
  ///
  /// In en, this message translates to:
  /// **'Gin & Tonic'**
  String get drinkGinTonic;

  /// No description provided for @drinkPinaColada.
  ///
  /// In en, this message translates to:
  /// **'Piña Colada'**
  String get drinkPinaColada;

  /// No description provided for @drinkCosmopolitan.
  ///
  /// In en, this message translates to:
  /// **'Cosmopolitan'**
  String get drinkCosmopolitan;

  /// No description provided for @drinkMaiTai.
  ///
  /// In en, this message translates to:
  /// **'Mai Tai'**
  String get drinkMaiTai;

  /// No description provided for @drinkBloodyMary.
  ///
  /// In en, this message translates to:
  /// **'Bloody Mary'**
  String get drinkBloodyMary;

  /// No description provided for @drinkDaiquiri.
  ///
  /// In en, this message translates to:
  /// **'Daiquiri'**
  String get drinkDaiquiri;

  /// No description provided for @popularDrinks.
  ///
  /// In en, this message translates to:
  /// **'Popular {type}'**
  String popularDrinks(Object type);

  /// No description provided for @standardDrinksUnit.
  ///
  /// In en, this message translates to:
  /// **'SD'**
  String get standardDrinksUnit;

  /// No description provided for @gramsSugar.
  ///
  /// In en, this message translates to:
  /// **'g sugar'**
  String get gramsSugar;

  /// No description provided for @moderateConsumption.
  ///
  /// In en, this message translates to:
  /// **'Moderate consumption'**
  String get moderateConsumption;

  /// No description provided for @aboveRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Above recommendations'**
  String get aboveRecommendations;

  /// No description provided for @highConsumption.
  ///
  /// In en, this message translates to:
  /// **'High consumption'**
  String get highConsumption;

  /// No description provided for @veryHighConsider.
  ///
  /// In en, this message translates to:
  /// **'Very high - consider stopping'**
  String get veryHighConsider;

  /// No description provided for @noAlcoholToday.
  ///
  /// In en, this message translates to:
  /// **'No alcohol today'**
  String get noAlcoholToday;

  /// No description provided for @drinkWaterNow.
  ///
  /// In en, this message translates to:
  /// **'Drink 300-500 ml water now'**
  String get drinkWaterNow;

  /// No description provided for @addPinchSalt.
  ///
  /// In en, this message translates to:
  /// **'Add a pinch of salt'**
  String get addPinchSalt;

  /// No description provided for @avoidLateCoffee.
  ///
  /// In en, this message translates to:
  /// **'Avoid late coffee'**
  String get avoidLateCoffee;

  /// No description provided for @abvPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% ABV'**
  String abvPercent(Object percent);

  /// No description provided for @todaysElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Electrolytes'**
  String get todaysElectrolytes;

  /// No description provided for @greatBalance.
  ///
  /// In en, this message translates to:
  /// **'Great balance!'**
  String get greatBalance;

  /// No description provided for @gettingThere.
  ///
  /// In en, this message translates to:
  /// **'Getting there'**
  String get gettingThere;

  /// No description provided for @needMoreElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Need more electrolytes'**
  String get needMoreElectrolytes;

  /// No description provided for @lowElectrolyteLevels.
  ///
  /// In en, this message translates to:
  /// **'Low electrolyte levels'**
  String get lowElectrolyteLevels;

  /// No description provided for @electrolyteTips.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte Tips'**
  String get electrolyteTips;

  /// No description provided for @takeWithWater.
  ///
  /// In en, this message translates to:
  /// **'Take with plenty of water'**
  String get takeWithWater;

  /// No description provided for @bestBetweenMeals.
  ///
  /// In en, this message translates to:
  /// **'Best absorbed between meals'**
  String get bestBetweenMeals;

  /// No description provided for @startSmallAmounts.
  ///
  /// In en, this message translates to:
  /// **'Start with small amounts'**
  String get startSmallAmounts;

  /// No description provided for @extraDuringExercise.
  ///
  /// In en, this message translates to:
  /// **'Extra needed during exercise'**
  String get extraDuringExercise;

  /// No description provided for @electrolytesBasic.
  ///
  /// In en, this message translates to:
  /// **'Basic'**
  String get electrolytesBasic;

  /// No description provided for @electrolytesMixes.
  ///
  /// In en, this message translates to:
  /// **'Mixes'**
  String get electrolytesMixes;

  /// No description provided for @electrolytesPills.
  ///
  /// In en, this message translates to:
  /// **'Pills'**
  String get electrolytesPills;

  /// No description provided for @popularSalts.
  ///
  /// In en, this message translates to:
  /// **'Popular Salts & Broths'**
  String get popularSalts;

  /// No description provided for @popularMixes.
  ///
  /// In en, this message translates to:
  /// **'Popular Electrolyte Mixes'**
  String get popularMixes;

  /// No description provided for @popularSupplements.
  ///
  /// In en, this message translates to:
  /// **'Popular Supplements'**
  String get popularSupplements;

  /// No description provided for @electrolyteSaltWater.
  ///
  /// In en, this message translates to:
  /// **'Salt Water'**
  String get electrolyteSaltWater;

  /// No description provided for @electrolytePinkSalt.
  ///
  /// In en, this message translates to:
  /// **'Pink Salt'**
  String get electrolytePinkSalt;

  /// No description provided for @electrolyteSeaSalt.
  ///
  /// In en, this message translates to:
  /// **'Sea Salt'**
  String get electrolyteSeaSalt;

  /// No description provided for @electrolyteNuun.
  ///
  /// In en, this message translates to:
  /// **'Nuun'**
  String get electrolyteNuun;

  /// No description provided for @electrolyteLiquidIV.
  ///
  /// In en, this message translates to:
  /// **'Liquid IV'**
  String get electrolyteLiquidIV;

  /// No description provided for @electrolyteUltima.
  ///
  /// In en, this message translates to:
  /// **'Ultima'**
  String get electrolyteUltima;

  /// No description provided for @electrolytePropel.
  ///
  /// In en, this message translates to:
  /// **'Propel'**
  String get electrolytePropel;

  /// No description provided for @electrolytePedialyte.
  ///
  /// In en, this message translates to:
  /// **'Pedialyte'**
  String get electrolytePedialyte;

  /// No description provided for @electrolyteGatoradeZero.
  ///
  /// In en, this message translates to:
  /// **'Gatorade Zero'**
  String get electrolyteGatoradeZero;

  /// No description provided for @electrolytePotassiumChloride.
  ///
  /// In en, this message translates to:
  /// **'Potassium Chloride'**
  String get electrolytePotassiumChloride;

  /// No description provided for @electrolyteMagThreonate.
  ///
  /// In en, this message translates to:
  /// **'Mag Threonate'**
  String get electrolyteMagThreonate;

  /// No description provided for @electrolyteTraceMinerals.
  ///
  /// In en, this message translates to:
  /// **'Trace Minerals'**
  String get electrolyteTraceMinerals;

  /// No description provided for @electrolyteZMAComplex.
  ///
  /// In en, this message translates to:
  /// **'ZMA Complex'**
  String get electrolyteZMAComplex;

  /// No description provided for @electrolyteMultiMineral.
  ///
  /// In en, this message translates to:
  /// **'Multi-Mineral'**
  String get electrolyteMultiMineral;

  /// No description provided for @electrolyteLMNT.
  ///
  /// In en, this message translates to:
  /// **'LMNT'**
  String get electrolyteLMNT;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @todayHydration.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Hydration'**
  String get todayHydration;

  /// No description provided for @currentIntake.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get currentIntake;

  /// Daily goal label
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get dailyGoal;

  /// No description provided for @toGo.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get toGo;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached!'**
  String get goalReached;

  /// No description provided for @almostThere.
  ///
  /// In en, this message translates to:
  /// **'Almost there!'**
  String get almostThere;

  /// No description provided for @halfwayThere.
  ///
  /// In en, this message translates to:
  /// **'Halfway there'**
  String get halfwayThere;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @startDrinking.
  ///
  /// In en, this message translates to:
  /// **'Start drinking'**
  String get startDrinking;

  /// No description provided for @plainWater.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get plainWater;

  /// No description provided for @enhancedWater.
  ///
  /// In en, this message translates to:
  /// **'Enhanced'**
  String get enhancedWater;

  /// No description provided for @beverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get beverages;

  /// No description provided for @sodas.
  ///
  /// In en, this message translates to:
  /// **'Sodas'**
  String get sodas;

  /// No description provided for @popularPlainWater.
  ///
  /// In en, this message translates to:
  /// **'Popular Water Types'**
  String get popularPlainWater;

  /// No description provided for @popularEnhancedWater.
  ///
  /// In en, this message translates to:
  /// **'Enhanced & Infused'**
  String get popularEnhancedWater;

  /// No description provided for @popularBeverages.
  ///
  /// In en, this message translates to:
  /// **'Popular Beverages'**
  String get popularBeverages;

  /// No description provided for @popularSodas.
  ///
  /// In en, this message translates to:
  /// **'Popular Sodas & Energy'**
  String get popularSodas;

  /// No description provided for @hydrationTips.
  ///
  /// In en, this message translates to:
  /// **'Hydration Tips'**
  String get hydrationTips;

  /// No description provided for @drinkRegularly.
  ///
  /// In en, this message translates to:
  /// **'Drink small amounts regularly'**
  String get drinkRegularly;

  /// No description provided for @roomTemperature.
  ///
  /// In en, this message translates to:
  /// **'Room temperature water absorbs better'**
  String get roomTemperature;

  /// No description provided for @addLemon.
  ///
  /// In en, this message translates to:
  /// **'Add lemon for better taste'**
  String get addLemon;

  /// No description provided for @limitSugary.
  ///
  /// In en, this message translates to:
  /// **'Limit sugary drinks - they dehydrate'**
  String get limitSugary;

  /// No description provided for @warmWater.
  ///
  /// In en, this message translates to:
  /// **'Warm Water'**
  String get warmWater;

  /// No description provided for @iceWater.
  ///
  /// In en, this message translates to:
  /// **'Ice Water'**
  String get iceWater;

  /// No description provided for @filteredWater.
  ///
  /// In en, this message translates to:
  /// **'Filtered Water'**
  String get filteredWater;

  /// No description provided for @distilledWater.
  ///
  /// In en, this message translates to:
  /// **'Distilled Water'**
  String get distilledWater;

  /// No description provided for @springWater.
  ///
  /// In en, this message translates to:
  /// **'Spring Water'**
  String get springWater;

  /// No description provided for @hydrogenWater.
  ///
  /// In en, this message translates to:
  /// **'Hydrogen Water'**
  String get hydrogenWater;

  /// No description provided for @oxygenatedWater.
  ///
  /// In en, this message translates to:
  /// **'Oxygenated Water'**
  String get oxygenatedWater;

  /// No description provided for @cucumberWater.
  ///
  /// In en, this message translates to:
  /// **'Cucumber Water'**
  String get cucumberWater;

  /// No description provided for @limeWater.
  ///
  /// In en, this message translates to:
  /// **'Lime Water'**
  String get limeWater;

  /// No description provided for @berryWater.
  ///
  /// In en, this message translates to:
  /// **'Berry Water'**
  String get berryWater;

  /// No description provided for @mintWater.
  ///
  /// In en, this message translates to:
  /// **'Mint Water'**
  String get mintWater;

  /// No description provided for @gingerWater.
  ///
  /// In en, this message translates to:
  /// **'Ginger Water'**
  String get gingerWater;

  /// No description provided for @caffeineStatusNone.
  ///
  /// In en, this message translates to:
  /// **'No caffeine today'**
  String get caffeineStatusNone;

  /// No description provided for @caffeineStatusModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate: {amount}mg'**
  String caffeineStatusModerate(Object amount);

  /// No description provided for @caffeineStatusHigh.
  ///
  /// In en, this message translates to:
  /// **'High: {amount}mg'**
  String caffeineStatusHigh(Object amount);

  /// No description provided for @caffeineStatusVeryHigh.
  ///
  /// In en, this message translates to:
  /// **'Very high: {amount}mg!'**
  String caffeineStatusVeryHigh(Object amount);

  /// No description provided for @caffeineDailyLimit.
  ///
  /// In en, this message translates to:
  /// **'Daily limit: 400mg'**
  String get caffeineDailyLimit;

  /// No description provided for @caffeineWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Caffeine Warning'**
  String get caffeineWarningTitle;

  /// No description provided for @caffeineWarning400.
  ///
  /// In en, this message translates to:
  /// **'You\'ve exceeded 400mg caffeine today'**
  String get caffeineWarning400;

  /// No description provided for @caffeineTipWater.
  ///
  /// In en, this message translates to:
  /// **'Drink extra water to compensate'**
  String get caffeineTipWater;

  /// No description provided for @caffeineTipAvoid.
  ///
  /// In en, this message translates to:
  /// **'Avoid more caffeine today'**
  String get caffeineTipAvoid;

  /// No description provided for @caffeineTipSleep.
  ///
  /// In en, this message translates to:
  /// **'May affect your sleep quality'**
  String get caffeineTipSleep;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get total;

  /// No description provided for @cupsToday.
  ///
  /// In en, this message translates to:
  /// **'Cups today'**
  String get cupsToday;

  /// No description provided for @metabolizeTime.
  ///
  /// In en, this message translates to:
  /// **'Time to metabolize'**
  String get metabolizeTime;

  /// No description provided for @aboutCaffeine.
  ///
  /// In en, this message translates to:
  /// **'About Caffeine'**
  String get aboutCaffeine;

  /// No description provided for @caffeineInfo1.
  ///
  /// In en, this message translates to:
  /// **'Coffee contains natural caffeine that boosts alertness'**
  String get caffeineInfo1;

  /// No description provided for @caffeineInfo2.
  ///
  /// In en, this message translates to:
  /// **'Daily safe limit is 400mg for most adults'**
  String get caffeineInfo2;

  /// No description provided for @caffeineInfo3.
  ///
  /// In en, this message translates to:
  /// **'Caffeine half-life is 5-6 hours'**
  String get caffeineInfo3;

  /// No description provided for @caffeineInfo4.
  ///
  /// In en, this message translates to:
  /// **'Drink extra water to compensate for caffeine\'s diuretic effect'**
  String get caffeineInfo4;

  /// No description provided for @caffeineWarningPregnant.
  ///
  /// In en, this message translates to:
  /// **'Pregnant women should limit caffeine to 200mg/day'**
  String get caffeineWarningPregnant;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @consumed.
  ///
  /// In en, this message translates to:
  /// **'Consumed'**
  String get consumed;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get remaining;

  /// No description provided for @todaysCaffeine.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Caffeine'**
  String get todaysCaffeine;

  /// No description provided for @alreadyInFavorites.
  ///
  /// In en, this message translates to:
  /// **'Already in favorites'**
  String get alreadyInFavorites;

  /// No description provided for @ofRecommendedLimit.
  ///
  /// In en, this message translates to:
  /// **'of recommended limit'**
  String get ofRecommendedLimit;

  /// No description provided for @aboutAlcohol.
  ///
  /// In en, this message translates to:
  /// **'About Alcohol'**
  String get aboutAlcohol;

  /// No description provided for @alcoholInfo1.
  ///
  /// In en, this message translates to:
  /// **'One standard drink equals 10g of pure alcohol'**
  String get alcoholInfo1;

  /// No description provided for @alcoholInfo2.
  ///
  /// In en, this message translates to:
  /// **'Alcohol dehydrates — drink 250ml extra water per drink'**
  String get alcoholInfo2;

  /// No description provided for @alcoholInfo3.
  ///
  /// In en, this message translates to:
  /// **'Add sodium to help retain fluids after drinking'**
  String get alcoholInfo3;

  /// No description provided for @alcoholInfo4.
  ///
  /// In en, this message translates to:
  /// **'Each standard drink increases HRI by 3-5 points'**
  String get alcoholInfo4;

  /// No description provided for @alcoholWarningHealth.
  ///
  /// In en, this message translates to:
  /// **'Excessive alcohol consumption is harmful to health. The recommended limit is 2 SD for men and 1 SD for women per day.'**
  String get alcoholWarningHealth;

  /// No description provided for @supplementsInfo1.
  ///
  /// In en, this message translates to:
  /// **'Supplements help maintain electrolyte balance'**
  String get supplementsInfo1;

  /// No description provided for @supplementsInfo2.
  ///
  /// In en, this message translates to:
  /// **'Best taken with meals for absorption'**
  String get supplementsInfo2;

  /// No description provided for @supplementsInfo3.
  ///
  /// In en, this message translates to:
  /// **'Always take with plenty of water'**
  String get supplementsInfo3;

  /// No description provided for @supplementsInfo4.
  ///
  /// In en, this message translates to:
  /// **'Magnesium and potassium are key for hydration'**
  String get supplementsInfo4;

  /// No description provided for @supplementsWarning.
  ///
  /// In en, this message translates to:
  /// **'Consult with healthcare provider before starting any supplement regimen'**
  String get supplementsWarning;

  /// No description provided for @fromSupplementsToday.
  ///
  /// In en, this message translates to:
  /// **'From Supplements Today'**
  String get fromSupplementsToday;

  /// No description provided for @minerals.
  ///
  /// In en, this message translates to:
  /// **'Minerals'**
  String get minerals;

  /// No description provided for @vitamins.
  ///
  /// In en, this message translates to:
  /// **'Vitamins'**
  String get vitamins;

  /// No description provided for @essentialMinerals.
  ///
  /// In en, this message translates to:
  /// **'Essential Minerals'**
  String get essentialMinerals;

  /// No description provided for @otherSupplements.
  ///
  /// In en, this message translates to:
  /// **'Other Supplements'**
  String get otherSupplements;

  /// No description provided for @supplementTip1.
  ///
  /// In en, this message translates to:
  /// **'Take supplements with food for better absorption'**
  String get supplementTip1;

  /// No description provided for @supplementTip2.
  ///
  /// In en, this message translates to:
  /// **'Drink plenty of water with supplements'**
  String get supplementTip2;

  /// No description provided for @supplementTip3.
  ///
  /// In en, this message translates to:
  /// **'Space out multiple supplements throughout the day'**
  String get supplementTip3;

  /// No description provided for @supplementTip4.
  ///
  /// In en, this message translates to:
  /// **'Keep track of what works for you'**
  String get supplementTip4;

  /// No description provided for @calciumCarbonate.
  ///
  /// In en, this message translates to:
  /// **'Calcium Carbonate'**
  String get calciumCarbonate;

  /// No description provided for @traceMinerals.
  ///
  /// In en, this message translates to:
  /// **'Trace Minerals'**
  String get traceMinerals;

  /// No description provided for @vitaminA.
  ///
  /// In en, this message translates to:
  /// **'Vitamin A'**
  String get vitaminA;

  /// No description provided for @vitaminE.
  ///
  /// In en, this message translates to:
  /// **'Vitamin E'**
  String get vitaminE;

  /// No description provided for @vitaminK2.
  ///
  /// In en, this message translates to:
  /// **'Vitamin K2'**
  String get vitaminK2;

  /// No description provided for @folate.
  ///
  /// In en, this message translates to:
  /// **'Folate'**
  String get folate;

  /// No description provided for @biotin.
  ///
  /// In en, this message translates to:
  /// **'Biotin'**
  String get biotin;

  /// No description provided for @probiotics.
  ///
  /// In en, this message translates to:
  /// **'Probiotics'**
  String get probiotics;

  /// No description provided for @melatonin.
  ///
  /// In en, this message translates to:
  /// **'Melatonin'**
  String get melatonin;

  /// No description provided for @collagen.
  ///
  /// In en, this message translates to:
  /// **'Collagen'**
  String get collagen;

  /// No description provided for @glucosamine.
  ///
  /// In en, this message translates to:
  /// **'Glucosamine'**
  String get glucosamine;

  /// No description provided for @turmeric.
  ///
  /// In en, this message translates to:
  /// **'Turmeric'**
  String get turmeric;

  /// No description provided for @coq10.
  ///
  /// In en, this message translates to:
  /// **'CoQ10'**
  String get coq10;

  /// No description provided for @creatine.
  ///
  /// In en, this message translates to:
  /// **'Creatine'**
  String get creatine;

  /// No description provided for @ashwagandha.
  ///
  /// In en, this message translates to:
  /// **'Ashwagandha'**
  String get ashwagandha;

  /// No description provided for @selectCardioActivity.
  ///
  /// In en, this message translates to:
  /// **'Select Cardio Activity'**
  String get selectCardioActivity;

  /// No description provided for @selectStrengthActivity.
  ///
  /// In en, this message translates to:
  /// **'Select Strength Activity'**
  String get selectStrengthActivity;

  /// No description provided for @selectSportsActivity.
  ///
  /// In en, this message translates to:
  /// **'Select Sport'**
  String get selectSportsActivity;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessions;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total Time'**
  String get totalTime;

  /// No description provided for @waterLoss.
  ///
  /// In en, this message translates to:
  /// **'Water Loss'**
  String get waterLoss;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @drinkWaterAfterWorkout.
  ///
  /// In en, this message translates to:
  /// **'Drink water after workout'**
  String get drinkWaterAfterWorkout;

  /// No description provided for @replenishElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Replenish electrolytes'**
  String get replenishElectrolytes;

  /// No description provided for @restAndRecover.
  ///
  /// In en, this message translates to:
  /// **'Rest and recover'**
  String get restAndRecover;

  /// No description provided for @avoidSugaryDrinks.
  ///
  /// In en, this message translates to:
  /// **'Avoid sugary sports drinks'**
  String get avoidSugaryDrinks;

  /// No description provided for @elliptical.
  ///
  /// In en, this message translates to:
  /// **'Elliptical'**
  String get elliptical;

  /// No description provided for @rowing.
  ///
  /// In en, this message translates to:
  /// **'Rowing'**
  String get rowing;

  /// No description provided for @jumpRope.
  ///
  /// In en, this message translates to:
  /// **'Jump Rope'**
  String get jumpRope;

  /// No description provided for @stairClimbing.
  ///
  /// In en, this message translates to:
  /// **'Stair Climbing'**
  String get stairClimbing;

  /// No description provided for @bodyweight.
  ///
  /// In en, this message translates to:
  /// **'Bodyweight'**
  String get bodyweight;

  /// No description provided for @powerlifting.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get powerlifting;

  /// No description provided for @calisthenics.
  ///
  /// In en, this message translates to:
  /// **'Calisthenics'**
  String get calisthenics;

  /// No description provided for @resistanceBands.
  ///
  /// In en, this message translates to:
  /// **'Resistance Bands'**
  String get resistanceBands;

  /// No description provided for @kettlebell.
  ///
  /// In en, this message translates to:
  /// **'Kettlebell'**
  String get kettlebell;

  /// No description provided for @trx.
  ///
  /// In en, this message translates to:
  /// **'TRX'**
  String get trx;

  /// No description provided for @strongman.
  ///
  /// In en, this message translates to:
  /// **'Strongman'**
  String get strongman;

  /// No description provided for @pilates.
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get pilates;

  /// No description provided for @basketball.
  ///
  /// In en, this message translates to:
  /// **'Basketball'**
  String get basketball;

  /// No description provided for @soccerFootball.
  ///
  /// In en, this message translates to:
  /// **'Soccer/Football'**
  String get soccerFootball;

  /// No description provided for @golf.
  ///
  /// In en, this message translates to:
  /// **'Golf'**
  String get golf;

  /// No description provided for @martialArts.
  ///
  /// In en, this message translates to:
  /// **'Martial Arts'**
  String get martialArts;

  /// No description provided for @rockClimbing.
  ///
  /// In en, this message translates to:
  /// **'Rock Climbing'**
  String get rockClimbing;

  /// No description provided for @needsToReplenish.
  ///
  /// In en, this message translates to:
  /// **'Need to replenish'**
  String get needsToReplenish;

  /// No description provided for @electrolyteTrackingPro.
  ///
  /// In en, this message translates to:
  /// **'Track sodium, potassium & magnesium goals with detailed progress bars'**
  String get electrolyteTrackingPro;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @weather.
  ///
  /// In en, this message translates to:
  /// **'Weather'**
  String get weather;

  /// No description provided for @weatherTrackingPro.
  ///
  /// In en, this message translates to:
  /// **'Track heat index, humidity & weather impact on hydration goals'**
  String get weatherTrackingPro;

  /// No description provided for @sugarTracking.
  ///
  /// In en, this message translates to:
  /// **'Sugar Tracking'**
  String get sugarTracking;

  /// No description provided for @sugarTrackingPro.
  ///
  /// In en, this message translates to:
  /// **'Monitor natural, added & hidden sugar intake with HRI impact analysis'**
  String get sugarTrackingPro;

  /// No description provided for @dayOverview.
  ///
  /// In en, this message translates to:
  /// **'Day Overview'**
  String get dayOverview;

  /// No description provided for @tapForDetails.
  ///
  /// In en, this message translates to:
  /// **'Tap for details'**
  String get tapForDetails;

  /// No description provided for @noDataForDay.
  ///
  /// In en, this message translates to:
  /// **'No data for this day'**
  String get noDataForDay;

  /// No description provided for @sweatLoss.
  ///
  /// In en, this message translates to:
  /// **'sweat loss'**
  String get sweatLoss;

  /// No description provided for @cardio.
  ///
  /// In en, this message translates to:
  /// **'Cardio'**
  String get cardio;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @noWaterToday.
  ///
  /// In en, this message translates to:
  /// **'No water recorded today'**
  String get noWaterToday;

  /// No description provided for @noElectrolytesToday.
  ///
  /// In en, this message translates to:
  /// **'No electrolytes recorded today'**
  String get noElectrolytesToday;

  /// No description provided for @noCoffeeToday.
  ///
  /// In en, this message translates to:
  /// **'No coffee recorded today'**
  String get noCoffeeToday;

  /// No description provided for @noWorkoutsToday.
  ///
  /// In en, this message translates to:
  /// **'No workouts recorded today'**
  String get noWorkoutsToday;

  /// No description provided for @noWaterThisDay.
  ///
  /// In en, this message translates to:
  /// **'No water recorded this day'**
  String get noWaterThisDay;

  /// No description provided for @noElectrolytesThisDay.
  ///
  /// In en, this message translates to:
  /// **'No electrolytes recorded this day'**
  String get noElectrolytesThisDay;

  /// No description provided for @noCoffeeThisDay.
  ///
  /// In en, this message translates to:
  /// **'No coffee recorded this day'**
  String get noCoffeeThisDay;

  /// No description provided for @noWorkoutsThisDay.
  ///
  /// In en, this message translates to:
  /// **'No workouts recorded this day'**
  String get noWorkoutsThisDay;

  /// No description provided for @weeklyReport.
  ///
  /// In en, this message translates to:
  /// **'Weekly Report'**
  String get weeklyReport;

  /// No description provided for @weeklyReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deep insights and trends analysis'**
  String get weeklyReportSubtitle;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @workoutHydration.
  ///
  /// In en, this message translates to:
  /// **'Workout Hydration'**
  String get workoutHydration;

  /// No description provided for @workoutHydrationMessage.
  ///
  /// In en, this message translates to:
  /// **'In workout days you drink {percent}% more water'**
  String workoutHydrationMessage(Object percent);

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @weeklyActivityMessage.
  ///
  /// In en, this message translates to:
  /// **'You trained {minutes} minutes across {days} days'**
  String weeklyActivityMessage(Object days, Object minutes);

  /// No description provided for @workoutMinutesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Workout minutes per day'**
  String get workoutMinutesPerDay;

  /// No description provided for @daysWithWorkouts.
  ///
  /// In en, this message translates to:
  /// **'days with workouts'**
  String get daysWithWorkouts;

  /// No description provided for @noWorkoutsThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No workouts this week'**
  String get noWorkoutsThisWeek;

  /// No description provided for @noAlcoholThisWeek.
  ///
  /// In en, this message translates to:
  /// **'No alcohol this week'**
  String get noAlcoholThisWeek;

  /// No description provided for @csvExported.
  ///
  /// In en, this message translates to:
  /// **'Data exported to CSV'**
  String get csvExported;

  /// No description provided for @mondayShort.
  ///
  /// In en, this message translates to:
  /// **'MON'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In en, this message translates to:
  /// **'TUE'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In en, this message translates to:
  /// **'WED'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In en, this message translates to:
  /// **'THU'**
  String get thursdayShort;

  /// No description provided for @fridayShort.
  ///
  /// In en, this message translates to:
  /// **'FRI'**
  String get fridayShort;

  /// No description provided for @saturdayShort.
  ///
  /// In en, this message translates to:
  /// **'SAT'**
  String get saturdayShort;

  /// No description provided for @sundayShort.
  ///
  /// In en, this message translates to:
  /// **'SUN'**
  String get sundayShort;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @achievementsTabAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get achievementsTabAll;

  /// No description provided for @achievementsTabHydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get achievementsTabHydration;

  /// No description provided for @achievementsTabElectrolytes.
  ///
  /// In en, this message translates to:
  /// **'Electrolytes'**
  String get achievementsTabElectrolytes;

  /// No description provided for @achievementsTabSugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar Control'**
  String get achievementsTabSugar;

  /// No description provided for @achievementsTabAlcohol.
  ///
  /// In en, this message translates to:
  /// **'Alcohol'**
  String get achievementsTabAlcohol;

  /// No description provided for @achievementsTabWorkout.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get achievementsTabWorkout;

  /// No description provided for @achievementsTabHRI.
  ///
  /// In en, this message translates to:
  /// **'HRI'**
  String get achievementsTabHRI;

  /// No description provided for @achievementsTabStreaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks'**
  String get achievementsTabStreaks;

  /// No description provided for @achievementsTabSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special'**
  String get achievementsTabSpecial;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @achievementProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get achievementProgress;

  /// No description provided for @achievementPoints.
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get achievementPoints;

  /// No description provided for @achievementRarityCommon.
  ///
  /// In en, this message translates to:
  /// **'Common'**
  String get achievementRarityCommon;

  /// No description provided for @achievementRarityUncommon.
  ///
  /// In en, this message translates to:
  /// **'Uncommon'**
  String get achievementRarityUncommon;

  /// No description provided for @achievementRarityRare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get achievementRarityRare;

  /// No description provided for @achievementRarityEpic.
  ///
  /// In en, this message translates to:
  /// **'Epic'**
  String get achievementRarityEpic;

  /// No description provided for @achievementRarityLegendary.
  ///
  /// In en, this message translates to:
  /// **'Legendary'**
  String get achievementRarityLegendary;

  /// No description provided for @achievementStatsUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementStatsUnlocked;

  /// No description provided for @achievementStatsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get achievementStatsTotal;

  /// No description provided for @achievementFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get achievementFilterAll;

  /// No description provided for @achievementFilterUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get achievementFilterUnlocked;

  /// No description provided for @achievementSortProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get achievementSortProgress;

  /// No description provided for @achievementSortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get achievementSortName;

  /// No description provided for @achievementSortRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get achievementSortRarity;

  /// No description provided for @achievementNoAchievements.
  ///
  /// In en, this message translates to:
  /// **'No achievements yet'**
  String get achievementNoAchievements;

  /// No description provided for @achievementKeepUsing.
  ///
  /// In en, this message translates to:
  /// **'Keep using the app to unlock achievements!'**
  String get achievementKeepUsing;

  /// No description provided for @achievementFirstGlass.
  ///
  /// In en, this message translates to:
  /// **'First Drop'**
  String get achievementFirstGlass;

  /// No description provided for @achievementFirstGlassDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink your first glass of water'**
  String get achievementFirstGlassDesc;

  /// No description provided for @achievementHydrationGoal1.
  ///
  /// In en, this message translates to:
  /// **'Hydrated'**
  String get achievementHydrationGoal1;

  /// No description provided for @achievementHydrationGoal1Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach your daily water goal'**
  String get achievementHydrationGoal1Desc;

  /// No description provided for @achievementHydrationGoal7.
  ///
  /// In en, this message translates to:
  /// **'Week of Hydration'**
  String get achievementHydrationGoal7;

  /// No description provided for @achievementHydrationGoal7Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach water goal for 7 days in a row'**
  String get achievementHydrationGoal7Desc;

  /// No description provided for @achievementHydrationGoal30.
  ///
  /// In en, this message translates to:
  /// **'Hydration Master'**
  String get achievementHydrationGoal30;

  /// No description provided for @achievementHydrationGoal30Desc.
  ///
  /// In en, this message translates to:
  /// **'Reach water goal for 30 days in a row'**
  String get achievementHydrationGoal30Desc;

  /// No description provided for @achievementPerfectHydration.
  ///
  /// In en, this message translates to:
  /// **'Perfect Balance'**
  String get achievementPerfectHydration;

  /// No description provided for @achievementPerfectHydrationDesc.
  ///
  /// In en, this message translates to:
  /// **'Achieve 90-110% of water goal'**
  String get achievementPerfectHydrationDesc;

  /// No description provided for @achievementEarlyBird.
  ///
  /// In en, this message translates to:
  /// **'Early Bird'**
  String get achievementEarlyBird;

  /// No description provided for @achievementEarlyBirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Drink your first water before 9 AM'**
  String get achievementEarlyBirdDesc;

  /// No description provided for @achievementEarlyBirdTemplate.
  ///
  /// In en, this message translates to:
  /// **'Drink {volume} before 9 AM'**
  String achievementEarlyBirdTemplate(String volume);

  /// No description provided for @achievementNightOwl.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get achievementNightOwl;

  /// No description provided for @achievementNightOwlDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete hydration goal before 6 PM'**
  String get achievementNightOwlDesc;

  /// No description provided for @achievementLiterLegend.
  ///
  /// In en, this message translates to:
  /// **'Liter Legend'**
  String get achievementLiterLegend;

  /// No description provided for @achievementLiterLegendDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach your total hydration milestone'**
  String get achievementLiterLegendDesc;

  /// No description provided for @achievementLiterLegendTemplate.
  ///
  /// In en, this message translates to:
  /// **'Drink {volume} total'**
  String achievementLiterLegendTemplate(String volume);

  /// No description provided for @achievementSaltStarter.
  ///
  /// In en, this message translates to:
  /// **'Salt Starter'**
  String get achievementSaltStarter;

  /// No description provided for @achievementSaltStarterDesc.
  ///
  /// In en, this message translates to:
  /// **'Add your first electrolytes'**
  String get achievementSaltStarterDesc;

  /// No description provided for @achievementElectrolyteBalance.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get achievementElectrolyteBalance;

  /// No description provided for @achievementElectrolyteBalanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach all electrolyte goals in one day'**
  String get achievementElectrolyteBalanceDesc;

  /// No description provided for @achievementSodiumMaster.
  ///
  /// In en, this message translates to:
  /// **'Sodium Master'**
  String get achievementSodiumMaster;

  /// No description provided for @achievementSodiumMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach sodium goal 7 days in a row'**
  String get achievementSodiumMasterDesc;

  /// No description provided for @achievementPotassiumPro.
  ///
  /// In en, this message translates to:
  /// **'Potassium Pro'**
  String get achievementPotassiumPro;

  /// No description provided for @achievementPotassiumProDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach potassium goal 7 days in a row'**
  String get achievementPotassiumProDesc;

  /// No description provided for @achievementMagnesiumMaven.
  ///
  /// In en, this message translates to:
  /// **'Magnesium Maven'**
  String get achievementMagnesiumMaven;

  /// No description provided for @achievementMagnesiumMavenDesc.
  ///
  /// In en, this message translates to:
  /// **'Reach magnesium goal 7 days in a row'**
  String get achievementMagnesiumMavenDesc;

  /// No description provided for @achievementElectrolyteExpert.
  ///
  /// In en, this message translates to:
  /// **'Electrolyte Expert'**
  String get achievementElectrolyteExpert;

  /// No description provided for @achievementElectrolyteExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Perfect electrolyte balance for 30 days'**
  String get achievementElectrolyteExpertDesc;

  /// No description provided for @achievementSugarAwareness.
  ///
  /// In en, this message translates to:
  /// **'Sugar Awareness'**
  String get achievementSugarAwareness;

  /// No description provided for @achievementSugarAwarenessDesc.
  ///
  /// In en, this message translates to:
  /// **'Track sugar for the first time'**
  String get achievementSugarAwarenessDesc;

  /// No description provided for @achievementSugarUnder25.
  ///
  /// In en, this message translates to:
  /// **'Sweet Control'**
  String get achievementSugarUnder25;

  /// No description provided for @achievementSugarUnder25Desc.
  ///
  /// In en, this message translates to:
  /// **'Keep sugar intake low for a day'**
  String get achievementSugarUnder25Desc;

  /// No description provided for @achievementSugarUnder25Template.
  ///
  /// In en, this message translates to:
  /// **'Keep sugar under {weight} for a day'**
  String achievementSugarUnder25Template(String weight);

  /// No description provided for @achievementSugarWeekControl.
  ///
  /// In en, this message translates to:
  /// **'Sugar Discipline'**
  String get achievementSugarWeekControl;

  /// No description provided for @achievementSugarWeekControlDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain low sugar intake for a week'**
  String get achievementSugarWeekControlDesc;

  /// No description provided for @achievementSugarWeekControlTemplate.
  ///
  /// In en, this message translates to:
  /// **'Keep sugar under {weight} for 7 days'**
  String achievementSugarWeekControlTemplate(String weight);

  /// No description provided for @achievementSugarFreeDay.
  ///
  /// In en, this message translates to:
  /// **'Sugar Free'**
  String get achievementSugarFreeDay;

  /// No description provided for @achievementSugarFreeDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete a day with 0g added sugar'**
  String get achievementSugarFreeDayDesc;

  /// No description provided for @achievementSugarDetective.
  ///
  /// In en, this message translates to:
  /// **'Sugar Detective'**
  String get achievementSugarDetective;

  /// No description provided for @achievementSugarDetectiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Track hidden sugars 10 times'**
  String get achievementSugarDetectiveDesc;

  /// No description provided for @achievementSugarMaster.
  ///
  /// In en, this message translates to:
  /// **'Sugar Master'**
  String get achievementSugarMaster;

  /// No description provided for @achievementSugarMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Maintain very low sugar intake for a month'**
  String get achievementSugarMasterDesc;

  /// No description provided for @achievementNoSodaWeek.
  ///
  /// In en, this message translates to:
  /// **'Soda Free Week'**
  String get achievementNoSodaWeek;

  /// No description provided for @achievementNoSodaWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'No sodas for 7 days'**
  String get achievementNoSodaWeekDesc;

  /// No description provided for @achievementNoSodaMonth.
  ///
  /// In en, this message translates to:
  /// **'Soda Free Month'**
  String get achievementNoSodaMonth;

  /// No description provided for @achievementNoSodaMonthDesc.
  ///
  /// In en, this message translates to:
  /// **'No sodas for 30 days'**
  String get achievementNoSodaMonthDesc;

  /// No description provided for @achievementSweetToothTamed.
  ///
  /// In en, this message translates to:
  /// **'Sweet Tooth Tamed'**
  String get achievementSweetToothTamed;

  /// No description provided for @achievementSweetToothTamedDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce daily sugar by 50% for a week'**
  String get achievementSweetToothTamedDesc;

  /// No description provided for @achievementAlcoholTracker.
  ///
  /// In en, this message translates to:
  /// **'Awareness'**
  String get achievementAlcoholTracker;

  /// No description provided for @achievementAlcoholTrackerDesc.
  ///
  /// In en, this message translates to:
  /// **'Track alcohol consumption'**
  String get achievementAlcoholTrackerDesc;

  /// No description provided for @achievementModerateDay.
  ///
  /// In en, this message translates to:
  /// **'Moderation'**
  String get achievementModerateDay;

  /// No description provided for @achievementModerateDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Stay under 2 SD in a day'**
  String get achievementModerateDayDesc;

  /// No description provided for @achievementSoberDay.
  ///
  /// In en, this message translates to:
  /// **'Sober Day'**
  String get achievementSoberDay;

  /// No description provided for @achievementSoberDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete an alcohol-free day'**
  String get achievementSoberDayDesc;

  /// No description provided for @achievementSoberWeek.
  ///
  /// In en, this message translates to:
  /// **'Sober Week'**
  String get achievementSoberWeek;

  /// No description provided for @achievementSoberWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'7 days alcohol-free'**
  String get achievementSoberWeekDesc;

  /// No description provided for @achievementSoberMonth.
  ///
  /// In en, this message translates to:
  /// **'Sober Month'**
  String get achievementSoberMonth;

  /// No description provided for @achievementSoberMonthDesc.
  ///
  /// In en, this message translates to:
  /// **'30 days alcohol-free'**
  String get achievementSoberMonthDesc;

  /// No description provided for @achievementRecoveryProtocol.
  ///
  /// In en, this message translates to:
  /// **'Recovery Pro'**
  String get achievementRecoveryProtocol;

  /// No description provided for @achievementRecoveryProtocolDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete recovery protocol after drinking'**
  String get achievementRecoveryProtocolDesc;

  /// No description provided for @achievementFirstWorkout.
  ///
  /// In en, this message translates to:
  /// **'Get Moving'**
  String get achievementFirstWorkout;

  /// No description provided for @achievementFirstWorkoutDesc.
  ///
  /// In en, this message translates to:
  /// **'Log your first workout'**
  String get achievementFirstWorkoutDesc;

  /// No description provided for @achievementWorkoutWeek.
  ///
  /// In en, this message translates to:
  /// **'Active Week'**
  String get achievementWorkoutWeek;

  /// No description provided for @achievementWorkoutWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'Work out 3 times in a week'**
  String get achievementWorkoutWeekDesc;

  /// No description provided for @achievementCenturySweat.
  ///
  /// In en, this message translates to:
  /// **'Century Sweat'**
  String get achievementCenturySweat;

  /// No description provided for @achievementCenturySweatDesc.
  ///
  /// In en, this message translates to:
  /// **'Lose significant fluid through workouts'**
  String get achievementCenturySweatDesc;

  /// No description provided for @achievementCenturySweatTemplate.
  ///
  /// In en, this message translates to:
  /// **'Lose {volume} through workouts'**
  String achievementCenturySweatTemplate(String volume);

  /// No description provided for @achievementCardioKing.
  ///
  /// In en, this message translates to:
  /// **'Cardio King'**
  String get achievementCardioKing;

  /// No description provided for @achievementCardioKingDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 cardio sessions'**
  String get achievementCardioKingDesc;

  /// No description provided for @achievementStrengthWarrior.
  ///
  /// In en, this message translates to:
  /// **'Strength Warrior'**
  String get achievementStrengthWarrior;

  /// No description provided for @achievementStrengthWarriorDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 strength sessions'**
  String get achievementStrengthWarriorDesc;

  /// No description provided for @achievementHRIGreen.
  ///
  /// In en, this message translates to:
  /// **'Green Zone'**
  String get achievementHRIGreen;

  /// No description provided for @achievementHRIGreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep HRI in green zone for a day'**
  String get achievementHRIGreenDesc;

  /// No description provided for @achievementHRIWeekGreen.
  ///
  /// In en, this message translates to:
  /// **'Safe Week'**
  String get achievementHRIWeekGreen;

  /// No description provided for @achievementHRIWeekGreenDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep HRI in green zone for 7 days'**
  String get achievementHRIWeekGreenDesc;

  /// No description provided for @achievementHRIPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score'**
  String get achievementHRIPerfect;

  /// No description provided for @achievementHRIPerfectDesc.
  ///
  /// In en, this message translates to:
  /// **'Achieve HRI under 20'**
  String get achievementHRIPerfectDesc;

  /// No description provided for @achievementHRIRecovery.
  ///
  /// In en, this message translates to:
  /// **'Quick Recovery'**
  String get achievementHRIRecovery;

  /// No description provided for @achievementHRIRecoveryDesc.
  ///
  /// In en, this message translates to:
  /// **'Reduce HRI from red to green in one day'**
  String get achievementHRIRecoveryDesc;

  /// No description provided for @achievementHRIMaster.
  ///
  /// In en, this message translates to:
  /// **'HRI Master'**
  String get achievementHRIMaster;

  /// No description provided for @achievementHRIMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep HRI under 30 for 30 days'**
  String get achievementHRIMasterDesc;

  /// No description provided for @achievementStreak3.
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievementStreak3;

  /// No description provided for @achievementStreak3Desc.
  ///
  /// In en, this message translates to:
  /// **'3-day streak'**
  String get achievementStreak3Desc;

  /// No description provided for @achievementStreak7.
  ///
  /// In en, this message translates to:
  /// **'Week Warrior'**
  String get achievementStreak7;

  /// No description provided for @achievementStreak7Desc.
  ///
  /// In en, this message translates to:
  /// **'7-day streak'**
  String get achievementStreak7Desc;

  /// No description provided for @achievementStreak30.
  ///
  /// In en, this message translates to:
  /// **'Consistency King'**
  String get achievementStreak30;

  /// No description provided for @achievementStreak30Desc.
  ///
  /// In en, this message translates to:
  /// **'30-day streak'**
  String get achievementStreak30Desc;

  /// No description provided for @achievementStreak100.
  ///
  /// In en, this message translates to:
  /// **'Century Club'**
  String get achievementStreak100;

  /// No description provided for @achievementStreak100Desc.
  ///
  /// In en, this message translates to:
  /// **'100-day streak'**
  String get achievementStreak100Desc;

  /// No description provided for @achievementFirstWeek.
  ///
  /// In en, this message translates to:
  /// **'First Week'**
  String get achievementFirstWeek;

  /// No description provided for @achievementFirstWeekDesc.
  ///
  /// In en, this message translates to:
  /// **'Use the app for 7 days'**
  String get achievementFirstWeekDesc;

  /// No description provided for @achievementProMember.
  ///
  /// In en, this message translates to:
  /// **'PRO Member'**
  String get achievementProMember;

  /// No description provided for @achievementProMemberDesc.
  ///
  /// In en, this message translates to:
  /// **'Become a PRO subscriber'**
  String get achievementProMemberDesc;

  /// No description provided for @achievementDataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Analyst'**
  String get achievementDataExport;

  /// No description provided for @achievementDataExportDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your data to CSV'**
  String get achievementDataExportDesc;

  /// No description provided for @achievementAllCategories.
  ///
  /// In en, this message translates to:
  /// **'Jack of All Trades'**
  String get achievementAllCategories;

  /// No description provided for @achievementAllCategoriesDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock at least one achievement in each category'**
  String get achievementAllCategoriesDesc;

  /// No description provided for @achievementHunter.
  ///
  /// In en, this message translates to:
  /// **'Achievement Hunter'**
  String get achievementHunter;

  /// No description provided for @achievementHunterDesc.
  ///
  /// In en, this message translates to:
  /// **'Unlock 50% of all achievements'**
  String get achievementHunterDesc;

  /// No description provided for @achievementDetailsUnlockedOn.
  ///
  /// In en, this message translates to:
  /// **'Unlocked on'**
  String get achievementDetailsUnlockedOn;

  /// No description provided for @achievementNewUnlocked.
  ///
  /// In en, this message translates to:
  /// **'New achievement unlocked!'**
  String get achievementNewUnlocked;

  /// No description provided for @achievementViewAll.
  ///
  /// In en, this message translates to:
  /// **'View all achievements'**
  String get achievementViewAll;

  /// No description provided for @achievementCloseNotification.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get achievementCloseNotification;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'before'**
  String get before;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'after'**
  String get after;

  /// No description provided for @lose.
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get lose;

  /// No description provided for @through.
  ///
  /// In en, this message translates to:
  /// **'through'**
  String get through;

  /// No description provided for @throughWorkouts.
  ///
  /// In en, this message translates to:
  /// **'through workouts'**
  String get throughWorkouts;

  /// No description provided for @reach.
  ///
  /// In en, this message translates to:
  /// **'Reach'**
  String get reach;

  /// No description provided for @daysInRow.
  ///
  /// In en, this message translates to:
  /// **'days in a row'**
  String get daysInRow;

  /// No description provided for @completeHydrationGoal.
  ///
  /// In en, this message translates to:
  /// **'Complete hydration goal'**
  String get completeHydrationGoal;

  /// No description provided for @stayUnder.
  ///
  /// In en, this message translates to:
  /// **'Stay under'**
  String get stayUnder;

  /// No description provided for @inADay.
  ///
  /// In en, this message translates to:
  /// **'in a day'**
  String get inADay;

  /// No description provided for @alcoholFree.
  ///
  /// In en, this message translates to:
  /// **'alcohol-free'**
  String get alcoholFree;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @achieve.
  ///
  /// In en, this message translates to:
  /// **'Achieve'**
  String get achieve;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @for30Days.
  ///
  /// In en, this message translates to:
  /// **'for 30 days'**
  String get for30Days;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'liters'**
  String get liters;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @notCompleted.
  ///
  /// In en, this message translates to:
  /// **'Not completed'**
  String get notCompleted;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get times;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'row'**
  String get row;

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'of total'**
  String get ofTotal;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'per day'**
  String get perDay;

  /// No description provided for @perWeek.
  ///
  /// In en, this message translates to:
  /// **'per week'**
  String get perWeek;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'streak'**
  String get streak;

  /// No description provided for @tapToDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap to dismiss'**
  String get tapToDismiss;

  /// No description provided for @tutorialStep1.
  ///
  /// In en, this message translates to:
  /// **'Hi! I\'ll help you start your optimal hydration journey. Let\'s take the first sip of {volume}!'**
  String tutorialStep1(String volume);

  /// No description provided for @tutorialStep2.
  ///
  /// In en, this message translates to:
  /// **'Excellent! Now let\'s add another {volume} to feel how it works.'**
  String tutorialStep2(String volume);

  /// No description provided for @tutorialStep3.
  ///
  /// In en, this message translates to:
  /// **'Outstanding! You\'re ready to use FoodCoach independently. I\'ll be here to help you achieve perfect hydration!'**
  String get tutorialStep3;

  /// No description provided for @tutorialComplete.
  ///
  /// In en, this message translates to:
  /// **'Start using'**
  String get tutorialComplete;

  /// No description provided for @onboardingNotificationExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Reminders'**
  String get onboardingNotificationExamplesTitle;

  /// No description provided for @onboardingNotificationExamplesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'FoodCoach knows when you need water'**
  String get onboardingNotificationExamplesSubtitle;

  /// No description provided for @onboardingLocationExamplesTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Advice'**
  String get onboardingLocationExamplesTitle;

  /// No description provided for @onboardingLocationExamplesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We consider weather for accurate recommendations'**
  String get onboardingLocationExamplesSubtitle;

  /// No description provided for @onboardingAllowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get onboardingAllowNotifications;

  /// No description provided for @onboardingAllowLocation.
  ///
  /// In en, this message translates to:
  /// **'Allow Location'**
  String get onboardingAllowLocation;

  /// No description provided for @onboardingNewWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Reach your goal in 3 months'**
  String get onboardingNewWelcomeTitle;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'Track calories and weight'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Description.
  ///
  /// In en, this message translates to:
  /// **'Simple to use'**
  String get onboardingSlide1Description;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Control proteins, fats and carbohydrates'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Description.
  ///
  /// In en, this message translates to:
  /// **'Scientific approach'**
  String get onboardingSlide2Description;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Form habits forever'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Description.
  ///
  /// In en, this message translates to:
  /// **'Long-term effect'**
  String get onboardingSlide3Description;

  /// No description provided for @onboardingGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'What is your goal?'**
  String get onboardingGoalTitle;

  /// No description provided for @onboardingGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll customize the app for your task'**
  String get onboardingGoalSubtitle;

  /// No description provided for @onboardingLoseWeight.
  ///
  /// In en, this message translates to:
  /// **'Lose weight'**
  String get onboardingLoseWeight;

  /// No description provided for @onboardingLoseWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Shed excess pounds'**
  String get onboardingLoseWeightDesc;

  /// No description provided for @onboardingGainMuscle.
  ///
  /// In en, this message translates to:
  /// **'Gain muscle mass'**
  String get onboardingGainMuscle;

  /// No description provided for @onboardingGainMuscleDesc.
  ///
  /// In en, this message translates to:
  /// **'Increase muscles and strength'**
  String get onboardingGainMuscleDesc;

  /// No description provided for @onboardingMaintainWeight.
  ///
  /// In en, this message translates to:
  /// **'Maintain weight'**
  String get onboardingMaintainWeight;

  /// No description provided for @onboardingMaintainWeightDesc.
  ///
  /// In en, this message translates to:
  /// **'Keep current shape'**
  String get onboardingMaintainWeightDesc;

  /// No description provided for @onboardingImproveNutrition.
  ///
  /// In en, this message translates to:
  /// **'Improve nutrition'**
  String get onboardingImproveNutrition;

  /// No description provided for @onboardingImproveNutritionDesc.
  ///
  /// In en, this message translates to:
  /// **'Eat healthier food'**
  String get onboardingImproveNutritionDesc;

  /// No description provided for @onboardingBodyParamsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get onboardingBodyParamsTitle;

  /// No description provided for @onboardingBodyParamsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This data is used to calculate your personal nutrition plan'**
  String get onboardingBodyParamsSubtitle;

  /// No description provided for @onboardingGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get onboardingGender;

  /// No description provided for @onboardingMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get onboardingMale;

  /// No description provided for @onboardingFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get onboardingFemale;

  /// No description provided for @onboardingAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get onboardingAge;

  /// No description provided for @onboardingHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get onboardingHeight;

  /// No description provided for @onboardingCurrentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current weight'**
  String get onboardingCurrentWeight;

  /// No description provided for @onboardingTargetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target weight'**
  String get onboardingTargetWeight;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingActivityTitle.
  ///
  /// In en, this message translates to:
  /// **'How active are you?'**
  String get onboardingActivityTitle;

  /// No description provided for @onboardingActivitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Excluding workouts - only daily activity'**
  String get onboardingActivitySubtitle;

  /// No description provided for @onboardingSedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get onboardingSedentary;

  /// No description provided for @onboardingSedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Desk job, little walking'**
  String get onboardingSedentaryDesc;

  /// No description provided for @onboardingSedentaryExample.
  ///
  /// In en, this message translates to:
  /// **'Office, remote work, studying'**
  String get onboardingSedentaryExample;

  /// No description provided for @onboardingModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderately active'**
  String get onboardingModerate;

  /// No description provided for @onboardingModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'On feet part of the day'**
  String get onboardingModerateDesc;

  /// No description provided for @onboardingModerateExample.
  ///
  /// In en, this message translates to:
  /// **'Teacher, salesperson, parent'**
  String get onboardingModerateExample;

  /// No description provided for @onboardingActive.
  ///
  /// In en, this message translates to:
  /// **'Very active'**
  String get onboardingActive;

  /// No description provided for @onboardingActiveDesc.
  ///
  /// In en, this message translates to:
  /// **'Physical work'**
  String get onboardingActiveDesc;

  /// No description provided for @onboardingActiveExample.
  ///
  /// In en, this message translates to:
  /// **'Builder, courier, trainer'**
  String get onboardingActiveExample;

  /// No description provided for @onboardingCalculatePlan.
  ///
  /// In en, this message translates to:
  /// **'Calculate plan'**
  String get onboardingCalculatePlan;

  /// No description provided for @onboardingPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal nutrition plan'**
  String get onboardingPlanTitle;

  /// No description provided for @onboardingPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Based on your parameters and goal'**
  String get onboardingPlanSubtitle;

  /// No description provided for @onboardingDailyCalories.
  ///
  /// In en, this message translates to:
  /// **'Daily calories'**
  String get onboardingDailyCalories;

  /// No description provided for @onboardingProteins.
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get onboardingProteins;

  /// No description provided for @onboardingFats.
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get onboardingFats;

  /// No description provided for @onboardingCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get onboardingCarbs;

  /// No description provided for @onboardingPlanTip.
  ///
  /// In en, this message translates to:
  /// **'We use the scientifically proven Mifflin-St Jeor formula for accurate calculation'**
  String get onboardingPlanTip;

  /// No description provided for @onboardingStartNow.
  ///
  /// In en, this message translates to:
  /// **'Start now'**
  String get onboardingStartNow;

  /// No description provided for @onboardingEditPlan.
  ///
  /// In en, this message translates to:
  /// **'Edit plan'**
  String get onboardingEditPlan;

  /// No description provided for @onboardingWeightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get onboardingWeightProgress;

  /// No description provided for @onboardingCurrentWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get onboardingCurrentWeightLabel;

  /// No description provided for @onboardingTargetWeightLabel.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get onboardingTargetWeightLabel;

  /// No description provided for @onboardingProgressWeeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get onboardingProgressWeeks;

  /// No description provided for @onboardingRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingRegistrationTitle;

  /// No description provided for @onboardingRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save your progress and sync across devices'**
  String get onboardingRegistrationSubtitle;

  /// No description provided for @onboardingEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get onboardingEmail;

  /// No description provided for @onboardingPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get onboardingPassword;

  /// No description provided for @onboardingCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get onboardingCreateAccount;

  /// No description provided for @onboardingContinueGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get onboardingContinueGoogle;

  /// No description provided for @onboardingContinueApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get onboardingContinueApple;

  /// No description provided for @onboardingTryWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Try without account'**
  String get onboardingTryWithoutAccount;

  /// No description provided for @onboardingPasswordWeak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get onboardingPasswordWeak;

  /// No description provided for @onboardingPasswordMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get onboardingPasswordMedium;

  /// No description provided for @onboardingPasswordStrong.
  ///
  /// In en, this message translates to:
  /// **'Strong'**
  String get onboardingPasswordStrong;

  /// No description provided for @onboardingEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid email'**
  String get onboardingEmailInvalid;

  /// No description provided for @onboardingPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get onboardingPasswordTooShort;

  /// No description provided for @onboardingQuickStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your first meal'**
  String get onboardingQuickStartTitle;

  /// No description provided for @onboardingQuickStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s track something to get you started'**
  String get onboardingQuickStartSubtitle;

  /// No description provided for @onboardingSelectFood.
  ///
  /// In en, this message translates to:
  /// **'Select food'**
  String get onboardingSelectFood;

  /// No description provided for @onboardingChoosePortion.
  ///
  /// In en, this message translates to:
  /// **'Choose portion'**
  String get onboardingChoosePortion;

  /// No description provided for @onboardingConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get onboardingConfirm;

  /// No description provided for @onboardingSearchFood.
  ///
  /// In en, this message translates to:
  /// **'Search for food...'**
  String get onboardingSearchFood;

  /// No description provided for @onboardingBreakfastItems.
  ///
  /// In en, this message translates to:
  /// **'Popular breakfast items'**
  String get onboardingBreakfastItems;

  /// No description provided for @onboardingPortion.
  ///
  /// In en, this message translates to:
  /// **'Portion'**
  String get onboardingPortion;

  /// No description provided for @onboardingGrams.
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get onboardingGrams;

  /// No description provided for @onboardingAddToLog.
  ///
  /// In en, this message translates to:
  /// **'Add to log'**
  String get onboardingAddToLog;

  /// No description provided for @onboardingGreatStart.
  ///
  /// In en, this message translates to:
  /// **'Great start!'**
  String get onboardingGreatStart;

  /// No description provided for @onboardingFirstMealAdded.
  ///
  /// In en, this message translates to:
  /// **'Your first meal has been added'**
  String get onboardingFirstMealAdded;

  /// No description provided for @onboardingStartTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get onboardingStartTracking;

  /// No description provided for @onboardingSkipTutorial.
  ///
  /// In en, this message translates to:
  /// **'Skip tutorial'**
  String get onboardingSkipTutorial;

  /// Food catalog screen title
  ///
  /// In en, this message translates to:
  /// **'Food Catalog'**
  String get foodCatalog;

  /// Title for today's food intake summary
  ///
  /// In en, this message translates to:
  /// **'Today\'s Food Intake'**
  String get todaysFoodIntake;

  /// Message when no food has been logged today
  ///
  /// In en, this message translates to:
  /// **'No food logged today'**
  String get noFoodToday;

  /// Count of food items logged today
  ///
  /// In en, this message translates to:
  /// **'{count} food items'**
  String foodItemsCount(int count);

  /// Water from food label
  ///
  /// In en, this message translates to:
  /// **'Water from food'**
  String get waterFromFood;

  /// Label for last item
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// Fruits category
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get categoryFruits;

  /// Vegetables category
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get categoryVegetables;

  /// Soups category
  ///
  /// In en, this message translates to:
  /// **'Soups'**
  String get categorySoups;

  /// Dairy category
  ///
  /// In en, this message translates to:
  /// **'Dairy'**
  String get categoryDairy;

  /// Meat category
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get categoryMeat;

  /// Fast food category
  ///
  /// In en, this message translates to:
  /// **'Fast Food'**
  String get categoryFastFood;

  /// Weight in grams label
  ///
  /// In en, this message translates to:
  /// **'Weight (grams)'**
  String get weightGrams;

  /// Enter weight prompt
  ///
  /// In en, this message translates to:
  /// **'Enter weight'**
  String get enterWeight;

  /// Grams unit
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get grams;

  /// Calories label
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// Water content label
  ///
  /// In en, this message translates to:
  /// **'Water Content'**
  String get waterContent;

  /// Sugar label
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// Nutritional information
  ///
  /// In en, this message translates to:
  /// **'Nutritional Info'**
  String get nutritionalInfo;

  /// Calories per weight format
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal per {weight}g'**
  String caloriesPerWeight(int calories, int weight);

  /// Water per weight format
  ///
  /// In en, this message translates to:
  /// **'{water} ml water per {weight}g'**
  String waterPerWeight(int water, int weight);

  /// Sugar per weight format
  ///
  /// In en, this message translates to:
  /// **'{sugar}g sugar per {weight}g'**
  String sugarPerWeight(String sugar, int weight);

  /// Add food button
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// Food added success message
  ///
  /// In en, this message translates to:
  /// **'Food added successfully'**
  String get foodAdded;

  /// Invalid weight error message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get enterValidWeight;

  /// PRO only food label
  ///
  /// In en, this message translates to:
  /// **'PRO only'**
  String get proOnlyFood;

  /// PRO unlock message for food
  ///
  /// In en, this message translates to:
  /// **'Unlock PRO to access all food items'**
  String get unlockProForFood;

  /// Food tracker title
  ///
  /// In en, this message translates to:
  /// **'Food Tracker'**
  String get foodTracker;

  /// Today's food summary title
  ///
  /// In en, this message translates to:
  /// **'Today\'s Food Summary'**
  String get todaysFoodSummary;

  /// Kilocalories abbreviation
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// Per 100 grams
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get per100g;

  /// Add to favorites checkbox
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Favorites feature not yet available message
  ///
  /// In en, this message translates to:
  /// **'Favorites feature coming soon!'**
  String get favoritesFeatureComingSoon;

  /// Success message when food is added
  ///
  /// In en, this message translates to:
  /// **'{food} added! +{calories} kcal, +{water}'**
  String foodAddedSuccess(String food, int calories, String water);

  /// Select weight dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Weight'**
  String get selectWeight;

  /// Ounces unit
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get ounces;

  /// Items count
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// Tap to add food instruction
  ///
  /// In en, this message translates to:
  /// **'Tap to add food'**
  String get tapToAddFood;

  /// No food logged message
  ///
  /// In en, this message translates to:
  /// **'No food logged today'**
  String get noFoodLoggedToday;

  /// Light eating day status
  ///
  /// In en, this message translates to:
  /// **'Light eating day'**
  String get lightEatingDay;

  /// Moderate intake status
  ///
  /// In en, this message translates to:
  /// **'Moderate intake'**
  String get moderateIntake;

  /// Good calorie intake status
  ///
  /// In en, this message translates to:
  /// **'Good calorie intake'**
  String get goodCalorieIntake;

  /// Substantial meals status
  ///
  /// In en, this message translates to:
  /// **'Substantial meals'**
  String get substantialMeals;

  /// High calorie day status
  ///
  /// In en, this message translates to:
  /// **'High calorie day'**
  String get highCalorieDay;

  /// Very high intake status
  ///
  /// In en, this message translates to:
  /// **'Very high intake'**
  String get veryHighIntake;

  /// Calories tracker title
  ///
  /// In en, this message translates to:
  /// **'Calories Tracker'**
  String get caloriesTracker;

  /// Calories tracker description
  ///
  /// In en, this message translates to:
  /// **'Track your daily calorie intake from food'**
  String get trackYourDailyCalorieIntake;

  /// Unlock food tracking features message
  ///
  /// In en, this message translates to:
  /// **'Unlock food tracking features'**
  String get unlockFoodTrackingFeatures;

  /// Select food type title
  ///
  /// In en, this message translates to:
  /// **'Select food type'**
  String get selectFoodType;

  /// Apple fruit
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get foodApple;

  /// Banana fruit
  ///
  /// In en, this message translates to:
  /// **'Banana'**
  String get foodBanana;

  /// Orange fruit
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get foodOrange;

  /// Watermelon fruit
  ///
  /// In en, this message translates to:
  /// **'Watermelon'**
  String get foodWatermelon;

  /// Strawberry fruit
  ///
  /// In en, this message translates to:
  /// **'Strawberry'**
  String get foodStrawberry;

  /// Grapes fruit
  ///
  /// In en, this message translates to:
  /// **'Grapes'**
  String get foodGrapes;

  /// Pineapple fruit
  ///
  /// In en, this message translates to:
  /// **'Pineapple'**
  String get foodPineapple;

  /// Mango fruit
  ///
  /// In en, this message translates to:
  /// **'Mango'**
  String get foodMango;

  /// Pear fruit
  ///
  /// In en, this message translates to:
  /// **'Pear'**
  String get foodPear;

  /// Carrot vegetable
  ///
  /// In en, this message translates to:
  /// **'Carrot'**
  String get foodCarrot;

  /// Broccoli vegetable
  ///
  /// In en, this message translates to:
  /// **'Broccoli'**
  String get foodBroccoli;

  /// Spinach vegetable
  ///
  /// In en, this message translates to:
  /// **'Spinach'**
  String get foodSpinach;

  /// Tomato vegetable
  ///
  /// In en, this message translates to:
  /// **'Tomato'**
  String get foodTomato;

  /// Cucumber vegetable
  ///
  /// In en, this message translates to:
  /// **'Cucumber'**
  String get foodCucumber;

  /// Bell pepper vegetable
  ///
  /// In en, this message translates to:
  /// **'Bell Pepper'**
  String get foodBellPepper;

  /// Lettuce vegetable
  ///
  /// In en, this message translates to:
  /// **'Lettuce'**
  String get foodLettuce;

  /// Onion vegetable
  ///
  /// In en, this message translates to:
  /// **'Onion'**
  String get foodOnion;

  /// Celery vegetable
  ///
  /// In en, this message translates to:
  /// **'Celery'**
  String get foodCelery;

  /// Chicken soup
  ///
  /// In en, this message translates to:
  /// **'Chicken Soup'**
  String get foodChickenSoup;

  /// Tomato soup
  ///
  /// In en, this message translates to:
  /// **'Tomato Soup'**
  String get foodTomatoSoup;

  /// Vegetable soup
  ///
  /// In en, this message translates to:
  /// **'Vegetable Soup'**
  String get foodVegetableSoup;

  /// Minestrone soup
  ///
  /// In en, this message translates to:
  /// **'Minestrone'**
  String get foodMinestrone;

  /// Miso soup
  ///
  /// In en, this message translates to:
  /// **'Miso Soup'**
  String get foodMisoSoup;

  /// Mushroom soup
  ///
  /// In en, this message translates to:
  /// **'Mushroom Soup'**
  String get foodMushroomSoup;

  /// Beef stew
  ///
  /// In en, this message translates to:
  /// **'Beef Stew'**
  String get foodBeefStew;

  /// Lentil soup
  ///
  /// In en, this message translates to:
  /// **'Lentil Soup'**
  String get foodLentilSoup;

  /// French onion soup
  ///
  /// In en, this message translates to:
  /// **'French Onion Soup'**
  String get foodOnionSoup;

  /// Milk
  ///
  /// In en, this message translates to:
  /// **'Milk'**
  String get foodMilk;

  /// Greek yogurt
  ///
  /// In en, this message translates to:
  /// **'Greek Yogurt'**
  String get foodYogurt;

  /// Cheddar cheese
  ///
  /// In en, this message translates to:
  /// **'Cheddar Cheese'**
  String get foodCheese;

  /// Cottage cheese
  ///
  /// In en, this message translates to:
  /// **'Cottage Cheese'**
  String get foodCottageCheese;

  /// Butter
  ///
  /// In en, this message translates to:
  /// **'Butter'**
  String get foodButter;

  /// Heavy cream
  ///
  /// In en, this message translates to:
  /// **'Heavy Cream'**
  String get foodCream;

  /// Ice cream
  ///
  /// In en, this message translates to:
  /// **'Ice Cream'**
  String get foodIceCream;

  /// Mozzarella cheese
  ///
  /// In en, this message translates to:
  /// **'Mozzarella'**
  String get foodMozzarella;

  /// Parmesan cheese
  ///
  /// In en, this message translates to:
  /// **'Parmesan'**
  String get foodParmesan;

  /// Chicken breast
  ///
  /// In en, this message translates to:
  /// **'Chicken Breast'**
  String get foodChickenBreast;

  /// Ground beef
  ///
  /// In en, this message translates to:
  /// **'Ground Beef'**
  String get foodBeef;

  /// Salmon fish
  ///
  /// In en, this message translates to:
  /// **'Salmon'**
  String get foodSalmon;

  /// Chicken eggs
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get foodEggs;

  /// Tuna fish
  ///
  /// In en, this message translates to:
  /// **'Tuna'**
  String get foodTuna;

  /// Pork chop
  ///
  /// In en, this message translates to:
  /// **'Pork Chop'**
  String get foodPork;

  /// Turkey meat
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get foodTurkey;

  /// Shrimp
  ///
  /// In en, this message translates to:
  /// **'Shrimp'**
  String get foodShrimp;

  /// Bacon
  ///
  /// In en, this message translates to:
  /// **'Bacon'**
  String get foodBacon;

  /// McDonald's Big Mac
  ///
  /// In en, this message translates to:
  /// **'Big Mac'**
  String get foodBigMac;

  /// Pizza slice
  ///
  /// In en, this message translates to:
  /// **'Pizza Slice'**
  String get foodPizza;

  /// French fries
  ///
  /// In en, this message translates to:
  /// **'French Fries'**
  String get foodFrenchFries;

  /// Chicken nuggets
  ///
  /// In en, this message translates to:
  /// **'Chicken Nuggets'**
  String get foodChickenNuggets;

  /// Hot dog
  ///
  /// In en, this message translates to:
  /// **'Hot Dog'**
  String get foodHotDog;

  /// Tacos
  ///
  /// In en, this message translates to:
  /// **'Tacos'**
  String get foodTacos;

  /// Subway sandwich
  ///
  /// In en, this message translates to:
  /// **'Subway Sandwich'**
  String get foodSubway;

  /// Donut
  ///
  /// In en, this message translates to:
  /// **'Donut'**
  String get foodDonut;

  /// Burger King Whopper
  ///
  /// In en, this message translates to:
  /// **'Whopper'**
  String get foodBurgerKing;

  /// Meals count label
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get meals;

  /// Daily progress label
  ///
  /// In en, this message translates to:
  /// **'Daily Progress'**
  String get dailyProgress;

  /// Water from food label
  ///
  /// In en, this message translates to:
  /// **'from food'**
  String get fromFood;

  /// No food data message for weekly view
  ///
  /// In en, this message translates to:
  /// **'No food data this week'**
  String get noFoodThisWeek;

  /// Food intake chart title
  ///
  /// In en, this message translates to:
  /// **'Food Intake'**
  String get foodIntake;

  /// Food statistics title
  ///
  /// In en, this message translates to:
  /// **'Food Statistics'**
  String get foodStats;

  /// Total calories label
  ///
  /// In en, this message translates to:
  /// **'Total calories'**
  String get totalCalories;

  /// Average calories per day label
  ///
  /// In en, this message translates to:
  /// **'Avg per day'**
  String get avgCaloriesPerDay;

  /// Days with food label
  ///
  /// In en, this message translates to:
  /// **'Days with food'**
  String get daysWithFood;

  /// Average meals per day label
  ///
  /// In en, this message translates to:
  /// **'Meals per day'**
  String get avgMealsPerDay;

  /// Calories per day label
  ///
  /// In en, this message translates to:
  /// **'Calories per day'**
  String get caloriesPerDay;

  /// Sugar per day label
  ///
  /// In en, this message translates to:
  /// **'Sugar per day'**
  String get sugarPerDay;

  /// Food tracking feature name
  ///
  /// In en, this message translates to:
  /// **'Food Tracking'**
  String get foodTracking;

  /// Food tracking pro description
  ///
  /// In en, this message translates to:
  /// **'Track food impact on hydration and HRI'**
  String get foodTrackingPro;

  /// Hydration balance label
  ///
  /// In en, this message translates to:
  /// **'Hydration Balance'**
  String get hydrationBalance;

  /// High sodium food status
  ///
  /// In en, this message translates to:
  /// **'High sodium from food'**
  String get highSodiumFood;

  /// Hydrating food status
  ///
  /// In en, this message translates to:
  /// **'Great hydrating choices'**
  String get hydratingFood;

  /// Dry food status
  ///
  /// In en, this message translates to:
  /// **'Low water content food'**
  String get dryFood;

  /// Balanced food status
  ///
  /// In en, this message translates to:
  /// **'Balanced nutrition'**
  String get balancedFood;

  /// Advice when no food logged
  ///
  /// In en, this message translates to:
  /// **'Add meals to track food impact on hydration.'**
  String get foodAdviceEmpty;

  /// Advice for high sodium food
  ///
  /// In en, this message translates to:
  /// **'High sodium intake detected. Increase water to balance electrolytes.'**
  String get foodAdviceHighSodium;

  /// Advice for low water content food
  ///
  /// In en, this message translates to:
  /// **'Your food had low water content. Consider drinking extra water.'**
  String get foodAdviceLowWater;

  /// Advice for good hydrating food
  ///
  /// In en, this message translates to:
  /// **'Great! Your food helps hydration.'**
  String get foodAdviceGoodHydration;

  /// Advice for balanced food choices
  ///
  /// In en, this message translates to:
  /// **'Good nutrition! Remember to drink water.'**
  String get foodAdviceBalanced;

  /// Status for food rich in electrolytes
  ///
  /// In en, this message translates to:
  /// **'Rich in electrolytes'**
  String get richInElectrolytes;

  /// Recommended daily calorie intake
  ///
  /// In en, this message translates to:
  /// **'Recommended calories: ~{calories} kcal/day'**
  String recommendedCalories(int calories);

  /// Macronutrients card title
  ///
  /// In en, this message translates to:
  /// **'Macronutrients'**
  String get macronutrients;

  /// Proteins macronutrient label
  ///
  /// In en, this message translates to:
  /// **'Proteins'**
  String get proteins;

  /// Carbohydrates macronutrient label
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbohydrates;

  /// Carbohydrates information dialog title
  ///
  /// In en, this message translates to:
  /// **'Carbs Information'**
  String get carbsInfo;

  /// WHO recommendation section title
  ///
  /// In en, this message translates to:
  /// **'WHO Recommendation'**
  String get carbsWhoRecommendation;

  /// WHO carbohydrates recommendation details
  ///
  /// In en, this message translates to:
  /// **'The World Health Organization recommends that 55% of daily calories should come from carbohydrates. For a 2000-calorie diet, this equals about 275 grams of carbs per day.'**
  String get carbsWhoDetails;

  /// Whole foods recommendation title
  ///
  /// In en, this message translates to:
  /// **'Choose Whole Foods'**
  String get carbsWholeFoodsTitle;

  /// Whole foods carbohydrates recommendation
  ///
  /// In en, this message translates to:
  /// **'It\'s recommended to get carbohydrates from whole, unprocessed foods rather than refined products. This provides more nutrients, fiber, and sustained energy.'**
  String get carbsWholeFoodsDetails;

  /// Good carbohydrate sources title
  ///
  /// In en, this message translates to:
  /// **'Good Sources'**
  String get carbsGoodSources;

  /// List of good carbohydrate sources
  ///
  /// In en, this message translates to:
  /// **'• Whole grains (brown rice, quinoa, oats)\n• Fresh fruits and vegetables\n• Legumes (beans, lentils, peas)\n• Sweet potatoes and other root vegetables'**
  String get carbsGoodSourcesList;

  /// Dialog confirmation button
  ///
  /// In en, this message translates to:
  /// **'Understood'**
  String get understood;

  /// Normal diet mode
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get dietNormal;

  /// Low carb diet mode
  ///
  /// In en, this message translates to:
  /// **'Low Carb'**
  String get dietLowCarb;

  /// Keto diet mode
  ///
  /// In en, this message translates to:
  /// **'Keto'**
  String get dietKeto;

  /// Fats macronutrient label
  ///
  /// In en, this message translates to:
  /// **'Fats'**
  String get fats;

  /// Average calories per meal label
  ///
  /// In en, this message translates to:
  /// **'avg/meal'**
  String get avgCaloriesPerMeal;

  /// Track macronutrients description
  ///
  /// In en, this message translates to:
  /// **'Track your protein, carbs and fats'**
  String get trackMacronutrients;

  /// PRO feature label
  ///
  /// In en, this message translates to:
  /// **'PRO Feature'**
  String get proFeature;

  /// Scan barcode button tooltip
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get scanBarcode;

  /// Description for calorie tracking
  ///
  /// In en, this message translates to:
  /// **'Track your daily calorie intake and nutrition'**
  String get trackCaloriesDescription;

  /// Balance label for macronutrients chart
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// OpenFood catalog screen title
  ///
  /// In en, this message translates to:
  /// **'OpenFood Catalog'**
  String get openFoodCatalog;

  /// Search placeholder text for OpenFood catalog
  ///
  /// In en, this message translates to:
  /// **'Search 2M+ products...'**
  String get searchProducts;

  /// Message when no products found in search
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// Search catalog option in add menu
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchCatalog;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
