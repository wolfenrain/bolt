// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

void main() {
  group('Address', () {
    test('can be instantiated', () {
      expect(Address('0.0.0.0', 5555), isNotNull);
    });

    test('equality', () {
      final address1 = Address('0.0.0.0', 5555);
      final address2 = Address('0.0.0.0', 5555);

      expect(address1, equals(address2));
    });

    test('toString', () {
      final address = Address('0.0.0.0', 5555);

      expect(address.toString(), equals('0.0.0.0:5555'));
    });
  });
}
