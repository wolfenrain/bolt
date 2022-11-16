import 'package:bolt/bolt.dart';
import 'package:collection/collection.dart';

/// {@template data_serializer}
/// Serializes [DataObject] objects to and from bytes.
/// {@endtemplate}
class DataSerializer<T extends DataObject, V extends DataResolver<T>> {
  /// {@macro data_serializer}
  factory DataSerializer(
    int id,
    Function factory,
    Resolver<T, V> resolver, {
    List<RegisteredPayload<dynamic>> payloadTypes = const [],
    required BoltRegistry registry,
  }) {
    try {
      Function.apply(factory, [#some, #fake, #data, #here], {#some: #more});
      throw Exception('Data object $T is invalid');
    } catch (err) {
      if (err is! NoSuchMethodError) rethrow;
      final receiver = '$err'.split('\n')[1];
      final listRegex = RegExp('(?:List<([a-zA-Z0-9]+)>)');

      final positionalArgumentRegex = RegExp(
        r'(?:\[)?([a-zA-Z0-9?<>]+)(?:\])?',
      );

      final positionalInfo = receiver
          .replaceFirst('Receiver: Closure: (', '')
          .replaceFirst(RegExp(r'(?:{required .*?})?\)(.*?)$'), '');

      var positionalIndex = 0;
      final positionalArguments =
          positionalArgumentRegex.allMatches(positionalInfo).map((match) {
        final foundType = match.group(1)!;
        var type = foundType;
        if (listRegex.hasMatch(foundType)) {
          type = listRegex.firstMatch(foundType)!.group(1)!;
        }
        return DataArgument(
          positionalIndex: positionalIndex++,
          type: type.substring(
            0,
            type.length - (foundType.endsWith('?') ? 1 : 0),
          ),
          isNullable: foundType.endsWith('?'),
          isList: listRegex.hasMatch(foundType),
        );
      }).toList();

      final namedArgumentsRegex = RegExp(
        '(?:required ([a-zA-Z0-9?<>]+) ([a-zA-Z0-9]+))',
      );
      final namedArguments =
          namedArgumentsRegex.allMatches(receiver).map((match) {
        final foundType = match.group(1)!;
        var type = foundType;
        if (listRegex.hasMatch(foundType)) {
          type = listRegex.firstMatch(foundType)!.group(1)!;
        }
        final name = match.group(2)!;

        return DataArgument(
          name: name,
          type: type.substring(
            0,
            type.length - (foundType.endsWith('?') ? 1 : 0),
          ),
          isNullable: foundType.endsWith('?'),
          isList: listRegex.hasMatch(foundType),
        );
      }).toList();

      return DataSerializer<T, V>._(
        id,
        factory,
        resolver,
        [
          ...positionalArguments,
          ...namedArguments,
        ],
        registry,
        payloadTypes,
      );
    }
  }

  const DataSerializer._(
    this.id,
    this.factory,
    this.resolver,
    this.arguments,
    this.registry,
    this._payloadTypes,
  );

  /// The unique ID of the data.
  final int id;

  /// The factory for the data.
  final Function factory;

  /// The factory for the packet.
  final Resolver<T, V> resolver;

  /// The arguments of the data object constructor.
  final List<DataArgument> arguments;

  /// The registry that this serializer is registered to.
  final BoltRegistry registry;

  final List<RegisteredPayload<dynamic>> _payloadTypes;

  /// The payload types for the types of the [arguments].
  List<RegisteredPayload<dynamic>> get payloadTypes => [
        ...registry.payloadTypes,
        ..._payloadTypes,
      ];

  /// The name of the data.
  String get name => T.toString();

  /// Serialize the given [object] to bytes.
  List<int> serialize(T object) {
    final packet = resolver(object);

    final writer = Payload.write();
    for (final argument in arguments) {
      final dynamic value;
      if (argument.name == null) {
        value = packet.positionalArgument(argument.positionalIndex!);
      } else {
        value = packet.namedArgument(Symbol(argument.name!));
      }
      if (value == null && !argument.isNullable) {
        throw Exception(
          'Tried to retrieve field "${argument.name}" of $T, which is not '
          'nullable but it returned null\n\n'
          'Did you forget to add the ${argument.name} in the value() method?',
        );
      }
      final registeredType =
          payloadTypes.firstWhereOrNull((type) => type.name == argument.type);
      if (registeredType == null) {
        throw Exception('Unsupported type: ${argument.type}');
      }

      var payloadType = registeredType.type;
      if (argument.isList) payloadType = registeredType.listType;
      if (argument.isNullable) payloadType = nullable(payloadType);
      writer.set(payloadType, value);
    }

    try {
      return binarize(writer);
    } catch (err) {
      throw Exception('Failed to serialize $T: $err');
    }
  }

  /// Deserialize the given [bytes] to a data object.
  T deserialize(List<int> bytes) {
    final positionalArguments = <dynamic>[];
    final namedArguments = <Symbol, dynamic>{};

    final reader = Payload.read(bytes);
    for (final argument in arguments) {
      final registeredType =
          payloadTypes.firstWhereOrNull((type) => type.name == argument.type);
      if (registeredType == null) {
        throw Exception('Unsupported type: ${argument.type}');
      }

      var payloadType = registeredType.type;
      if (argument.isList) payloadType = registeredType.listType;
      if (argument.isNullable) payloadType = nullable(payloadType);

      if (argument.name == null) {
        positionalArguments.add(reader.get(payloadType));
      } else {
        namedArguments[Symbol(argument.name!)] = reader.get(payloadType);
      }
    }

    try {
      return Function.apply(factory, positionalArguments, namedArguments) as T;
    } catch (err) {
      throw Exception('Failed to deserialize $T: $err');
    }
  }
}

/// {@template data_argument}
/// Represents an argument of a data object constructor.
/// {@endtemplate}
class DataArgument {
  /// {@macro data_argument}
  const DataArgument({
    this.name,
    this.positionalIndex,
    required this.type,
    required this.isNullable,
    required this.isList,
  });

  /// The name of the argument.
  ///
  /// If this is null, it is a positional argument.
  final String? name;

  /// The index of the argument.
  ///
  /// If this is null, it is a named argument.
  final int? positionalIndex;

  /// The type of the argument.
  final String type;

  /// Whether the argument is nullable.
  final bool isNullable;

  /// If the argument is a list.
  final bool isList;
}

/// {@template registered_payload}
/// A payload type that is registered for a specific type.
/// {@endtemplate}
class RegisteredPayload<T> {
  /// {@macro registered_payload}
  const RegisteredPayload(this.type);

  /// The name of the type.
  String get name => '$T';

  /// The payload type.
  final PayloadType<T> type;

  /// Strongly wrap the [type] to a [PayloadType] that can be used for
  /// lists.
  PayloadType<List<T>> get listType => list(type);
}
