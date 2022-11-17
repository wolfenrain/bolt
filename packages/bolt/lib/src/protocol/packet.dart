import 'package:bolt/bolt.dart';

/// {@template packet}
/// A packet that was received from the network.
/// {@endtemplate}
class Packet<T> {
  /// {@macro packet}
  Packet(this.address, this.data);

  /// The address of the packet.
  final Address address;

  /// The data of the packet.
  final T data;
}
