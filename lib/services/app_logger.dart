import 'package:logging/logging.dart';

// Named loggers — one per feature area so output is filterable by name.
final Logger appLog = Logger('App');
final Logger cardRepoLog = Logger('CardRepository');
final Logger scheduleRepoLog = Logger('ScheduleRepository');
final Logger notificationLog = Logger('NotificationService');

/// Call once in [main] before [runApp].
///
/// Configures the root logger to print every record to stdout in a structured
/// format that an AI agent (or a human) can parse from CLI test output:
///
///   [LEVEL] LoggerName: message
///   [SEVERE] CardRepository: deferCard failed — FormatException: ...
///
/// In release builds the [Level.INFO] floor means debug noise is suppressed
/// while warnings and errors still surface.
void setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print — intentional structured stdout for CLI/agent reads
    // ignore: avoid_print
    print(
      '[${record.level.name}] ${record.loggerName}: ${record.message}'
      '${record.error != null ? ' — ${record.error}' : ''}',
    );
  });
}
