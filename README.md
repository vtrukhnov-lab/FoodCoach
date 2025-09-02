# HydraCoach 💧

Smart water and electrolyte tracking app optimized for keto, fasting, and active lifestyle.

**Version:** 0.1.1 | **Status:** Production Ready | **[Changelog](CHANGELOG.md)**

## 🎯 Features

### Core Functionality
- **Smart Water Tracking** - Personalized daily goals based on weight, diet, and activity
- **Electrolyte Balance** - Track sodium, potassium, and magnesium intake
- **Weather Integration** - Automatic goal adjustments based on Heat Index
- **Hydration Status** - Real-time monitoring with risk assessment
- **Push Notifications** - Firebase Cloud Messaging integration ✨
- **Smart Reminders** - Context-aware notifications (post-coffee, heat warnings)

### Advanced Features
- **Diet Modes** - Optimized for normal, keto, and intermittent fasting
- **Daily Reports** - Evening summary with insights and recommendations
- **History & Analytics** - Track progress over days, weeks, and months
- **Customizable Settings** - Units, reminders, and personal preferences

## 📱 Screenshots

<details>
<summary>View Screenshots</summary>

- Main Dashboard with progress rings
- Weather card with heat adjustments
- Daily report and analytics
- History and trends
- Settings and profile

</details>

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (3.0 or higher)
- iOS/Android development environment
- Firebase project (for push notifications)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/vtrukhnov-lab/hydracoach.git
cd hydracoach
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Create a project in [Firebase Console](https://console.firebase.google.com)
   - Add Android/iOS apps
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place files in respective directories

4. Run the app:
```bash
# For iOS
flutter run -d ios

# For Android
flutter run -d android

# For Web (limited functionality)
flutter run -d chrome
```

## 🏗️ Project Structure

```
hydracoach/
├── lib/
│   ├── main.dart                    # App entry point and core logic
│   ├── screens/                     # App screens
│   │   ├── onboarding_screen.dart
│   │   ├── history_screen.dart
│   │   └── settings_screen.dart
│   ├── services/                    # Business logic
│   │   ├── weather_service.dart
│   │   └── notification_service.dart
│   └── widgets/                     # Reusable components
│       ├── weather_card.dart
│       └── daily_report.dart
├── android/                         # Android specific files
├── ios/                            # iOS specific files
├── pubspec.yaml                    # Dependencies
├── CHANGELOG.md                    # Version history
└── README.md                       # Documentation
```

## 📊 Tech Stack

- **Framework**: Flutter 3.x
- **State Management**: Provider
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Local Storage**: SharedPreferences
- **Charts**: fl_chart
- **Animations**: flutter_animate
- **Notifications**: flutter_local_notifications + FCM
- **Location**: geolocator
- **Weather API**: OpenWeatherMap

## 🎨 Key Algorithms

### Water Goals Calculation
```dart
waterMin = 22 ml × weight(kg)
waterOpt = 30 ml × weight(kg)
waterMax = 36 ml × weight(kg)
```

### Heat Index Adjustments
- HI < 27°C: No adjustment
- HI 27-32°C: +5% water, +500mg sodium
- HI 32-39°C: +8% water, +1000mg sodium
- HI > 39°C: +12% water, +1500mg sodium

### Hydration Status
- **Normal**: Balanced water and electrolytes
- **Dilution Risk**: Water > 115% goal, Sodium < 60% goal
- **Dehydration**: Water < 90% goal
- **Low Salt**: Sodium < 50% goal

## 🔜 Roadmap

### Phase 1: Core Features ✅
- [x] Basic water tracking
- [x] Electrolyte monitoring
- [x] Weather integration
- [x] Daily reports
- [x] Push notifications via Firebase
- [x] Local notifications

### Phase 2: Enhanced Features (Current)
- [ ] Cloud sync via Firestore
- [ ] Export data (CSV/PDF)
- [ ] Dark theme
- [ ] Widget support
- [ ] Weekly analytics

### Phase 3: Advanced Features
- [ ] Apple Watch / WearOS apps
- [ ] AI-powered recommendations
- [ ] Social features and challenges
- [ ] Integration with fitness apps (Google Fit, Apple Health)
- [ ] Pro subscription model

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Authors

- **Viktor Trukhnov** - *Initial work* - [vtrukhnov-lab](https://github.com/vtrukhnov-lab)

## 🙏 Acknowledgments

- Inspired by the need for better hydration tracking on keto/fasting diets
- Weather data from OpenWeatherMap API
- Icons and design inspiration from Material Design
- AI-assisted development methodology

## 📧 Contact

For questions or suggestions, please open an issue or contact the maintainer.

---

**Built with ❤️ using Flutter**