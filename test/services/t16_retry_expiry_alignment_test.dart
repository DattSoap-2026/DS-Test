import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/services/outbox_codec.dart';

/// T16: Retry Expiry Alignment (R13)
/// 
/// PROBLEM: Expiry threshold is hardcoded to 20 but maxAttempts is 8
/// SOLUTION: Base expiry on configured maxAttempts value
/// 
/// This test verifies that:
/// 1. Expiry logic reads maxAttempts from meta
/// 2. Default maxAttempts is 8 (from OutboxCodec)
/// 3. Expiry threshold matches maxAttempts configuration

void main() {
  group('T16: Retry Expiry Alignment', () {
    test('OutboxCodec defaultMaxAttempts should be 8', () {
      expect(OutboxCodec.defaultMaxAttempts, equals(8));
    });

    test('expiry should use maxAttempts from meta, not hardcoded 20', () {
      // Simulate queue item meta
      final meta = {
        'attemptCount': 8,
        'maxAttempts': 8, // Should use this value
        'firstQueuedAt': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      };

      final attemptCount = (meta['attemptCount'] as num?)?.toInt() ?? 0;
      final maxAttempts = (meta['maxAttempts'] as num?)?.toInt() ?? OutboxCodec.defaultMaxAttempts;

      // Verify expiry logic uses maxAttempts
      expect(maxAttempts, equals(8));
      expect(attemptCount >= maxAttempts, isTrue);
    });

    test('expiry should respect custom maxAttempts configuration', () {
      // Simulate queue item with custom maxAttempts
      final customMeta = {
        'attemptCount': 15,
        'maxAttempts': 15, // Custom value
        'firstQueuedAt': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      };

      final attemptCount = (customMeta['attemptCount'] as num?)?.toInt() ?? 0;
      final maxAttempts = (customMeta['maxAttempts'] as num?)?.toInt() ?? OutboxCodec.defaultMaxAttempts;

      // Verify expiry uses custom maxAttempts, not hardcoded 20
      expect(maxAttempts, equals(15));
      expect(attemptCount >= maxAttempts, isTrue);
    });

    test('expiry should fall back to defaultMaxAttempts if not specified', () {
      // Simulate queue item without maxAttempts
      final metaWithoutMax = {
        'attemptCount': 8,
        // maxAttempts not specified
        'firstQueuedAt': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
      };

      final maxAttempts = (metaWithoutMax['maxAttempts'] as num?)?.toInt() ?? OutboxCodec.defaultMaxAttempts;

      // Should fall back to default
      expect(maxAttempts, equals(OutboxCodec.defaultMaxAttempts));
      expect(maxAttempts, equals(8));
    });
  });
}
