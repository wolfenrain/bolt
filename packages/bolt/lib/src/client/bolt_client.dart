import 'dart:async';

import 'package:bolt/bolt.dart';
import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:bolt/src/utils/utils.dart';
import 'package:meta/meta.dart';

/// {@template bolt_client}
/// A client for connecting to a server.
/// {@endtemplate}
abstract class BoltClient extends BoltProtocol {
  /// {@macro bolt_client}
  BoltClient({
    required BoltBinding binding,
    required this.server,
    super.logger,
  })  : _connectionStateController = StreamController.broadcast(),
        super(bindings: [binding]) {
    connectionState = _connectionStateController.stream;

    on(_challenge);
    on(_connectionAccepted);
    on(_connectionDenied);
  }

  /// The server address.
  final Address server;

  /// The current connection state of the client.
  late final Stream<ConnectionState> connectionState;
  final StreamController<ConnectionState> _connectionStateController;
  ConnectionState _state = ConnectionState.disconnected;
  ConnectionState get _connectionState => _state;
  set _connectionState(ConnectionState state) {
    _state = state;
    _connectionStateController.add(state);
  }

  /// The current connection state of the client.
  ConnectionState get currentConnectionState => _connectionState;

  final List<StreamSubscription<DataObject>> _subscriptions = [];
  final List<StreamSubscription<Acknowledged<DataObject>>> _ackSubscriptions =
      [];

  /// The connection's unique identifier.
  int? get id => _connectionId;
  int? _connectionId;

  Timer? _connectionTimeout;
  Timer? _stateRepeatTimer;

  int get _salt => _clientSalt == null || _serverSalt == null
      ? 0
      : (_clientSalt! ^ _serverSalt!);
  int? _clientSalt;
  int? _serverSalt;

  @override
  int retrieveSalt(Address address) => _salt;

  /// Called when the client is connected to the server.
  void onConnected() {}

  /// Called when the client is disconnected from the server.
  void onDisconnected() {}

  /// Sends [data] to the server.
  @mustCallSuper
  void send<T extends DataObject>(T data) => rawSend(data, server, _salt);

  /// Registers a callback for when a [DataObject] of type [T] is received.
  void on<T extends DataObject>(void Function(T data) callback) {
    _subscriptions.add(
      packets
          .where((packet) => packet.data is T)
          .map((packet) => packet.data as T)
          .listen(callback),
    );
  }

  /// Registers a callback for when an [Acknowledged] of a [DataObject] of type
  /// [T] is received.
  void onAck<T extends DataObject>(
    void Function(Acknowledged<T> data) callback,
  ) {
    _ackSubscriptions.add(
      acknowledgedPackets
          .where((ack) => ack.object is T)
          .map((ack) => ack.cast<T>())
          .listen(callback),
    );
  }

  /// Removes a callback for when a [DataObject] of type [T] is received.
  void off<T extends DataObject>(void Function(T message) callback) {
    for (final subscription
        in _subscriptions.whereType<StreamSubscription<T>>()) {
      if (subscription.onData == callback) {
        subscription.cancel();
        _subscriptions.remove(subscription);
        break;
      }
    }
  }

  /// Removes a callback for when an [Acknowledged] of a [DataObject] of type
  /// [T] is received.
  void offAck<T extends DataObject>(
    void Function(Acknowledged<T> data) callback,
  ) {
    for (final subscription
        in _ackSubscriptions.whereType<StreamSubscription<Acknowledged<T>>>()) {
      if (subscription.onData == callback) {
        subscription.cancel();
        _ackSubscriptions.remove(subscription);
        break;
      }
    }
  }

  @override
  Future<void> disconnect() async {
    logger.detail('Disconnecting from server');
    for (var i = 0; i < 10; i++) {
      send(Disconnect());
    }
    _cleanup();
    return super.disconnect();
  }

  @override
  void rawSend<T extends DataObject, V extends DataResolver<T>>(
    T object,
    Address address, [
    int salt = 0,
  ]) {
    if (_connectionState == ConnectionState.disconnected) {
      return logger.warn('Cannot send data when disconnected');
    }
    return super.rawSend(object, address, salt);
  }

  /// Connects to the [server].
  @mustCallSuper
  Future<void> connect(String token) async {
    await bind();
    _clientSalt = generateSalt();

    packets.listen((packet) {
      _connectionTimeout?.cancel();
      _connectionTimeout = Timer(const Duration(seconds: 5), () {
        logger.detail('Connection timed out');
        _cleanup();
      });
    });

    _connectionState = ConnectionState.sendingConnectionRequest;
    _connectionTimeout = Timer(const Duration(seconds: 5), () {
      if (_connectionState == ConnectionState.sendingConnectionRequest) {
        logger.detail('Connection timed out');
        _cleanup();
      }
    });
    _repeatSendingState(token);
  }

  void _repeatSendingState(String token) {
    switch (_connectionState) {
      case ConnectionState.sendingConnectionRequest:
        rawSend(
          ConnectionRequest(token: token, clientSalt: _clientSalt!),
          server,
        );
        break;
      case ConnectionState.sendingChallengeResponse:
        rawSend(ChallengeResponse(result: _salt), server);
        break;
      case ConnectionState.connected:
        _stateRepeatTimer?.cancel();
        return _stateRepeatTimer = null;
      case ConnectionState.disconnected:
        break;
    }

    _stateRepeatTimer = Timer(
      const Duration(milliseconds: 100),
      () => _repeatSendingState(token),
    );
  }

  void _challenge(Challenge data) {
    if (_connectionState != ConnectionState.sendingConnectionRequest) return;

    _connectionState = ConnectionState.sendingChallengeResponse;
    _serverSalt = data.serverSalt;
    rawSend(ChallengeResponse(result: _salt), server);
  }

  void _connectionAccepted(ConnectionAccepted data) {
    if (_connectionState != ConnectionState.sendingChallengeResponse) return;

    logger.detail('Connected to server, connection id: ${data.connectionId}');
    _connectionId = data.connectionId;

    _connectionState = ConnectionState.connected;

    // Remove all start up listeners.
    off(_challenge);
    off(_connectionAccepted);
    off(_connectionDenied);

    // Add listeners for the rest of the connection.
    on(_disconnect);

    onConnected();
  }

  void _connectionDenied(ConnectionDenied data) {
    logger.detail('Connection denied');
    _cleanup();
  }

  void _disconnect(Disconnect data) {
    logger.detail('Disconnected from server');
    _cleanup();
  }

  void _cleanup() {
    _connectionState = ConnectionState.disconnected;
    _clientSalt = null;
    _serverSalt = null;
    _connectionId = null;
    _connectionTimeout?.cancel();
    _connectionTimeout = null;
    _stateRepeatTimer?.cancel();
    _stateRepeatTimer = null;

    // Remove all start up listeners.
    off(_challenge);
    off(_connectionAccepted);
    off(_connectionDenied);

    onDisconnected();
  }
}

/// The connection state of the client.
enum ConnectionState {
  /// The client is not connected to a server.
  disconnected,

  /// The client is attempting to connect to a server.
  sendingConnectionRequest,

  /// The client is attempting to respond to a challenge from the server.
  sendingChallengeResponse,

  /// The client is connected to a server.
  connected,
}
