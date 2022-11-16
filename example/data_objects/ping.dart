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
    registry.register(100, Ping.new, _Resolver.new);
  }
}

class _Resolver extends DataResolver<Ping> implements Ping {
  _Resolver(super.data);

  @override
  dynamic positionalArgument(int index) {
    switch (index) {
      case 0:
        return data.timestamp;
    }
  }
}
