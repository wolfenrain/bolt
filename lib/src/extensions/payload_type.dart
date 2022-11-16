import 'package:bolt/bolt.dart';

/// Extension on [PayloadType].
extension PayloadTypeX<T> on PayloadType<T> {
  /// Register this [PayloadType] on the given [registry].
  void register(BoltRegistry registry) {
    registry.registerPayloadType<T>(this);
  }
}
