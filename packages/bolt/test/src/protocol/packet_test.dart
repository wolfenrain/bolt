// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

void main() {
  group('Packet', () {
    test('can be instantiated', () {
      final packet = Packet(Address('127.0.0.0', 5555), 'Hello World!');

      expect(packet.address, equals(Address('127.0.0.0', 5555)));
      expect(packet.data, equals('Hello World!'));
    });
  });
}
