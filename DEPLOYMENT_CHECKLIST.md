# Firebase Deployment Checklist

## Pre-Deployment

- [ ] Backup current rules: `firebase firestore:rules > firestore.rules.backup`
- [ ] Review changes in `firestore.indexes.json` (7 new indexes)
- [ ] Review changes in `firestore.rules` (5 new collection rules)
- [ ] Ensure Firebase CLI is authenticated: `firebase login`

## Validation

- [ ] Validate indexes syntax: `firebase firestore:indexes`
- [ ] Validate rules syntax: `firebase deploy --only firestore:rules --dry-run`
- [ ] Confirm no syntax errors in output

## Deployment

- [ ] Deploy atomically: `firebase deploy --only firestore:rules,firestore:indexes`
- [ ] Wait for deployment confirmation message
- [ ] Note deployment timestamp for monitoring

## Post-Deployment Verification

- [ ] Check Firebase Console > Firestore > Indexes tab
- [ ] Verify 7 new indexes show "Building" status:
  - messages (recipientId, createdAt)
  - messages (senderId, createdAt)
  - stock_balances (locationId, productId)
  - inventory_commands (commandType, createdAt)
  - inventory_commands (actorUid, createdAt)
  - inventory_locations (type, isActive)
  - accounting_compensation_log (transactionRefId, createdAt)

- [ ] Wait 5-15 minutes for indexes to reach "Enabled" status
- [ ] Check Firebase Console > Firestore > Rules tab for updated timestamp

## Testing

- [ ] Test unauthenticated access to products (should fail)
- [ ] Test salesman reading own sales (should succeed)
- [ ] Test salesman reading other salesman's sales (should fail)
- [ ] Test admin reading all sales (should succeed)
- [ ] Test client writing to stock_balances (should fail - server-only)

## Monitoring (First 24 Hours)

- [ ] Monitor Firebase Console > Firestore > Usage for error spikes
- [ ] Check application error logs for permission-denied errors
- [ ] Verify no query performance degradation
- [ ] Confirm all 7 new indexes reach "Enabled" state

## Rollback (If Needed)

If critical issues arise:
```bash
# Restore previous rules
git checkout HEAD~1 firestore.rules
firebase deploy --only firestore:rules

# Delete problematic indexes from Firebase Console
```

## Sign-Off

- Deployed By: _______________
- Date: _______________
- Time: _______________
- Deployment ID: _______________
- Status: ☐ Success  ☐ Rolled Back  ☐ Issues (see notes)

Notes:
_________________________________________________________________
_________________________________________________________________
_________________________________________________________________
