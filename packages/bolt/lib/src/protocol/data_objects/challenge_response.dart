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
