# DattSoap Project Audit Summary

**Date:** March 7, 2026  
**Project Status:** Active / Stabilization Phase  

---

## 1. Project Overview
**Name:** DattSoap (ERP for Sona Farm)  
**Purpose:** A comprehensive Enterprise Resource Planning (ERP) application designed for a soap manufacturing facility. It manages the entire lifecycle of production—from raw materials to finished goods—alongside HR, Sales, and Accounting.

---

## 2. Technology Stack
*   **Core Framework:** Flutter (SDK ^3.10.7)
*   **Backend Services:** Firebase (Authentication, Cloud Firestore, Cloud Storage, Cloud Functions, Firebase Messaging)
*   **Local Database (Offline-First):** Isar NoSQL Database (used for reliable local storage and synchronization)
*   **State Management:** Mixed usage of `Provider` and `Riverpod`.
*   **Routing:** `go_router` for robust deep-linking and state-based navigation.
*   **Design System:** "Neutral Future" - a custom Material 3 based system focused on eye safety (no pure blacks/whites) and comfort for long-term usage.
*   **Key Utilities:** 
    *   `SyncManager`: Centralized logic for handling offline data mutations via a durable outbox queue.
    *   `Google Generative AI`: Integrated for "AI Brain" capabilities.
    *   `FL Chart`: For production analytics and sales dashboards.
    *   `Isar Generator / Build Runner`: For type-safe local database schemas.

---

## 3. Current Progress & Audit Mapping

### ✅ What is Done (Completely Implemented)
*   **Dashboard & UI Foundation:** "Neutral Future" theme system, responsive layout, and command palette.
*   **Authentication:** Multi-role login (Admin, Owner, Production Supervisor, Bhatti Supervisor, Salesman, Delivery, etc.) with Firebase UID canonicalization.
*   **Production Module (Bhatti & Cutting):** 
    *   Full lifecycle from boiling (Bhatti) to cutting batches.
    *   Stock adjustment logic for semi-finished and finished goods (ACID compliant).
    *   Yield and waste analysis reporting.
*   **HR Module:** 
    *   Employee attendance, leave management, and holiday tracking.
    *   Payroll processing (including advances and performance reviews).
*   **Sales & Distribution:** 
    *   Dealer and customer management.
    *   Sales entry, returns, and trip tracking.
    *   WhatsApp invoice pipeline for glass-less billing.
*   **Inventory:** Multi-warehouse support (`Main` focused), opening stock management, and product masters.

### 🚧 Current Work / Stabilization (March 2026)
*   **T5 (Just Finished):** Applied canonical Firebase UID across sales paths to resolve identity mismatch issues.
*   **T6 (Next Step):** Moving Production, Bhatti, and Cutting stock mutations to the durable `SyncManager` outbox queue to ensure 100% reliable offline operation for factory floors.

---

## 4. Core Business Logic (Agent Context)
The app operates on a **Role-Based Access Control (RBAC)** model. Data integrity is maintained via a **Synchronization Pipeline**:
1.  **Offline First:** Operators (Cutting/Bhatti) often work in areas with poor connectivity. All transactions are written locally to Isar first.
2.  **Durable Queue:** The `SyncManager` watches for connectivity and pushes local changes to Firestore in order, handling conflicts via `ConflictService`.
3.  **Traceability:** Every batch has a `BatchGeneId` (SHA256) for full genealogy tracking from raw oil to a soap bar.
4.  **Stock Symmetry:** Every "Issue" from the store must have a corresponding "Production" or "Return" to maintain perfect inventory balance.

---

## 5. Directory Structure Reference
*   `lib/core/`: Theme, Firebase config, and global shortcuts.
*   `lib/modules/`: High-level business modules (HR, Accounting).
*   `lib/services/`: Core logic (Sync, Database, specific module services).
*   `lib/screens/`: 180+ UI screens categorized by module.
*   `lib/models/`: Data entities and enums.
*   `lib/data/repositories/`: Data access layer for Isar and Firestore.

---

**Next Recommended Task for Agents:**  
Focus on `T6 / R7`: Update `cutting_batch_service.dart`, `bhatti_service.dart`, and `production_service.dart` to use the `SyncManager` queue instead of immediate Firestore calls.
