import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/card_model.dart';
import '../../data/templates.dart';
import '../../providers/cards_provider.dart';
import '../../routes.dart';
import '../../theme.dart';
import '../settings/settings_screen.dart';
import '../timer/timer_screen.dart';

class DeckScreen extends ConsumerStatefulWidget {
  const DeckScreen({super.key});

  @override
  ConsumerState<DeckScreen> createState() => _DeckScreenState();
}

class _DeckScreenState extends ConsumerState<DeckScreen>
    with WidgetsBindingObserver {
  bool _navigating = false;
  bool _justOneMode = false;
  int _justOneIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(_onLoad);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reschedule notifications when app comes back to foreground
      // NotificationService.instance.rescheduleAll() is intentionally not
      // awaited here — fire and forget to avoid blocking the UI.
    }
  }

  Future<void> _onLoad() async {
    try {
      await ref.read(cardsProvider.notifier).loadCards();
      await _checkArchivePrompts();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not load cards.')));
      }
    }
  }

  Future<void> _checkArchivePrompts() async {
    final candidates = await ref
        .read(cardsProvider.notifier)
        .getCardsNeedingArchivePrompt();
    if (candidates.isNotEmpty && mounted) {
      _showArchivePrompt(candidates.first);
    }
  }

  void _showArchivePrompt(CardModel card) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => _ArchivePromptSheet(
          card: card,
          onRest: () => ref.read(cardsProvider.notifier).archiveCard(card.id),
        ),
      );
    });
  }

  Future<void> _openTimer(CardModel card) async {
    if (_navigating) return;
    setState(() => _navigating = true);
    await Navigator.of(context).push(fadeRoute(TimerScreen(card: card)));
    if (mounted) {
      setState(() => _navigating = false);
      await _onLoad();
    }
  }

  Future<void> _openAddFlow() async {
    final cards = ref.read(cardsProvider);
    final defaultGoal = cards.isNotEmpty ? _mostRecentGoal(cards) : null;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _TemplateBrowserSheet(defaultGoal: defaultGoal),
    );
    if (mounted) await _onLoad();
  }

  String? _mostRecentGoal(List<CardModel> cards) {
    final sorted = [...cards]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.first.goalLabel;
  }

  void _enterJustOneMode() {
    final cards = ref.read(cardsProvider);
    if (cards.isEmpty) return;
    setState(() {
      _justOneMode = true;
      _justOneIndex = 0;
    });
  }

  void _exitJustOneMode() => setState(() => _justOneMode = false);

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsProvider);

    return Scaffold(
      body: SafeArea(
        child: _justOneMode ? _buildJustOneMode(cards) : _buildDeckView(cards),
      ),
      floatingActionButton: _justOneMode
          ? null
          : Semantics(
              label: 'Add card',
              button: true,
              child: FloatingActionButton(
                onPressed: _openAddFlow,
                child: const Icon(Icons.add),
              ),
            ),
    );
  }

  Widget _buildDeckView(List<CardModel> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              const Text('Your Deck', style: AppTextStyles.screenTitle),
              if (cards.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${cards.length}',
                  style: AppTextStyles.screenTitle.copyWith(
                    color: AppColors.textFaint,
                  ),
                ),
              ],
              const Spacer(),
              if (cards.isNotEmpty)
                Semantics(
                  label: 'Just One mode',
                  button: true,
                  child: IconButton(
                    onPressed: _enterJustOneMode,
                    icon: const Icon(
                      Icons.filter_1_outlined,
                      color: AppColors.textFaint,
                      size: 20,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              Semantics(
                label: 'Settings',
                button: true,
                child: IconButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                    if (mounted) await _onLoad();
                  },
                  icon: const Icon(
                    Icons.tune,
                    color: AppColors.textFaint,
                    size: 20,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: cards.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (_, i) {
                    final card = cards[i];
                    return Dismissible(
                      key: ValueKey(card.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          'Later',
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                      onDismissed: (_) {
                        ref.read(cardsProvider.notifier).deferCard(card.id);
                      },
                      child: _CardTile(
                        card: card,
                        onTap: () => _openTimer(card),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildJustOneMode(List<CardModel> cards) {
    if (cards.isEmpty || _justOneIndex >= cards.length) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("That's all of them.", style: AppTextStyles.bodyMuted),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: _exitJustOneMode,
              child: const Text('Back to deck'),
            ),
          ],
        ),
      );
    }

    final card = cards[_justOneIndex];
    return GestureDetector(
      onTap: _exitJustOneMode,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.page,
              AppSpacing.md,
              AppSpacing.page,
              AppSpacing.xs,
            ),
            child: Row(
              children: [
                const Spacer(),
                Semantics(
                  label: 'Exit Just One mode',
                  button: true,
                  child: IconButton(
                    onPressed: _exitJustOneMode,
                    icon: const Icon(Icons.close, color: AppColors.textFaint),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          GestureDetector(
            onTap: () {}, // Absorb taps on the card itself
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.actionLabel, style: AppTextStyles.cardAction),
                    if (card.goalLabel != null &&
                        card.goalLabel!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(card.goalLabel!, style: AppTextStyles.cardGoal),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Text(card.durationLabel, style: AppTextStyles.badge),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _exitJustOneMode();
                      _openTimer(card);
                    },
                    child: const Text('Start'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      ref.read(cardsProvider.notifier).deferCard(card.id);
                      final newCards = ref.read(cardsProvider);
                      if (_justOneIndex >= newCards.length) {
                        _exitJustOneMode();
                      } else {
                        setState(() {});
                      }
                    },
                    child: const Text('Not today'),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Add your first card\nto get started.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Semantics(
            button: true,
            label: 'Add a card',
            child: FilledButton.icon(
              onPressed: _openAddFlow,
              icon: const Icon(Icons.add),
              label: const Text('Add a card'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Card Tile ────────────────────────────────────────────────────────────────

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onTap});

  final CardModel card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Semantics(
        button: true,
        label: '${card.actionLabel}. Tap to start timer.',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.actionLabel,
                        style: AppTextStyles.cardAction,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (card.goalLabel != null && card.goalLabel!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            card.goalLabel!,
                            style: AppTextStyles.cardGoal,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(card.durationLabel, style: AppTextStyles.badge),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Archive Prompt Sheet ─────────────────────────────────────────────────────

class _ArchivePromptSheet extends StatelessWidget {
  const _ArchivePromptSheet({required this.card, required this.onRest});

  final CardModel card;
  final VoidCallback onRest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "You've set this one aside a few times. Want to rest it for now?",
            style: AppTextStyles.headline,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(card.actionLabel, style: AppTextStyles.bodyMuted),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRest();
              },
              child: const Text('Rest it'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Keep it'),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

// ─── Template Browser Sheet ───────────────────────────────────────────────────

class _TemplateBrowserSheet extends StatelessWidget {
  const _TemplateBrowserSheet({this.defaultGoal});

  final String? defaultGoal;

  void _openAddSheet(
    BuildContext context, {
    String? prefilledAction,
    String? prefilledGoal,
  }) {
    Navigator.of(context).pop(); // Close template browser
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddCardSheet(
        defaultGoal: prefilledGoal ?? defaultGoal,
        prefilledAction: prefilledAction,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              child: Row(
                children: [
                  const Text('New card', style: AppTextStyles.sheetTitle),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _openAddSheet(context),
                    child: const Text('Start blank'),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: AppSpacing.xs,
              ),
              child: Text(
                'Or choose a template to start from:',
                style: AppTextStyles.bodyMuted,
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                children: [
                  for (final area in templateAreas) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        AppSpacing.xs,
                      ),
                      child: Text(
                        area,
                        style: AppTextStyles.label.copyWith(letterSpacing: 0.8),
                      ),
                    ),
                    for (final t in starterTemplates.where(
                      (t) => t.area == area,
                    ))
                      _TemplateRow(
                        template: t,
                        onTap: () => _openAddSheet(
                          context,
                          prefilledAction: t.actionLabel,
                          prefilledGoal: t.goalLabel,
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.template, required this.onTap});

  final CardTemplate template;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.page,
          vertical: 12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template.actionLabel,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(template.goalLabel, style: AppTextStyles.cardGoal),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textFaint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Card Sheet ───────────────────────────────────────────────────────────

class _AddCardSheet extends ConsumerStatefulWidget {
  const _AddCardSheet({this.defaultGoal, this.prefilledAction});

  final String? defaultGoal;
  final String? prefilledAction;

  @override
  ConsumerState<_AddCardSheet> createState() => _AddCardSheetState();
}

class _AddCardSheetState extends ConsumerState<_AddCardSheet> {
  final _goalController = TextEditingController();
  final _actionController = TextEditingController();
  final _actionFocus = FocusNode();
  bool _saving = false;
  double _durationMinutes = 2;

  @override
  void initState() {
    super.initState();
    if (widget.defaultGoal != null) _goalController.text = widget.defaultGoal!;
    if (widget.prefilledAction != null) {
      _actionController.text = widget.prefilledAction!;
    }
  }

  @override
  void dispose() {
    _goalController.dispose();
    _actionController.dispose();
    _actionFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final action = _actionController.text.trim();
    if (action.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final goal = _goalController.text.trim();
      final now = DateTime.now().millisecondsSinceEpoch;
      final card = CardModel(
        id: now.toString(),
        goalLabel: goal.isEmpty ? null : goal,
        actionLabel: action,
        durationSeconds: (_durationMinutes * 60).round(),
        sortOrder: 0,
        createdAt: now,
      );
      await ref.read(cardsProvider.notifier).addCard(card);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not save card. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.md,
        AppSpacing.page,
        AppSpacing.md + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('New card', style: AppTextStyles.sheetTitle),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _goalController,
            style: const TextStyle(color: AppColors.textPrimary),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _actionFocus.requestFocus(),
            decoration: const InputDecoration(labelText: 'Goal (optional)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _actionController,
            focusNode: _actionFocus,
            autofocus: widget.prefilledAction == null,
            style: const TextStyle(color: AppColors.textPrimary),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
            decoration: const InputDecoration(
              labelText: 'Action (required)',
              hintText: 'e.g. Open the document',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text('Duration', style: AppTextStyles.label),
              const Spacer(),
              Text(
                '${_durationMinutes.round()} min',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Slider(
            value: _durationMinutes,
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppColors.textPrimary,
            inactiveColor: AppColors.surfaceHigh,
            onChanged: (v) => setState(() => _durationMinutes = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: Semantics(
              button: true,
              label: 'Save card',
              child: FilledButton(
                onPressed: (_actionController.text.trim().isEmpty || _saving)
                    ? null
                    : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
