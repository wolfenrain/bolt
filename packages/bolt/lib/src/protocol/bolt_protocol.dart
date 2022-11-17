import 'dart:async';

import 'package:async/async.dart';
import 'package:bolt/bolt.dart';
import 'package:bolt/src/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// {@template bolt_protocol}
/// The underlying protocol for Bolt that can send and receive [DataObject]s.
///
/// Right now it uses UDP directly, this should be doen through provides
/// bindings.
/// {@endtemplate}
abstract class BoltProtocol {
  /// {@macro bolt_protocol}
  BoltProtocol({
    Logger? logger,
    this.protocolVersion = 1,
    required List<BoltBinding> bindings,
  })  : _bindings = bindings,
        _packetsController = StreamController.broadcast(),
        _acknowledgedPacketController = StreamController.broadcast(),
        logger = logger ?? Logger() {
    packets = _packetsController.stream;
    acknowledgedPackets = _acknowledgedPacketController.stream;
    _rawPackets = StreamGroup.merge(_bindings.map((b) => b.rawPackets));
  }

  /// The registry that holds all the data objects serializers and payload
  /// types.
  final BoltRegistry registry = BoltRegistry();

  /// The logger to use.
  final Logger logger;

  /// The version of the protocol, this is used to determine if the client and
  /// server are compatible.
  final int protocolVersion;

  /// Stream of packets received from the other end.
  late final Stream<Packet<DataObject>> packets;
  final StreamController<Packet<DataObject>> _packetsController;

  /// Stream of packets that were acknowledged by the other end.
  late final Stream<Acknowledged<DataObject>> acknowledgedPackets;
  final StreamController<Acknowledged<DataObject>>
      _acknowledgedPacketController;

  final List<BoltBinding> _bindings;

  late final Stream<Packet<List<int>>> _rawPackets;
  StreamSubscription<Packet<List<int>>>? _packetsSubscription;

  /// The salt to use for a packet sent to [address].
  int retrieveSalt(Address address);

  /// Bind all the bindings.
  Future<void> bind() async {
    await Future.wait(_bindings.map((b) => b.bind()));

    _packetsSubscription = _rawPackets.listen((packet) {
      final data = _deserialize(packet.data, address: packet.address);
      if (data == null) return;
      logger.detail('Received data: $data from ${packet.address}');
      _packetsController.add(Packet(packet.address, data));
    });
  }

  /// Disconnect and unbind all the bindings.
  @mustCallSuper
  Future<void> disconnect() async {
    await _packetsSubscription?.cancel();
    _packetsSubscription = null;
    await Future.wait(_bindings.map((b) => b.unbind()));
  }

  /// Send a [DataObject] packet to the [address].
  @mustCallSuper
  void rawSend<T extends DataObject, V extends DataResolver<T>>(
    T object,
    Address address, [
    int salt = 0,
  ]) {
    logger.detail('Sending $object to $address');

    final data = _serialize<T, V>(object, saltCheck: salt, address: address);

    final binding = _bindings.firstWhereOrNull((b) => b.isAwareOff(address));
    if (binding == null) return;
    return binding.send(data, address);
  }

  final _packetsSendToAddress = <Address, SequenceBuffer<_SentPacketData>>{};
  final _packetsReceivedFromAddress =
      <Address, SequenceBuffer<_MessageReceivedData>>{};
  final _messagesSentToAddress = <Address, SequenceBuffer<_MessageSentData>>{};

