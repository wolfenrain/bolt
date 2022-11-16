import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';

import 'data_objects/data_objects.dart';

class ExampleServer extends BoltServer {
  ExampleServer(super.address);

  @override
  Future<bool> verifyAuth(Connection connection, String token) async {
    return token == 'super_secure_token';
  }
}

Future<void> main() async {
  final server = ExampleServer(const Address('0.0.0.0', 5555));
  Ping.register(server.registry);
  Pong.register(server.registry);

  server.connected.listen((connection) {
    server.logger.info('New connection from ${connection.address}!');
  });

  server.disconnected.listen((connection) {
    server.logger.info('Connection from ${connection.address} disconnected!');
  });

  server.on((Message<Ping> message) {
    server.logger.info('Received ping from ${message.connection.address}!');
    server.send(Pong(timestamp: message.data.timestamp), message.connection);
  });

  await server.start();
  server.logger.info('Server started!');
}
