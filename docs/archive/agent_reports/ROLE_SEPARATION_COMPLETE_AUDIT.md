# COMPLETE PROJECT AUDIT - ROLE SEPARATION

**Date**: 2024
**Scope**: Full project audit with role-based access control
**Focus**: Bhatti Supervisor vs Production Supervisor

---

## 👥 ROLE DEFINITIONS

### BHATTI SUPERVISOR
**Primary Responsibility**: Raw Materials → Semi-Finished Products
**Unit**: Bhatti (Gita Bhatti / Sona Bhatti)
**Key Tasks**:
1. Create Bhatti batches using formulas
2. Consume raw materials from godown
3. Consume oils/liquids from tanks
4. Produce semi-finished soap base (boxes)
5. Track wastage and reusable materials
6. Monitor Bhatti operations
7. Manage Bhatti inventory

**Access Required**:
- ✅ Bhatti Dashboard
- ✅ Bhatti Cooking Screen (Create Batch)
- ✅ Bhatti Batch Edit Screen
- ✅ Bhatti Supervisor Screen (List Batches)
- ✅ Raw Material Stock
- ✅ Tank Management
- ✅ Semi-Finished Stock (Output)
- ❌ Cutting Operations (NO ACCESS)
- ❌ Finished Goods (NO ACCESS)
- ❌ Packing Operations (NO ACCESS)

---

### PRODUCTION SUPERVISOR
**Primary Responsibility**: Semi-Finished → Finished Goods
**Unit**: Production/Cutting Department
**Key Tasks**:
1. Create cutting batches
2. Consume semi-finished products (boxes)
3. Produce finished goods (pieces)
4. Manage packaging materials
5. Track cutting wastage
6. Quality control (weight validation)
7. Packing operations
8. Manage finished goods inventory

**Access Required**:
- ✅ Production Dashboard
- ✅ Cutting Batch Entry Screen
- ✅ Cutting History Screen
- ✅ Batch Details Screen
- ✅ Semi-Finished Stock (Input)
- ✅ Finished Goods Stock (Output)
- ✅ Packaging Materials
- ✅ Packing Operations
- ❌ Bhatti Operations (NO ACCESS)
- ❌ Raw Materials (NO ACCESS)
- ❌ Tank Management (NO ACCESS)

---

## 🔍 CURRENT STATE ANALYSIS

### Issue #1: Role Confusion
**Problem**: Both roles can access each other's screens
**Current**: No proper role-based access control
**Impact**: Bhatti Supervisor can create cutting batches, Production Supervisor can create Bhatti batches

### Issue #2: Mixed Dashboards
**Problem**: Dashboards show data from both departments
**Current**: Production Dashboard shows Bhatti + Cutting data
**Impact**: Confusing for role-specific users

### Issue #3: Stock Visibility
**Problem**: All users see all stock types
**Current**: Bhatti Supervisor sees finished goods, Production Supervisor sees raw materials
**Impact**: Unnecessary information, potential confusion

---

## 📊 COMPLETE WORKFLOW SEPARATION

### WORKFLOW 1: BHATTI SUPERVISOR
```
┌─────────────────────────────────────────────────┐
│ BHATTI SUPERVISOR WORKFLOW                      │
├─────────────────────────────────────────────────┤
│ 1. Login as Bhatti Supervisor                   │
│ 2. View Bhatti Dashboard                        │
│    - Active batches                             │
│    - Raw material consumption                   │
│    - Tank levels                                │
│    - Semi-finished output                       │
│ 3. Create New Bhatti Batch                      │
│    - Select Bhatti (Gita/Sona)                  │
│    - Select formula                             │
│    - Select raw materials                       │
│    - Select tank materials                      │
│    - Enter batch count                          │
│    - System calculates output boxes             │
│ 4. System Actions                               │
│    - Reduce raw material stock                  │
│    - Reduce tank stock                          │
│    - Increase semi-finished stock               │
│    - Create stock ledger entries                │
│ 5. View Bhatti History                          │
│    - List of batches created                    │
│    - Material consumption                       │
│    - Output produced                            │
│ 6. Manage Bhatti Inventory                      │
│    - Raw materials                              │
│    - Tanks                                      │
│    - Semi-finished products                     │
└─────────────────────────────────────────────────┘

SCREENS ACCESSIBLE:
✅ Bhatti Dashboard
✅ Bhatti Supervisor Screen
✅ Bhatti Cooking Screen
✅ Bhatti Batch Edit Screen
✅ Raw Material Stock
✅ Tank Management
✅ Semi-Finished Stock

SCREENS BLOCKED:
❌ Production Dashboard
❌ Cutting Batch Entry
❌ Cutting History
❌ Finished Goods Stock
❌ Packaging Materials
```