  /// Serialize the data object into a binary data.
  List<int> _serialize<T extends DataObject, V extends DataResolver<T>>(
    T object, {
    required int saltCheck,
    required Address address,
  }) {
    if (!_packetsSendToAddress.containsKey(address)) {
      _packetsSendToAddress[address] =
          SequenceBuffer(1024, _SentPacketData.new);
    }
    if (!_packetsReceivedFromAddress.containsKey(address)) {
      _packetsReceivedFromAddress[address] =
          SequenceBuffer(1024, _MessageReceivedData.new);
    }
    if (!_messagesSentToAddress.containsKey(address)) {
      _messagesSentToAddress[address] =
          SequenceBuffer(1024, _MessageSentData.new);
    }
    final sentPackets = _packetsSendToAddress[address]!;
    final receivedPackets = _packetsReceivedFromAddress[address]!;
    final sentMessages = _messagesSentToAddress[address]!;

    final resolver = registry.getResolver<T>();
    final data = resolver.serialize(object);

    // The sequence number to use for this packet.
    final packetSequence = sentPackets.sequence;

    // Generate ack bits
    final ack = receivedPackets.sequence - 1;
    var ackBits = 0;
    for (var i = 0; i < 32; i++) {
      final sequence = ack - i;
      if (receivedPackets.find(sequence) != null) {
        ackBits |= 1 << i;
      }
    }

    // Insert ack entry
    final entry = sentPackets.insert(packetSequence);
    if (entry != null) {
      entry.acknowledged = false;
    }

    // Insert message entry
    final messageEntry = sentMessages.insert(packetSequence);
    if (messageEntry != null) {
      messageEntry
        ..timeSent = DateTime.now().millisecondsSinceEpoch
        ..object = object;
    }

    final writer = Payload.write()
      // Header
      ..set(uint16, protocolVersion)
      ..set(uint32, crc32(data))
      ..set(int64, saltCheck)
      ..set(uint16, packetSequence)
      ..set(uint16, ack)
      ..set(uint32, ackBits)

      // Data object
      ..set(uint8, registry.getIdOfResolver<T>())
      ..set(uint16, data.length)
      ..set(Bytes(data.length), data);

    // Inflate the data to 1024 bytes
    return List.filled(1024, 0)..setAll(0, binarize(writer));
  }

  /// Deserialize the data object from a binary data.
  DataObject? _deserialize(
    List<int> data, {
    required Address address,
  }) {
    if (!_packetsSendToAddress.containsKey(address)) {
      _packetsSendToAddress[address] =
          SequenceBuffer(1024, _SentPacketData.new);
    }
    if (!_packetsReceivedFromAddress.containsKey(address)) {
      _packetsReceivedFromAddress[address] =
          SequenceBuffer(1024, _MessageReceivedData.new);
    }
    if (!_messagesSentToAddress.containsKey(address)) {
      _messagesSentToAddress[address] =
          SequenceBuffer(1024, _MessageSentData.new);
    }
    final sentPackets = _packetsSendToAddress[address]!;
    final receivedPackets = _packetsReceivedFromAddress[address]!;
    final sentMessages = _messagesSentToAddress[address]!;

    if (data.length < 1024) {
      throw Exception('Packet is too small');
    }
    final reader = Payload.read(data);

    // Read header
    final protocolVersion = reader.get(uint16);
    final crc = reader.get(uint32);
    final receivedSalt = reader.get(int64);
    final packetSequence = reader.get(uint16);
    final ack = reader.get(uint16);
    var ackBits = reader.get(uint32);

    // Process acknowledgements
    for (var i = 0; i < 32; i++) {
      if (ackBits & 1 == 1) {
        final sequence = ack - i;
        final sentEntry = sentPackets.find(sequence);
        if (sentEntry != null && !sentEntry.acknowledged) {
          final messageEntry = sentMessages.find(sequence);
          if (messageEntry != null) {
            final time = DateTime.now().millisecondsSinceEpoch;
            final latency = time - messageEntry.timeSent;

            _acknowledgedPacketController.add(
              Acknowledged(address, messageEntry.object!, latency),
            );
          }
          sentEntry.acknowledged = true;
        }
      }
      ackBits >>= 1;
    }

    receivedPackets.insert(packetSequence);

    // Read data object
    final id = reader.get(uint8);
    final length = reader.get(uint16);
    final bytes = reader.get(Bytes(length));

    if (protocolVersion != this.protocolVersion) {
      throw Exception('Invalid protocol id: $protocolVersion');
    }

    // Invalid salt, ignore data
    if (receivedSalt != retrieveSalt(address)) return null;
    if (crc != crc32(bytes)) {
      throw Exception('CRC32 checksum failed');
    }

    return registry.getResolverById(id)?.deserialize(bytes);
  }
}

class _SentPacketData {
  bool acknowledged = false;
}

class _MessageSentData {
  int timeSent = 0;

  DataObject? object;
}

class _MessageReceivedData {}
