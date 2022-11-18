import 'package:bolt/src/utils/utils.dart';
import 'package:test/test.dart';

class _Data {}

void main() {
  group('SequenceBuffer', () {
    late SequenceBuffer sequenceBuffer;

    setUp(() {
      sequenceBuffer = SequenceBuffer(2, _Data.new);
    });

    test('can be instantiated', () {
      expect(sequenceBuffer.size, equals(2));
      expect(sequenceBuffer.sequence, equals(0));
    });

    test('insert', () {
      final sequenceBuffer = SequenceBuffer(2, _Data.new);

      final data1 = sequenceBuffer.insert(0);
      final data2 = sequenceBuffer.insert(1);
      final data3 = sequenceBuffer.insert(2);

      final data4 = sequenceBuffer.insert(0);

      expect(data1, isNotNull);
      expect(data2, isNotNull);
      expect(data3, isNotNull);
      expect(data1, equals(data3));
      expect(data1, isNot(equals(data2)));

      expect(data4, isNull);
    });

    test('remove', () {
      final sequenceBuffer = SequenceBuffer(2, _Data.new);

      final data1 = sequenceBuffer.insert(0);
      final data2 = sequenceBuffer.insert(1);

      sequenceBuffer
        ..remove(0)
        ..remove(1);

      final data4 = sequenceBuffer.insert(0);
      final data5 = sequenceBuffer.insert(1);

      expect(data1, isNotNull);
      expect(data2, isNotNull);

      expect(data4, isNotNull);
      expect(data5, isNotNull);
    });

    test('removeOldEntries', () {
      sequenceBuffer
        ..insert(0)
        ..insert(1)
        ..insert(3);

      expect(sequenceBuffer.find(0), isNotNull);

      sequenceBuffer.removeOldEntries();

      expect(sequenceBuffer.find(0), isNull);
      expect(sequenceBuffer.find(1), isNull);
      expect(sequenceBuffer.find(2), isNull);
      expect(sequenceBuffer.find(3), isNotNull);
    });

    test('isAvailable', () {
      final data1 = sequenceBuffer.insert(0);
      final data2 = sequenceBuffer.insert(1);

      expect(sequenceBuffer.isAvailable(0), isFalse);
      expect(sequenceBuffer.isAvailable(1), isFalse);
      expect(sequenceBuffer.isAvailable(2), isFalse);
      expect(sequenceBuffer.isAvailable(3), isFalse);

      sequenceBuffer.remove(0);

      expect(sequenceBuffer.isAvailable(0), isTrue);
    });

    test('getIndex', () {
      expect(sequenceBuffer.getIndex(105), equals(105 % 2));
    });

    test('find', () {
      final data1 = sequenceBuffer.insert(0);

      expect(sequenceBuffer.find(0), equals(data1));
      expect(sequenceBuffer.find(1), isNull);
    });

    test('getAtIndex', () {
      final data1 = sequenceBuffer.insert(0);
      final data2 = sequenceBuffer.insert(1);

      expect(sequenceBuffer.getAtIndex(0), equals(data1));
      expect(sequenceBuffer.getAtIndex(1), equals(data2));
    });
  });
}
