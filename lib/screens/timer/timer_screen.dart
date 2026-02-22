import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../data/models/card_model.dart';
import '../../routes.dart';
import '../../services/notification_service.dart';
import '../../theme.dart';
import '../deck/deck_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, required this.card});

  final CardModel card;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late int _secondsRemaining;
  Timer? _ticker;
  bool _isRunning = true;
  bool _isComplete = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseOpacity;

  late final AnimationController _completionController;
  late final Animation<double> _completionOpacity;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.card.durationSeconds;

    WakelockPlus.enable();
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _completionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _completionOpacity = CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeIn,
    );

    _startTicker();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _pulseController.dispose();
    _completionController.dispose();
    WakelockPlus.disable();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) _pause();
  }

  void _startTicker() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _ticker?.cancel();
          _isRunning = false;
          _isComplete = true;
          _onComplete();
        }
      });
    });
  }

  void _pause() {
    _ticker?.cancel();
    _pulseController.stop();
    if (mounted) setState(() => _isRunning = false);
  }

  void _resume() {
    if (_isComplete) return;
    _pulseController.repeat(reverse: true);
    setState(() => _isRunning = true);
    _startTicker();
  }

  void _togglePause() {
    if (_isRunning) {
      _pause();
    } else {
      _resume();
    }
  }

  Future<void> _onComplete() async {
    _pulseController.stop();
    await HapticFeedback.mediumImpact();
    _completionController.forward();

    // Request notification permission and show explainer in parallel
    // during the 2-second completion pause
    await Future.wait([
      Future<void>.delayed(const Duration(seconds: 2)),
      _handlePostCompletion(),
    ]);

    if (!mounted) return;
    _goToDeck();
  }

  Future<void> _handlePostCompletion() async {
    await _maybeRequestNotificationPermission();
    await _maybeShowExplainer();
  }

  Future<void> _maybeRequestNotificationPermission() async {
    try {
      final prefs = SharedPreferencesAsync();
      final asked = await prefs.getBool('hasAskedNotificationPermission') ?? false;
      if (asked) return;
      await prefs.setBool('hasAskedNotificationPermission', true);
      await NotificationService.instance.requestPermission();
    } catch (_) {}
  }

  Future<void> _maybeShowExplainer() async {
    try {
      final prefs = SharedPreferencesAsync();
      final seen = await prefs.getBool('hasSeenExplainer') ?? false;
      if (seen) return;
      await prefs.setBool('hasSeenExplainer', true);
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => const _ExplainerSheet(),
      );
    } catch (_) {}
  }

  void _goToDeck() {
    Navigator.of(context).pushAndRemoveUntil(
      fadeRoute(const DeckScreen()),
      (route) => false,
    );
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isRunning || _isComplete,
      child: Scaffold(
        body: SafeArea(
          child: GestureDetector(
            onTap: _isComplete ? null : _togglePause,
            behavior: HitTestBehavior.opaque,
            child: SizedBox.expand(
              child: _isComplete ? _buildCompletion() : _buildTimer(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  widget.card.actionLabel,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.timerLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Semantics(
                label: 'Time remaining: ${_formatTime(_secondsRemaining)}',
                child: Text(
                  _formatTime(_secondsRemaining),
                  style: AppTextStyles.timerDisplay,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FadeTransition(
                opacity: _pulseOpacity,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.textPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!_isRunning)
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Center(
              child: Semantics(
                button: true,
                label: 'End session',
                child: TextButton(
                  onPressed: _goToDeck,
                  child: const Text('End session'),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCompletion() {
    return Center(
      child: FadeTransition(
        opacity: _completionOpacity,
        child: const Text("That's it.", style: AppTextStyles.completion),
      ),
    );
  }
}

// ─── Post-Completion Explainer ────────────────────────────────────────────────

class _ExplainerSheet extends StatelessWidget {
  const _ExplainerSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("That's how it works.", style: AppTextStyles.headline),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            "Two minutes was enough to start. The hardest part isn't the doing — it's deciding to begin. You just did that.",
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}
