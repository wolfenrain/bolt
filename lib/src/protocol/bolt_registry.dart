import 'package:bolt/bolt.dart';
import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:bolt/src/protocol/data_serializer.dart';
import 'package:collection/collection.dart';

/// {@template bolt_registry}
/// A registry for [DataSerializer]s, [DataObject]s, and [PayloadType]s.
/// {@endtemplate}
class BoltRegistry {
  /// {@macro bolt_registry}
  BoltRegistry() {
    _addSerializer(1, ConnectionRequest.new, ConnectionRequestResolver.new);
    _addSerializer(2, Challenge.new, ChallengeResolver.new);
    _addSerializer(3, ChallengeResponse.new, ChallengeResponseResolver.new);
    _addSerializer(4, ConnectionAccepted.new, ConnectionAcceptedResolver.new);
    _addSerializer(5, ConnectionDenied.new, ConnectionDeniedResolver.new);
    _addSerializer(6, Disconnect.new, DisconnectResolver.new);
  }

  /// Register a data object of type [T].
  ///
  /// This will allow the [DataResolver] class to serialize and deserialize the
  /// data.
  void register<T extends DataObject, V extends DataResolver<T>>(
    int id,
    Function factory,
    Resolver<T, V> resolver, {
    List<RegisteredPayload<dynamic>> payloadTypes = const [],
  }) {
    if (id < 100) {
      throw Exception('Data object ID $id is reserved');
    }

    final serializer = getSerializerById(id);
    // Only register unique schema ids
    if (serializer != null) {
      throw Exception(
        '''Data object $T tried to register with id $id, but that id is already registered to ${serializer.name}''',
      );
    }

    _addSerializer<T, V>(id, factory, resolver, payloadTypes: payloadTypes);
  }

  /// Register a global [PayloadType] for a specific type.
  void registerPayloadType<T>(PayloadType<T> type) {
    _payloadTypes.add(RegisteredPayload<T>(type));
  }

  /// The payload types that are available for the data objects. These are used
  /// to convert the data objects to binary data and back.
  ///
  /// You can add your own payload types by using [registerPayloadType] or by
  /// passing custom ones for your data objects when registering them.
  List<RegisteredPayload<dynamic>> get payloadTypes =>
      UnmodifiableListView(_payloadTypes);

  final List<RegisteredPayload<dynamic>> _payloadTypes = [
    const RegisteredPayload<String>(string32),
    const RegisteredPayload<int>(int64),
    const RegisteredPayload<double>(float64),
  ];

  /// Get a serializer by generics [T] and [V].
  DataSerializer<T, V>
      getSerializer<T extends DataObject, V extends DataResolver<T>>() {
    return _serializers.whereType<DataSerializer<T, V>>().first;
  }

  /// Get a serializer by the given [id].
  DataSerializer<T, V>?
      getSerializerById<T extends DataObject, V extends DataResolver<T>>(
    int id,
  ) {
    return _serializers.firstWhereOrNull(
      (serializer) => serializer.id == id,
    ) as DataSerializer<T, V>?;
  }

  /// Add a new serializer.
  void _addSerializer<T extends DataObject, V extends DataResolver<T>>(
    int id,
    Function factory,
    Resolver<T, V> resolver, {
    List<RegisteredPayload<dynamic>> payloadTypes = const [],
  }) {
    _serializers.add(
      DataSerializer<T, V>(
        id,
        factory,
        resolver,
        payloadTypes: payloadTypes,
        registry: this,
      ),
    );
  }

  final List<DataSerializer> _serializers = [];
}
