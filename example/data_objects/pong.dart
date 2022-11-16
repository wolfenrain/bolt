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
    registry.register(101, Pong.new, _Resolver.new);
  }
}

class _Resolver extends DataResolver<Pong> implements Pong {
  _Resolver(super.data);

  @override
  dynamic namedArgument(Symbol name) {
    switch (name) {
      case #timestamp:
        return data.timestamp;
    }
  }
}
