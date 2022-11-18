import 'package:bolt/src/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  group('BitArray', () {
    test('can be instantiated', () {
      final bitArray = BitArray(1024);

      expect(bitArray.size, equals(1024));
      expect(bitArray.bytes, equals(128));
    });

    test('set and get a bit ', () {
      final bitArray = BitArray(1024)
        ..setBit(0)
        ..setBit(8)
        ..setBit(16);

      expect(bitArray.getBit(0), isTrue);
      expect(bitArray.getBit(8), isTrue);
      expect(bitArray.getBit(16), isTrue);

      expect(bitArray.getBit(1), isFalse);
      expect(bitArray.getBit(9), isFalse);
      expect(bitArray.getBit(17), isFalse);
    });

    test('clear a bit', () {
      final bitArray = BitArray(1024)
        ..setBit(0)
        ..setBit(8)
        ..setBit(16);

      expect(bitArray.getBit(0), isTrue);
      expect(bitArray.getBit(8), isTrue);
      expect(bitArray.getBit(16), isTrue);

      bitArray
        ..clearBit(0)
        ..clearBit(8)
        ..clearBit(16);

      expect(bitArray.getBit(0), isFalse);
      expect(bitArray.getBit(8), isFalse);
      expect(bitArray.getBit(16), isFalse);
    });
  });
}
