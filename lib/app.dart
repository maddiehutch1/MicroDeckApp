import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/deck/deck_screen.dart';
import 'screens/welcome/welcome_screen.dart';
import 'theme.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? _hasCompletedOnboarding;

  @override
  void initState() {
    super.initState();
    _loadOnboardingFlag();
  }

  Future<void> _loadOnboardingFlag() async {
    bool done = false;
    try {
      final prefs = SharedPreferencesAsync();
      done = await prefs.getBool('hasCompletedOnboarding') ?? false;
    } catch (_) {
      // Default to onboarding on any prefs failure — safe fallback
    }
    setState(() => _hasCompletedOnboarding = done);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Micro-Deck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: _hasCompletedOnboarding == null
          ? const Scaffold(body: SizedBox.shrink())
          : _hasCompletedOnboarding!
          ? const DeckScreen()
          : const WelcomeScreen(),
    );
  }
}
