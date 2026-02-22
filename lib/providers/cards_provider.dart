import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/card_model.dart';
import '../data/repositories/card_repository.dart';

class CardsNotifier extends Notifier<List<CardModel>> {
  final _repo = CardRepository();

  @override
  List<CardModel> build() => [];

  Future<void> loadCards() async {
    state = await _repo.getAllCards();
  }

  Future<void> addCard(CardModel card) async {
    await _repo.insertCard(card);
    await loadCards();
  }

  Future<void> deleteCard(String id) async {
    await _repo.deleteCard(id);
    await loadCards();
  }

  Future<void> deferCard(String id) async {
    // Remove optimistically so Dismissible doesn't find the item still in tree
    state = state.where((c) => c.id != id).toList();
    await _repo.deferCard(id);
    await loadCards();
  }

  Future<void> archiveCard(String id) async {
    state = state.where((c) => c.id != id).toList();
    await _repo.archiveCard(id);
    await loadCards();
  }

  Future<void> restoreCard(String id) async {
    await _repo.restoreCard(id);
    await loadCards();
  }

  Future<List<CardModel>> getCardsNeedingArchivePrompt() async {
    return _repo.getCardsNeedingArchivePrompt();
  }

  Future<int> getActiveCardCount() async {
    return _repo.getActiveCardCount();
  }
}

final cardsProvider =
    NotifierProvider<CardsNotifier, List<CardModel>>(CardsNotifier.new);
