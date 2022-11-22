import 'package:bolt/bolt.dart';

/// {@template resolver_already_registered}
/// Thrown when a [DataResolver] is already registered for a given [id].
/// {@endtemplate}
class ResolverAlreadyRegistered<T> implements Exception {
  /// {@macro resolver_already_registered}
  ResolverAlreadyRegistered(this.id, this.resolver);

  /// The id that was already registered.
  final int id;

  /// The resolver that was already registered.
  final DataResolver<dynamic> resolver;

  @override
  String toString() {
    return '''Data object $T tried to register with id $id, but that id is already registered to ${resolver.name}''';
  }
}
