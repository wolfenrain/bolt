import 'package:bolt/bolt.dart';

/// {@template pong}
/// Sent by the server to the client to respond to a ping.
/// {@endtemplate}
class Pong extends DataObject {
  /// {@macro pong}
  const Pong({
    required this.timestamp,
  });

  /// The timestamp of the ping.
  final int timestamp;

  @override
  List<Object?> get props => [timestamp];

  /// Registers this data class.
  static void register(BoltRegistry registry) {
    registry.registerObject(
      101,
      DataResolver<Pong>(Pong.new, [
        Argument.named((d) => d.timestamp, type: uint32, name: #timestamp),
      ]),
    );
  }
}
