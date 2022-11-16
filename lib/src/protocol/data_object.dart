import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

/// The factory for [DataResolver]s.
typedef Resolver<T extends DataObject, V extends DataResolver<T>> = V Function(
  T,
);

/// {@template data_object}
/// Represents the data of a packet being sent over the network.
///
/// Each custom data object must extend this class and have a [DataResolver]
/// that implements the custom data object.
/// {@endtemplate}
@immutable
abstract class DataObject extends Equatable {
  /// {@macro data_object}
  const DataObject();
}

/// {@template data_resolver}
/// Resolves symbols to values for a specific [DataObject].
///
/// Each data object must have a resolver that implements the data object.
/// {@endtemplate}
class DataResolver<T extends DataObject> {
  /// {@macro data_resolver}
  DataResolver(this.data);

  /// The data of the packet.
  final T data;

  /// Retrieve teh value of a positional argument.
  dynamic positionalArgument(int index) {}

  /// Retrieves the value of a named argument.
  dynamic namedArgument(Symbol name) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
