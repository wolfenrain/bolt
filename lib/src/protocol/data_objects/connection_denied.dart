import 'package:bolt/bolt.dart';

/// {@template connection_denied}
/// Sent by the server to the client if the client failed to resolve a
/// challenge.
/// {@endtemplate}
class ConnectionDenied extends DataObject {
  @override
  List<Object> get props => [];
}

/// {@template connection_denied_resolver}
/// Resolver for [ConnectionDenied]. Used internally.
/// {@endtemplate}
class ConnectionDeniedResolver extends DataResolver<ConnectionDenied>
    implements ConnectionDenied {
  /// {@macro connection_denied_resolver}
  ConnectionDeniedResolver(super.data);
}
