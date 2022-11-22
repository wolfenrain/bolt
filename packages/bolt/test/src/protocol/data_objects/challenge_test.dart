// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('Challenge', () {
    test('can be instantiated', () {
      final challenge = Challenge(clientSalt: 10, serverSalt: 10);

      expect(challenge.clientSalt, equals(10));
      expect(challenge.serverSalt, equals(10));
    });

    test('equality', () {
      final challenge1 = Challenge(clientSalt: 10, serverSalt: 10);
      final challenge2 = Challenge(clientSalt: 10, serverSalt: 10);

      expect(challenge1, equals(challenge2));
    });
  });
}
