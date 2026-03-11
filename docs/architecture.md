# DattSoap ERP - Architecture Overview

**Version:** 2.7  
**Last Updated:** March 2026

---

## System Overview

DattSoap ERP is a Flutter-based offline-first manufacturing ERP system designed for soap manufacturing operations. The system supports multi-role access, real-time sync, and comprehensive business workflows.

---

## Architecture Patterns

### 1. Offline-First Architecture
- **Local Database:** Isar (NoSQL, high-performance)
- **Cloud Database:** Firebase Firestore
- **Sync Strategy:** Durable outbox queue pattern
- **Conflict Resolution:** Last-write-wins with timestamp

### 2. State Management
- **Provider Pattern:** For app-wide state
- **Local State:** StatefulWidget for UI-specific state
- **Stream-based:** Real-time updates from Firestore

### 3. Service Layer
- **Base Service:** Common CRUD operations
- **Specialized Services:** Module-specific business logic
- **Transaction Support:** ACID compliance for critical operations

---

## Technology Stack

### Frontend
- **Framework:** Flutter 3.x
- **Language:** Dart
- **UI Components:** Material Design 3
- **Navigation:** GoRouter
- **State Management:** Provider

### Backend
- **Authentication:** Firebase Auth
- **Database:** Cloud Firestore
- **Storage:** Firebase Storage
- **Functions:** Cloud Functions (Node.js)

### Local Storage
- **Primary DB:** Isar
- **Preferences:** SharedPreferences
- **Secure Storage:** flutter_secure_storage

---

## Module Architecture

### Core Modules
1. **Authentication & Authorization**
   - Firebase Auth integration
   - Role-based access control (RBAC)
   - User session management

2. **Sync System**
   - Durable queue for offline operations
   - Automatic retry with exponential backoff
   - Conflict detection and resolution

3. **Master Data**
   - Products (raw, semi-finished, finished)
   - Customers and suppliers
   - Users and roles
   - Warehouses and locations

### Business Modules
1. **Production**
   - Production batches
   - BOM (Bill of Materials)
   - Stock adjustments

2. **Bhatti (Cooking)**
   - Batch cooking process
   - Formula management
   - Material issue tracking

3. **Cutting**
   - Cutting batches
   - Yield tracking
   - Waste analysis

4. **Inventory**
   - Stock management
   - Stock transfers
   - Stock adjustments

5. **Sales**
   - Sales orders
   - Salesman routes
   - Customer management

6. **Dispatch**
   - Stock dispatch
   - Dealer dispatch
   - Trip management

7. **Payments**
   - Payment vouchers
   - Outstanding tracking
   - Payment history

---

## Data Flow

### Write Operations
```
User Action → Service Layer → Local DB (Isar) → Sync Queue → Firestore
```

### Read Operations
```
Firestore Stream → Local DB Cache → UI Layer
```

### Offline Operations
```
User Action → Service Layer → Local DB → Sync Queue (pending)
[When online] → Sync Queue Processor → Firestore
```

---

## Security Architecture

### Authentication
- Firebase Auth with email/password
- Secure token storage
- Automatic token refresh

### Authorization
- Role-based access control (RBAC)
- Screen-level protection
- Operation-level permissions

### Data Security
- Firestore security rules
- Encrypted local storage for sensitive data
- Audit logging for critical operations

---

## Performance Optimization

### Database
- Indexed queries for fast lookups
- Pagination for large datasets
- Lazy loading for reports

### UI
- Efficient widget rebuilds
- Image caching and optimization
- Debounced search inputs

### Sync
- Batch operations where possible
- Incremental sync for large datasets
- Background sync with WorkManager

---

## Scalability Considerations

### Current Capacity
- Users: 50+ concurrent
- Products: 1000+
- Daily transactions: 500+
- Offline queue: 1000+ items

### Future Enhancements
- Multi-warehouse support
- Advanced analytics
- Mobile app optimization
- Web dashboard

---

## File Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── entities/            # Isar entities
│   └── types/               # Type definitions
├── services/                # Business logic
│   ├── base_service.dart   # Common CRUD
│   └── [module]_service.dart
├── screens/                 # UI screens
│   └── [module]/
├── providers/               # State management
├── routers/                 # Navigation
├── utils/                   # Utilities
├── constants/               # Constants
└── core/                    # Core functionality
    ├── theme/              # Theme system
    └── sync/               # Sync engine
```

---

## Design Principles

### 1. Separation of Concerns
- UI layer separate from business logic
- Service layer handles all data operations
- Models define data structure only

### 2. DRY (Don't Repeat Yourself)
- Base service for common operations
- Reusable widgets and components
- Shared utilities and helpers

### 3. SOLID Principles
- Single Responsibility
- Open/Closed
- Liskov Substitution
- Interface Segregation
- Dependency Inversion

### 4. Offline-First
- All operations work offline
- Automatic sync when online
- User never blocked by connectivity

---

## Testing Strategy

### Unit Tests
- Service layer logic
- Utility functions
- Model validation

### Integration Tests
- Database operations
- Sync queue processing
- API integration

### E2E Tests
- Critical user workflows
- Multi-role scenarios
- Offline/online transitions

---

## Deployment Architecture

### Development
- Local development with Firebase emulators
- Hot reload for rapid iteration

### Staging
- Firebase staging project
- Test data and users
- Pre-production validation

### Production
- Firebase production project
- Signed APK distribution
- Monitoring and analytics

---

## Monitoring & Observability

### Crash Reporting
- Firebase Crashlytics
- Automatic crash reports
- Stack traces and device info

### Performance Monitoring
- Firebase Performance
- Screen load times
- Network request tracking

### Analytics
- Firebase Analytics
- User behavior tracking
- Feature usage metrics

---

## Technical Debt

See [technical_debt.md](technical_debt.md) for current items.

### Priority Items
1. Complete timestamp ID to UUID migration
2. Production queue migration (T6)
3. Enhanced error handling
4. Comprehensive test coverage

---

## References

- [Sync System](sync_system.md)
- [Security & RBAC](security_rbac.md)
- [Module Documentation](modules/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)

---

**Maintained by DattSoap Development Team**
