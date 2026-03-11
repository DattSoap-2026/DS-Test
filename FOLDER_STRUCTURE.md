# DattSoap ERP - Complete Folder Structure

**Version:** 2.7  
**Last Updated:** March 2026

---

## 📁 Root Level

```
flutter_app/
├── android/              # Android platform configuration
├── assets/               # Static assets (images, fonts, data)
├── backlog/              # Future features (not yet integrated)
├── docs/                 # Documentation (NEW - organized structure)
├── installer/            # Windows installer configuration
├── ios/                  # iOS platform configuration
├── lib/                  # Main application source code
├── linux/                # Linux platform configuration
├── macos/                # macOS platform configuration
├── mock_data/            # Test/mock data
├── scripts/              # Utility scripts
├── skills/               # AI agent skills
├── test/                 # Test files
├── third_party/          # Third-party dependencies
├── web/                  # Web platform configuration
└── windows/              # Windows platform configuration
```

---

## 📦 Key Folders (Detailed)

### `/android/` - Android Platform
- **Purpose:** Android-specific build configuration
- **Key Files:**
  - `app/build.gradle.kts` - Build configuration
  - `app/google-services.json` - Firebase config
  - `keystore/` - APK signing keys
  - `key.properties` - Keystore credentials

### `/assets/` - Static Assets
```
assets/
├── data/                 # JSON data files
│   └── product_images.json
├── fonts/                # Custom fonts
├── icons/                # App icons
└── images/               # Images
    ├── products/         # Product images
    │   ├── finished/     # Finished product images
    │   ├── traded/       # Traded product images
    │   └── placeholder.png
    └── company-logo.png
```
- **Purpose:** Static resources used in the app

### `/backlog/` - Future Features
- **Purpose:** Code for features not yet integrated
- **Files:**
  - `queue_management_service.dart` - Admin queue tool
  - `pre_sale_stock_validator.dart` - Stock validation
  - `README.md` - Backlog documentation

### `/docs/` - Documentation (NEW ✅)
```
docs/
├── README.md                          # Master documentation index
├── architecture.md                    # System architecture
├── sync_system.md                     # Sync documentation
├── master_data.md                     # Master data guide
├── security_rbac.md                   # Security & RBAC
├── DOCUMENTATION_AUDIT_REPORT.md     # Audit report
│
├── modules/                           # Module documentation
│   ├── production_module.md
│   ├── bhatti_module.md
│   ├── cutting_module.md
│   ├── inventory_module.md
│   ├── sales_module.md
│   └── dispatch_module.md
│
└── archive/                           # Historical documentation
    ├── audit_reports/                # 32 audit reports
    ├── implementation_reports/       # 17 progress reports
    ├── task_reports/                 # 15 task docs (T1-T17)
    ├── feature_reports/              # 41 feature reports
    ├── migration_reports/            # 9 migration docs
    ├── dev_notes/                    # 18 dev notes
    ├── agent_reports/                # 21 agent reports
    └── misc/                         # 6 superseded files
```
- **Purpose:** Complete project documentation
- **Status:** Newly organized (March 2026)

### `/installer/` - Windows Installer
- **Purpose:** Inno Setup installer configuration
- **Files:**
  - `dattsoap_installer.iss` - Installer script
  - `build_and_package.bat` - Build script
  - `output/` - Generated installers

