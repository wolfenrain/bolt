import 'package:bolt/bolt.dart';
import 'package:bolt/src/protocol/data_objects/data_objects.dart';

/// {@template bolt_registry}
/// A registry for [DataResolver]s.
/// {@endtemplate}
class BoltRegistry {
  /// {@macro bolt_registry}
  BoltRegistry() {
    _resolvers[1] = DataResolver<ConnectionRequest>(ConnectionRequest.new, [
      Argument.named((d) => d.token, type: string16, name: #token),
      Argument.named((d) => d.clientSalt, type: uint64, name: #clientSalt),
    ]);
    _resolvers[2] = DataResolver<Challenge>(Challenge.new, [
      Argument.named((d) => d.clientSalt, type: uint64, name: #clientSalt),
      Argument.named((d) => d.serverSalt, type: uint64, name: #serverSalt),
    ]);
    _resolvers[3] = DataResolver<ChallengeResponse>(ChallengeResponse.new, [
      Argument.named((d) => d.result, type: uint64, name: #result),
    ]);
    _resolvers[4] = DataResolver<ConnectionAccepted>(ConnectionAccepted.new, [
      Argument.named((d) => d.connectionId, type: uint16, name: #connectionId),
    ]);
    _resolvers[5] = const DataResolver<ConnectionDenied>(ConnectionDenied.new);
    _resolvers[6] = const DataResolver<Disconnect>(Disconnect.new);
  }

  /// Register a data object of type [T].
  ///
  /// This will allow the [DataResolver] class to serialize and deserialize the
  /// data.
  void registerObject<T extends DataObject>(int id, DataResolver<T> resolver) {
    if (id < 100) {
      throw Exception('Data object ID $id is reserved');
    }

    final existingResolver = getResolverById(id);
    // Only register unique schema ids
    if (existingResolver != null) {
      throw Exception(
        '''Data object $T tried to register with id $id, but that id is already registered to ${existingResolver.name}''',
      );
    }
    _resolvers[id] = resolver;
  }

  /// Get a resolver by type.
  DataResolver<T> getResolver<T extends DataObject>() {
    return _resolvers.values.firstWhere((e) => e is DataResolver<T>)
        as DataResolver<T>;
  }

  /// Get a resolver by the given [id].
  DataResolver<T>? getResolverById<T extends DataObject>(int id) {
    return _resolvers[id] as DataResolver<T>?;
  }

  /// Get the id of a resolver by type.
  int getIdOfResolver<T extends DataObject>() {
    return _resolvers.entries.firstWhere((e) => e.value is DataResolver<T>).key;
  }

  late final Map<int, DataResolver<dynamic>> _resolvers = {};
}
