import 'package:flutter/material.dart';

import '../../theme.dart';
import 'onboarding_action_screen.dart';

class OnboardingGoalScreen extends StatefulWidget {
  const OnboardingGoalScreen({super.key});

  @override
  State<OnboardingGoalScreen> createState() => _OnboardingGoalScreenState();
}

class _OnboardingGoalScreenState extends State<OnboardingGoalScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OnboardingActionScreen(goal: text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              Semantics(
                label: 'Back',
                button: true,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textMuted,
                  ),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
              const Spacer(flex: 2),
              const Text(
                'What do you want to work toward?',
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'A goal, an area of life, anything you want more of.',
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _controller,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _advance(),
                decoration: const InputDecoration(
                  hintText: 'e.g. Run more often · Sleep better',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Next',
                  child: FilledButton(
                    onPressed: _controller.text.trim().isEmpty
                        ? null
                        : _advance,
                    child: const Text('Next →'),
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
