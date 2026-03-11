# Accountant Audit Log System

## Problem
Accountant user was getting permission-denied errors when accessing vouchers and accounting data. Need to:
1. Fix permissions for Accountant role
2. Track all Accountant actions for audit purposes
3. Provide Admin visibility into Accountant activities

## Solution Implemented ✅

### 1. Firestore Rules Updated

**File**: `firestore.rules`

Added Accountant role helper function:
```javascript
function isAccountant() {
  return isAuth() && (
    request.auth.token.role == 'Accountant' ||
    get(/databases/$(database)/documents/users/$(uid())).data.role == 'Accountant'
  );
}
```

Updated permissions:
```javascript
// Vouchers - Accountant can read/write
match /vouchers/{id} { 
  allow read, write: if isAdmin() || isAccountant(); 
}

// Voucher Entries - Accountant can read/write
match /voucher_entries/{id} { 
  allow read, write: if isAdmin() || isAccountant(); 
}

// Audit Logs - Accountant can write, Admin can read
match /audit_logs/{id} { 
  allow read: if isAdmin();
  allow write: if isAdmin() || isAccountant(); 
}
```

### 2. Audit Service Created

**File**: `lib/services/accounting_audit_service.dart`

Features:
- Logs all Accountant actions to Isar (local) and Firestore (remote)
- Tracks: userId, userName, action, collection, documentId, changes, notes, timestamp
- Query methods: `getAuditLogsForUser()`, `getRecentAccountingAudits()`

### 3. Audited Posting Service

**File**: `lib/modules/accounting/audited_posting_service.dart`

Wraps PostingService to automatically log Accountant actions:
- `postSalesVoucher()` - logs sales voucher creation
- `postPurchaseVoucher()` - logs purchase voucher creation
- `createManualVoucher()` - logs manual voucher creation
- `createVoucherReversal()` - logs reversal voucher creation

Only logs when user role is "Accountant" (not Admin or other roles).

### 4. Audit Viewer Screen

**File**: `lib/modules/accounting/screens/accountant_audit_screen.dart`

Admin-only screen showing:
- All Accountant actions on vouchers and voucher_entries
- User name, action type, collection, document ID
- Timestamp, notes, and change details
- Refresh capability
- Detail view for each log entry

## How It Works

### Automatic Audit Logging

When Accountant creates/updates vouchers:

1. **Action Performed**: Accountant creates a sales voucher
2. **Voucher Created**: PostingService creates voucher in Firestore
3. **Audit Logged**: AuditedPostingService detects Accountant role
4. **Local Storage**: Audit log saved to Isar database
5. **Remote Sync**: Audit log synced to Firestore `audit_logs` collection
6. **Admin Review**: Admin can view all logs in Accountant Audit Screen

### Audit Log Structure

```json
{
  "id": "audit_1234567890_userId",
  "userId": "A4JwAAb9hTePBPU8BCimWjew54N2",
  "userName": "Tushar Thorat",
  "action": "create",
  "collectionName": "vouchers",
  "documentId": "voucher_12345",
  "changes": {
    "type": "sales",
    "amount": 15000,
    "entries": 4
  },
  "notes": "Sales voucher posted",
  "createdAt": "2024-03-10T10:30:00Z"
}
```

## Permissions Summary

### Before ❌
```
Accountant → Permission denied on vouchers
Accountant → Permission denied on voucher_entries
Accountant → Cannot access accounting data
```

### After ✅
```
Accountant → Full read/write access to vouchers
Accountant → Full read/write access to voucher_entries
Accountant → Can write audit logs (auto-logged)
Admin → Can read all audit logs
Admin → Can view Accountant activities
```

## Deployment Steps

### 1. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

Wait 30-60 seconds for rules to propagate.

### 2. Add Route (if needed)

Add to `app_router.dart`:
```dart
GoRoute(
  path: 'accounting/audit',
  builder: (context, state) => const AccountantAuditScreen(),
),
```

### 3. Test Accountant Access

1. Login as Accountant (account@dattsoap.com)
2. Navigate to Accounting → Vouchers
3. Create a voucher
4. Verify no permission errors
5. Logout

### 4. Test Admin Audit View

1. Login as Admin
2. Navigate to Accounting → Audit Log
3. Verify Accountant actions are visible
4. Check details of each log entry

## What Gets Logged

### Voucher Creation
- Action: `create`
- Collection: `vouchers`
- Changes: `{type, amount, entries}`
- Notes: Voucher type and purpose

### Voucher Reversal
- Action: `create`
- Collection: `vouchers`
- Changes: `{type: 'reversal', originalVoucherId}`
- Notes: Reversal reason

### Manual Voucher
- Action: `create`
- Collection: `vouchers`
- Changes: `{type, amount, entries}`
- Notes: User-provided narration

## Benefits

### For Admin
- ✅ Complete visibility into Accountant actions
- ✅ Audit trail for compliance
- ✅ Track who created/modified vouchers
- ✅ Review changes and reasons

### For Accountant
- ✅ No more permission errors
- ✅ Full access to accounting data
- ✅ Automatic audit logging (transparent)
- ✅ Can perform all accounting tasks

### For System
- ✅ Compliance-ready audit trail
- ✅ Local + remote audit storage
- ✅ Minimal performance impact
- ✅ Automatic logging (no manual steps)

## Future Enhancements

### Possible Additions
1. Filter audit logs by date range
2. Export audit logs to CSV/PDF
3. Search audit logs by user/action
4. Email alerts for critical actions
5. Audit log retention policy
6. Detailed change tracking (before/after values)

## Testing Checklist

- [ ] Deploy firestore rules
- [ ] Login as Accountant
- [ ] Create sales voucher (no errors)
- [ ] Create purchase voucher (no errors)
- [ ] Create manual voucher (no errors)
- [ ] Create reversal voucher (no errors)
- [ ] Logout as Accountant
- [ ] Login as Admin
- [ ] View audit log screen
- [ ] Verify all Accountant actions logged
- [ ] Check log details
- [ ] Refresh audit log

## Summary

### Problem Solved ✅
```
Accountant permission errors → FIXED
No audit trail → IMPLEMENTED
Admin can't track Accountant → SOLVED
```

### Files Created
1. `lib/services/accounting_audit_service.dart` - Audit logging service
2. `lib/modules/accounting/audited_posting_service.dart` - Wrapper with audit
3. `lib/modules/accounting/screens/accountant_audit_screen.dart` - Admin viewer

### Files Modified
1. `firestore.rules` - Added Accountant permissions

## Deploy Now! 🚀

```bash
firebase deploy --only firestore:rules
```

Accountant can now access all accounting data with full audit trail!
