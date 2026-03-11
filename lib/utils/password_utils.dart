import 'dart:math';

String generateSecurePassword([int length = 12]) {
  const String chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()-_=+';
  final Random random = Random.secure();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
}
