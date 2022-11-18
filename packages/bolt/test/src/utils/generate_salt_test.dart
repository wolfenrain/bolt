import 'dart:math';

import 'package:bolt/src/utils/utils.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _MockRandom extends Mock implements Random {}

void main() {
  group('generateSalt', () {
    test('generates a salt', () {
      final random = _MockRandom();
      when(() => random.nextInt(any())).thenReturn(42);

      final salt = generateSalt(random: random);
      expect(salt, equals(180388626474));

      verify(() => random.nextInt(pow(2, 32) as int)).called(2);
    });

    test('generates a salt with a seed', () {
      final salt = generateSalt(seed: 1337);
      // ignore: avoid_js_rounded_ints
      expect(salt, equals(7069807611553583506));
    });
  });
}
