import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';

/// {@template untyped_message}
/// A message received by the server.
/// {@endtemplate}
class UntypedMessage<T> {
  /// {@macro untyped_message}
  const UntypedMessage(this.connection, this.data);

  /// The connection that sent the message.
  final Connection connection;

  /// The data that was sent by the connection.
  final T data;
}

/// {@template message}
/// A message received by the server. The [data] is guaranteed to be of type
/// [T].
/// {@endtemplate}
class Message<T extends DataObject> extends UntypedMessage<T> {
  /// {@macro message}
  const Message(super.from, super.data);

  @override
  T get data => super.data;
}

/// {@template acknowledge_message}
/// A message received by the server that is an acknowledgement of a previous
/// message of type [T].
/// {@endtemplate}
class AcknowledgedMessage<T extends DataObject>
    extends UntypedMessage<Acknowledged<T>> {
  /// {@macro acknowledge_message}
  const AcknowledgedMessage(super.from, super.data);
}
