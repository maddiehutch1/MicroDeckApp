import 'dart:convert';

class ScheduleModel {
  const ScheduleModel({
    required this.id,
    required this.cardId,
    required this.weekdays,
    required this.timeOfDayMinutes,
    this.isRecurring = true,
    this.isActive = true,
  });

  final String id;
  final String cardId;

  /// Days of week: 0=Sun, 1=Mon, 2=Tue, 3=Wed, 4=Thu, 5=Fri, 6=Sat
  final List<int> weekdays;

  /// Minutes since midnight (e.g. 480 = 8:00 AM)
  final int timeOfDayMinutes;

  final bool isRecurring;
  final bool isActive;

  int get hour => timeOfDayMinutes ~/ 60;
  int get minute => timeOfDayMinutes % 60;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'cardId': cardId,
      'weekdays': jsonEncode(weekdays),
      'timeOfDayMinutes': timeOfDayMinutes,
      'isRecurring': isRecurring ? 1 : 0,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory ScheduleModel.fromMap(Map<String, Object?> map) {
    return ScheduleModel(
      id: map['id'] as String,
      cardId: map['cardId'] as String,
      weekdays: List<int>.from(
        jsonDecode(map['weekdays'] as String) as List<dynamic>,
      ),
      timeOfDayMinutes: map['timeOfDayMinutes'] as int,
      isRecurring: (map['isRecurring'] as int) == 1,
      isActive: (map['isActive'] as int) == 1,
    );
  }
}
