import 'package:bolt/bolt.dart';

/// {@template connection_request}
/// Sent by the client to the server to request a connection.
/// {@endtemplate}
class ConnectionRequest extends DataObject {
  /// {@macro connection_request}
  const ConnectionRequest({
    required this.token,
    required this.clientSalt,
  });

  /// Private token used to authenticate the client.
  final String token;

  /// Random 64 bit number generated by the client.
  final int clientSalt;

  @override
  List<Object> get props => [token, clientSalt];
}

/// {@template connection_request_resolver}
/// Resolver for [ConnectionRequest]. Used internally.
/// {@endtemplate}
class ConnectionRequestResolver extends DataResolver<ConnectionRequest>
    implements ConnectionRequest {
  /// {@macro connection_request_resolver}
  ConnectionRequestResolver(super.data);

  @override
  dynamic namedArgument(Symbol name) {
    switch (name) {
      case #token:
        return data.token;
      case #clientSalt:
        return data.clientSalt;
    }
  }
}