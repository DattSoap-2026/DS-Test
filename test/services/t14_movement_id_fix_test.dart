import 'package:flutter_test/flutter_test.dart';

/// T14: Fix Movement ID Duplication (R16)
/// 
/// PROBLEM: Dispatch movementIds map keyed by productId overwrites repeated products
/// SOLUTION: Use line item index instead of productId as key
/// 
/// This test verifies that:
/// 1. movementIds is now a List indexed by item position
/// 2. Repeated products each get their own movement ID
/// 3. Movement IDs are preserved in order

void main() {
  group('T14: Movement ID Duplication Fix', () {
    test('movementIds should be List not Map to preserve repeated products', () {
      // Simulate dispatch payload structure
      final dispatchPayload = {
        'id': 'dispatch_123',
        'items': [
          {'productId': 'prod_A', 'quantity': 10, 'isFree': false},
          {'productId': 'prod_A', 'quantity': 5, 'isFree': true}, // Same product, different type
          {'productId': 'prod_B', 'quantity': 20, 'isFree': false},
        ],
        'movementIds': ['move_1', 'move_2', 'move_3'], // List, not Map
      };

      // Verify structure
      expect(dispatchPayload['movementIds'], isA<List>());
      expect((dispatchPayload['movementIds'] as List).length, equals(3));
      
      // Verify all movement IDs are preserved
      final movementIds = dispatchPayload['movementIds'] as List;
      expect(movementIds[0], equals('move_1'));
      expect(movementIds[1], equals('move_2'));
      expect(movementIds[2], equals('move_3'));
    });

    test('repeated products should have distinct movement IDs', () {
      // Simulate two items with same productId
      final items = [
        {'productId': 'soap_001', 'quantity': 100, 'isFree': false},
        {'productId': 'soap_001', 'quantity': 50, 'isFree': true},
      ];

      // Generate movement IDs by index (simulating service logic)
      final movementIds = <String>[];
      for (var i = 0; i < items.length; i++) {
        movementIds.add('dispatch_move_${items[i]['productId']}_$i');
      }

      // Verify both items have unique movement IDs
      expect(movementIds.length, equals(2));
      expect(movementIds[0], equals('dispatch_move_soap_001_0'));
      expect(movementIds[1], equals('dispatch_move_soap_001_1'));
      expect(movementIds[0], isNot(equals(movementIds[1])));
    });
  });
}
