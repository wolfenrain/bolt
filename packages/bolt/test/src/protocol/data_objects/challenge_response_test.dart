// ignore_for_file: prefer_const_constructors

import 'package:bolt/src/protocol/data_objects/data_objects.dart';
import 'package:test/test.dart';

void main() {
  group('ChallengeResponse', () {
    test('can be instantiated', () {
      final challengeResponse = ChallengeResponse(result: 10);

      expect(challengeResponse.result, equals(10));
    });

    test('equality', () {
      final challengeResponse1 = ChallengeResponse(result: 10);
      final challengeResponse2 = ChallengeResponse(result: 10);

      expect(challengeResponse1, equals(challengeResponse2));
    });
  });
}
