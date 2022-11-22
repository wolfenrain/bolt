// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectionRequest', () {
    test('can be instantiated', () {
      final connectionRequest =
          ConnectionRequest(token: 'token', clientSalt: 10);

      expect(connectionRequest.token, equals('token'));
      expect(connectionRequest.clientSalt, equals(10));
    });

    test('equality', () {
      final connectionRequest1 = ConnectionRequest(
        token: 'token',
        clientSalt: 10,
      );
      final connectionRequest2 = ConnectionRequest(
        token: 'token',
        clientSalt: 10,
      );

      expect(connectionRequest1, equals(connectionRequest2));
    });
  });
}
