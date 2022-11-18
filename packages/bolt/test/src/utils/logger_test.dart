import 'dart:async';

import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

void main() {
  group('Logger', () {
    test('writeln', () {
      _runWithLogs((logger, logs) {
        logger.writeln('Hello World!');

        expect(logs, equals(['Hello World!']));
      });
    });

    test('delayed', () {
      _runWithLogs((logger, logs) {
        logger.delayed('Hello World!');

        expect(logs, equals([]));

        logger.flush();

        expect(logs, equals(['Hello World!']));
      });
    });

    group('info', () {
      test('logs correctly', () {
        _runWithLogs((logger, logs) {
          logger.info('Hello World!');

          expect(logs, equals(['Hello World!']));
        });
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.info('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });

    group('err', () {
      test('logs correctly', () {
        _runWithLogs(
          (logger, logs) {
            logger.err('Hello World!');

            expect(logs, equals(['\x1B[31mHello World!\x1B[0m']));
          },
          level: Level.error,
        );
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.err('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });

    group('alert', () {
      test('logs correctly', () {
        _runWithLogs(
          (logger, logs) {
            logger.alert('Hello World!');

            expect(logs, equals(['\x1B[41m\x1B[37mHello World!\x1B[0m']));
          },
          level: Level.critical,
        );
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.alert('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });

    group('detail', () {
      test('logs correctly', () {
        _runWithLogs(
          (logger, logs) {
            logger.detail('Hello World!');

            expect(logs, equals(['\x1B[90mHello World!\x1B[0m']));
          },
          level: Level.debug,
        );
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.detail('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });

    group('warn', () {
      test('logs correctly', () {
        _runWithLogs(
          (logger, logs) {
            logger.warn('Hello World!');

            expect(logs, equals(['\x1B[33m\x1B[1mHello World!\x1B[0m']));
          },
          level: Level.warning,
        );
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.warn('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });

    group('success', () {
      test('logs correctly', () {
        _runWithLogs((logger, logs) {
          logger.success('Hello World!');

          expect(logs, equals(['\x1B[32mHello World!\x1B[0m']));
        });
      });

      test('does not log if log level is lower', () {
        _runWithLogs(
          (logger, logs) {
            logger.success('Hello World!');

            expect(logs, equals([]));
          },
          level: Level.quiet,
        );
      });
    });
  });
}

void _runWithLogs(
  void Function(Logger logger, List<String> logs) callback, {
  Level level = Level.info,
}) {
  final logger = Logger(level: level);
  final logs = <String>[];

  return runZoned(
    () => callback(logger, logs),
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        logs.add(line);
      },
    ),
  );
}
