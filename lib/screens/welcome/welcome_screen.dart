import 'package:flutter/material.dart';

import '../../theme.dart';
import '../onboarding/onboarding_goal_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              const Text('Micro-Deck', style: AppTextStyles.appName),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Start the thing you keep putting off.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                "One card. Two minutes. That's it.",
                style: AppTextStyles.bodyMuted,
              ),
              const Spacer(flex: 4),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: "Let's begin",
                  child: FilledButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OnboardingGoalScreen(),
                        ),
                      );
                    },
                    child: const Text("Let's begin →"),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
