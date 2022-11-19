// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  @override
  List<Object> get props => [];
}

void main() {
  group('BoltRegistry', () {
    test('can be instantiated', () {
      final registry = BoltRegistry();

      expect(
        registry.getResolverById(1),
        isA<DataResolver<ConnectionRequest>>(),
      );
      expect(registry.getResolverById(2), isA<DataResolver<Challenge>>());
      expect(
        registry.getResolverById(3),
        isA<DataResolver<ChallengeResponse>>(),
      );
      expect(
        registry.getResolverById(4),
        isA<DataResolver<ConnectionAccepted>>(),
      );
      expect(
        registry.getResolverById(5),
        isA<DataResolver<ConnectionDenied>>(),
      );
      expect(registry.getResolverById(6), isA<DataResolver<Disconnect>>());
      expect(registry.getResolverById(7), isNull);
    });

    group('registerObject', () {
      test('can register a data object', () {
        final registry = BoltRegistry()
          ..registerObject(
            100,
            DataResolver<_TestDataObject>(_TestDataObject.new, []),
          );

        expect(
          registry.getResolverById(100),
          isA<DataResolver<_TestDataObject>>(),
        );
      });

      test('throws exception if id is already registered', () {
        final registry = BoltRegistry()
          ..registerObject(
            100,
            DataResolver<_TestDataObject>(_TestDataObject.new, []),
          );

        expect(
          () => registry.registerObject(
            100,
            DataResolver<_TestDataObject>(_TestDataObject.new, []),
          ),
          throwsA(isA<ResolverAlreadyRegistered<_TestDataObject>>()),
        );
      });

      test('throws exception if id is reserved', () {
        final registry = BoltRegistry();

        expect(
          () => registry.registerObject(
            0,
            DataResolver<_TestDataObject>(_TestDataObject.new, []),
          ),
          throwsA(isA<ResolverIdReserved>()),
        );
      });
    });

    test('getResolver', () {
      final registry = BoltRegistry()
        ..registerObject(
          100,
          DataResolver<_TestDataObject>(_TestDataObject.new, []),
        );

      expect(
        registry.getResolver<_TestDataObject>(),
        isA<DataResolver<_TestDataObject>>(),
      );
    });

    test('getIdOfResolver', () {
      final registry = BoltRegistry()
        ..registerObject(
          100,
          DataResolver<_TestDataObject>(_TestDataObject.new, []),
        );

      expect(
        registry.getIdOfResolver<_TestDataObject>(),
        equals(100),
      );
    });
  });
}
