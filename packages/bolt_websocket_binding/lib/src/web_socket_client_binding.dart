import 'dart:async';

import 'package:bolt/bolt.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// {@template web_socket_client_binding}
/// A binding that uses web sockets to send and receive packets.
///
/// This binding is used by the client.
/// {@endtemplate}
class WebSocketClientBinding extends BoltBinding {
  /// {@macro web_socket_client_binding}
  WebSocketClientBinding(
    this.server, {
    super.logger,
  }) : _packetController = StreamController.broadcast();

  /// The server to connect to.
  final Address server;

  @override
  Stream<Packet<List<int>>> get rawPackets => _packetController.stream;
  final StreamController<Packet<List<int>>> _packetController;

  WebSocketChannel? _webSocket;

  @override
  Future<void> bind() async {
    if (_webSocket != null) return;

    _webSocket = WebSocketChannel.connect(
      Uri.parse('ws://${server.host}:${server.port}'),
    );

    _webSocket!.stream.listen(
      (data) {
        if (data is String) return logger.warn('Received string data');
        _packetController.add(Packet(server, data as List<int>));
      },
      onDone: () {
        _webSocket?.sink.close();
        _webSocket = null;
      },
    );
  }

  @override
  Future<void> unbind() async {
    await _webSocket?.sink.close();
    _webSocket = null;
  }

  @override
  void send(List<int> data, Address address) {
    _webSocket?.sink.add(data);
  }

  @override
  bool isAwareOff(Address address) => address == server;
}
