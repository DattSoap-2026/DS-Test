# V2-7 UI Migration - Manual Verification Checklist

## Pre-Testing Setup
- [ ] Build the app: `flutter build windows --release` (or your target platform)
- [ ] Clear app data/cache to test fresh state
- [ ] Ensure test user credentials are ready

---

## 1. Authentication & Routing Tests

### Test 1.1: Login Flow
- [ ] Open app (should show login screen)
- [ ] Enter valid credentials
- [ ] Click login
- [ ] **Expected**: Redirects to appropriate dashboard based on role
- [ ] **Verify**: No console errors

### Test 1.2: Logout Flow
- [ ] Navigate to any protected route
- [ ] Click user menu  Logout
- [ ] Confirm logout dialog
- [ ] **Expected**: Redirects to login screen immediately
- [ ] **Verify**: No "permission denied" errors in console

### Test 1.3: Session Persistence
- [ ] Login successfully
- [ ] Close app completely
- [ ] Reopen app
- [ ] **Expected**: User remains logged in, lands on dashboard
- [ ] **Verify**: No loading flicker or re-authentication

### Test 1.4: Protected Route Access
- [ ] Logout
- [ ] Try to manually navigate to `/dashboard` (if possible)
- [ ] **Expected**: Redirects to login
- [ ] Login and navigate to dashboard
- [ ] **Expected**: Access granted

---

## 2. Alerts Screen Tests

### Test 2.1: Loading State
- [ ] Navigate to Settings  System Alerts
- [ ] **Expected**: Shows loading spinner initially
- [ ] **Verify**: No blank screen or crash

### Test 2.2: Data Display
- [ ] Wait for alerts to load
- [ ] **Expected**: Shows list of alerts OR "All clear" message
- [ ] **Verify**: Alerts display with proper formatting

### Test 2.3: Mark as Read
- [ ] Click on an unread alert
- [ ] **Expected**: Alert marked as read, UI updates
- [ ] **Verify**: No page refresh required

### Test 2.4: Clear All
- [ ] Click "Clear Read" button
- [ ] Confirm dialog
- [ ] **Expected**: Read alerts removed, list updates
- [ ] **Verify**: Unread alerts remain

### Test 2.5: Error Handling
- [ ] Disconnect internet (if testing offline mode)
- [ ] Navigate to alerts
- [ ] **Expected**: Shows error message gracefully
- [ ] Reconnect internet
- [ ] **Expected**: Retry works

---

## 3. Inventory Table Tests

### Test 3.1: Product List Display
- [ ] Navigate to Inventory  Stock Overview
- [ ] **Expected**: Products load and display in table
- [ ] **Verify**: Stock levels, prices, status badges visible

### Test 3.2: Filtering
- [ ] Use search box to filter products
- [ ] **Expected**: Table updates reactively
- [ ] Clear search
- [ ] **Expected**: Full list returns

### Test 3.3: Sorting
- [ ] Click column headers to sort
- [ ] **Expected**: Table re-sorts without full reload
- [ ] **Verify**: Sort order persists

### Test 3.4: Department Breakdown (Expandable)
- [ ] Click expand icon on a raw material product
- [ ] **Expected**: Shows department stock breakdown
- [ ] **Verify**: Loading spinner  data OR "No allocations"
- [ ] Click collapse
- [ ] **Expected**: Breakdown hides

---

## 4. Vehicle Issue Dialog Tests

### Test 4.1: Dialog Open
- [ ] Navigate to Vehicles
- [ ] Click "Report Issue" button
- [ ] **Expected**: Dialog opens

### Test 4.2: Vehicle Dropdown Loading
- [ ] Observe vehicle dropdown
- [ ] **Expected**: Shows loading indicator  populates with vehicles
- [ ] **Verify**: No duplicate vehicles in list

### Test 4.3: Form Submission
- [ ] Select vehicle
- [ ] Enter description
- [ ] Select priority
- [ ] Click "Report Issue"
- [ ] **Expected**: Dialog closes, success message shown
- [ ] **Verify**: Issue appears in vehicle details

