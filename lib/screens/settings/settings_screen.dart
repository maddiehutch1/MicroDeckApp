import 'package:flutter/material.dart';

import '../../data/models/card_model.dart';
import '../../data/repositories/card_repository.dart';
import '../../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repo = CardRepository();
  List<CardModel> _archived = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final archived = await _repo.getAllArchivedCards();
      setState(() {
        _archived = archived;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _restore(CardModel card) async {
    try {
      await _repo.restoreCard(card.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not restore card.')),
        );
      }
    }
  }

  Future<void> _delete(CardModel card) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete permanently?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(card.actionLabel, style: AppTextStyles.bodyMuted),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _repo.deleteCard(card.id);
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not delete card.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
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
                      constraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Text('Settings', style: AppTextStyles.screenTitle),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                AppSpacing.xs,
              ),
              child: Text(
                'Resting cards',
                style: AppTextStyles.label.copyWith(letterSpacing: 0.8),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.textMuted,
                      ),
                    )
                  : _archived.isEmpty
                  ? Center(
                      child: Text(
                        'No resting cards.',
                        style: AppTextStyles.bodyMuted,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      itemCount: _archived.length,
                      itemBuilder: (_, i) => _ArchivedCardRow(
                        card: _archived[i],
                        onRestore: () => _restore(_archived[i]),
                        onDelete: () => _delete(_archived[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedCardRow extends StatelessWidget {
  const _ArchivedCardRow({
    required this.card,
    required this.onRestore,
    required this.onDelete,
  });

  final CardModel card;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 14,
        ),
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
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (card.goalLabel != null && card.goalLabel!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        card.goalLabel!,
                        style: AppTextStyles.cardGoal,
                      ),
                    ),
                ],
              ),
            ),
            Semantics(
              label: 'Restore ${card.actionLabel}',
              button: true,
              child: TextButton(
                onPressed: onRestore,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textMuted,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(44, 44),
                ),
                child: const Text('Restore'),
              ),
            ),
            Semantics(
              label: 'Delete ${card.actionLabel}',
              button: true,
              child: IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.textFaint,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
