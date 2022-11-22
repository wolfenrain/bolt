/// {@template non_nullable_argument}
/// Thrown when a non-nullable argument of a data object is null.
class NonNullableArgument<T> implements Exception {
  /// {@macro non_nullable_argument}
  NonNullableArgument(this.name);

  /// The name of the argument.
  final Symbol name;

  @override
  String toString() {
    final regex = RegExp(r'Symbol\("(.*)"\)');
    final match = regex.firstMatch(name.toString());
    final nameString = match?.group(1) ?? name.toString();

    return '''
Tried to retrieve field "$nameString" of $T, which is not nullable but it returned null

Did you forget to wrap the payload type in "nullable"?''';
  }
}
