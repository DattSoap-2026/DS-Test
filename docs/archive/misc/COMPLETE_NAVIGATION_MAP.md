# DattSoap - Complete RBAC Structure & Navigation Map

**Date:** January 22, 2026  
**Status:** RBAC Audit Complete & Fixed 

---

## User Roles & Their Authorized Pages

### 1. ADMIN
**Access Level:** FULL SYSTEM ACCESS
-  All menus visible
-  All pages accessible
-  All operations allowed

---

### 2. PRODUCTION SUPERVISOR  (FOCUSED VIEW)

**Authorized Menus:**
```
Production ()
 Dashboard ()
 Cutting Entry ()
 History ()
```

**Total Pages Visible:** 3  
**Total Menus Visible:** 1

**Can Also Access (Direct Route):**
- Production Report (`/dashboard/reports/production`)

**Cannot See:**
-  Salesman Performance
-  Tasks menu
-  Reports menu (main)
-  All other departmental menus
-  Dashboard (main)

---

### 3. STORE INCHARGE
**Authorized Menus:**
```
Procurement ()
 Purchase Orders
 Receive Goods (GRN)
 Smart Reorder
 Issue Materials
 Fuel Stock
 Fuel History

Inventory ()
 Stock Inventory
 Liquid Tanks
 Stock Adjustments

Fuel Mgmt ()
 Current Fuel Stock
 Fuel History

Vehicle Mgmt ()
 Vehicle Fleet
 Maintenance Logs
 Diesel Tracking
 Tyre Management

Dispatch ()
 Stock Dispatch
 Dealer Dispatch
 Create Trip

Business Partners ()

Management ()
 Formulas
 (limited access)

Location & ... ()
 Real-time Tracking
 Route Planning

Reports ()
 Production
 Financial
 (limited)

Payments ()

Tasks ()
```

**Cannot See:**
-  Settings
-  Salesman Performance
-  Returns
-  Bhatti menu
-  Driver menu
-  Production menu

---

### 4. SALESMAN
**Authorized Menus:**
```
Home () [Bottom]
Customers () [Bottom]
New Sale () [Bottom]
Reports () [Bottom]
My Stock () [Bottom]
```

**Special Pages:**
- Salesman Performance Report
- Target Analysis
- Salesman Inventory
- Customer List
- Sales Entry

**Cannot See:**
-  Procurement
-  Inventory
-  Fuel
-  Vehicles
-  Dispatch
-  Management
-  Settings
-  Production
-  Bhatti
-  Driver
-  Tasks (except as task assignee)

---

### 5. FUEL INCHARGE
**Authorized Menus:**
```
Fuel Mgmt ()
 Add Fuel Log (Can add only)
 (Limited access)

Reports ()
 (Limited reports only)
```

**Cannot See:**
-  Most other menus
-  Production
-  Procurement
-  Inventory
-  Vehicles
-  Management
-  Settings

---

### 6. BHATTI SUPERVISOR
**Authorized Menus:**
```
Dashboard () [Bottom]
Batch Mgmt () [Bottom]
Reports () [Bottom]
```

**Role-Specific:**
- Bhatti Overview
- Manage Batches (Cooking process)
- Bhatti Reports

**Cannot See:**
-  All top-level menus
-  Production
-  Salesman pages
-  Fuel
-  Vehicles
-  Dispatch
-  Management
-  Settings

---

### 7. DRIVER
**Authorized Menus:**
```
Tasks ()
```

**Can Access:**
- Task assignments
- Duty management
- Trip details
- Dashboard (main)

**Cannot See:**
-  Production
-  Procurement
-  Inventory
-  Management
-  Settings
-  Salesman pages
-  Bhatti pages

---

## Top-Level Navigation Menu

| Menu Item | Roles | Visible? |
|-----------|-------|----------|
| Dashboard | admin, storeIncharge, salesman, fuelIncharge, driver |  |
| Procurement | admin, storeIncharge |  |
| Inventory | admin, storeIncharge |  |
| **Production** | **admin, productionSupervisor** |  Production Supervisor |
| Fuel Mgmt | admin, storeIncharge, fuelIncharge |  |
| Vehicle Mgmt | admin, storeIncharge |  |
| Dispatch | admin, storeIncharge |  |
| Business Partners | admin, storeIncharge |  |
| Management | admin, storeIncharge |  |
| Location & ... | admin, storeIncharge |  |
| Reports | admin, storeIncharge, fuelIncharge |  |
| Returns | salesman, admin, storeIncharge |  |
| Tasks | admin, salesman, storeIncharge, driver |  |
| Payments | admin, storeIncharge |  |
| Settings | admin |  |
| Bhatti Menu | bhattiSupervisor |  |
| Salesman Menu | salesman |  |

