import 'dart:async';
import 'dart:io';

import 'package:bolt/bolt.dart';

/// {@template web_socket_server_binding}
/// A binding that uses web sockets to send and receive packets.
///
/// This binding is used by the server.
/// {@endtemplate}
class WebSocketServerBinding extends BoltBinding {
  /// {@macro web_socket_server_binding}
  WebSocketServerBinding(
    this.address, {
    super.logger,
  }) : _packetController = StreamController.broadcast();

  /// The address to bind to.
  final Address address;

  @override
  Stream<Packet<List<int>>> get rawPackets => _packetController.stream;
  final StreamController<Packet<List<int>>> _packetController;

  HttpServer? _server;

  final Map<Address, WebSocket> _sockets = {};

  @override
  Future<void> bind() async {
    if (_server != null) return;

    _server = await HttpServer.bind(address.host, address.port);
    logger.detail('Listening on ${_server!.address.address}:${_server!.port}');

    _server!.listen((request) async {
      if (request.uri.path != '/') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final address = Address(
        request.connectionInfo!.remoteAddress.address,
        request.connectionInfo!.remotePort,
      );
      final socket = await WebSocketTransformer.upgrade(request);
      _sockets[address] = socket;
      socket.listen(
        (data) {
          if (data is String) return logger.warn('Received string data');
          _packetController.add(Packet(address, data as List<int>));
        },
        onDone: () {
          _sockets.remove(address);
          socket.close();
        },
      );
    });
  }

  @override
  Future<void> unbind() async {
    await _server?.close();
    _server = null;
  }

  @override
  void send(List<int> data, Address address) {
    if (!_sockets.containsKey(address)) return;
    _sockets[address]!.add(data);
  }

  @override
  bool isAwareOff(Address address) => _sockets.containsKey(address);
}
