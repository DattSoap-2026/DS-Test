# Security & Role-Based Access Control (RBAC)

**Version:** 2.7  
**Last Updated:** March 2026

---

## Overview

DattSoap ERP implements comprehensive role-based access control with screen-level and operation-level permissions.

---

## User Roles

### 1. Admin
**Access:** Full system access  
**Screens:** All  
**Operations:** All

### 2. Store Incharge
**Access:** Inventory, procurement, dispatch  
**Screens:** Procurement, inventory, dispatch, vehicles, fuel, payments  
**Operations:** Create/edit/delete in assigned modules

### 3. Production Supervisor
**Access:** Production and cutting only  
**Screens:** Production dashboard, cutting entry, history  
**Operations:** Create batches, view reports  
**Restrictions:** Cannot access other departments

### 4. Bhatti Supervisor
**Access:** Bhatti operations only  
**Screens:** Bhatti dashboard, cooking, material issue  
**Operations:** Create batches, issue materials  
**Restrictions:** Cannot access other departments

### 5. Salesman
**Access:** Sales and customers (mobile)  
**Screens:** Sales, customers, performance  
**Operations:** Create sales, manage customers  
**Restrictions:** Own data only

### 6. Fuel Incharge
**Access:** Fuel logging only  
**Screens:** Fuel management  
**Operations:** Add fuel logs  
**Restrictions:** Limited access

### 7. Driver
**Access:** Task management  
**Screens:** Tasks, trips  
**Operations:** View assignments, update status  
**Restrictions:** Own tasks only

---

## Access Control Implementation

### Screen-Level Protection

**File:** `lib/utils/access_guard.dart`

```dart
class AccessGuard {
  static void checkBhattiAccess(BuildContext context) {
    final user = context.read<AuthProvider>().state.user;
    if (!_hasBhattiAccess(user.role)) {
      _showAccessDenied(context);
      context.go('/dashboard');
    }
  }
  
  static void checkProductionAccess(BuildContext context) {
    final user = context.read<AuthProvider>().state.user;
    if (!_hasProductionAccess(user.role)) {
      _showAccessDenied(context);
      context.go('/dashboard');
    }
  }
}
```

### Usage in Screens

```dart
@override
void initState() {
  super.initState();
  AccessGuard.checkBhattiAccess(context);
  // ... rest of initialization
}
```

---

## Navigation Filtering

**File:** `lib/constants/nav_items.dart`

Navigation items filtered by role:

```dart
NavItem(
  title: 'Production',
  icon: Icons.factory,
  route: '/dashboard/production',
  roles: [UserRole.admin, UserRole.productionSupervisor],
),
```

Only matching roles see the menu item.

---

## Permission Matrix

| Module | Admin | Store | Prod Sup | Bhatti Sup | Salesman | Fuel | Driver |
|--------|-------|-------|----------|------------|----------|------|--------|
| Dashboard | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Procurement | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Inventory | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Production | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Bhatti | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Cutting | ✅ | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Sales | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Dispatch | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Vehicles | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Fuel | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Payments | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Reports | ✅ | ✅ | ✅* | ✅* | ✅* | ✅* | ❌ |
| Settings | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Tasks | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ | ✅ |

*Limited to own department reports

---

## Firebase Security Rules

### Firestore Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Sales - user can only access own sales
    match /sales/{saleId} {
      allow read: if request.auth != null && 
        (resource.data.salesmanId == request.auth.uid || 
         get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'storeIncharge']);
      allow create: if request.auth != null && 
        request.resource.data.salesmanId == request.auth.uid;
    }
    
    // Production - only production roles
    match /production_batches/{batchId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'productionSupervisor'];
    }
    
    // Bhatti - only bhatti roles
    match /bhatti_batches/{batchId} {
      allow read, write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'bhattiSupervisor'];
    }
    
    // Master data - read all, write admin only
    match /products/{productId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

---

## Authentication

### Firebase Auth
- Email/password authentication
- Secure token storage
- Automatic token refresh
- Session management

### Login Flow
1. User enters credentials
2. Firebase Auth validates
3. Retrieve user role from Firestore
4. Load user permissions
5. Navigate to role-specific dashboard

---

## Data Security

### Local Storage
- Sensitive data encrypted
- Secure token storage
- Auto-logout on inactivity

### Network
- HTTPS only
- Certificate pinning
- Request validation

### Audit Logging
- All critical operations logged
- User actions tracked
- Timestamp and user ID recorded

---

## Best Practices

### For Developers
1. Always check user role before operations
2. Use AccessGuard for screen protection
3. Filter navigation by role
4. Validate permissions server-side
5. Log security events

### For Administrators
1. Assign minimum required permissions
2. Review user roles regularly
3. Monitor audit logs
4. Disable inactive users
5. Rotate credentials periodically

---

## Testing RBAC

### Test Scenarios
1. Login as each role
2. Verify visible menus
3. Attempt unauthorized access
4. Check data filtering
5. Verify operation permissions

### Expected Behavior
- Unauthorized screens redirect to dashboard
- Access denied message shown
- Navigation filtered correctly
- Data scoped to user permissions

---

## References

- [Architecture](architecture.md)
- [Master Data](master_data.md)
- [Module Documentation](modules/)
