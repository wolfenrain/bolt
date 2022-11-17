import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:bolt_udp_binding/bolt_udp_binding.dart';
import 'package:bolt_websocket_binding/bolt_websocket_binding.dart';
import 'package:example/example.dart';

class ExampleServer extends BoltServer {
  ExampleServer(
    String host, {
    super.logger,
  }) : super(
          bindings: [
            UdpBinding(Address(host, 5555), logger: logger),
            WebSocketServerBinding(Address(host, 5556), logger: logger)
          ],
        ) {
    Ping.register(registry);
    Pong.register(registry);

    on(_onPinged);
  }

  @override
  void onConnected(Connection connection) {
    logger.info('New connection from ${connection.address}!');
  }

  @override
  void onDisconnected(Connection connection) {
    logger.info('Connection from ${connection.address} disconnected!');
  }

  void _onPinged(Message<Ping> message) {
    logger.info('Received ping from ${message.connection.address}!');
    send(Pong(timestamp: message.data.timestamp), message.connection);
  }

  @override
  Future<bool> verifyAuth(Connection connection, String token) async {
    return token == 'super_secure_token';
  }
}

Future<void> main() async {
  final server = ExampleServer('0.0.0.0');
  await server.start();

  server.logger.info('Server started!');
}
