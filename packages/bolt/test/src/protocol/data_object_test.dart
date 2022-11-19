import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  @override
  List<Object?> get props => [];
}

void main() {
  group('DataObject', () {
    test('can be instantiated', () {
      final dataObject = _TestDataObject();

      expect(dataObject, isNotNull);
    });
  });
}
