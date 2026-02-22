import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/card_model.dart';
import '../../providers/cards_provider.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../deck/deck_screen.dart';
import '../timer/timer_screen.dart';

class OnboardingConfirmScreen extends ConsumerStatefulWidget {
  const OnboardingConfirmScreen({
    super.key,
    required this.goal,
    required this.action,
  });

  final String goal;
  final String action;

  @override
  ConsumerState<OnboardingConfirmScreen> createState() =>
      _OnboardingConfirmScreenState();
}

class _OnboardingConfirmScreenState
    extends ConsumerState<OnboardingConfirmScreen> {
  bool _submitting = false;

  Future<CardModel?> _createAndSaveCard() async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final card = CardModel(
        id: now.toString(),
        goalLabel: widget.goal,
        actionLabel: widget.action,
        durationSeconds: 120,
        sortOrder: 0,
        createdAt: now,
      );
      await ref.read(cardsProvider.notifier).addCard(card);
      final prefs = SharedPreferencesAsync();
      await prefs.setBool('hasCompletedOnboarding', true);
      return card;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Something went wrong. Please try again.')),
        );
      }
      return null;
    }
  }

  Future<void> _startNow() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final card = await _createAndSaveCard();
    if (!mounted) return;
    if (card == null) {
      setState(() => _submitting = false);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(TimerScreen(card: card)),
      (route) => false,
    );
  }

  Future<void> _saveLater() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    final card = await _createAndSaveCard();
    if (!mounted) return;
    if (card == null) {
      setState(() => _submitting = false);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const DeckScreen()),
      (route) => false,
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
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.textMuted),
                  padding: EdgeInsets.zero,
                  iconSize: 24,
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                ),
              ),
              const Spacer(flex: 2),
              const Text(
                "Good. Let's do two minutes of it right now.",
                style: AppTextStyles.headline,
              ),
              const SizedBox(height: AppSpacing.lg),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.action,
                  style: AppTextStyles.cardAction,
                ),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Start now',
                  child: FilledButton(
                    onPressed: _submitting ? null : _startNow,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.background,
                            ),
                          )
                        : const Text('Start now'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: double.infinity,
                child: Semantics(
                  button: true,
                  label: 'Save for later',
                  child: TextButton(
                    onPressed: _submitting ? null : _saveLater,
                    child: const Text('Save for later'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
