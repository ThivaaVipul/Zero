import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hive_ce/hive.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/hydration/screens/hydration_screen.dart';
import '../../features/journal/screens/journal_screen.dart';
import '../../features/progress/screens/progress_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  redirect: (context, state) {
    final box = Hive.box('settingsBox');
    final isFirstRun = box.get('isFirstRun', defaultValue: true);
    
    if (isFirstRun && state.matchedLocation != '/onboarding') {
      return '/onboarding';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/hydration',
      builder: (context, state) => const HydrationScreen(),
    ),
    GoRoute(
      path: '/journal',
      builder: (context, state) => const JournalScreen(),
    ),
    GoRoute(
      path: '/progress',
      builder: (context, state) => const ProgressScreen(),
    ),
  ],
);
