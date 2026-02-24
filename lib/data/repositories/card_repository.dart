import '../../services/app_logger.dart';
import '../database.dart';
import '../models/card_model.dart';

class CardRepository {
  Future<void> insertCard(CardModel card) async {
    final db = await getDatabase();
    await db.insert('cards', card.toMap());
    cardRepoLog.info('insertCard id=${card.id} action="${card.actionLabel}"');
  }

  Future<List<CardModel>> getAllCards() async {
    final db = await getDatabase();
    final rows = await db.query(
      'cards',
      where: 'isArchived = 0',
      orderBy: 'sortOrder ASC, createdAt ASC',
    );
    final cards = rows.map(CardModel.fromMap).toList();
    cardRepoLog.fine('getAllCards → ${cards.length} active cards');
    return cards;
  }

  Future<List<CardModel>> getAllArchivedCards() async {
    final db = await getDatabase();
    final rows = await db.query(
      'cards',
      where: 'isArchived = 1',
      orderBy: 'createdAt DESC',
    );
    final cards = rows.map(CardModel.fromMap).toList();
    cardRepoLog.fine('getAllArchivedCards → ${cards.length} archived cards');
    return cards;
  }

  Future<void> deleteCard(String id) async {
    final db = await getDatabase();
    await db.delete('cards', where: 'id = ?', whereArgs: [id]);
    await db.delete('deferrals', where: 'cardId = ?', whereArgs: [id]);
    await db.delete('schedules', where: 'cardId = ?', whereArgs: [id]);
    cardRepoLog.info(
      'deleteCard id=$id (card + deferrals + schedules removed)',
    );
  }

  Future<void> archiveCard(String id) async {
    final db = await getDatabase();
    await db.update(
      'cards',
      {'isArchived': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
    cardRepoLog.info('archiveCard id=$id → isArchived=1');
  }

  Future<void> restoreCard(String id) async {
    final db = await getDatabase();
    final rows = await db.query(
      'cards',
      columns: ['sortOrder'],
      where: 'isArchived = 0',
      orderBy: 'sortOrder DESC',
      limit: 1,
    );
    final maxSort = rows.isEmpty ? 0 : (rows.first['sortOrder'] as int) + 1;
    await db.update(
      'cards',
      {'isArchived': 0, 'sortOrder': maxSort},
      where: 'id = ?',
      whereArgs: [id],
    );
    cardRepoLog.info('restoreCard id=$id → sortOrder=$maxSort');
  }

  /// Moves card to bottom of deck and records a deferral.
  Future<void> deferCard(String id) async {
    final db = await getDatabase();
    final rows = await db.query(
      'cards',
      columns: ['sortOrder'],
      where: 'isArchived = 0',
      orderBy: 'sortOrder DESC',
      limit: 1,
    );
    final maxSort = rows.isEmpty ? 0 : (rows.first['sortOrder'] as int) + 1;
    await db.update(
      'cards',
      {'sortOrder': maxSort},
      where: 'id = ?',
      whereArgs: [id],
    );
    await db.insert('deferrals', {
      'cardId': id,
      'deferredAt': DateTime.now().millisecondsSinceEpoch,
    });
    cardRepoLog.info(
      'deferCard id=$id → moved to sortOrder=$maxSort, deferral recorded',
    );
  }

  /// Returns deferral count for a card in the past [withinMs] milliseconds.
  Future<int> getDeferralCount(String cardId, int withinMs) async {
    final db = await getDatabase();
    final since = DateTime.now().millisecondsSinceEpoch - withinMs;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM deferrals WHERE cardId = ? AND deferredAt >= ?',
      [cardId, since],
    );
    return (result.first['count'] as int? ?? 0);
  }

  /// Returns non-archived cards that have been deferred 3+ times in the past 7 days.
  Future<List<CardModel>> getCardsNeedingArchivePrompt() async {
    final db = await getDatabase();
    final sevenDaysMs = 7 * 24 * 60 * 60 * 1000;
    final since = DateTime.now().millisecondsSinceEpoch - sevenDaysMs;
    final rows = await db.rawQuery(
      '''
      SELECT c.* FROM cards c
      INNER JOIN (
        SELECT cardId, COUNT(*) as deferCount
        FROM deferrals
        WHERE deferredAt >= ?
        GROUP BY cardId
        HAVING deferCount >= 3
      ) d ON c.id = d.cardId
      WHERE c.isArchived = 0
    ''',
      [since],
    );
    final candidates = rows.map(CardModel.fromMap).toList();
    if (candidates.isNotEmpty) {
      cardRepoLog.info(
        'getCardsNeedingArchivePrompt → ${candidates.length} candidate(s): '
        '${candidates.map((c) => c.id).join(', ')}',
      );
    }
    return candidates;
  }

  Future<int> getActiveCardCount() async {
    final db = await getDatabase();
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM cards WHERE isArchived = 0',
    );
    return (result.first['count'] as int? ?? 0);
  }
}
