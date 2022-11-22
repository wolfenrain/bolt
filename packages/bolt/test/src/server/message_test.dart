// ignore_for_file: prefer_const_constructors

import 'package:bolt/bolt.dart';
import 'package:bolt/server.dart';
import 'package:test/test.dart';

class _TestDataObject extends DataObject {
  @override
  List<Object> get props => [];
}

void main() {
  late Connection connection;

  setUp(() {
    connection = const Connection(
      clientSalt: 10,
      serverSalt: 10,
      address: Address('127.0.0.1', 0),
    );
  });

  group('UntypedMessage', () {
    test('can be instantiated', () {
      final message = UntypedMessage(connection, 'data');

      expect(message.connection, equals(connection));
      expect(message.data, 'data');
    });
  });

  group('Message', () {
    test('can be instantiated', () {
      final message = Message(connection, _TestDataObject());

      expect(message.connection, equals(connection));
      expect(message.data, isA<_TestDataObject>());
    });
  });

  group('AcknowledgedMessage', () {
    test('can be instantiated', () {
      final message = AcknowledgedMessage<_TestDataObject>(
        connection,
        Acknowledged(Address('127.0.0.1', 1337), _TestDataObject(), 0),
      );

      expect(message.connection, equals(connection));
      expect(message.data, isA<Acknowledged<_TestDataObject>>());
    });
  });
}
