// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectionDenied', () {
    test('can be instantiated', () {
      final connectionDenied = ConnectionDenied();

      expect(connectionDenied, isNotNull);
    });

    test('equality', () {
      final connectionDenied1 = ConnectionDenied();
      final connectionDenied2 = ConnectionDenied();

      expect(connectionDenied1, equals(connectionDenied2));
    });
  });
}
