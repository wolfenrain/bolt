import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

void main() {
  group('ResolverIdReserved', () {
    test('can be instantiated', () {
      final exception = ResolverIdReserved(1);

      expect(exception.id, equals(1));
    });

    test('toString', () {
      final exception = ResolverIdReserved(1);

      expect(
        exception.toString(),
        equals('Data object ID 1 is reserved'),
      );
    });
  });
}
