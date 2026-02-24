import '../database.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  Future<void> insertSchedule(ScheduleModel schedule) async {
    final db = await getDatabase();
    await db.insert('schedules', schedule.toMap());
  }

  Future<List<ScheduleModel>> getAllActiveSchedules() async {
    final db = await getDatabase();
    final rows = await db.query('schedules', where: 'isActive = 1');
    return rows.map(ScheduleModel.fromMap).toList();
  }

  Future<List<ScheduleModel>> getSchedulesForCard(String cardId) async {
    final db = await getDatabase();
    final rows = await db.query(
      'schedules',
      where: 'cardId = ?',
      whereArgs: [cardId],
    );
    return rows.map(ScheduleModel.fromMap).toList();
  }

  Future<void> deleteSchedule(String id) async {
    final db = await getDatabase();
    await db.delete('schedules', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateScheduleActive(String id, {required bool isActive}) async {
    final db = await getDatabase();
    await db.update(
      'schedules',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
