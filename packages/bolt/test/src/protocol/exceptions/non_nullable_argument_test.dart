import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

void main() {
  group('NonNullableArgument', () {
    test('can be instantiated', () {
      final exception = NonNullableArgument<DataObject>(#argument);

      expect(exception.name, equals(#argument));
    });

    test('toString', () {
      final exception = NonNullableArgument<DataObject>(#argument);

      expect(
        exception.toString(),
        equals('''
Tried to retrieve field "argument" of DataObject, which is not nullable but it returned null

Did you forget to wrap the payload type in "nullable"?'''),
      );
    });
  });
}
