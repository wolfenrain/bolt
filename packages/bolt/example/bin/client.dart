import 'package:bolt/bolt.dart';
import 'package:bolt/client.dart';
import 'package:bolt_udp_binding/bolt_udp_binding.dart';
import 'package:example/example.dart';

class ExampleClient extends BoltClient {
  ExampleClient(
    Address address, {
    super.logger,
  }) : super(
          binding: UdpBinding(address, logger: logger),
          server: const Address('0.0.0.0', 5555),
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
  final client = ExampleClient(const Address('0.0.0.0', 7777));
  await client.connect('super_secure_token');

  client.logger.info('Client started!');
}
