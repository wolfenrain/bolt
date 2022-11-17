import 'package:bolt/bolt.dart';

/// {@template data_resolver}
/// Defines how a [DataObject] is resolved to and from binary data.
/// {@endtemplate}
class DataResolver<T extends DataObject> {
  /// {@macro data_resolver}
  const DataResolver(this.factory, [this.arguments = const []]);

  /// The factory that creates a [DataObject] of type [T].
  final Function factory;

  /// The arguments that are used to resolve the [DataObject] to and from binary
  /// data.
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

/// {@template argument}
/// Describes an argument of a [DataObject] constructor.
/// {@endtemplate}
class Argument<T, V> {
  /// {@macro argument}
  ///
  /// Define a positional argument.
  Argument.positional(
    this.from, {
    required this.type,
  }) : name = null;

  /// {@macro argument}
  ///
  /// Define a named argument.
  Argument.named(
    this.from, {
    required this.type,
    required Symbol this.name,
  });

  /// The function that retrieves the value of this argument from the data
  /// object.
  final V Function(T d) from;

  /// The type of this argument, used to serialize and deserialize the value.
  final PayloadType<V> type;

  /// The name of this argument, used when passed as a named argument.
  final Symbol? name;

  /// Whether this argument is nullable.
  bool get isNullable => type is PayloadType<V?>;
}
