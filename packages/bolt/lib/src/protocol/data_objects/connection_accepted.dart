import 'package:bolt/bolt.dart';

/// {@template connection_accepted}
/// Sent by the server to the client after a challenge was resolved correctly
/// through a challenge response.
/// {@endtemplate}
class ConnectionAccepted extends DataObject {
  /// {@macro connection_accepted}
  const ConnectionAccepted({
    required this.connectionId,
  });

  /// The connection id assigned by the server.
  final int connectionId;

  @override
  List<Object> get props => [connectionId];
}
