// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectionAccepted', () {
    test('can be instantiated', () {
      final connectionAccepted = ConnectionAccepted(connectionId: 1);

      expect(connectionAccepted.connectionId, equals(1));
    });

    test('equality', () {
      final connectionAccepted1 = ConnectionAccepted(connectionId: 1);
      final connectionAccepted2 = ConnectionAccepted(connectionId: 1);

      expect(connectionAccepted1, equals(connectionAccepted2));
    });
  });
}
