import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:bolt_websocket_binding/bolt_websocket_binding.dart';

import 'data_objects/data_objects.dart';

class ExampleServer extends BoltServer {
  ExampleServer(
    Address address, {
    super.logger,
  }) : super(bindings: [WebSocketServerBinding(address, logger: logger)]) {
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
  final server = ExampleServer(const Address('0.0.0.0', 5555));
  await server.start();

  server.logger.info('Server started!');
}
