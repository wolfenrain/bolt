import 'package:bolt/bolt.dart';

/// {@template disconnect}
/// Sent by either the client or the server to disconnect from the other.
/// {@endtemplate}
class Disconnect extends DataObject {
  @override
  List<Object> get props => [];
}

/// {@template disconnect_resolver}
/// Resolver for [Disconnect]. Used internally.
/// {@endtemplate}
class DisconnectResolver extends DataResolver<Disconnect>
    implements Disconnect {
  /// {@macro disconnect_resolver}
  DisconnectResolver(super.data);
}
