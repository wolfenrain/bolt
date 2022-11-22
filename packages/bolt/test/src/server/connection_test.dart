// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:test/test.dart';

void main() {
  group('Connection', () {
    test('can be instantiated', () {
      final connection = Connection(
        clientSalt: 10,
        serverSalt: 10,
        address: Address('127.0.0.1', 7687),
      );

      expect(connection.clientSalt, equals(10));
      expect(connection.serverSalt, equals(10));
      expect(connection.salt, equals(0));
      expect(connection.address, equals(Address('127.0.0.1', 7687)));
    });

    test('equality', () {
      final connection1 = Connection(
        clientSalt: 10,
        serverSalt: 10,
        address: Address('127.0.0.1', 7687),
      );
      final connection2 = Connection(
        clientSalt: 10,
        serverSalt: 10,
        address: Address('127.0.0.1', 7687),
      );

      expect(connection1, equals(connection2));
    });

    test('toString', () {
      final connection = Connection(
        clientSalt: 10,
        serverSalt: 10,
        address: Address('127.0.0.1', 7687),
      );

      expect(
        connection.toString(),
        equals('Connection { address: 127.0.0.1:7687 }'),
      );
    });
  });
}
