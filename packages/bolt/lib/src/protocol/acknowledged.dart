import 'package:bolt/bolt.dart';

/// {@template acknowledged}
/// A acknowledged data object that was previously sent to a connection.
/// {@endtemplate}
class Acknowledged<T extends DataObject> {
  /// {@macro acknowledged}
  const Acknowledged(this.address, this.object, this.latency);

  /// The address of the connection that sent the acknowledgement.
  final Address address;

  /// The data object that was acknowledged.
  final T object;

  /// The latency between sending the data object and receiving the
  /// acknowledgement.
  final int latency;

  /// Casts the acknowledged data object to a different type.
  Acknowledged<V> cast<V extends DataObject>() {
    return Acknowledged<V>(address, object as V, latency);
  }
}
