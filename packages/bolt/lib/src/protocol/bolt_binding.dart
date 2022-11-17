import 'package:bolt/bolt.dart';

/// {@template bolt_binding}
/// {@endtemplate}
abstract class BoltBinding {
  /// {@macro bolt_binding}
  BoltBinding({
    Logger? logger,
  }) : logger = logger ?? Logger();

  /// The logger to use.
  final Logger logger;

  /// Stream of packets received by the other end.
  Stream<Packet<List<int>>> get packets;

  /// Bind the binding.
  Future<void> bind();

  /// Disconnect the binding.
  Future<void> unbind();

  /// Send [data] to [address].
  void send(List<int> data, Address address);
}
