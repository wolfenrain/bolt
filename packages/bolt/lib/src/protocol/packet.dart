import 'package:bolt/bolt.dart';
import 'package:equatable/equatable.dart';

/// {@template packet}
/// A packet that was received from the network.
/// {@endtemplate}
class Packet<T extends Object> extends Equatable {
  /// {@macro packet}
  const Packet(this.address, this.data);

  /// The address of the packet.
  final Address address;

  /// The data of the packet.
  final T data;

  @override
  List<Object> get props => [address, data];
}
