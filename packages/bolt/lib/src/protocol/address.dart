import 'package:equatable/equatable.dart';

/// {@template address}
/// An address that holds an [host] and a [port].
/// {@endtemplate}
class Address extends Equatable {
  /// {@macro address}
  const Address(this.host, this.port);

  /// The numeric address of the host.
  ///
  /// For IPv4 addresses this is using the dotted-decimal notation.
  /// For IPv6 it is using the hexadecimal representation.
  /// For Unix domain addresses, this is a file path.
  final String host;

  /// The port of the address.
  final int port;

  @override
  List<Object?> get props => [host, port];

  @override
  String toString() => '$host:$port';
}
