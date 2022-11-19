/// {@template resolver_id_reserved}
/// Exception thrown when a data resolver tries to register with an id that is
/// reserved.
/// {@endtemplate}
class ResolverIdReserved implements Exception {
  /// {@macro resolver_id_reserved}
  ResolverIdReserved(this.id);

  /// The id that was reserved.
  final int id;

  @override
  String toString() {
    return 'Data object ID $id is reserved';
  }
}