---

### WORKFLOW 2: PRODUCTION SUPERVISOR
```
┌─────────────────────────────────────────────────┐
│ PRODUCTION SUPERVISOR WORKFLOW                  │
├─────────────────────────────────────────────────┤
│ 1. Login as Production Supervisor               │
│ 2. View Production Dashboard                    │
│    - Cutting batches                            │
│    - Semi-finished consumption                  │
│    - Finished goods output                      │
│    - Packaging usage                            │
│ 3. Create New Cutting Batch                     │
│    - Select semi-finished product               │
│    - Enter batch count                          │
│    - System calculates boxes needed             │
│    - Select finished product                    │
│    - Enter units produced                       │
│    - Validate weight                            │
│    - System calculates packaging                │
│ 4. System Actions                               │
│    - Reduce semi-finished stock                 │
│    - Increase finished goods stock              │
│    - Reduce packaging stock                     │
│    - Create stock ledger entries                │
│ 5. View Cutting History                         │
│    - List of batches created                    │
│    - Semi-finished consumption                  │
│    - Finished goods output                      │
│    - Packaging usage                            │
│ 6. Manage Production Inventory                  │
│    - Semi-finished products                     │
│    - Finished goods                             │
│    - Packaging materials                        │
└─────────────────────────────────────────────────┘

SCREENS ACCESSIBLE:
✅ Production Dashboard
✅ Cutting Batch Entry
✅ Cutting History
✅ Batch Details
✅ Semi-Finished Stock
✅ Finished Goods Stock
✅ Packaging Materials

SCREENS BLOCKED:
❌ Bhatti Dashboard
❌ Bhatti Supervisor Screen
❌ Bhatti Cooking Screen
❌ Raw Material Stock
❌ Tank Management
```

---

## 🔒 REQUIRED ACCESS CONTROL IMPLEMENTATION

### File: `lib/models/types/user_types.dart`

**Current Roles**:
```dart
enum UserRole {
  owner,
  admin,
  productionManager,
  salesManager,
  accountant,
  dispatchManager,
  bhattiSupervisor,      // ← Bhatti operations only
  driver,
  salesman,
  gateKeeper,
  storeIncharge,
  productionSupervisor,  // ← Cutting/Packing operations only
  fuelIncharge,
  vehicleMaintenanceManager,
  dealerManager,
}
```

**Access Control Helpers Needed**:
```dart
extension UserRoleExtension on UserRole {
  // Bhatti Access
  bool get canAccessBhatti {
    return this == UserRole.bhattiSupervisor ||
           this == UserRole.admin ||
           this == UserRole.owner ||
           this == UserRole.productionManager;
  }
  
  // Production/Cutting Access
  bool get canAccessProduction {
    return this == UserRole.productionSupervisor ||
           this == UserRole.admin ||
           this == UserRole.owner ||
           this == UserRole.productionManager;
  }
  
  // Raw Material Access
  bool get canAccessRawMaterials {
    return this == UserRole.bhattiSupervisor ||
           this == UserRole.storeIncharge ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }
  
  // Finished Goods Access
  bool get canAccessFinishedGoods {
    return this == UserRole.productionSupervisor ||
           this == UserRole.dispatchManager ||
           this == UserRole.salesManager ||
           this == UserRole.admin ||
           this == UserRole.owner;
  }
}
```

---

## 🚫 SCREEN-LEVEL ACCESS CONTROL

### Bhatti Screens
**Files to Protect**:
- `bhatti_dashboard_screen.dart`
- `bhatti_supervisor_screen.dart`
- `bhatti_cooking_screen.dart`
- `bhatti_batch_edit_screen.dart`

**Add Access Check**:
```dart
@override
void initState() {
  super.initState();
  final user = context.read<AuthProvider>().currentUser;
  if (user == null || !user.role.canAccessBhatti) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access Denied: Bhatti operations only'),
          backgroundColor: AppColors.error,
        ),
      );
    });
  }
}
```

