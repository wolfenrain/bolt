<p align="center">
<img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/assets/bolt_full.png" height="320" alt="bolt logo" />
</p>

<h1 align="center">Bolt is a network protocol to send and receive strongly typed data objects</h1>

<p align="center">
<a href="https://github.com/wolfenrain/bolt/tree/main/packages/bolt"><img src="https://img.shields.io/pub/v/bolt.svg" alt="pub package"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://github.com/wolfenrain/bolt/actions/workflows/main.yaml/badge.svg" alt="bolt"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

## Documentation 📝

For documentation about Bolt, see the [docs](https://github.com/wolfenrain/bolt/tree/main/docs) section.

An example of Bolt can be found in the [example](https://github.com/wolfenrain/bolt/tree/main/example) directory.

## Quick Start 🚀

### Prerequisites 📝

In order to start using Bolt you must have the [Dart SDK][dart_install_link] installed on your machine.

### Installing 🧑‍💻

Add `bolt` to your `pubspec.yaml`:

```sh
# 📦 Install bolt from pub.dev
dart pub add bolt
```

### Creating a shared Data Object 💿

Create a shared `DataObject` for the client and server:

```dart
class Ping extends DataObject {
  const Ping(this.timestamp);

  final int timestamp;

  @override
  List<Object?> get props => [timestamp];

  static void register(BoltRegistry registry) {
    registry.registerObject(
      100,
      DataResolver<Ping>(Ping.new, [
        Argument.positional<Ping, int>((d) => d.timestamp, type: uint32),
      ]),
    );
  }
}
```

### Creating a Server 🏁

Define a server, register the data object and listen to messages:

```dart
class ExampleServer extends BoltServer {
  ExampleServer(super.address, {required super.bindings}) {
    Ping.register(registry);

    on(_onPinged);
  }

  void _onPinged(Message<Ping> message) {
    // Do something on ping ...
  }

  @override
  Future<bool> verifyAuth(Connection connection, String token) async {
    return token == 'super_secure_token';
  }
}
```

### Creating a Client ✨

Define the client, register the data object and implement the `onConnected` method:

```dart
class ExampleClient extends BoltClient {
  ExampleClient(super.address, {super.server, required super.binding}) {
    Ping.register(registry);
  }

  @override
  void onConnected() {
    send(Ping(DateTime.now().millisecondsSinceEpoch));
  }
}
```

[dart_install_link]: https://dart.dev/get-dart
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
