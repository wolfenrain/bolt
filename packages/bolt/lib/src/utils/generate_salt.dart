import 'dart:math';

/// Generates a random salt.
int generateSalt() {
  final random = Random();
  final random1 = random.nextInt(pow(2, 32) as int);
  final random2 = random.nextInt(pow(2, 32) as int);
  return (random1 << 32) | random2;
}