---

### Production Screens
**Files to Protect**:
- `production_dashboard_consolidated_screen.dart`
- `cutting_batch_entry_screen.dart`
- `cutting_history_screen.dart`
- `batch_details_screen.dart`

**Add Access Check**:
```dart
@override
void initState() {
  super.initState();
  final user = context.read<AuthProvider>().currentUser;
  if (user == null || !user.role.canAccessProduction) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access Denied: Production operations only'),
          backgroundColor: AppColors.error,
        ),
      );
    });
  }
}
```

---

## 📱 NAVIGATION MENU FILTERING

### File: `lib/widgets/navigation/main_drawer.dart` (or similar)

**Filter Menu Items by Role**:
```dart
List<MenuItem> _getMenuItems(UserRole role) {
  final items = <MenuItem>[];
  
  // Dashboard (All)
  items.add(MenuItem(title: 'Dashboard', icon: Icons.dashboard));
  
  // Bhatti Section (Bhatti Supervisor only)
  if (role.canAccessBhatti) {
    items.add(MenuItem(title: 'Bhatti Dashboard', icon: Icons.fire));
    items.add(MenuItem(title: 'Create Bhatti Batch', icon: Icons.add));
    items.add(MenuItem(title: 'Bhatti History', icon: Icons.history));
    items.add(MenuItem(title: 'Raw Materials', icon: Icons.inventory));
    items.add(MenuItem(title: 'Tanks', icon: Icons.water));
  }
  
  // Production Section (Production Supervisor only)
  if (role.canAccessProduction) {
    items.add(MenuItem(title: 'Production Dashboard', icon: Icons.factory));
    items.add(MenuItem(title: 'Create Cutting Batch', icon: Icons.cut));
    items.add(MenuItem(title: 'Cutting History', icon: Icons.history));
    items.add(MenuItem(title: 'Finished Goods', icon: Icons.inventory_2));
    items.add(MenuItem(title: 'Packaging', icon: Icons.package));
  }
  
  return items;
}
```

---

## 📊 DASHBOARD SEPARATION

### Current: Mixed Dashboard
**Problem**: Shows both Bhatti and Cutting data
**File**: `production_dashboard_consolidated_screen.dart`

### Solution: Role-Based Dashboards

**Bhatti Dashboard** (`bhatti_dashboard_screen.dart`):
```dart
- Active Bhatti Batches
- Raw Material Consumption (Today/Week/Month)
- Tank Levels
- Semi-Finished Output (Boxes)
- Wastage Tracking
- Cost Analysis
- Bhatti Efficiency
```

**Production Dashboard** (`production_dashboard_consolidated_screen.dart`):
```dart
- Active Cutting Batches
- Semi-Finished Consumption (Boxes)
- Finished Goods Output (Pieces)
- Packaging Usage
- Cutting Wastage
- Weight Validation Stats
- Production Efficiency
```

---

## 🗄️ STOCK VISIBILITY CONTROL

