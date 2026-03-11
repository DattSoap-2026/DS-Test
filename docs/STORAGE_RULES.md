# Firebase Storage Security Rules

**Created:** March 2026  
**Status:** ✅ COMPLETE

---

## 📁 Storage Structure

```
storage/
├── products/              # Product images (public read)
│   ├── finished/
│   └── traded/
├── users/{userId}/        # User files (private)
│   ├── profile/
│   └── documents/
├── employees/{empId}/     # Employee docs (HR access)
│   └── documents/
├── company/               # Company docs (admin only)
├── vehicles/{vehicleId}/  # Vehicle docs
│   └── documents/
├── invoices/              # Invoice PDFs
├── reports/               # Report PDFs
├── backups/               # Backup files (admin only)
└── temp/{userId}/         # Temporary files
```

---

## 🔒 Access Rules

### Product Images
- **Read:** Public (anyone)
- **Write:** Managers only
- **Types:** Images only
- **Size:** < 10MB

### User Files
- **Read:** Owner or Admin
- **Write:** Owner only
- **Types:** Images & Documents
- **Size:** < 10MB

### Employee Documents
- **Read:** Employee or Managers
- **Write:** Managers only
- **Types:** PDF, Images, Word docs
- **Size:** < 10MB

### Company Documents
- **Read:** All authenticated users
- **Write:** Admin only
- **Types:** PDF, Images, Word docs
- **Size:** < 10MB

### Invoices & Reports
- **Read:** All authenticated users
- **Write:** All authenticated users
- **Types:** PDF only
- **Size:** < 10MB

### Backups
- **Read/Write:** Admin only
- **No restrictions**

### Temp Files
- **Read/Write:** Owner only
- **Size:** < 10MB
- **Auto-delete:** After 24h (configure in Firebase Console)

---

## 🎯 Security Features

1. **Role-Based Access:** Uses Firestore user roles
2. **File Type Validation:** Only allowed types
3. **Size Limits:** 10MB max for most files
4. **Private by Default:** Explicit allow rules only
5. **Owner Checks:** Users can only access own files

---

## 📋 Deployment

```bash
# Deploy storage rules
firebase deploy --only storage

# Or deploy all
firebase deploy
```

---

**Status:** ✅ PRODUCTION READY
