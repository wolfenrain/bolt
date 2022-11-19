// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('Disconnect', () {
    test('can be instantiated', () {
      final disconnect = Disconnect();

      expect(disconnect, isNotNull);
    });

    test('equality', () {
      final disconnect1 = Disconnect();
      final disconnect2 = Disconnect();

      expect(disconnect1, equals(disconnect2));
    });
  });
}
