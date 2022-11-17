<p align="center">
<img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/assets/bolt_full.png" height="320" alt="bolt logo" />
</p>

<p align="center">
<a href="https://github.com/wolfenrain/bolt"><img src="https://img.shields.io/pub/v/bolt.svg" alt="pub package"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://github.com/wolfenrain/bolt/actions/workflows/main.yaml/badge.svg" alt="bolt"></a>
<a href="https://github.com/wolfenrain/bolt/actions"><img src="https://raw.githubusercontent.com/wolfenrain/bolt/main/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/very_good_analysis"><img src="https://img.shields.io/badge/style-very_good_analysis-B22C89.svg" alt="style: very good analysis"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

---

## What is Bolt

Bolt is a network protocol written in Dart to send and receive strongly typed data objects. It is designed to be easy to use and to be as fast as possible.

Bolt is split into two parts, the `BoltClient` and the `BoltServer`. They both implement the `BoltProtocol`, which handles settings up the connection, verifying the connection is secure and sending/receiving data objects.
 
Everything is abstracted away in these classes, this means that you can implement your own abstraction on top of Bolt by just extending from `BoltClient` and `BoltServer`.

Bolt works on the principal of shared code, this means that you write common code that is shared between both server and client. 

**Note**: Currently the `BoltProtocol` is using UDP as it's network transfer protocol but in the future will be abstracted to allow for other protocols.

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

Create a shared Data Object for the client and server:

```dart
class Ping extends DataObject {
  const Ping(this.timestamp);

  final int timestamp;

  @override
  List<Object?> get props => [timestamp];

  static void register(BoltRegistry registry) {
    registry.register(100, Ping.new, _Resolver.new);
  }
}

class _Resolver extends DataResolver<Ping> implements Ping {
  _Resolver(super.data);

  @override
  dynamic positionalArgument(int index) {
    switch (index) {
      case 0:
        return data.timestamp;
    }
  }
}

```

### Creating a Server 🏁

Define a server, register the data object and listen to messages:

```dart
class ExampleServer extends BoltServer {
  ExampleServer(super.address) {
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

Define the client, register the data objects and implement the `onConnected` method:

```dart
class ExampleClient extends BoltClient {
  ExampleClient(super.address, {super.server}) {
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
