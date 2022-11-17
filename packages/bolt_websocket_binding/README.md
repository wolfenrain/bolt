<p align="center">
<img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/assets/bolt_full.png" height="320" alt="bolt logo" />
</p>

<h1 align="center">Provides bi-directional WebSocket Bindings for Bolt</h1>

<p align="center">
<a href="https://github.com/wolfenrain/bolt/tree/main/packages/bolt_websocket_binding"><img src="https://img.shields.io/pub/v/bolt_websocket_binding.svg" alt="pub package"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://github.com/wolfenrain/bolt/actions/workflows/main.yaml/badge.svg" alt="bolt"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

## Quick Start 🚀

### Prerequisites 📝

In order to start using the WebSocket bindings for Bolt you must have the [Dart SDK][dart_install_link] installed on your machine.

### Installing 🧑‍💻

Add `bolt_websocket_binding` to your `pubspec.yaml`:

```sh
# 📦 Install bolt_websocket_binding from pub.dev
dart pub add bolt_websocket_binding
```

### Add the binding to a Server 🏁

Add the `WebSocketServerBinding` to the list of bindings of your server:

```dart
import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:bolt_websocket_binding/bolt_websocket_binding.dart';

class ExampleServer extends BoltServer {
  ExampleServer(
    Address address, {
    super.logger,
  }) : super(bindings: [WebSocketServerBinding(address, logger: logger)]);

  ...

}
```

### Add the binding to a Client ✨

Pass the `WebSocketClientBinding` to the binding of your client:

```dart
import 'package:bolt/bolt.dart';
import 'package:bolt/client.dart';
import 'package:bolt_websocket_binding/bolt_websocket_binding.dart';

class ExampleClient extends BoltClient {
  ExampleClient({
    super.logger,
    required super.server,
  }) : super(binding: WebSocketClientBinding(server, logger: logger));

  ...

}
```

[dart_install_link]: https://dart.dev/get-dart
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis