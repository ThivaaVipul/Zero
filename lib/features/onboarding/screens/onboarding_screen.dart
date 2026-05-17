import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hive_ce/hive.dart';
import '../../../app/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: '',
      description: 'A premium fasting experience designed for your focus and health.',
      imagePath: 'assets/logo/logo.png',
      color: AppColors.primary,
    ),
    OnboardingData(
      title: 'SMART TRACKING',
      description: 'Track your fasts, hydration, and journal your mood—all in one place.',
      icon: Icons.timer_outlined,
      color: AppColors.secondary,
    ),
    OnboardingData(
      title: 'INSIGHTFUL PROGRESS',
      description: 'Visualize your journey with detailed charts and personalized insights.',
      icon: Icons.insights_outlined,
      color: AppColors.accent,
    ),
  ];

  void _finishOnboarding() {
    Hive.box('settingsBox').put('isFirstRun', false);
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (page.imagePath != null)
                      Image.asset(
                        page.imagePath!,
                        width: 240,
                        height: 240,
                        fit: BoxFit.contain,
                      ).animate(key: ValueKey(index)).scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn()
                    else
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: page.color.withAlpha(30),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(page.icon, size: 80, color: page.color),
                      ).animate(key: ValueKey(index)).scale(duration: 600.ms, curve: Curves.easeOutBack).fadeIn(),
                    const SizedBox(height: 60),
                    Text(
                      page.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ).animate(key: ValueKey('t$index')).slideY(begin: 0.5, end: 0).fadeIn(),
                    const SizedBox(height: 20),
                    Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ).animate(key: ValueKey('d$index')).fadeIn(delay: 200.ms),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 60,
            left: 40,
            right: 40,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? AppColors.primary : AppColors.card,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ).animate(target: _currentPage == index ? 1 : 0).scale(),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(duration: 500.ms, curve: Curves.easeInOut);
                      } else {
                        _finishOnboarding();
                      }
                    },
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
                      style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData? icon;
  final String? imagePath;
  final Color color;

  OnboardingData({
    required this.title,
    required this.description,
    this.icon,
    this.imagePath,
    required this.color,
  });
}
