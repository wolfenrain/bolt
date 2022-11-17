# Bolt Server

## Listening to Data Objects

The server can listen to messages that contain a given `DataObject`, this message is represented by the `Message` class and holds the received `DataObject` and from which connection the message came.

We can listen to these messages using the `on` method, which allows us to register a handler for a given `DataObject` type:

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

You can remove the handler by calling the `off` method:

```dart
...

  server.off(_onMyObject);

...
```

## Listening to acknowledgements of Data Objects

In some cases you might want to know when a message that you had sent to a client was received. Bolt has a built-in system for acknowledgements of Data Objects, for more information related to the system see the [Acknowledgments section](./protocol.md#acknowledgments) in the Protocol documentation.

An acknowledged message is represented by the `AcknowledgedMessage` class and holds the original `DataObject` that was sent and which connection received it. 

You can listen to acknowledged messages by using the `onAck` method:

```dart
Future<void> main() async {
  final server = ExampleServer(...);

  ...

  server.onAck(_onAcknowledgedMyObject);

  ...

  await server.start();
}

void _onAcknowledgedMyObject(AcknowledgedMessage<MyObject> message) {
  print('The ${message.data} that was sent to ${message.connection.address} was acknowledged!')
}
```

You can remove the acknowledgment handler by calling the `offAck` method:

```dart
...

  server.offAck(_onAcknowledgedMyObject);

...
```