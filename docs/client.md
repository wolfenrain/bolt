# Bolt Client

## Listening to Data Objects

The client can listen to data objects that were send by the server. By using the `on` method, which allows us to register a handler for a given `DataObject` type:

```dart
Future<void> main() async {
  final client = ExampleClient(...);

  ...

  client.on(_onMyObject);

  ...

  await client.connect(...);
}

void _onMyObject(MyObject object) {
  print('Received: ${object} from the server');
}
```

You can remove the handler by calling the `off` method:

```dart
...

  client.off(_onMyObject);

...
```

## Listening to acknowledgements of Data Objects

In some cases you might want to know when a `DataObject` that you had send was received by the server. Bolt has a built-in system for acknowledgements of Data Objects, for more information related to the system see the [Acknowledgments section](./protocol.md#acknowledgments) in the Protocol documentation.

To listen to acknowledgments from the server on `DataObjects` that were sent by the client, use the `onAck` method:

```dart
Future<void> main() async {
  final client = ExampleClient(...);

  ...

  client.onAck(_onAcknowledgedMyObject);

  ...

  await client.connect(...);
}

void _onAcknowledgedMyObject(Acknowledged<MyObject> ack) {
  print('The ${ack.object} that I emitted was acknowledged by the server');
  print('It took ${ack.latency}ms for the full round trip');
}
```

You can remove the acknowledgment handler by calling the `offAck` method:

```dart
...

  client.offAck(_onAcknowledgedMyObject);

...
```