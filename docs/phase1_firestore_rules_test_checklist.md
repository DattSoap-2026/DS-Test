# Phase 1: Firestore Rules Test Checklist

## Emulator Setup
- Start Firestore emulator with updated `firestore.rules`.
- Use test users for:
  - Admin/Owner
  - Sales Manager / Salesman
  - Production Manager / Production Supervisor / Bhatti Supervisor
  - Accountant
  - Unauthorized authenticated user

## Collection Coverage Tests
1. `payments`
   - Sales role can create.
   - Accountant can create/update/read.
   - Admin can delete.
   - Unauthorized role denied for write.
2. `payment_links`
   - Sales role can create.
   - Accountant can create/update/read.
   - Admin can delete.
3. `products` production-team update
   - Production team update allowed when only:
     - `stock`/`currentStock`
     - `stockUpdatedAt`
     - `stockUpdatedBy`
     - `updatedAt`
     - `updatedAtEpoch`
   - Production team denied when unrelated fields are changed.

## Regression Checks
1. Existing collections still enforce prior expectations:
   - `sales`, `returns`, `customers`, `dealers`, `delivery_trips`, `opening_stock_entries`, `production_entries`.
2. Default deny still active for unknown collections.

## Data Type Checks
1. Payment write contains normalized `createdAt` and `updatedAt` strings.
2. `updatedAtEpoch` remains numeric when present.

## Sign-off Criteria
- All allow/deny cases pass in emulator tests.
- No unintended permission broadening detected.
- No sync write denied for canonical collections in happy-path scenario.