### Test 4.4: Validation
- [ ] Try to submit without selecting vehicle
- [ ] **Expected**: Validation error shown
- [ ] Try to submit without description
- [ ] **Expected**: Validation error shown

---

## 5. Refill Tank Dialog Tests

### Test 5.1: Dialog Open
- [ ] Navigate to Inventory  Tanks
- [ ] Click "Refill" on any tank
- [ ] **Expected**: Dialog opens

### Test 5.2: Suppliers Loading
- [ ] Observe supplier autocomplete field
- [ ] **Expected**: Shows loading  populates suppliers
- [ ] Click field
- [ ] **Expected**: Shows all suppliers in dropdown

### Test 5.3: PO Auto-fill
- [ ] Check "Reference" field
- [ ] **Expected**: Auto-filled with latest PO number
- [ ] **Verify**: Can be manually edited

### Test 5.4: Tank Selection
- [ ] Search for a tank in autocomplete
- [ ] **Expected**: Filters results reactively
- [ ] Select tank
- [ ] **Expected**: Shows current stock and capacity info

### Test 5.5: Form Submission
- [ ] Enter valid quantity
- [ ] Select supplier
- [ ] Click "Confirm Refill"
- [ ] **Expected**: Dialog closes, tank stock updates
- [ ] **Verify**: Transaction logged

### Test 5.6: Validation
- [ ] Try to exceed tank capacity
- [ ] **Expected**: Validation error shown
- [ ] Try negative quantity
- [ ] **Expected**: Validation error shown

---

## 6. Notifications Screen Tests

### Test 6.1: Loading State
- [ ] Navigate to Notifications (bell icon)
- [ ] **Expected**: Shows loading spinner initially

### Test 6.2: Notifications Display
- [ ] Wait for load
- [ ] **Expected**: Shows notifications OR "All caught up" message
- [ ] **Verify**: Proper icons, timestamps, formatting

### Test 6.3: Mark as Read
- [ ] Click on unread notification
- [ ] **Expected**: Marked as read, visual state changes
- [ ] **Verify**: Badge count decreases

### Test 6.4: Clear Read
- [ ] Click "Clear Read" button
- [ ] **Expected**: Read notifications removed
- [ ] **Verify**: Unread remain

---

## 7. Accounting Dashboard Tests

### Test 7.1: Dashboard Loading
- [ ] Navigate to Accounting Dashboard (if role permits)
- [ ] **Expected**: Shows loading spinner initially

### Test 7.2: Financial Metrics Display
- [ ] Wait for load
- [ ] **Expected**: Shows cash balance, bank balance, receivables, payables, GST
- [ ] **Verify**: All metrics display with proper formatting

### Test 7.3: Ledger List
- [ ] Scroll to ledger drill-down section
- [ ] **Expected**: Shows list of accounts
- [ ] Click on an account
- [ ] **Expected**: Navigates to ledger details

### Test 7.4: Quick Actions (Accountant Role)
- [ ] If accountant role, verify quick action buttons visible
- [ ] Click "Sales" voucher button
- [ ] **Expected**: Navigates to voucher entry screen

### Test 7.5: Refresh
- [ ] Pull to refresh (mobile) or use refresh button
- [ ] **Expected**: Data reloads, shows loading state briefly

### Test 7.6: Error Handling
- [ ] Simulate network error (disconnect internet)
- [ ] Navigate to accounting dashboard
- [ ] **Expected**: Shows error message
- [ ] Reconnect
- [ ] **Expected**: Retry works

---

## 8. Main Scaffold / Navigation Tests

### Test 8.1: Sidebar Navigation (Desktop)
- [ ] Click various sidebar menu items
- [ ] **Expected**: Routes change, active state highlights correctly
- [ ] **Verify**: No navigation lag or flicker

### Test 8.2: Bottom Navigation (Mobile)
- [ ] On mobile view, use bottom nav bar
- [ ] **Expected**: Routes change, active icon highlighted
- [ ] **Verify**: Smooth transitions