---

## Navigation Filtering Logic

The system uses `nav_items.dart` to filter menus based on user role:

```dart
// User role is checked against NavItem.roles
// Only NavItems matching user.role are displayed

// For Production Supervisor
if (userRole == UserRole.productionSupervisor) {
  // Can see:
  // - Production menu (all submenu items)
  // - Production report (/dashboard/reports/production)
  
  // Cannot see:
  // - Salesman Performance (admin only)
  // - Tasks (admin, salesman, storeIncharge, driver only)
  // - Reports menu (admin, storeIncharge, fuelIncharge only)
  // - All other menus
}
```

---

## Production Supervisor - Detailed Menu

### Production Dashboard (`/dashboard/production`)
- **Role:** admin, productionSupervisor 
- **Show:** Today's cutting summary, batch counts, waste totals
- **Actions:** Start Cutting, View Reports, History

### Cutting Entry (`/dashboard/production/cutting/entry`)
- **Role:** admin, productionSupervisor 
- **Show:** Cutting form for batch entry
- **Operations:** Semi-finished input, finished goods output, waste tracking
- **Features:** Weight validation, stock adjustments, calculations

### History (`/dashboard/production/cutting/history`)
- **Role:** admin, productionSupervisor 
- **Show:** Read-only batch history
- **Filter:** By date, product
- **Details:** Batch metrics, yield %, waste analysis

### Production Report (`/dashboard/reports/production`)
- **Role:** admin, productionSupervisor 
- **Access:** Direct via hyperlink (not in menu)
- **Show:** Production analytics, KPIs, trends
- **Read-only:** True

---

## Why These Rules?

### Production Supervisor Role Restrictions

**Why NO access to Salesman pages?**
- Different department
- Different KPIs
- Different responsibilities

**Why NO access to Tasks?**
- Tasks are for general operations
- Production supervisors have specific cutting tasks only

**Why NO access to Reports menu (main)?**
- General reports are for admin/store
- Production supervisor gets only their report

**Why NO access to Fuel/Vehicles/Dispatch?**
- Completely different departments
- No operational need
- Data security

**Why CAN access Production Report?**
- Direct operational need
- Reports on their own cutting work
- Read-only analytics

---

## Authorization Summary

```
Production Supervisor Menu Access:
 TOP LEVEL MENUS: 1/15 visible (Production only)
 SUBMENU ITEMS: 3/3 production items
 TOTAL PAGES: 4 (Dashboard, Cutting Entry, History, Report)
 OPERATIONS: Create batches, view history, read reports
 RESTRICTIONS: No cross-department access, no admin functions
```

---

## Recent RBAC Fixes (Jan 22, 2026)

### Issue 1: Reports Menu Visibility
- **Before:** productionSupervisor in Reports menu roles
- **After:** Removed from top-level Reports menu
- **Fix:** Can only access Production report directly

### Issue 2: Tasks Menu
- **Before:** productionSupervisor in Tasks roles
- **After:** Removed from Tasks menu
- **Fix:** Production supervisors don't see Tasks menu

### Issue 3: Reports Submenu Duplication
- **Before:** Production menu had duplicate Reports item
- **After:** Removed to avoid confusion
- **Fix:** Cleaner menu structure

---

## Testing RBAC

**To verify Production Supervisor sees only correct pages:**

1. Login as Production Supervisor
2. Check visible menus: Should see ONLY Production
3. Try to access other pages: Should be blocked by RBAC
4. Click on Cutting Entry: Should open form
5. Click on History: Should show batch list
6. Click on Reports link: Should show production report
7. Cannot see Salesman Performance: RBAC blocking works

---

## File References

- **Navigation Configuration:** `lib/constants/nav_items.dart`
- **Router Setup:** `lib/routers/app_router.dart`
- **Production Screens:**
  - `lib/screens/production/production_dashboard_consolidated_screen.dart`
  - `lib/screens/production/cutting_batch_entry_screen.dart`
  - `lib/screens/production/cutting_history_screen.dart`
- **Reports:** `lib/screens/reports/production_report_screen.dart`

---

## Build Status
 Flutter Analyze: 22 issues (0 errors)  
 RBAC properly enforced  
 No broken navigation  
 Role-based menu filtering working

---

**RBAC Audit Complete** 

