import 'package:bolt/bolt.dart';

/// {@template packet}
/// A packet that was received from the network.
/// {@endtemplate}
class Packet {
  /// {@macro packet}
  Packet(this.address, this.data);

  /// The data of the packet.
  final DataObject data;

  /// The address of the packet.
  final Address address;
}
