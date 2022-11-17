import 'dart:async';

import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:bolt/src/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// Handler for messages sent by a [Connection].
typedef MessageHandler<T extends UntypedMessage<dynamic>> = FutureOr<void>
    Function(
  T message,
);

/// {@template bolt_server}
/// A server that listens for incoming [Connection]s.
/// {@endtemplate}
abstract class BoltServer extends BoltProtocol {
  /// {@macro bolt_server}
  BoltServer({
    required super.bindings,
    super.logger,
    this.maxConnections = 64,
  })  : _connections = List.filled(maxConnections, null),
        _confirmedConnections = List.filled(maxConnections, false),
        _connectedController = StreamController<Connection>.broadcast(),
        _disconnectedController = StreamController<Connection>.broadcast() {
    connected = _connectedController.stream;
    disconnected = _disconnectedController.stream;

    _serverSalt = generateSalt();

    on(_connectionRequest);
    on(_challengeResponse);
    on(_disconnect);
  }

  /// The maximum amount of connections that the server allows.
  final int maxConnections;

  late final int _serverSalt;

  final List<StreamSubscription<Message>> _subscriptions = [];
  final List<StreamSubscription<AcknowledgedMessage>> _ackSubscriptions = [];

  /// Stream of connections that have connected to the server.
  late final Stream<Connection> connected;
  final StreamController<Connection> _connectedController;

  /// Stream of connections that have disconnected from the server.
  late final Stream<Connection> disconnected;
  final StreamController<Connection> _disconnectedController;

  /// The connected connections.
  List<Connection> get connections => [..._connections.whereType<Connection>()];
  final List<Connection?> _connections;
  final List<bool> _confirmedConnections;
  final Map<Connection, Timer?> _connectionTimers = {};
  final List<Connection> _pendingConnections = [];

  @override
  int retrieveSalt(Address address) {
    return _findExistingConnection(address)?.salt ?? 0;
  }

  /// Called when a connection is connected to the server.
  void onConnected(Connection connection) {}

  /// Called when a connection is disconnected from the server.
  void onDisconnected(Connection connection) {}

  /// Sends [data] to a [connection].
  @mustCallSuper
  void send<T extends DataObject, V extends DataResolver<T>>(
    T data,
    Connection connection,
  ) {
    // If the connection is not yet confirmed, send a connection accepted
    // before sending the data.
    final index = _connections.indexOf(connection);
    if (index != -1 && !_confirmedConnections[index]) {
      rawSend(
        ConnectionAccepted(connectionId: index),
        connection.address,
        connection.salt,
      );
    }
    rawSend(data, connection.address, connection.salt);
  }

  /// Broadcasts [data] to all connections.
  ///
  /// If [exclude] is provided, the [data] will not be sent to that connection.
  @mustCallSuper
  void broadcast<T extends DataObject, V extends DataResolver<T>>(
    T data, {
    Connection? exclude,
  }) {
    for (final connection in connections) {
      if (connection == exclude) continue;
      send<T, V>(data, connection);
    }
  }

  /// Registers a handler for when a [Message] of type [T] is received from a
  /// connection.
  void on<T extends DataObject>(MessageHandler<Message<T>> handler) {
    _subscriptions.add(
      packets.where((packet) => packet.data is T).map((packet) {
        final connection = _findExistingConnection(packet.address) ??
            Connection(clientSalt: 0, serverSalt: 0, address: packet.address);

        // Check if the connection is known and confirmed, if it is known but
        // not confirmed set it to confirmed.
        final index = _connections.indexOf(connection);
        if (index != -1 && !_confirmedConnections[index]) {
          _confirmedConnections[index] = true;
        }
        return Message<T>(connection, packet.data as T);
      }).listen(handler),
    );
  }

  /// Registers a handler for when an [AcknowledgedMessage] of type [T] is
  /// received from a connection.
  void onAck<T extends DataObject>(
    MessageHandler<AcknowledgedMessage<T>> handler,
  ) {
    _ackSubscriptions.add(
      acknowledgedPackets.where((ack) => ack.object is T).map((ack) {
        final connection = _findExistingConnection(ack.address) ??
            Connection(clientSalt: 0, serverSalt: 0, address: ack.address);
        return AcknowledgedMessage<T>(connection, ack.cast<T>());
      }).listen(handler),
    );
  }

  /// Removes a handler for when a [Message] of type [T] is received from a
  /// connection.
  void off<T extends DataObject>(MessageHandler<Message<T>> handler) {
    for (final subscription
        in _subscriptions.whereType<StreamSubscription<Message<T>>>()) {
      if (subscription.onData == handler) {
        subscription.cancel();
        _subscriptions.remove(subscription);
        break;
      }
    }
  }