### Test 8.3: Tab Management (Desktop)
- [ ] Open new tab (Ctrl+T or + button)
- [ ] **Expected**: New tab opens with dashboard
- [ ] Switch between tabs
- [ ] **Expected**: Content switches correctly
- [ ] Close tab
- [ ] **Expected**: Tab closes, switches to adjacent tab

### Test 8.4: Sync Button
- [ ] Click sync button in top bar
- [ ] **Expected**: Shows syncing indicator
- [ ] Wait for completion
- [ ] **Expected**: Success message shown

### Test 8.5: Theme Toggle
- [ ] Click theme toggle button
- [ ] **Expected**: Theme switches (light  dark)
- [ ] **Verify**: All screens respect new theme

### Test 8.6: Notifications Badge
- [ ] Check notification bell icon
- [ ] **Expected**: Shows badge count if unread alerts exist
- [ ] Click bell
- [ ] **Expected**: Opens notifications screen

### Test 8.7: User Menu
- [ ] Click user avatar
- [ ] **Expected**: Menu opens with profile, settings, logout
- [ ] Click profile
- [ ] **Expected**: Navigates to profile screen
- [ ] Click logout
- [ ] **Expected**: Logout flow works (see Test 1.2)

---

## 9. Performance Tests

### Test 9.1: Initial Load Time
- [ ] Measure time from app launch to dashboard display
- [ ] **Expected**: < 3 seconds on good connection
- [ ] **Verify**: No unnecessary re-renders

### Test 9.2: Navigation Speed
- [ ] Navigate between multiple screens rapidly
- [ ] **Expected**: Smooth transitions, no lag
- [ ] **Verify**: No memory leaks (check task manager)

### Test 9.3: Data Refresh
- [ ] Trigger manual sync
- [ ] **Expected**: Completes within reasonable time
- [ ] **Verify**: UI remains responsive during sync

---

## 10. Edge Cases & Error Scenarios

### Test 10.1: Offline Mode
- [ ] Disconnect internet
- [ ] Navigate to various screens
- [ ] **Expected**: Cached data shown OR proper offline message
- [ ] Try to submit forms
- [ ] **Expected**: Queued for sync OR error message

### Test 10.2: Session Expiry
- [ ] Login
- [ ] Wait for session to expire (or manually expire token)
- [ ] Try to navigate
- [ ] **Expected**: Redirects to login with message

### Test 10.3: Concurrent Sessions
- [ ] Login on two devices
- [ ] Logout on one device
- [ ] **Expected**: Other device handles gracefully

### Test 10.4: Large Data Sets
- [ ] Navigate to screen with many items (e.g., inventory with 1000+ products)
- [ ] **Expected**: Loads efficiently, no UI freeze
- [ ] **Verify**: Pagination or virtualization works

---

## 11. Regression Tests

### Test 11.1: Existing Features
- [ ] Test 5-10 existing features not listed above
- [ ] **Expected**: All work as before migration
- [ ] **Verify**: No visual regressions

### Test 11.2: Forms & Dialogs
- [ ] Test various forms (sales, purchases, etc.)
- [ ] **Expected**: All submit correctly
- [ ] **Verify**: Validation works

### Test 11.3: Reports
- [ ] Generate various reports
- [ ] **Expected**: Data loads and displays correctly
- [ ] **Verify**: Export functions work

---

## Sign-Off

### Tester Information
- **Name**: ___________________________
- **Date**: ___________________________
- **Environment**: ___________________________

### Results Summary
- **Total Tests**: _____
- **Passed**: _____
- **Failed**: _____
- **Blocked**: _____

### Critical Issues Found
1. ___________________________
2. ___________________________
3. ___________________________

### Recommendation
- [ ] **APPROVE** - Ready for merge
- [ ] **APPROVE WITH NOTES** - Minor issues, can be fixed post-merge
- [ ] **REJECT** - Critical issues, requires fixes before merge

### Notes
_____________________________________________________________
_____________________________________________________________
_____________________________________________________________

---

**Signature**: ___________________________
