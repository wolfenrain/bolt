// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  const _TestDataObject(this.value, {required this.otherValue});

  final int value;

  final double? otherValue;

  @override
  List<Object?> get props => [value, otherValue];
}

void main() {
  group('DataResolver', () {
    late DataResolver<_TestDataObject> dataResolver;

    setUp(() {
      dataResolver = DataResolver<_TestDataObject>(_TestDataObject.new, [
        Argument<_TestDataObject, int>.positional(
          (d) => d.value,
          type: uint32,
        ),
        Argument<_TestDataObject, double?>.named(
          (d) => d.otherValue,
          type: float64,
          name: #otherValue,
        ),
      ]);
    });

    test('name', () {
      expect(dataResolver.name, equals('_TestDataObject'));
    });

    group('serialize', () {
      test('correctly', () {
        final dataObject = _TestDataObject(42, otherValue: 3.14);
        final buffer = dataResolver.serialize(dataObject);

        expect(buffer, equals([0, 0, 0, 42, 64, 9, 30, 184, 81, 235, 133, 31]));
      });

      test('throws exception if value is null and argument is not', () {
        final dataObject = _TestDataObject(42, otherValue: null);

        expect(
          () => dataResolver.serialize(dataObject),
          throwsA(isA<NonNullableArgument<_TestDataObject>>()),
        );
      });
    });

    group('deserialize', () {
      test('correctly', () {
        final buffer = [0, 0, 0, 42, 64, 9, 30, 184, 81, 235, 133, 31];
        final dataObject = dataResolver.deserialize(buffer);

        expect(dataObject, equals(_TestDataObject(42, otherValue: 3.14)));
      });
    });
  });

  group('Argument', () {
    late _TestDataObject dataObject;

    setUp(() {
      dataObject = _TestDataObject(1, otherValue: 2.5);
    });

    test('positional', () {
      final argument = Argument<_TestDataObject, int>.positional(
        (d) => d.value,
        type: uint32,
      );

      expect(argument.type, equals(uint32));
      expect(argument.name, isNull);
      expect(argument.from(dataObject), equals(1));
    });

    test('named', () {
      final argument = Argument<_TestDataObject, double?>.named(
        (d) => d.otherValue,
        type: float64,
        name: #otherValue,
      );

      expect(argument.type, equals(float64));
      expect(argument.name, equals(#otherValue));
      expect(argument.from(dataObject), equals(2.5));
    });

    test('isNullable', () {
      final nullableArgument = Argument<_TestDataObject, double?>.named(
        (d) => d.otherValue,
        type: nullable(float64),
        name: #otherValue,
      );

      final nonNullableArgument = Argument<_TestDataObject, int>.positional(
        (d) => d.value,
        type: uint32,
      );

      expect(nullableArgument.isNullable, isTrue);
      expect(nonNullableArgument.isNullable, isFalse);
    });
  });
}
