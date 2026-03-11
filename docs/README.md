# DattSoap ERP - Documentation Index

**Last Updated:** March 2026  
**Version:** 2.7  
**Status:** Production Ready

---

## 📚 Quick Navigation

### For Developers
- [Architecture Overview](architecture.md)
- [Sync System](sync_system.md)
- [Module Documentation](modules/)

### For Operations
- [Deployment Guide](deployment_guide.md)
- [User Guides](user_guides/)

### For Maintenance
- [Technical Debt](technical_debt.md)
- [Archive](archive/)

---

## 🏗️ System Architecture

### Core Systems
- **[Architecture Overview](architecture.md)** - System design, patterns, and structure
- **[Sync System](sync_system.md)** - Offline-first sync architecture
- **[Security & RBAC](security_rbac.md)** - Role-based access control
- **[WhatsApp Message Sync](WHATSAPP_MESSAGE_SUMMARY.md)** - WhatsApp-like messaging system

### Data Management
- **[Master Data](master_data.md)** - Products, customers, suppliers, users
- **[Database Schema](database_schema.md)** - Firestore collections and Isar local DB

---

## 📦 Module Documentation

### Production Modules
- **[Production Module](modules/production_module.md)** - Production batches and workflows
- **[Bhatti Module](modules/bhatti_module.md)** - Soap cooking and batch management
- **[Cutting Module](modules/cutting_module.md)** - Cutting batches and finished goods

### Inventory & Procurement
- **[Inventory Module](modules/inventory_module.md)** - Stock management and tracking
- **[Procurement Module](modules/procurement_module.md)** - Purchase orders and GRN

### Sales & Distribution
- **[Sales Module](modules/sales_module.md)** - Sales orders and invoicing
- **[Dispatch Module](modules/dispatch_module.md)** - Stock and dealer dispatch
- **[Route Orders](modules/route_orders.md)** - Route-based order management

### Financial
- **[Payments Module](modules/payments_module.md)** - Payment tracking and vouchers
- **[Reports Module](modules/reports_module.md)** - Analytics and reporting

### Support Modules
- **[Vehicle Management](modules/vehicle_module.md)** - Fleet and maintenance
- **[Fuel Management](modules/fuel_module.md)** - Fuel tracking
- **[HR Module](modules/hr_module.md)** - Employee management

---

## 👥 User Roles & Access

### Role Documentation
- **Admin** - Full system access
- **Store Incharge** - Inventory, procurement, dispatch
- **Production Supervisor** - Production and cutting operations
- **Bhatti Supervisor** - Bhatti cooking operations
- **Salesman** - Sales and customer management
- **Fuel Incharge** - Fuel logging
- **Driver** - Task management

See [RBAC Documentation](security_rbac.md) for detailed permissions.

---

## 🚀 Deployment & Operations

### Deployment
- **[Build & Distribution Guide](BUILD_DISTRIBUTION_GUIDE.md)** - APK building and signing
- **[Firebase Deployment](firebase_deploy_runbook.md)** - Cloud functions and rules
- **[Release Update Runbook](release_update_runbook.md)** - Update procedures

### Operations
- **[Transaction Reset](FULL_TRANSACTION_RESET_RUNBOOK.md)** - System reset procedures
- **[Troubleshooting](troubleshooting.md)** - Common issues and solutions

---

## 📊 Reports & Analytics

### Available Reports
- Production Reports (yield, waste analysis)
- Sales Reports (salesman performance, targets)
- Financial Reports (payments, outstanding)
- Inventory Reports (stock levels, movements)
- Vehicle Reports (maintenance, fuel consumption)

See [Reports Module](modules/reports_module.md) for details.

---

## 🔧 Technical Documentation

### Development
- **[Code Quality](code_quality.md)** - Standards and best practices
- **[Testing Guide](testing_guide.md)** - Unit, integration, and E2E tests
- **[Theme System](../README.md#theme-system-neutral-future)** - Design system

### Integration
- **[Firebase Integration](firebase_integration.md)** - Auth, Firestore, Storage
- **[Offline Support](offline_support.md)** - Local database and sync
- **[Image Handling](IMAGE_HANDLING_TECHNICAL_REVIEW.md)** - Image storage and optimization
- **[WhatsApp Service](WHATSAPP_MESSAGE_SYNC_AUDIT.md)** - WhatsApp Business API integration

---

## 📝 Recent Updates

### Version 2.7 (March 2026)
- ✅ Canonical Firebase UID implementation (T5)
- ✅ Department stock symmetry fixes (T1)
- ✅ Salesman allocation improvements (T2)
- ✅ Opening stock hardening (T3-T4)
- ✅ WhatsApp-like auto-sync audit complete
- ✅ WhatsApp message system architecture documented
- ⏳ Production queue migration (T6 - planned)
- ⏳ WhatsApp message sync implementation (11 hours estimated)

See [CONTINUE_FROM_HERE.md](../CONTINUE_FROM_HERE.md) for current status.

---

## 🗂️ Archive

Historical documentation and audit reports have been moved to [archive/](archive/).

### Archived Categories
- Audit reports (multiple iterations)
- Implementation progress reports
- Migration reports (V2 upgrade)
- Task-specific documentation (T1-T17)
- Temporary development notes

---

## 📞 Support & Contacts

### Documentation Issues
- Missing information? Create an issue
- Outdated content? Submit a PR
- Questions? Contact the development team

### Emergency Contacts
- **Technical Lead** - System architecture
- **DevOps** - Deployment issues
- **Support** - User issues

---

## 🎯 Getting Started

### New Developers
1. Read [Architecture Overview](architecture.md)
2. Review [Sync System](sync_system.md)
3. Explore module documentation
4. Check [Code Quality](code_quality.md) standards

### New Users
1. Review role-specific documentation
2. Check [User Guides](user_guides/)
3. Explore module features

### Deployment Team
1. Read [Build & Distribution Guide](BUILD_DISTRIBUTION_GUIDE.md)
2. Review [Firebase Deployment](firebase_deploy_runbook.md)
3. Check [Release Update Runbook](release_update_runbook.md)

---

## 📋 Documentation Standards

### File Naming
- Use lowercase with underscores: `module_name.md`
- Module docs in `modules/` folder
- Archive old docs in `archive/`

### Content Structure
- Start with overview and purpose
- Include code examples where relevant
- Add diagrams for complex flows
- Keep updated with version info

---

**Documentation maintained by the DattSoap Development Team**
