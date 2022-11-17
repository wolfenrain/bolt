
# Data Objects

Data objects represent the data that is sent over the line from one side to the other. They are strongly typed instances and are often used as a form of messages between two sides.

## Defining a Data Object

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
}
```

**Note**: It is recommend to make a `DataObject` immutable, as it purely represents data that will be send over the line.

## Registering a Data Object

Once you have defined a `DataObject` you can register it, this has to happen on both the client and server side using the same object id. Lets register the data object that we defined to both the client and server instances.

First add a static `register` method to the data object:

```dart
class MyObject extends DataObject {
  ...

  static void register(BoltRegistry registry) {
    registry.registerObject(
      100,
      DataResolver<MyObject>(MyObject.new, [
        Argument.positional<MyObject, int>((d) => d.someValue, type: uint32),
        Argument.named<MyObject, double>(
          (d) => d.someOtherValue, 
          type: float32, 
          name: #someOtherValue
        ),
      ]),
    );
  }

  ...
}
```

By defining a `DataResolver` for the `DataObject` we can map each argument on the constructor to an `Argument` instance. An `Argument` main purpose is to retrieve the value of a field, tell the resolver what payload type should be used for serialization and if it is named argument. The name should match the argument name on the constructor.

Now that we have a common method for registering the data object, lets call it for both the client and the server:

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
