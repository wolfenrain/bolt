import 'package:bolt/bolt.dart';

/// {@template bolt_binding}
/// Defines a communication protocol for Bolt. This is used to define through
/// which protocol packets are sent and received.
/// {@endtemplate}
abstract class BoltBinding {
  /// {@macro bolt_binding}
  BoltBinding({
    Logger? logger,
  }) : logger = logger ?? Logger();

  /// The logger to use.
  final Logger logger;

  /// Stream of raw packets received by the other end.
  Stream<Packet<List<int>>> get rawPackets;

  /// Bind the binding.
  Future<void> bind();

  /// Disconnect the binding.
  Future<void> unbind();

  /// Send [data] to [address].
  void send(List<int> data, Address address);

  /// Whether the binding is aware of [address].
  ///
  /// This is used to determine if a packet should be sent to [address] or not
  /// through this binding.
  bool isAwareOff(Address address);
}
