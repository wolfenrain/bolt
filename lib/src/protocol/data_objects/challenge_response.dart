import 'package:bolt/bolt.dart';

/// {@template challenge_response}
/// Sent by the client to the server to respond to a challenge.
/// {@endtemplate}
class ChallengeResponse extends DataObject {
  /// {@macro challenge_response}
  const ChallengeResponse({
    required this.result,
  });

  /// The result of the challenge.
  final int result;

  @override
  List<Object> get props => [result];
}

/// {@template challenge_response_resolver}
/// Resolver for [ChallengeResponse]. Used internally.
/// {@endtemplate}
class ChallengeResponseResolver extends DataResolver<ChallengeResponse>
    implements ChallengeResponse {
  /// {@macro challenge_response_resolver}
  ChallengeResponseResolver(super.data);

  @override
  dynamic namedArgument(Symbol name) {
    switch (name) {
      case #result:
        return data.result;
    }
  }
}