### Semi-Finished Products
**Visible To**:
- ✅ Bhatti Supervisor (Output - can see what they produced)
- ✅ Production Supervisor (Input - can see what's available)
- ✅ Admin/Owner (Full visibility)

### Raw Materials
**Visible To**:
- ✅ Bhatti Supervisor (Input - can see what's available)
- ✅ Store Incharge (Management)
- ✅ Admin/Owner (Full visibility)
- ❌ Production Supervisor (No access)

### Finished Goods
**Visible To**:
- ✅ Production Supervisor (Output - can see what they produced)
- ✅ Sales Manager (For selling)
- ✅ Dispatch Manager (For dispatch)
- ✅ Admin/Owner (Full visibility)
- ❌ Bhatti Supervisor (No access)

---

## 🔄 HANDOVER POINT: SEMI-FINISHED PRODUCTS

### Critical Integration Point
**Location**: Semi-Finished Stock
**Purpose**: Handover from Bhatti to Production

**Bhatti Supervisor View**:
```
Semi-Finished Stock (OUTPUT)
- Shows what they produced
- Can see stock levels
- Can see which batches created it
- Read-only access
```

**Production Supervisor View**:
```
Semi-Finished Stock (INPUT)
- Shows what's available for cutting
- Can see stock levels
- Can consume for cutting batches
- Read-only access (cannot modify)
```

**Business Rule**:
- Bhatti Supervisor INCREASES semi-finished stock
- Production Supervisor DECREASES semi-finished stock
- Both can VIEW but only their operations can MODIFY

---

## 🚨 CRITICAL CHANGES REQUIRED

### Priority 1: Access Control (CRITICAL)
1. Add role extension methods to UserRole
2. Add access checks to all Bhatti screens
3. Add access checks to all Production screens
4. Filter navigation menu by role
5. Test access denial

### Priority 2: Dashboard Separation (HIGH)
1. Keep Bhatti Dashboard for Bhatti Supervisor
2. Keep Production Dashboard for Production Supervisor
3. Remove cross-department data from each
4. Add role-based data filtering

### Priority 3: Stock Visibility (MEDIUM)
1. Filter stock screens by role
2. Show only relevant stock types
3. Add role-based stock queries
4. Update stock services

### Priority 4: UI/UX Updates (LOW)
1. Update screen titles to be role-specific
2. Add role badges/indicators
3. Update help text for each role
4. Add role-specific tutorials

---

## 🧪 TESTING CHECKLIST

### Bhatti Supervisor Tests
- [ ] Login as Bhatti Supervisor
- [ ] Can access Bhatti Dashboard
- [ ] Can create Bhatti batch
- [ ] Can view Bhatti history
- [ ] Can see raw materials
- [ ] Can see tanks
- [ ] Can see semi-finished stock (output)
- [ ] CANNOT access Production Dashboard
- [ ] CANNOT create cutting batch
- [ ] CANNOT see finished goods
- [ ] CANNOT see packaging materials

### Production Supervisor Tests
- [ ] Login as Production Supervisor
- [ ] Can access Production Dashboard
- [ ] Can create cutting batch
- [ ] Can view cutting history
- [ ] Can see semi-finished stock (input)
- [ ] Can see finished goods
- [ ] Can see packaging materials
- [ ] CANNOT access Bhatti Dashboard
- [ ] CANNOT create Bhatti batch
- [ ] CANNOT see raw materials
- [ ] CANNOT see tanks

### Admin Tests
- [ ] Login as Admin
- [ ] Can access ALL screens
- [ ] Can see ALL stock types
- [ ] Can perform ALL operations

---

## 📋 IMPLEMENTATION STEPS

### Step 1: Add Role Extensions
**File**: `lib/models/types/user_types.dart`
**Action**: Add canAccessBhatti, canAccessProduction methods

### Step 2: Protect Bhatti Screens
**Files**: All bhatti_*.dart screens
**Action**: Add access check in initState

### Step 3: Protect Production Screens
**Files**: All production/cutting screens
**Action**: Add access check in initState

### Step 4: Filter Navigation
**File**: Navigation/drawer widget
**Action**: Show only relevant menu items

### Step 5: Separate Dashboards
**Files**: Dashboard screens
**Action**: Filter data by role

### Step 6: Control Stock Visibility
**Files**: Stock screens and services
**Action**: Filter by role

### Step 7: Test Everything
**Action**: Run complete test suite

---

## 🎯 EXPECTED OUTCOME

### Before Implementation
- ❌ Both roles can access all screens
- ❌ Confusing mixed dashboards
- ❌ Unnecessary stock visibility
- ❌ No clear role separation

### After Implementation
- ✅ Role-based access control
- ✅ Separate dashboards per role
- ✅ Relevant stock visibility only
- ✅ Clear role separation
- ✅ Better user experience
- ✅ Reduced confusion
- ✅ Improved security

---

## 📊 SUMMARY

**Current State**: Mixed access, no role separation
**Required State**: Strict role-based access control

**Bhatti Supervisor**:
- Focus: Raw Materials → Semi-Finished
- Unit: Bhatti (Gita/Sona)
- Access: Bhatti operations only

**Production Supervisor**:
- Focus: Semi-Finished → Finished Goods
- Unit: Production/Cutting
- Access: Production operations only

**Critical Changes**: 7 major areas
**Estimated Effort**: 3-4 days
**Priority**: HIGH (Security & UX)

**Status**: Ready for implementation ✅
