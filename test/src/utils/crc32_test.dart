import 'dart:convert';

import 'package:bolt/src/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('crc32', () {
    test('should return the correct crc32', () {
      expect(crc32(utf8.encode('')), equals(0));
      expect(crc32(utf8.encode('a')), equals(0xe8b7be43));
      expect(crc32(utf8.encode('abc')), equals(0x352441c2));
      expect(crc32(utf8.encode('message digest')), equals(0x20159d7f));
      expect(
        crc32(utf8.encode('abcdefghijklmnopqrstuvwxyz')),
        equals(0x4c2750bd),
      );
      expect(
        crc32(
          utf8.encode(
            'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789',
          ),
        ),
        equals(0x1fc2e6d2),
      );
    });

    test('throws exception when a bit is wrong', () {
      expect(
        () => crc32([256]),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
