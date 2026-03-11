# Full Transaction Reset - Testing Checklist

## Pre-Reset Verification

### Setup Test Data
- [ ] Create at least 5 sales records
- [ ] Create at least 3 dispatch records
- [ ] Allocate stock to at least 2 salesmen
- [ ] Create at least 2 route orders
- [ ] Create at least 1 production log
- [ ] Verify employee documents exist

### Verify Data Exists
- [ ] Check Firebase Console: `sales` collection has records
- [ ] Check Firebase Console: `dispatches` collection has records
- [ ] Check Firebase Console: `salesman_allocated_stock` exists
- [ ] Check Local DB: Sales table has records
- [ ] Check UI: My Stock page shows allocated stock > 0
- [ ] Check UI: Dispatch history shows records
- [ ] Check UI: Sales history shows records

## Execute Reset

### Admin Authorization
- [ ] Login as Admin user
- [ ] Navigate to System Data -> Data Buckets
- [ ] Click "Run Full Transaction Reset"
- [ ] Verify confirmation dialog appears
- [ ] Type "RESET TRANSACTIONS" exactly
- [ ] Confirm reset

### Monitor Progress
- [ ] Progress indicator shows
- [ ] Status messages update:
  - [ ] "Deleting Firebase transactional data..."
  - [ ] "Clearing allocated stock..."
  - [ ] "Resetting tank/godown stock..."
  - [ ] "Recomputing product stock..."
  - [ ] "Wiping local transactional data..."
  - [ ] "Clearing local caches..."
  - [ ] "Finalizing..."
- [ ] No errors displayed
- [ ] Completion dialog shows success

## Post-Reset Verification

### Firebase Collections (Should be EMPTY)
- [ ] `sales` - empty
- [ ] `sale_items` - empty
- [ ] `sales_history` - empty
- [ ] `sales_payments` - empty
- [ ] `sales_returns` - empty
- [ ] `dispatches` - empty
- [ ] `dispatch_items` - empty
- [ ] `dispatch_history` - empty
- [ ] `salesman_allocated_stock` - empty
- [ ] `salesman_stock_transactions` - empty
- [ ] `salesman_stock_history` - empty
- [ ] `route_orders` - empty
- [ ] `route_order_items` - empty
- [ ] `production_logs` - empty
- [ ] `stock_ledger` - empty
- [ ] `tank_transactions` - empty
- [ ] `alerts` - empty

### Firebase Collections (Should be PRESERVED)
- [ ] `users` - has records
- [ ] `employees` - has records
- [ ] `routes` - has records
- [ ] `business_partners` - has records
- [ ] `products` - has records
- [ ] `vehicles` - has records
- [ ] `employee_documents` - has records (CRITICAL)
- [ ] `tanks` - has records (names preserved)
- [ ] `departments` - has records
- [ ] `units` - has records
- [ ] `categories` - has records

### User Stock Reset
- [ ] Check `users` collection: all `allocatedStock` fields are empty `{}`
- [ ] Check `users` collection: all `allocatedStockJson` fields are empty or null

### Product Stock Reset
- [ ] Check `products` collection: stock values match opening stock
- [ ] Verify no negative stock values
- [ ] Verify stock calculation is correct

### Tank/Godown Stock Reset
- [ ] Check `tanks` collection: all `currentStock` = 0
- [ ] Check `tanks` collection: all `fillLevel` = 0
- [ ] Check `tanks` collection: tank names still exist
- [ ] Check `tanks` collection: godown names still exist
- [ ] Check `tanks` collection: godown `bags` = 0

### Local Database Verification
- [ ] Open app without crash
- [ ] Sales table is empty
- [ ] Dispatch table is empty
- [ ] Production table is empty
- [ ] Products table has records
- [ ] Users table has records
- [ ] Routes table has records
- [ ] Employee documents table has records (CRITICAL)

### UI Verification
- [ ] My Stock page shows 0 allocated stock
- [ ] Sales History page is empty
- [ ] Dispatch History page is empty
- [ ] Production History page is empty
- [ ] Route Orders page is empty
- [ ] Products page shows products with opening stock
- [ ] Users page shows all users
- [ ] Routes page shows all routes
- [ ] Employee Documents page shows documents (CRITICAL)
- [ ] Tanks page shows tank names with 0 stock

### Cache Verification
- [ ] Check SharedPreferences: `local_sales_queue` removed
- [ ] Check SharedPreferences: `local_dispatch_queue` removed
- [ ] Check SharedPreferences: `salesman_stock_cache` removed
- [ ] Check SharedPreferences: `dispatch_cache` removed
- [ ] Check SharedPreferences: `inventory_cache` removed
- [ ] Check SharedPreferences: all `last_sync_*` keys removed

### Audit Log Verification
- [ ] Check Firebase Console: `audit_logs` collection
- [ ] Verify entry with action: `full_transaction_reset`
- [ ] Verify entry has `status: started`
- [ ] Verify entry has `status: completed`
- [ ] Verify entry has correct `userId`
- [ ] Verify entry has correct timestamp

### Sync Verification
- [ ] Force sync after reset
- [ ] Verify no sync errors
- [ ] Verify master data syncs correctly
- [ ] Verify no duplicate records created

## Negative Testing

### Authorization Tests
- [ ] Try reset as non-admin user - should fail
- [ ] Try reset without internet - should fail
- [ ] Try reset without user logged in - should fail

### Data Integrity Tests
- [ ] Create new sale after reset - should work
- [ ] Create new dispatch after reset - should work
- [ ] Allocate stock after reset - should work
- [ ] Verify opening stock is preserved
- [ ] Verify product images are preserved

## Performance Testing
- [ ] Reset completes in < 5 minutes for 1000 records
- [ ] No memory leaks during reset
- [ ] App remains responsive after reset

## Edge Cases
- [ ] Reset with 0 transactions - should complete
- [ ] Reset with corrupted data - should handle gracefully
- [ ] Reset interrupted midway - verify partial state
- [ ] Reset with offline queue pending - should clear queue

## Final Verification
- [ ] App opens without crash
- [ ] All master data intact
- [ ] All transaction data cleared
- [ ] Stock values correct
- [ ] Employee documents preserved
- [ ] Audit log created
- [ ] System ready for new transactions

## Sign-off
- Tester Name: _______________
- Date: _______________
- Result: [ ] PASS [ ] FAIL
- Notes: _______________
