// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  @override
  List<Object> get props => [];
}

void main() {
  group('Acknowledged', () {
    late _TestDataObject dataObject;
    late Address address;

    setUp(() {
      address = Address('127.0.0.1', 1234);
      dataObject = _TestDataObject();
    });

    test('can be instantiated', () {
      final acknowledged = Acknowledged(address, dataObject, 0);

      expect(acknowledged.address, equals(address));
      expect(acknowledged.object, equals(dataObject));
      expect(acknowledged.latency, equals(0));
    });

    test('can be casted', () {
      final acknowledged = Acknowledged<DataObject>(address, dataObject, 0);
      final casted = acknowledged.cast<_TestDataObject>();

      expect(acknowledged, isA<Acknowledged<DataObject>>());
      expect(casted, isA<Acknowledged<_TestDataObject>>());
    });
  });
}
