import 'package:bolt/bolt.dart';
import 'package:bolt/client.dart';
import 'package:bolt_websocket_binding/bolt_websocket_binding.dart';
import 'package:example/example.dart';

class ExampleClient extends BoltClient {
  ExampleClient(
    Address server, {
    super.logger,
  }) : super(
          binding: WebSocketClientBinding(server, logger: logger),
          server: server,
        ) {
    Ping.register(registry);
    Pong.register(registry);

    on(_onPong);
  }

  @override
  void onConnected() {
    logger.info('Connected, sending ping...');
    send(Ping(DateTime.now().millisecondsSinceEpoch));
  }

  @override
  void onDisconnected() {
    logger.info('Disconnected!');

    off(_onPong);
  }

  Future<void> _onPong(Pong pong) async {
    logger.info('Received pong from server!');
    await Future<void>.delayed(const Duration(seconds: 1));
    send(Ping(DateTime.now().millisecondsSinceEpoch));
  }
}

Future<void> main() async {
  final client = ExampleClient(const Address('0.0.0.0', 5556));
  await client.connect('super_secure_token');

  client.logger.info('Client started!');
}
