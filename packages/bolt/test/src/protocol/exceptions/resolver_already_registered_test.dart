import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  @override
  List<Object> get props => [];
}

void main() {
  group('ResolverAlreadyRegistered', () {
    late DataResolver<_TestDataObject> resolver;

    setUp(() {
      resolver = const DataResolver<_TestDataObject>(_TestDataObject.new, []);
    });

    test('can be instantiated', () {
      final exception =
          ResolverAlreadyRegistered<_TestDataObject>(100, resolver);

      expect(exception.id, equals(100));
      expect(exception.resolver, equals(resolver));
    });

    test('toString', () {
      final exception =
          ResolverAlreadyRegistered<_TestDataObject>(100, resolver);

      expect(
        exception.toString(),
        equals(
          '''Data object _TestDataObject tried to register with id 100, but that id is already registered to _TestDataObject''',
        ),
      );
    });
  });
}
