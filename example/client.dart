import 'package:bolt/bolt.dart';
import 'package:bolt/client.dart';

import 'data_objects/data_objects.dart';

class ExampleClient extends BoltClient {
  ExampleClient(super.address) : super(server: const Address('0.0.0.0', 5555));
}

Future<void> main() async {
  final client = ExampleClient(const Address('0.0.0.0', 7778));
  Ping.register(client.registry);
  Pong.register(client.registry);

  client.connectionState.listen((state) {
    switch (state) {
      case ConnectionState.disconnected:
        client.logger.info('Disconnected!');
        break;
      case ConnectionState.sendingConnectionRequest:
        client.logger.info('Sending connection request...');
        break;
      case ConnectionState.sendingChallengeResponse:
        client.logger.info('Sending challenge response...');
        break;
      case ConnectionState.connected:
        client.logger.info('Connected, sending ping...');
        client.send(Ping(DateTime.now().millisecondsSinceEpoch));
        break;
    }
  });

  client.on((Pong pong) async {
    client.logger.info('Received pong from server!');
    await Future<void>.delayed(const Duration(seconds: 1));
    client.send(Ping(DateTime.now().millisecondsSinceEpoch));
  });

  await client.connect('super_secure_token');
  client.logger.info('Client started!');
}
