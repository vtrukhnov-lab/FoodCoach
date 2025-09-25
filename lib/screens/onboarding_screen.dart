// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/hydration_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics_service.dart';
import 'onboarding/pages/welcome_page.dart';
import 'onboarding/pages/goal_page.dart';
import 'onboarding/pages/body_parameters_page.dart';
import 'onboarding/pages/activity_page.dart';
import 'onboarding/pages/personal_plan_page.dart';
import 'onboarding/pages/registration_page.dart';
import 'onboarding/pages/quick_start_page.dart';
import 'onboarding/widgets/first_intake_tutorial.dart';
import 'main_shell.dart';
import 'paywall_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final AnalyticsService _analytics = AnalyticsService();

  static const Map<int, String> _stepIds = {
    0: 'welcome',
    1: 'goal',
    2: 'body_parameters',
    3: 'activity',
    4: 'personal_plan',
    5: 'registration',
    6: 'quick_start',
  };

  // User data
  String? _selectedGoal;
  String? _gender;
  int? _age;
  double? _height;
  double? _currentWeight;
  double? _targetWeight;
  String? _activity;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _analytics.logOnboardingStart();
      _trackStepView(_currentPage);
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _stepIdFor(int index) => _stepIds[index] ?? 'step_$index';

  void _trackStepView(int index) {
    final stepId = _stepIdFor(index);
    _analytics.logOnboardingStepViewed(
      stepId: stepId,
      stepIndex: index,
      screenName: 'onboarding_$stepId',
    );
  }

  void _trackStepCompleted(int index) {
    final stepId = _stepIdFor(index);
    _analytics.logOnboardingStepCompleted(
      stepId: stepId,
      stepIndex: index,
    );
  }

  void _completeStep(int index) {
    _trackStepCompleted(index);
  }

  void _goToNextPage() {
    _completeStep(_currentPage);
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator (показываем для экранов 1-5)
            if (_currentPage > 0 && _currentPage < 5)
              _buildProgressIndicator(),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                  _trackStepView(page);
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // 0 - Welcome Page
                  WelcomePage(
                    onStart: _goToNextPage,
                  ),

                  // 1 - Goal Page
                  GoalPage(
                    selectedGoal: _selectedGoal,
                    onGoalChanged: (goal) {
                      setState(() {
                        _selectedGoal = goal;
                      });
                      _analytics.logOnboardingOptionSelected(
                        stepId: _stepIdFor(1),
                        option: 'goal',
                        value: goal,
                      );
                    },
                    onNext: _goToNextPage,
                    onBack: _goToPreviousPage,
                  ),

                  // 2 - Body Parameters Page
                  BodyParametersPage(
                    gender: _gender,
                    age: _age,
                    height: _height,
                    currentWeight: _currentWeight,
                    targetWeight: _targetWeight,
                    goal: _selectedGoal ?? 'maintain_weight',
                    onGenderChanged: (gender) {
                      setState(() {
                        _gender = gender;
                      });
                    },
                    onAgeChanged: (age) {
                      setState(() {
                        _age = age;
                      });
                    },
                    onHeightChanged: (height) {
                      setState(() {
                        _height = height;
                      });
                    },
                    onCurrentWeightChanged: (weight) {
                      setState(() {
                        _currentWeight = weight;
                      });
                    },
                    onTargetWeightChanged: (weight) {
                      setState(() {
                        _targetWeight = weight;
                      });
                    },
                    onNext: _goToNextPage,
                    onBack: _goToPreviousPage,
                  ),

                  // 3 - Activity Page
                  ActivityPage(
                    selectedActivity: _activity,
                    onActivityChanged: (activity) {
                      setState(() {
                        _activity = activity;
                      });
                      _analytics.logOnboardingOptionSelected(
                        stepId: _stepIdFor(3),
                        option: 'activity_level',
                        value: activity,
                      );
                    },
                    onNext: _goToNextPage,
                    onBack: _goToPreviousPage,
                  ),

                  // 4 - Personal Plan Page
                  PersonalPlanPage(
                    goal: _selectedGoal ?? 'maintain_weight',
                    gender: _gender ?? 'male',
                    age: _age ?? 25,
                    height: _height ?? 170,
                    currentWeight: _currentWeight ?? 70,
                    targetWeight: _targetWeight,
                    activity: _activity ?? 'moderate',
                    onContinue: _goToNextPage,
                    onEditPlan: () => _goToPage(1), // Вернуться к выбору цели
                    onBack: _goToPreviousPage,
                  ),

                  // 5 - Registration Page
                  RegistrationPage(
                    onContinue: _goToNextPage,
                    onSkip: _goToNextPage,
                    onBack: _goToPreviousPage,
                  ),

                  // 6 - Quick Start Page
                  QuickStartPage(
                    onComplete: _completeOnboarding,
                    onSkip: _completeOnboarding,
                    onBack: _goToPreviousPage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProgressIndicator() {
    final totalSteps = 4; // Показываем прогресс для шагов 1-4
    final currentStep = _currentPage;

    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(totalSteps, (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 4,
            decoration: BoxDecoration(
              color: index < currentStep
                ? const Color(0xFF2EC5FF)
                : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ).animate().scaleX(
            begin: index < currentStep ? 0 : 1,
            end: 1,
            duration: 300.ms,
          ),
        )),
      ),
    );
  }
  
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();

    // Сохраняем данные пользователя
    if (_selectedGoal != null) await prefs.setString('goal', _selectedGoal!);
    if (_gender != null) await prefs.setString('gender', _gender!);
    if (_age != null) await prefs.setInt('age', _age!);
    if (_height != null) await prefs.setDouble('height', _height!);
    if (_currentWeight != null) await prefs.setDouble('weight', _currentWeight!);
    if (_targetWeight != null) await prefs.setDouble('targetWeight', _targetWeight!);
    if (_activity != null) await prefs.setString('activity', _activity!);

    // Устанавливаем метрическую систему по умолчанию
    await prefs.setString('units', 'metric');

    // Расчет дневной нормы калорий
    if (_currentWeight != null && _height != null && _age != null && _gender != null) {
      // Формула Миффлина-Сан Жеора
      double bmr;
      if (_gender == 'male') {
        bmr = 10 * _currentWeight! + 6.25 * _height! - 5 * _age! + 5;
      } else {
        bmr = 10 * _currentWeight! + 6.25 * _height! - 5 * _age! - 161;
      }

      // Коэффициент активности
      double activityMultiplier = 1.375; // По умолчанию умеренная активность
      if (_activity == 'sedentary') activityMultiplier = 1.2;
      if (_activity == 'active') activityMultiplier = 1.55;

      // TDEE и корректировка под цель
      double tdee = bmr * activityMultiplier;
      double dailyCalories = tdee;

      if (_selectedGoal == 'lose_weight') {
        dailyCalories = tdee - 500;
      } else if (_selectedGoal == 'gain_muscle') {
        dailyCalories = tdee + 300;
      }

      await prefs.setInt('dailyCaloriesGoal', dailyCalories.round());
    }

    // Обновляем провайдер
    if (mounted) {
      final provider = Provider.of<HydrationProvider>(context, listen: false);
      provider.updateProfile(
        weight: _currentWeight ?? 70,
        dietMode: 'normal',
        activityLevel: _activity ?? 'medium',
        fastingSchedule: 'none',
      );
    }
  }

  Future<void> _completeOnboarding() async {
    // Сохраняем данные пользователя
    await _saveUserData();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);

    await _analytics.logOnboardingComplete();

    if (mounted) {
      // Показываем paywall
      final bool? purchased = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PaywallScreen(
            showCloseButton: true,
            source: 'onboarding',
          ),
          fullscreenDialog: true,
        ),
      );

      if (mounted) {
        // Показываем туториал первого глотка
        final shouldShowTutorial = prefs.getBool('tutorialCompleted') != true;

        if (shouldShowTutorial) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const _MainShellWithTutorial()),
            (route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const MainShell()),
            (route) => false,
          );
        }
      }
    }
  }
}

// Обёртка для MainShell с туториалом
class _MainShellWithTutorial extends StatefulWidget {
  const _MainShellWithTutorial();

  @override
  State<_MainShellWithTutorial> createState() => _MainShellWithTutorialState();
}

class _MainShellWithTutorialState extends State<_MainShellWithTutorial> {
  bool _showTutorial = true;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const MainShell(),
        
        if (_showTutorial)
          FirstIntakeTutorial(
            onComplete: () async {
              setState(() {
                _showTutorial = false;
              });
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('tutorialCompleted', true);
            },
          ),
      ],
    );
  }
}