### `/lib/` - Main Application Code
```
lib/
├── config/               # App configuration
├── constants/            # Constants and enums
├── core/                 # Core functionality
│   ├── constants/        # Core constants
│   ├── error/            # Error handling
│   ├── firebase/         # Firebase config
│   ├── shortcuts/        # Keyboard shortcuts
│   ├── theme/            # Theme system
│   └── utils/            # Core utilities
├── data/                 # Data layer
│   ├── local/            # Local database (Isar)
│   ├── providers/        # Data providers
│   ├── repositories/     # Repository pattern
│   └── seeds/            # Seed data
├── domain/               # Business logic
│   ├── engines/          # Calculation engines
│   └── repositories/     # Domain repositories
├── exceptions/           # Custom exceptions
├── models/               # Data models
│   ├── bom/              # Bill of Materials
│   ├── inventory/        # Inventory models
│   ├── theme/            # Theme models
│   └── types/            # Type definitions
├── modules/              # Feature modules
│   ├── accounting/       # Accounting module
│   ├── alerts/           # Alerts system
│   └── hr/               # HR module
├── providers/            # State management
├── routers/              # Navigation
├── screens/              # UI screens
│   ├── analytics/        # Analytics screens
│   ├── auth/             # Authentication
│   ├── bhatti/           # Bhatti (cooking)
│   ├── business_partners/# Partners management
│   ├── customers/        # Customer management
│   ├── dashboard/        # Dashboards
│   ├── dispatch/         # Dispatch operations
│   ├── driver/           # Driver module
│   ├── fuel/             # Fuel management
│   ├── inventory/        # Inventory screens
│   ├── management/       # Master data
│   ├── map/              # GPS/Maps
│   ├── orders/           # Route orders
│   ├── payments/         # Payments
│   ├── production/       # Production
│   ├── purchase_orders/  # Purchase orders
│   ├── reports/          # Reports
│   ├── returns/          # Returns
│   ├── sales/            # Sales
│   ├── settings/         # Settings
│   ├── sync/             # Sync management
│   ├── tasks/            # Task management
│   └── vehicles/         # Vehicle management
├── services/             # Business services
│   ├── bom/              # BOM services
│   ├── delegates/        # Sync delegates
│   ├── firebase/         # Firebase services
│   └── reports/          # Report services
├── utils/                # Utility functions
├── widgets/              # Reusable widgets
│   ├── common/           # Common widgets
│   ├── dashboard/        # Dashboard widgets
│   ├── dialogs/          # Dialog widgets
│   ├── inventory/        # Inventory widgets
│   ├── navigation/       # Navigation widgets
│   ├── products/         # Product widgets
│   ├── reports/          # Report widgets
│   ├── responsive/       # Responsive layouts
│   ├── sales/            # Sales widgets
│   ├── settings/         # Settings widgets
│   ├── shared/           # Shared widgets
│   ├── tasks/            # Task widgets
│   ├── ui/               # UI components
│   └── vehicles/         # Vehicle widgets
└── main.dart             # App entry point
```

### `/lib/config/` - Configuration
- **Purpose:** App-wide configuration
- **Files:** `changelog.dart` - Version history

### `/lib/constants/` - Constants
- **Purpose:** App constants and enums
- **Key Files:**
  - `nav_items.dart` - Navigation configuration
  - `role_access_matrix.dart` - RBAC permissions
  - `product_images.dart` - Product image mappings

### `/lib/core/` - Core Functionality
- **Purpose:** Core app functionality
- **Subfolders:**
  - `constants/` - Core constants
  - `error/` - Error handling
  - `firebase/` - Firebase configuration
  - `shortcuts/` - Keyboard shortcuts
  - `theme/` - Theme system (Neutral Future)
  - `utils/` - Core utilities

### `/lib/data/` - Data Layer
- **Purpose:** Data access and persistence
- **Subfolders:**
  - `local/entities/` - Isar database entities
  - `providers/` - Data providers
  - `repositories/` - Repository implementations
  - `seeds/` - Seed data

### `/lib/domain/` - Business Logic
- **Purpose:** Business rules and domain logic
- **Subfolders:**
  - `engines/` - Calculation engines (inventory, sales)
  - `repositories/` - Domain repository interfaces

### `/lib/models/` - Data Models
- **Purpose:** Data structures and types
- **Key Subfolders:**
  - `bom/` - Bill of Materials models
  - `inventory/` - Inventory models
  - `types/` - Type definitions (cutting, production, sales, etc.)

### `/lib/modules/` - Feature Modules
- **Purpose:** Self-contained feature modules
- **Modules:**
  - `accounting/` - Accounting and vouchers
  - `alerts/` - Alert system
  - `hr/` - Human resources

### `/lib/providers/` - State Management
- **Purpose:** Provider-based state management
- **Key Providers:**
  - `auth_provider.dart` - Authentication state
  - `theme_provider.dart` - Theme state
  - `inventory_provider.dart` - Inventory state

### `/lib/routers/` - Navigation
- **Purpose:** App routing configuration
- **Files:** `app_router.dart` - GoRouter configuration

### `/lib/screens/` - UI Screens
- **Purpose:** All app screens organized by module
- **Major Modules:**
  - `auth/` - Login, splash
  - `bhatti/` - Soap cooking operations
  - `dashboard/` - Role-based dashboards
  - `dispatch/` - Stock and dealer dispatch
  - `inventory/` - Stock management
  - `production/` - Production batches
  - `reports/` - Analytics and reports
  - `sales/` - Sales orders
  - `settings/` - App settings

### `/lib/services/` - Business Services
- **Purpose:** Business logic and data operations
- **Key Services:**
  - `base_service.dart` - Common CRUD operations
  - `bhatti_service.dart` - Bhatti operations
  - `cutting_batch_service.dart` - Cutting operations
  - `inventory_service.dart` - Inventory management
  - `production_service.dart` - Production batches
  - `sales_service.dart` - Sales operations
  - `sync_manager.dart` - Sync orchestration
