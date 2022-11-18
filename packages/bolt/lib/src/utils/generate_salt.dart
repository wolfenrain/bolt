import 'dart:math';

import 'package:meta/meta.dart';

/// Generates a random salt.
int generateSalt({@visibleForTesting Random? random, int? seed}) {
  final rnd = random ?? Random(seed);
  final random1 = rnd.nextInt(pow(2, 32) as int);
  final random2 = rnd.nextInt(pow(2, 32) as int);
  return (random1 << 32) | random2;
}
