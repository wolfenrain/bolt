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

Currently the `BoltProtocol` is using UDP as it's network transfer protocol but in the future will be abstracted to allow for other protocols.

## Installation 💻

**❗ In order to start using Bolt you must have the [Dart SDK][dart_install_link] installed on your machine.**

Add `bolt` to your `pubspec.yaml`:

```yaml
dependencies:
  bolt:
```

Install it:

```sh
dart pub get
```

## Usage

Bolt works on the principal of shared code, both client and server will have to register the same data objects and other features to ensure correct communication. 

### Data Objects

Data objects represent the data that is sent over the line from one side to the other. They are strongly typed instances and are often used as a form of messages between two sides.

#### Defining a Data Object

Defining custom data objects is easy, you extends from the `DataObject` class and define what arguments and fields your class has. You also have to define a `DataResolver` that implements your class. It will help you resolve the data when serializing from and to binary data.

```dart
import 'package:bolt/bolt.dart';

class MyObject extends DataObject {
  const MyObject(
    this.someValue, {
    required this.someOtherValue,
  });

  final int someValue

  final double someOtherValue;

  @override
  List<Object?> get props => [someValue, someOtherValue];

  static void register(BoltRegistry registry) {
    registry.register(100, MyObject.new, _Resolver.new);
  }
}

class _Resolver extends DataResolver<MyObject> implements MyObject {
  _Resolver(super.data);

  dynamic positionalArgument(int index) {
    switch(index) {
      case 0:
        return data.someValue;
    }
  }

  @override
  dynamic namedArgument(Symbol name) {
    switch (name) {
      case #someOtherValue:
        return data.someOtherValue;
    }
  }
}
```

**Note**: If your data object has nullable values or a `List` of values, Bolt will automatically serialize and deserialize that for you.

#### Registering a Data Object

Once you have defined a `DataObject` you can register it, this has to happen on both the client and server side using the same object id. In the above example we already defined a static `register` method to help with this. Lets register them to our client and server instances:

```dart
class ExampleClient extends BoltClient {
  ExampleClient(super.address, {super.server});

  ...
}

Future<void> main() async {
  final client = ExampleClient(...);
  MyObject.register(client.registry);
  
  ...
}
```

```dart

class ExampleServer extends BoltServer {
  ExampleServer(super.address);

  @override
  Future<bool> verifyAuth(Connection connection, String token) async {
    ...
  }
}


Future<void> main() async {
  final server = ExampleServer(...);
  MyObject.register(server.registry);
  
  ...
}
```

We can now, emit our `MyObject` over the line and both the client and server will be able to properly serialize the data.

#### Listening to Data Objects

Both the client and server can listen to data objects, the client listens directly to the type while the server listens to a `Message` version of it, which contains the connection that send the `DataObject`.

Both the client and server expose an `on` and `off` method to register handlers for a given `DataObject`:

```dart
Future<void> main() async {
  final client = ExampleClient(...);

  ...

  client.on(_onMyObject);

  ...

  await client.connect('super_secure_token');
}

void _onMyObject(MyObject object) {
  print('Received: ${object}');
}
```

```dart
Future<void> main() async {
  final server = ExampleServer(...);

  ...

  server.on(_onMyObject);

  ...

  await server.start();
  
}

void _onMyObject(Message<MyObject> message) {
  print('Received: ${message.data} from ${message.connection}');
}
```

Bolt also handles acknowledgements for `DataObjects` automatically, you can register handlers by using the `onAck` and `offAck` methods. Whenever the other side acknowledged a message that you emitted it will trigger your handler for that data object type.

### Payload Types

Sometimes you want to send more over than just the the primitive types, maybe you want to send over a custom class? This is where payload types come in.

A `PayloadType` is concept that comes from [Binarize](https://pub.dev/packages/binarize) and it basically defines how to serialize and deserialize a type to binary and back.

#### Defining a Payload Type

Let's define a payload type for a simple class:

```dart
class MySimpleClass {
  MySimpleClass(this.aString, this.anInt, this.aDouble);

  final String aString;

  final int anInt;

  final double aDouble;
}
```

We want to pack this class into binary and also unpack it from binary, so we define a custom payload type:

```dart
import 'package:bolt/bolt.dart';

class _MySimpleClass extends PayloadType<MySimpleClass> {
  const _MySimpleClass();

  @override
  int length(MySimpleClass value) =>
      string16.length(value.aString) +
      int32.length(value.anInt) +
      float32.length(value.aDouble);

  @override
  MySimpleClass get(ByteData data, int offset) {
    var currentOffset = offset;

    final aString = string16.get(data, currentOffset);
    currentOffset += string16.length(aString);

    final anInt = int32.get(data, currentOffset);
    currentOffset += int32.length(anInt);

    final aDouble = float32.get(data, currentOffset);
    currentOffset += float32.length(aDouble);

    return MySimpleClass(aString, anInt, aDouble);
  }

  @override
  void set(MySimpleClass value, ByteData data, int offset) {
    var currentOffset = offset;

    string16.set(value.aString, data, currentOffset);
    currentOffset += string16.length(value.aString);

    int32.set(value.anInt, data, currentOffset);
    currentOffset += int32.length(value.anInt);

    float32.set(value.aDouble, data, currentOffset);
    currentOffset += float32.length(value.aDouble);
  }
}

const mySimpleClass = _MySimpleClass();
```

We now have a `mySimpleClass` variable that we can use to pack and unpack our `MySimpleClass` instances.

#### Registering a Payload Type

Just like the `DataObject` we can register payload types to Bolt through the `BoltRegistry`, both the client and server need to register it to be able to serialize the data:

```dart
...

Future<void> main() async {
  final client = ExampleClient(...);

  ...

  mySimpleClass.register(client.registry);
  
  ...
}
```

```dart
...

Future<void> main() async {
  final server = ExampleServer(...);
  
  ...

  mySimpleClass.register(server.registry);
  
  ...
}
```

And now Bolt knows about our custom class and will use our payload type to serialize it into binary and back whenever it is part of a `DataObject`.

**Note**: You can also pass different payload types to `BoltRegistry.register`, to either add or overwrite payload types for certain value types.

[dart_install_link]: https://dart.dev/get-dart
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
