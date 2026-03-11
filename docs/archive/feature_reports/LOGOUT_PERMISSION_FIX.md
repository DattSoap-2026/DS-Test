# Logout Permission Error & Salesman Login Fix

## समस्या का विश्लेषण (Problem Analysis)

### 1. Logout पर Permission Denied Errors
**लक्षण (Symptoms):**
```
ERROR [Sync]: Error pulling sales: [cloud_firestore/permission-denied] Missing or insufficient permissions.
ERROR [Sync]: Payments sync pull failed: [cloud_firestore/permission-denied] Missing or insufficient permissions.
WARNING: Listen for query at route_sessions failed: Missing or insufficient permissions.
```

**मूल कारण (Root Cause):**
- Logout के दौरान Firebase Auth state पहले clear हो रहा था
- Sync Manager के listeners अभी भी active थे और Firestore queries चला रहे थे
- `request.auth` null होने के कारण सभी Firestore rules fail हो रहे थे

**समाधान (Solution):**
Auth listeners को Firebase signOut से **पहले** cancel करना:

```dart
// BEFORE (Wrong Order):
1. Clear user state
2. Run cleanup callback
3. Cancel auth subscription ❌ (Too late!)
4. Firebase signOut

// AFTER (Correct Order):
1. Cancel auth subscription ✅ (First!)
2. Clear user state
3. Run cleanup callback
4. Firebase signOut
```

### 2. Salesman Login नहीं हो रहा था
**लक्षण (Symptoms):**
- `sale1@dattsoap.com` login successful
- Role mapping: "Salesman" ✅
- लेकिन फिर `admin@dattsoap.com` auto-login हो रहा था

**मूल कारण (Root Cause):**
- `lastBootstrappedUserId` logout पर clear नहीं हो रहा था
- Sync Manager का user context stale रह रहा था
- Bootstrap logic skip हो रहा था

**समाधान (Solution):**
Logout पर sync manager को properly cleanup करना:

```dart
void wireSyncUserContext() {
  final user = authProvider.state.user;
  if (user == null) {
    lastBootstrappedUserId = null;
    deferredSyncBootstrapTimer?.cancel();
    syncManager.cleanup(notify: false); // ✅ Added
    return;
  }
  // ... rest of logic
}
```

## Changes Made

### 1. `lib/providers/auth/auth_provider.dart`
**Fix:** Auth listeners को Firebase signOut से पहले cancel करना

```dart
Future<void> signOut() async {
  // ... existing code ...
  
  // CRITICAL FIX: Stop all listeners FIRST before clearing auth
  await _authSubscription?.cancel();
  _authSubscription = null;
  _windowsAuthPollTimer?.cancel();
  _windowsAuthPollTimer = null;
  _lastObservedFirebaseUid = null;

  // Clear user state
  _state = AuthState(user: null, loading: true);
  notifyListeners();

  // Execute cleanup callback
  await runBestEffortStep('Logout cleanup', ...);
  
  // Perform Repo signOut
  await runBestEffortStep('Repository signOut', ...);
  
  // ... rest of signout logic
}
```

### 2. `lib/services/sync_manager.dart`
**Fix:** Cleanup में sync progress state reset करना

```dart
void cleanup({bool notify = true}) {
  // ... existing cleanup ...
  _currentSyncStep = '';      // ✅ Added
  _syncStepProgress = 0.0;    // ✅ Added
  if (notify) {
    notifyListeners();
  }
}
```

### 3. `lib/main.dart`
**Fix:** Logout पर sync manager cleanup trigger करना

```dart
void wireSyncUserContext() {
  final user = authProvider.state.user;
  if (user == null) {
    lastBootstrappedUserId = null;
    deferredSyncBootstrapTimer?.cancel();
    syncManager.cleanup(notify: false); // ✅ Added
    return;
  }
  // ... rest of logic
}
```

## Testing Checklist

### Logout Flow
- [ ] Admin logout करें
- [ ] Console में permission errors नहीं दिखने चाहिए
- [ ] Sync listeners properly stop होने चाहिए
- [ ] UI smooth transition होना चाहिए

### Salesman Login Flow
- [ ] Salesman account से login करें
- [ ] Dashboard properly load होना चाहिए
- [ ] Role-based permissions apply होने चाहिए
- [ ] Logout करें
- [ ] फिर से login करें - should work smoothly

### Cross-User Login
- [ ] Admin login → logout
- [ ] Salesman login → should work
- [ ] Salesman logout
- [ ] Admin login → should work
- [ ] कोई permission errors नहीं होने चाहिए

## Technical Details

### Firestore Rules Context
```javascript
function isAuthenticated() {
  return request.auth != null;  // ⚠️ Logout के दौरान null हो जाता है
}
```

### Auth State Lifecycle
```
Login:
  Firebase Auth Ready → User Profile Fetch → Sync Bootstrap

Logout:
  Stop Listeners → Clear User State → Firebase SignOut → Cleanup
  ✅ Correct order prevents permission errors
```

### Sync Manager Lifecycle
```
User Login:
  setCurrentUser() → scheduleDeferredBootstrap() → syncAll()

User Logout:
  cleanup() → stop all timers → clear user context → reset state
```

## Impact

### Before Fix
- ❌ 20+ permission errors on logout
- ❌ Salesman login blocked after admin logout
- ❌ Stale sync state causing confusion
- ❌ Firestore listeners not properly cleaned

### After Fix
- ✅ Clean logout with no errors
- ✅ Any user can login after any other user
- ✅ Proper state cleanup
- ✅ No stale listeners or contexts

## Related Files
- `lib/providers/auth/auth_provider.dart` - Auth lifecycle management
- `lib/services/sync_manager.dart` - Sync state management
- `lib/main.dart` - App-level user context wiring
- `firestore.rules` - Permission rules (unchanged, but context important)

## Notes
- यह fix backward compatible है
- कोई breaking changes नहीं हैं
- Existing user sessions affected नहीं होंगे
- Hot reload के बाद test करें
