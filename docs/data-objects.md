
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

## Registering a Data Object

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

The `MyObject` class is now registered to our client and server and can be emitted and received over the line.