/// {@template logger}
/// A basic Logger class that can be used to log messages to the console.
/// {@endtemplate}
class Logger {
  /// {@macro logger}
  Logger({
    this.level = Level.info,
  });

  /// The current log level for this logger.
  Level level;

  final _queue = <String?>[];

  /// Flushes internal message queue.
  void flush([void Function(String?)? print]) {
    final writeln = print ?? info;
    for (final message in _queue) {
      writeln(message);
    }
    _queue.clear();
  }

  /// Write message to the console.
  // ignore: avoid_print
  void writeln(String? message) => print(message);

  /// Writes info message to the console.
  void info(String? message) {
    if (level.index > Level.info.index) return;
    writeln(message);
  }

  /// Writes delayed message to the console.
  void delayed(String? message) => _queue.add(message);

  /// Writes error message to the console.
  void err(String? message) {
    if (level.index > Level.error.index) return;
    writeln('\x1B[31m$message\x1B[0m');
  }

  /// Writes alert message to the console.
  void alert(String? message) {
    if (level.index > Level.critical.index) return;
    writeln('\x1B[41m\x1B[37m$message\x1B[0m');
  }

  /// Writes detail message to the console.
  void detail(String? message) {
    if (level.index > Level.debug.index) return;
    writeln('\x1B[90m$message\x1B[0m');
  }

  /// Writes warning message to the console.
  void warn(String? message) {
    if (level.index > Level.warning.index) return;
    writeln('\x1B[33m\x1B[1m$message\x1B[0m');
  }

  /// Writes success message to the console.
  void success(String? message) {
    if (level.index > Level.info.index) return;
    writeln('\x1B[32m$message\x1B[0m');
  }
}

/// Indicates the desired logging level.
enum Level {
  /// The most verbose log level -- everything is logged.
  verbose,

  /// Used for debug info.
  debug,

  /// Default log level used for standard logs.
  info,

  /// Used to indicate a potential problem.
  warning,

  /// Used to indicate a problem.
  error,

  /// Used to indicate an urgent/severe problem.
  critical,

  /// The least verbose level -- nothing is logged.
  quiet,
}
