import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

Database? _db;

Future<Database> getDatabase() async {
  if (_db != null) return _db!;
  final dbPath = await getDatabasesPath();
  _db = await openDatabase(
    join(dbPath, 'microdeck.db'),
    version: 3,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE cards (
          id TEXT PRIMARY KEY,
          goalLabel TEXT,
          actionLabel TEXT NOT NULL,
          durationSeconds INTEGER NOT NULL,
          sortOrder INTEGER NOT NULL,
          createdAt INTEGER NOT NULL,
          isArchived INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE deferrals (
          cardId TEXT NOT NULL,
          deferredAt INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE schedules (
          id TEXT PRIMARY KEY,
          cardId TEXT NOT NULL,
          weekdays TEXT NOT NULL,
          timeOfDayMinutes INTEGER NOT NULL,
          isRecurring INTEGER NOT NULL,
          isActive INTEGER NOT NULL
        )
      ''');
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < 2) {
        await db.execute(
          'ALTER TABLE cards ADD COLUMN isArchived INTEGER NOT NULL DEFAULT 0',
        );
        await db.execute('''
          CREATE TABLE deferrals (
            cardId TEXT NOT NULL,
            deferredAt INTEGER NOT NULL
          )
        ''');
      }
      if (oldVersion < 3) {
        await db.execute('''
          CREATE TABLE schedules (
            id TEXT PRIMARY KEY,
            cardId TEXT NOT NULL,
            weekdays TEXT NOT NULL,
            timeOfDayMinutes INTEGER NOT NULL,
            isRecurring INTEGER NOT NULL,
            isActive INTEGER NOT NULL
          )
        ''');
      }
    },
  );
  return _db!;
}
