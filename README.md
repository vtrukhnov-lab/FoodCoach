# FoodCoach 🥗

Smart nutrition tracking app with barcode scanning and comprehensive food analysis.

## ✨ Features

### Core Features (FREE)
- **Barcode Scanning** - Instant product recognition with camera
- **Food Database** - Powered by OpenFoodFacts with 2M+ products
- **Nutrition Tracking** - Calories, macros, and micronutrients
- **Smart Portions** - Weight-based accurate nutrition calculation
- **Daily Overview** - Visual progress tracking with charts
- **Food History** - Complete meal and snack logging
- **Multi-language** - Support for English, Russian, and Spanish

### PRO Features (Subscription)
- **Advanced Analytics** - Weekly nutrition reports with insights
- **Custom Foods** - Add personal recipes and meals
- **Meal Planning** - Plan your nutrition ahead
- **Export Data** - CSV export for nutrition analysis
- **Sync Across Devices** - Cloud backup and synchronization
- **Nutrition Goals** - Personalized targets for health goals

## 📱 Screenshots

<details>
<summary>View Screenshots</summary>

- Barcode scanner with real-time detection
- Food database search and selection
- Nutrition dashboard with progress
- Daily food log and history
- Macronutrient breakdown charts
- Settings and goal configuration

</details>

## 🛠️ Tech Stack

- **Framework:** Flutter 3.0+
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore, Remote Config)
- **Food Database:** OpenFoodFacts API
- **Barcode Scanning:** mobile_scanner
- **Analytics:** Firebase Analytics + AppsFlyer
- **Localization:** Flutter ARB (EN/RU/ES)
- **Local Storage:** SharedPreferences
- **Charts:** fl_chart
- **Notifications:** flutter_local_notifications

## 📁 Project Structure

```
foodcoach/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   └── food_intake.dart      # Food tracking model
│   ├── screens/                  # UI screens
│   │   ├── home_screen.dart      # Dashboard
│   │   ├── barcode_scanner_screen.dart # Scanner
│   │   ├── onboarding/           # Onboarding flow
│   │   └── settings/             # Settings
│   ├── services/                 # Business logic
│   │   ├── openfoodfacts_service.dart # Food database
│   │   ├── notification_service.dart
│   │   └── analytics_service.dart
│   ├── widgets/                  # Reusable UI components
│   │   ├── home/                 # Dashboard widgets
│   │   └── common/               # Shared widgets
│   ├── providers/                # State management
│   ├── utils/                    # Utilities
│   └── l10n/                     # Localization files
│       ├── app_en.arb
│       ├── app_ru.arb
│       └── app_es.arb
├── assets/                       # Images, icons, fonts
├── test/                         # Tests
└── pubspec.yaml                  # Dependencies
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS/Android development environment
- Firebase project configured
- Camera permissions for barcode scanning

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vtrukhnov-lab/FoodCoach.git
cd FoodCoach
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate localization files:
```bash
flutter gen-l10n
```

4. Configure Firebase:
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)

5. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your API keys
```

6. Run the app:
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For Web (limited functionality)
flutter run -d chrome
```

## 🍎 Food Database Integration

### OpenFoodFacts API
FoodCoach uses the OpenFoodFacts database, providing access to:
- 2M+ products worldwide
- Detailed nutrition information
- Ingredient lists and allergens
- Product images and brands
- Nutrition scores (Nutri-Score, Nova)

### Nutrition Calculation
```
Per serving calculations:
- Weight-based portion control
- Accurate macro/micronutrient scaling
- Calorie tracking with daily goals
- Sugar, sodium, and fiber monitoring
```

### Barcode Recognition
- Real-time camera scanning
- Support for EAN, UPC, and other formats
- Instant product lookup
- Offline fallback for manual entry

## 🔧 Core Features

### Nutrition Tracking
```
Macronutrients:
- Proteins: Target based on body weight
- Carbohydrates: Customizable daily limits
- Fats: Healthy fat intake monitoring

Micronutrients:
- Sodium: Daily intake tracking
- Sugar: Added vs natural sugar distinction
- Fiber: Daily fiber goal progress
```

### Food Logging
- Barcode scanning for instant recognition
- Manual search in OpenFoodFacts database
- Custom portion sizes and weights
- Meal categorization (breakfast, lunch, dinner, snacks)
- Edit and delete logged foods

## 🌍 Localization

The app supports multiple languages through ARB files:

- **English** (en) - Primary language
- **Russian** (ru) - Русский
- **Spanish** (es) - Español

To add a new language:
1. Create `app_XX.arb` in `lib/l10n/`
2. Translate all keys from `app_en.arb`
3. Run `flutter gen-l10n`

## 📊 Analytics Events

Key events tracked:
- Barcode scanning success/failure
- Food logging and portion selection
- Daily nutrition goal progress
- Search queries and results
- User engagement metrics
- Subscription events

## 🧪 Testing

Run tests:
```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit

# Widget tests
flutter test test/widget

# Integration tests
flutter test integration_test
```

## 📦 Build & Release

### Android
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ipa --release
```

## 🗺️ Roadmap

- [x] Phase 1: Barcode scanning and basic tracking ✅
- [ ] Phase 2: Advanced nutrition analytics 🚧
- [ ] Phase 3: Meal planning and recipes
- [ ] Phase 4: Health integrations (Apple Health, Google Fit)
- [ ] Phase 5: AI-powered recommendations
- [ ] Phase 6: Social features and challenges
- [ ] Phase 7: Nutritionist consultations

### Upcoming Features
- Recipe creator and nutrition calculator
- Meal planning with shopping lists
- Restaurant menu integration
- Nutrition goal coaching
- Weight management tracking
- Dietary restriction filters

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards

- Follow Flutter style guide
- Add tests for new features
- Update localization files
- Document complex logic
- Keep commits atomic

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Food data from OpenFoodFacts community
- Barcode scanning by mobile_scanner
- Icons from Material Design
- Analytics by Firebase & AppsFlyer
- Special thanks to the nutrition tracking community

## 📞 Support

For questions or support:
- Open an issue on GitHub
- Email: support@foodcoach.app
- Documentation: [docs.foodcoach.app](https://docs.foodcoach.app)

## 👨‍💻 Author

**Viktor Trukhnov**
- GitHub: [@vtrukhnov-lab](https://github.com/vtrukhnov-lab)
- Email: viktor@foodcoach.app

---

Built with ❤️ using Flutter and OpenFoodFacts