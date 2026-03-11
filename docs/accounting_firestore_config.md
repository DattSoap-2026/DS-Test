# Accounting Firestore Deployment Snippets

## Firestore Indexes (`firestore.indexes.json`)
```json
{
  "indexes": [
    {
      "collectionGroup": "vouchers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "voucherType", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "vouchers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "transactionRefId", "order": "ASCENDING" },
        { "fieldPath": "__name__", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "vouchers",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" },
        { "fieldPath": "__name__", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "voucher_entries",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ledgerId", "order": "ASCENDING" },
        { "fieldPath": "date", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "voucher_entries",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "voucherId", "order": "ASCENDING" },
        { "fieldPath": "__name__", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "voucher_entries",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "ledgerId", "order": "ASCENDING" },
        { "fieldPath": "voucherType", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "accounts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "group", "order": "ASCENDING" },
        { "fieldPath": "parentGroup", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "financial_years",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "yearStart", "order": "ASCENDING" },
        { "fieldPath": "yearEnd", "order": "ASCENDING" }
      ]
    }
  ],
  "fieldOverrides": []
}
```

## Firestore Rules Snippet (Accountant-Restricted Accounting Access)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function userDoc() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid));
    }

    function userRole() {
      return isSignedIn() && userDoc().exists() ? userDoc().data.role : '';
    }

    function isAccountant() {
      return userRole() == 'Accountant' || userRole() == 'accountant';
    }

    function isAdminLike() {
      return userRole() == 'Admin' || userRole() == 'Owner';
    }

    match /accounts/{docId} {
      allow read: if isAccountant();
      allow write: if false;
    }

    match /voucher_entries/{docId} {
      allow read: if isAccountant();
      allow create, update: if false;
      allow delete: if false;
    }

    match /vouchers/{docId} {
      allow read: if isAccountant();
      allow create, update: if isAccountant();
      allow delete: if false;
    }

    match /financial_years/{docId} {
      allow read: if isAccountant();
      allow create, update: if isAccountant();
      allow delete: if false;
    }

    match /accounting_compensation_log/{docId} {
      allow read: if isAccountant() || isAdminLike();
      allow create: if isAccountant();
      allow update, delete: if false;
    }

    match /users/{docId} {
      allow write: if !isAccountant();
    }

    match /public_settings/{docId} {
      allow write: if !isAccountant();
    }

    match /settings/{docId} {
      allow write: if !isAccountant();
    }

    match /tax_config/{docId} {
      allow write: if !isAccountant();
    }

    match /gst_settings/{docId} {
      allow write: if !isAccountant();
    }
  }
}
```

Note: merge this snippet with your existing production rules base to avoid overriding current operational protections.
