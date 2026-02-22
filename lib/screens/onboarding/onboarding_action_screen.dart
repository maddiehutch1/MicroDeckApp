import 'package:flutter/material.dart';

import '../../theme.dart';
import 'onboarding_confirm_screen.dart';

class OnboardingActionScreen extends StatefulWidget {
  const OnboardingActionScreen({super.key, required this.goal});

  final String goal;

  @override
  State<OnboardingActionScreen> createState() => _OnboardingActionScreenState();
}

class _OnboardingActionScreenState extends State<OnboardingActionScreen> {
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
      MaterialPageRoute(
        builder: (_) => OnboardingConfirmScreen(
          goal: widget.goal,
          action: text,
        ),
      ),
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
                  icon: const Icon(Icons.arrow_back, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),
              const Spacer(flex: 1),
              Text(
                widget.goal,
                style: AppTextStyles.contextLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                "What's one tiny thing that starts it?",
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Start with a verb. Make it small enough to do right now.',
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
                  hintText: 'e.g. Put on my running shoes',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: "Let's go",
                  child: FilledButton(
                    onPressed:
                        _controller.text.trim().isEmpty ? null : _advance,
                    child: const Text("Let's go →"),
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
