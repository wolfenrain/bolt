import 'package:bolt/bolt.dart';

/// {@template ping}
/// Sent by the client to the server to check if the connection is still alive.
/// {@endtemplate}
class Ping extends DataObject {
  /// {@macro ping}
  const Ping(this.timestamp);

  /// The timestamp of the ping.
  final int timestamp;

  @override
  List<Object?> get props => [timestamp];

  /// Registers this data class.
  static void register(BoltRegistry registry) {
    registry.registerObject(
      100,
      DataResolver<Ping>(Ping.new, [
        Argument.positional((d) => d.timestamp, type: uint32),
      ]),
    );
  }
}
