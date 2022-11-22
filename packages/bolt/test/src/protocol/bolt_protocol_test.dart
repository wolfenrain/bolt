// ignore_for_file: prefer_const_constructors

import 'dart:async';

import 'package:bolt/bolt.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _TestProtocol extends BoltProtocol {
  _TestProtocol({super.logger, required super.bindings, super.protocolVersion});

  @override
  int retrieveSalt(Address address) => 42;
}

class _TestDataObject extends DataObject {
  @override
  List<Object> get props => [];
}

class _FakeAddress extends Fake implements Address {}

class _MockLogger extends Mock implements Logger {}

class _MockBinding extends Mock implements BoltBinding {}

void main() {
  group('BoltProtocol', () {
    late Logger logger;
    late BoltBinding binding;
    late StreamController<Packet<List<int>>> rawPacketsController;
    late BoltProtocol protocol;

    setUp(() {
      logger = _MockLogger();

      binding = _MockBinding();

      rawPacketsController = StreamController<Packet<List<int>>>();
      when(() => binding.rawPackets).thenAnswer(
        (_) => rawPacketsController.stream,
      );
      when(() => binding.bind()).thenAnswer((_) async {});
      when(() => binding.unbind()).thenAnswer((_) async {});
      when(() => binding.isAwareOff(any())).thenReturn(true);

      protocol = _TestProtocol(
        logger: logger,
        bindings: [binding],
        protocolVersion: 1337,
      );

      protocol.registry.registerObject(
        100,
        DataResolver<_TestDataObject>(_TestDataObject.new, []),
      );
    });

    setUpAll(() {
      registerFallbackValue(_FakeAddress());
    });

    test('bind', () async {
      await protocol.bind();

      verify(() => binding.bind()).called(1);
      verify(() => binding.rawPackets).called(1);
    });

    test('disconnect', () async {
      final protocol = _TestProtocol(bindings: [binding]);

      await protocol.disconnect();

      verify(() => binding.unbind()).called(1);
    });

    group('sending packets', () {
      test('sends an object', () async {
        late var bytes = <int>[];
        when(() => binding.send(any(), any())).thenAnswer(
          (invocation) {
            bytes = invocation.positionalArguments[0] as List<int>;
          },
        );

        protocol.rawSend(_TestDataObject(), Address('127.0.0.1', 1337), 42);

        verify(
          () => binding.send(
            any(
              that: isA<List<int>>()
                  .having((p0) => p0.length, 'length', equals(1024)),
            ),
            Address('127.0.0.1', 1337),
          ),
        );

        final reader = Payload.read(bytes);
        expect(reader.get(uint16), equals(1337)); // Protocol version
        expect(reader.get(uint32), equals(0)); // CRC32
        expect(reader.get(uint64), equals(42)); // Salt check
        expect(reader.get(uint16), equals(0)); // Packet sequence
        expect(reader.get(uint16), equals(65535)); // Ack
        expect(reader.get(uint32), equals(0)); // Ack bits
        expect(reader.get(uint8), equals(100)); // Data id
        expect(reader.get(uint16), equals(0)); // Data length
      });

      test('sends object with list of acknowledges received objects', () async {
        await protocol.bind();

        const packetSequence = 100;

        final packet = createFakePacket(packetSequence: packetSequence);
        rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));
        await Future<void>.delayed(Duration.zero);

        late var bytes = <int>[];
        when(() => binding.send(any(), any())).thenAnswer(
          (invocation) {
            bytes = invocation.positionalArguments[0] as List<int>;
          },
        );

        protocol.rawSend(_TestDataObject(), Address('127.0.0.1', 1338), 42);

        verify(
          () => binding.send(
            any(
              that: isA<List<int>>()
                  .having((p0) => p0.length, 'length', equals(1024)),
            ),
            Address('127.0.0.1', 1338),
          ),
        );

        final reader = Payload.read(bytes);
        expect(reader.get(uint16), equals(1337)); // Protocol version
        expect(reader.get(uint32), equals(0)); // CRC32
        expect(reader.get(uint64), equals(42)); // Salt check
        expect(reader.get(uint16), equals(0)); // Packet sequence
        expect(reader.get(uint16), equals(packetSequence)); // Ack
        expect(reader.get(uint32), equals(1)); // Ack bits
        expect(reader.get(uint8), equals(100)); // Data id
        expect(reader.get(uint16), equals(0)); // Data length
      });
    });

    group('receiving packets', () {
      test('receives an object', () async {
        await protocol.bind();

        final packet = createFakePacket();
        rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));

        expect(
          protocol.packets,
          emitsInOrder(
            [equals(Packet(Address('127.0.0.1', 1338), _TestDataObject()))],
          ),
        );
      });

      test(
        'receives an object with acknowledgments of received objects',
        () async {
          await protocol.bind();

          protocol
            ..rawSend(_TestDataObject(), Address('127.0.0.1', 1338), 42)
            ..rawSend(_TestDataObject(), Address('127.0.0.1', 1338), 42);

          final packet = createFakePacket(ack: 1, acks: [true, true]);
          rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));
          await Future<void>.delayed(Duration.zero);

          expect(
            protocol.acknowledgedPackets,
            emitsInOrder([
              equals(90),
            ]),
          );
        },
      );

      test('logs an error if the packet is not sized incorrectly', () async {
        await protocol.bind();

        final packet = [...createFakePacket(), 0];
        rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));
        await Future<void>.delayed(Duration.zero);

        verify(
          () => logger.err(
            any(that: contains('Received packet with invalid length: 1025')),
          ),
        ).called(1);
      });

      test('logs an error if the protocol version is wrong', () async {
        await protocol.bind();

        final packet = createFakePacket(protocolVersion: 1338);
        rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));
        await Future<void>.delayed(Duration.zero);

        verify(
          () => logger.err(any(that: contains('Invalid protocol id: 1338'))),
        ).called(1);
      });

      test('logs an error if the CRC checksum is wrong', () async {
        await protocol.bind();

        final packet = createFakePacket(crc32: 1338);
        rawPacketsController.add(Packet(Address('127.0.0.1', 1338), packet));
        await Future<void>.delayed(Duration.zero);

        verify(
          () => logger.err(any(that: contains('CRC32 checksum failed'))),
        ).called(1);
      });
    });
  });
}

List<int> createFakePacket({
  int protocolVersion = 1337,
  int crc32 = 0,
  int saltCheck = 42,
  int packetSequence = 0,
  int ack = 0,
  int dataId = 100,
  int dataLength = 0,
  List<bool> acks = const [],
}) {
  var ackBits = 0;
  for (var i = 0; i < 32; i++) {
    final sequence = ack - i;

    if (acks.length > i && acks[i]) {
      ackBits |= 1 << i;
    }
  }

  final writer = Payload.write()
    ..set(uint16, protocolVersion) // Protocol version
    ..set(uint32, crc32) // CRC32
    ..set(uint64, saltCheck) // Salt check
    ..set(uint16, packetSequence) // Packet sequence
    ..set(uint16, ack) // Ack
    ..set(uint32, ackBits) // Ack bits
    ..set(uint8, dataId) // Data id
    ..set(uint16, dataLength); // Data length

  return List.filled(1024, 0)..setAll(0, binarize(writer));
}