- **Subfolders:**
  - `bom/` - BOM validation
  - `delegates/` - Sync delegates
  - `reports/` - Report generation

### `/lib/utils/` - Utilities
- **Purpose:** Helper functions and utilities
- **Key Files:**
  - `access_guard.dart` - RBAC enforcement
  - `responsive.dart` - Responsive design
  - `pdf_generator.dart` - PDF generation
  - `unit_converter.dart` - Unit conversions

### `/lib/widgets/` - Reusable Widgets
- **Purpose:** Reusable UI components
- **Categories:**
  - `common/` - Common widgets
  - `dashboard/` - KPI cards, charts
  - `dialogs/` - Dialog components
  - `ui/` - UI components (buttons, cards, etc.)

### `/scripts/` - Utility Scripts
- **Purpose:** Maintenance and utility scripts
- **Key Scripts:**
  - `backfill_sales_accounting_dimensions.dart`
  - `role_ui_walkthrough.dart`
  - `responsive_guard.dart`

### `/test/` - Tests
```
test/
├── constants/            # Constant tests
├── data/                 # Data layer tests
├── domain/               # Domain logic tests
├── integration/          # Integration tests
│   ├── t1_department_stock_integrity_test.dart
│   ├── t2_salesman_allocation_block_test.dart
│   ├── t4_opening_stock_set_balance_test.dart
│   ├── t5_salesman_uid_identity_test.dart
│   └── ... (T1-T17 tests)
├── models/               # Model tests
├── modules/              # Module tests
├── quality/              # Quality guards
├── screens/              # Screen tests
├── services/             # Service tests
├── utils/                # Utility tests
├── validation/           # Validation tests
└── widgets/              # Widget tests
```
- **Purpose:** Unit, integration, and widget tests

---

## 🔑 Key Files (Root)

### Configuration Files
- `pubspec.yaml` - Flutter dependencies
- `analysis_options.yaml` - Dart analyzer config
- `firebase.json` - Firebase configuration
- `firestore.rules` - Firestore security rules
- `firestore.indexes.json` - Firestore indexes

### Documentation Files (Root)
- `README.md` - Project overview & theme system
- `BUILD_DISTRIBUTION_GUIDE.md` - Deployment guide
- `FULL_TRANSACTION_RESET_RUNBOOK.md` - Operations runbook
- `CONTINUE_FROM_HERE.md` - Current development status
- `DOCUMENTATION_CLEANUP_SUMMARY.md` - Cleanup project summary
- `DOCUMENTATION_PROJECT_COMPLETE.md` - Completion report
- `DOCUMENTATION_QUICK_START.md` - Quick start guide
- `DOCUMENTATION_VERIFICATION_COMPLETE.md` - Verification report

### Build Files
- `cleanup_docs.bat` - Documentation cleanup script
- `setup_images.bat` - Image setup script
- `generate_images.py` - Image generation

---

## 📊 Folder Statistics

### Code Organization
- **Total Folders:** 200+
- **Source Code:** `lib/` (main application)
- **Tests:** `test/` (comprehensive test suite)
- **Documentation:** `docs/` (organized structure)

### Documentation
- **Active Docs:** 12 files in `docs/`
- **Module Docs:** 6 modules documented
- **Archived:** 159 historical files
- **Technical Docs:** 40+ phase/runbook files

### Platform Support
- **Mobile:** Android, iOS
- **Desktop:** Windows, macOS, Linux
- **Web:** Progressive Web App

---

## 🎯 Key Folder Purposes

### Development
- **`lib/`** - All application source code
- **`test/`** - All test files
- **`scripts/`** - Utility and maintenance scripts

### Documentation
- **`docs/`** - Complete project documentation
- **`docs/modules/`** - Module-specific documentation
- **`docs/archive/`** - Historical documentation

### Build & Deploy
- **`android/`** - Android build configuration
- **`installer/`** - Windows installer
- **`assets/`** - Static resources

### Configuration
- **Root config files** - Flutter, Firebase, analysis
- **Platform folders** - Platform-specific configuration

---

## 📝 Navigation Tips

### Finding Code
- **Screens:** `lib/screens/[module]/`
- **Services:** `lib/services/`
- **Models:** `lib/models/types/`
- **Widgets:** `lib/widgets/`

### Finding Documentation
- **Start:** `docs/README.md`
- **Architecture:** `docs/architecture.md`
- **Modules:** `docs/modules/`
- **Historical:** `docs/archive/`

### Finding Tests
- **Unit Tests:** `test/services/`, `test/utils/`
- **Integration Tests:** `test/integration/`
- **Widget Tests:** `test/widgets/`

---

**Last Updated:** March 2026  
**Maintained by:** DattSoap Development Team
