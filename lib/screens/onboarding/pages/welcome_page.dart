// lib/screens/onboarding/pages/welcome_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../l10n/app_localizations.dart';

class WelcomePage extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback? onSignIn;

  const WelcomePage({
    super.key,
    required this.onStart,
    this.onSignIn,
  });

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<CarouselSlide> _getSlides(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      CarouselSlide(
        icon: Icons.trending_up,
        title: l10n.onboardingSlide1Title,
        description: l10n.onboardingSlide1Description,
        color: const Color(0xFF2EC5FF),
      ),
      CarouselSlide(
        icon: Icons.pie_chart,
        title: l10n.onboardingSlide2Title,
        description: l10n.onboardingSlide2Description,
        color: const Color(0xFF8AF5A3),
      ),
      CarouselSlide(
        icon: Icons.calendar_today,
        title: l10n.onboardingSlide3Title,
        description: l10n.onboardingSlide3Description,
        color: const Color(0xFFFFB366),
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _startAutoplay();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoplay() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;

      final slides = _getSlides(context);
      final nextPage = (_currentPage + 1) % slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopAutoplay() {
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // Логотип
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2EC5FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Colors.white,
              size: 40,
            ),
          ).animate()
            .scale(duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 32),

          // Заголовок
          Text(
            l10n.onboardingNewWelcomeTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 40),

          // Карусель
          SizedBox(
            height: 220,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: slides.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _stopAutoplay,
                  child: _buildSlide(slides[index]),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Индикаторы
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentPage
                      ? const Color(0xFF2EC5FF)
                      : Colors.grey[300],
                ),
              ).animate(target: index == _currentPage ? 1 : 0)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0)),
            ),
          ),

          const Spacer(),

          // Кнопки
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  widget.onStart();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EC5FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  l10n.onboardingStartButton,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),

              const SizedBox(height: 16),

              if (widget.onSignIn != null)
                TextButton(
                  onPressed: widget.onSignIn,
                  child: Text(
                    l10n.onboardingHaveAccount,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSlide(CarouselSlide slide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: slide.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: slide.color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: slide.color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              slide.icon,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            slide.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class CarouselSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  CarouselSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}