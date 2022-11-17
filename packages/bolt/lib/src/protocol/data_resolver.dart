import 'package:bolt/bolt.dart';

/// {@template data_resolver}
/// Defines how a [DataObject] is resolved to and from binary data.
/// {@endtemplate}
class DataResolver<T extends DataObject> {
  /// {@macro data_resolver}
  const DataResolver(this.factory, [this.arguments = const []]);

  final Function factory;

  final List<Argument<T, dynamic>> arguments;

  /// The name of the data object.
  String get name => T.toString();

  /// Serialize the given [object] to bytes.
  List<int> serialize(T object) {
    final writer = Payload.write();
    for (final argument in arguments) {
      final value = argument.from(object);

      if (value == null && !argument.isNullable) {
        throw Exception(
          'Tried to retrieve field "${argument.name}" of $T, which is not '
          'nullable but it returned null\n\n'
          'Did you forget to wrap the payload type in "nullable"?',
        );
      }

      writer.set(argument.type, value);
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
      if (argument.name == null) {
        positionalArguments.add(reader.get(argument.type));
      } else {
        namedArguments[argument.name!] = reader.get(argument.type);
      }
    }

    try {
      return Function.apply(factory, positionalArguments, namedArguments) as T;
    } catch (err) {
      throw Exception('Failed to deserialize $T: $err');
    }
  }
}

class Argument<T, V> {
  Argument.positional(
    this.from, {
    required this.type,
  }) : name = null;

  Argument.named(
    this.from, {
    required this.type,
    required Symbol this.name,
  });

  final PayloadType<V> type;

  final V Function(T d) from;

  final Symbol? name;

  bool get isNullable => type is PayloadType<Object?>;
}