  /// Removes a handler for when an [AcknowledgedMessage] of type [T] is
  /// received from a connection.
  void offAck<T extends DataObject>(
    MessageHandler<AcknowledgedMessage<T>> handler,
  ) {
    for (final subscription in _ackSubscriptions
        .whereType<StreamSubscription<AcknowledgedMessage<T>>>()) {
      if (subscription.onData == handler) {
        subscription.cancel();
        _ackSubscriptions.remove(subscription);
        break;
      }
    }
  }

  /// Disconnects a connection.
  @mustCallSuper
  void disconnectConnection(Connection connection) {
    for (var i = 0; i < 10; i++) {
      send(Disconnect(), connection);
    }
    _cleanupConnection(connection);
  }

  /// Starts listening for incoming connections.
  @mustCallSuper
  Future<void> start() async {
    await bind();

    packets.listen((packet) {
      final connection = _findExistingConnection(packet.address) ??
          Connection(clientSalt: 0, serverSalt: 0, address: packet.address);
      if (_connectionTimers[connection] != null) {
        _connectionTimeout(connection);
      }
    });
  }

  /// Called when a connection request is received, to validate the
  /// authentication token.
  Future<bool> verifyAuth(Connection connection, String token);

  Future<void> _connectionRequest(Message<ConnectionRequest> message) async {
    final connection = _findExistingConnection(message.connection.address);

    // Existing connection.
    if (connection != null &&
        connection.clientSalt == message.data.clientSalt) {
      logger.detail('$connection reconnected');
      return send(
        ConnectionAccepted(connectionId: _connections.indexOf(connection)),
        connection,
      );
    }

    // If the token is invalid, disconnect the connection.
    if (!(await verifyAuth(message.connection, message.data.token))) {
      logger.detail('${message.connection} tried to connect, but was denied');
      return rawSend(ConnectionDenied(), message.connection.address);
    }

    // New connection, but we already have the maximum amount of connections.
    if (_connections.every((e) => e != null)) {
      logger.detail('${message.connection} tried to connect, but we are full');
      return rawSend(ConnectionDenied(), message.connection.address);
    }

    final pendingConnection = _pendingConnections.firstWhere(
      (connection) => connection.address == message.connection.address,
      orElse: () => Connection(
        clientSalt: message.data.clientSalt,
        serverSalt: _serverSalt,
        address: message.connection.address,
      ),
    );
    if (!_pendingConnections.contains(pendingConnection)) {
      _pendingConnections.add(pendingConnection);
    }

    return rawSend(
      Challenge(
        clientSalt: pendingConnection.clientSalt,
        serverSalt: pendingConnection.serverSalt,
      ),
      pendingConnection.address,
    );
  }

  void _challengeResponse(Message<ChallengeResponse> message) {
    final connection = _pendingConnections.firstWhereOrNull(
      (element) =>
          element.salt == message.data.result &&
          element.address == message.connection.address,
    );
    if (connection == null) {
      logger.detail(
        'Received a challenge response from ${message.connection} '
        'but no pending connection was found',
      );
      return rawSend(ConnectionDenied(), message.connection.address);
    }

    final int connectionId;
    if (_pendingConnections.contains(connection) &&
        !_connections.contains(connection)) {
      logger.detail('${message.connection} sent a valid challenge');
      _pendingConnections.remove(connection);

      connectionId = _connections.indexWhere((element) => element == null);
      if (connectionId == -1) {
        logger.detail('$connection tried to connect, but we are full');
        return rawSend(ConnectionDenied(), message.connection.address);
      }

      _connections[connectionId] = connection;
      _connectionTimeout(connection);
      logger.detail('$connection connected');
      _connectedController.add(connection);
      onConnected(connection);
    } else {
      connectionId = _connections.indexOf(connection);
    }

    return send(
      ConnectionAccepted(connectionId: connectionId),
      connection,
    );
  }

  void _disconnect(Message<Disconnect> message) {
    _cleanupConnection(message.connection);
  }

  Connection? _findExistingConnection(Address address) {
    return _connections.firstWhereOrNull(
      (element) => element?.address == address,
    );
  }

  void _cleanupConnection(Connection connection) {
    _connectionTimers[connection]?.cancel();
    _connectionTimers.remove(connection);

    final index = _connections.indexOf(connection);
    if (index != -1) {
      _connections[index] = null;
      _confirmedConnections[index] = false;

      _disconnectedController.add(connection);
      onDisconnected(connection);
    }
  }

  void _connectionTimeout(Connection connection) {
    _connectionTimers[connection]?.cancel();
    _connectionTimers[connection] = Timer(
      const Duration(seconds: 5),
      () => _onConnectionTimeout(connection),
    );
  }

  void _onConnectionTimeout(Connection connection) {
    logger.detail('$connection timed out');
    disconnectConnection(connection);
  }
}
