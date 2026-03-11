# 🔒 LOCKED FIXES — returns_service.dart

> **Lock Policy:** Per user's master constitution `lock_and_fix_policy`, all fixes below are **LOCKED**.  
> No future agent or change may modify these areas without **explicit user approval**.

---

## Fix #1: Firestore `runTransaction` → `WriteBatch` in `performSync`

| Field | Value |
|---|---|
| **Date** | 2026-02-16 |
| **Scope** | `ReturnsService.performSync()` — lines 810–940 |
| **Root Cause** | `firestoreDb.runTransaction(...)` crashes Windows app due to platform-channel threading (messages sent on non-platform thread) |
| **Fix** | Replaced with sequential reads + `WriteBatch` for atomic writes. Wrapped entire method in try-catch so sync queue handles retries instead of crashing app. |
| **Status** | 🔒 LOCKED |

---

## Fix #2: Fire-and-forget sync in approve/reject/add

| Field | Value |
|---|---|
| **Date** | 2026-02-16 |
| **Scope** | `approveReturnRequest()`, `rejectReturnRequest()`, `addReturnRequest()` — sync calls |
| **Root Cause** | `await _queueAndSyncReturn(...)` blocked the UI by awaiting the full Firestore operation. On slow/offline network, app hung indefinitely. |
| **Fix** | Changed to `.then()` fire-and-forget pattern. Local Isar write is source of truth; sync runs in background. Errors are logged, not thrown. |
| **Status** | 🔒 LOCKED |

---

## Fix #3: `getReturnRequests` — local-first from Isar

| Field | Value |
|---|---|
| **Date** | 2026-02-16 |
| **Scope** | `ReturnsService.getReturnRequests()` — lines 301–340 |
| **Root Cause** | Method queried **Firestore only** — caused hang on reload after approval, returned empty list when offline. |
| **Fix** | Rewrote to query local Isar DB with `statusEqualTo`, `salesmanIdEqualTo`, `sortByCreatedAtDesc`. Works fully offline. |
| **Status** | 🔒 LOCKED |

---

## Fix #4: Graceful salesman-not-found handling

| Field | Value |
|---|---|
| **Date** | 2026-02-16 |
| **Scope** | `_adjustSalesmanStockInTxn()` — salesman lookup + allocated stock |
| **Root Cause** | Threw hard exception when salesman user or allocated stock not found locally (e.g. admin on different device). Crashed approval. |
| **Fix** | Logs warning and returns gracefully. Server sync handles actual stock adjustments. |
| **Status** | 🔒 LOCKED |

---

## Fix #5: Isar API corrections (`getById` → `filter().idEqualTo().findFirst()`)

| Field | Value |
|---|---|
| **Date** | 2026-02-16 |
| **Scope** | All Isar queries for `returns`, `users`, `products` collections in `returns_service.dart` |
| **Root Cause** | `getById` is not a standard Isar method — only available as custom extension on specific collections. |
| **Fix** | Replaced all `getById(id)` with `filter().idEqualTo(id).findFirst()`. Added missing entity imports for generated filter extensions. |
| **Status** | 🔒 LOCKED |

---

> ⚠️ **To unlock any fix above, the user must explicitly approve the change.**
