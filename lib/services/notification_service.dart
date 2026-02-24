import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/card_model.dart';
import '../data/models/schedule_model.dart';
import '../data/repositories/card_repository.dart';
import '../data/repositories/schedule_repository.dart';
import 'app_logger.dart';

/// Max notifications to register at once — iOS hard limit is 64.
const int _kMaxScheduled = 40;

/// Android notification channel for card reminders.
const _androidChannel = AndroidNotificationDetails(
  'micro_deck_reminders',
  'Card Reminders',
  channelDescription: 'Reminders to start your habit cards',
  importance: Importance.high,
  priority: Priority.high,
  // NOTE: Replace '@mipmap/ic_launcher' with a proper white-on-transparent
  // notification icon added to android/app/src/main/res/drawable/
  icon: '@mipmap/ic_launcher',
);

const _notificationDetails = NotificationDetails(
  android: _androidChannel,
  iOS: DarwinNotificationDetails(),
);

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
    _initialized = true;
    notificationLog.info('NotificationService initialised');
  }

  void _onNotificationTap(NotificationResponse response) {
    // Payload is the cardId. Navigation is handled at app level.
    // This is a stub — wire up deep navigation in a follow-up if needed.
  }

  /// Requests notification permission from the OS.
  /// Returns true if granted.
  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      final result = granted ?? false;
      notificationLog.info('iOS permission request → granted=$result');
      return result;
    }

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      final result = granted ?? false;
      notificationLog.info('Android permission request → granted=$result');
      return result;
    }

    notificationLog.warning(
      'requestPermission: no platform implementation found',
    );
    return false;
  }

  /// Cancels all pending notifications and re-registers the next
  /// [_kMaxScheduled] instances from all active schedules.
  Future<void> rescheduleAll() async {
    await init();
    await _plugin.cancelAll();

    final schedules = await ScheduleRepository().getAllActiveSchedules();
    if (schedules.isEmpty) {
      notificationLog.fine(
        'rescheduleAll: no active schedules, nothing to register',
      );
      return;
    }

    final cardRepo = CardRepository();
    final upcoming = <_ScheduledInstance>[];

    for (final schedule in schedules) {
      // Get the card to use its action label in the notification
      final cards = await cardRepo.getAllCards();
      final cardMatches = cards.where((c) => c.id == schedule.cardId);
      if (cardMatches.isEmpty) continue;
      final card = cardMatches.first;

      final instances = _nextOccurrences(schedule, 8);
      for (final time in instances) {
        upcoming.add(
          _ScheduledInstance(schedule: schedule, card: card, time: time),
        );
      }
    }

    // Sort by time and register up to the limit
    upcoming.sort((a, b) => a.time.compareTo(b.time));
    final toRegister = upcoming.take(_kMaxScheduled).toList();

    for (var i = 0; i < toRegister.length; i++) {
      final instance = toRegister[i];
      final durationLabel = instance.card.durationLabel;
      await _plugin.zonedSchedule(
        id: i,
        title: instance.card.actionLabel,
        body: durationLabel,
        scheduledDate: instance.time,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: instance.card.id,
      );
    }

    notificationLog.info(
      'rescheduleAll: registered ${toRegister.length} notification(s) '
      'across ${schedules.length} schedule(s)',
    );
  }

  /// Computes up to [count] future occurrences for a schedule.
  List<tz.TZDateTime> _nextOccurrences(ScheduleModel schedule, int count) {
    final local = tz.local;
    final now = tz.TZDateTime.now(local);
    final results = <tz.TZDateTime>[];
    var daysAhead = 0;

    while (results.length < count && daysAhead < 365) {
      final candidate = tz.TZDateTime(
        local,
        now.year,
        now.month,
        now.day + daysAhead,
        schedule.hour,
        schedule.minute,
      );
      // Convert Dart weekday (1=Mon..7=Sun) to our scheme (0=Sun..6=Sat)
      final dayOfWeek = candidate.weekday % 7;
      if (candidate.isAfter(now) && schedule.weekdays.contains(dayOfWeek)) {
        results.add(candidate);
      }
      daysAhead++;
    }
    return results;
  }
}

class _ScheduledInstance {
  const _ScheduledInstance({
    required this.schedule,
    required this.card,
    required this.time,
  });

  final ScheduleModel schedule;
  final CardModel card;
  final tz.TZDateTime time;
}
