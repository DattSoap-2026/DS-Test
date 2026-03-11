# Project Organization & Scalability Guidelines

**Version:** 2.7  
**Last Updated:** March 2026

---

## 📋 Organization Rules

### File Placement

**Code Files:**
- Screens → `lib/screens/[module]/`
- Services → `lib/services/`
- Models → `lib/models/types/`
- Widgets → `lib/widgets/[category]/`

**Documentation:**
- Active docs → `docs/`
- Module docs → `docs/modules/`
- Historical → `docs/archive/`

**Tests:**
- Unit tests → `test/services/`, `test/utils/`
- Integration → `test/integration/`
- Widget tests → `test/widgets/`

---

## 🎯 Naming Conventions

**Files:**
- `snake_case.dart` for all Dart files
- `module_name_screen.dart` for screens
- `module_name_service.dart` for services
- `module_name.md` for documentation

**Classes:**
- `PascalCase` for classes
- `camelCase` for methods/variables
- `SCREAMING_SNAKE_CASE` for constants

---

## 📦 Module Structure

**New Module Template:**
```
lib/
├── models/types/
│   └── module_types.dart
├── services/
│   └── module_service.dart
├── screens/module/
│   ├── module_screen.dart
│   └── module_form_screen.dart
└── widgets/module/
    └── module_widget.dart

docs/modules/
└── module_name.md

test/
├── services/
│   └── module_service_test.dart
└── integration/
    └── module_integration_test.dart
```

---

## 🔧 Maintenance Rules

**Weekly:**
- Delete temp files (`test_*.txt`, `*.log`)
- Review and archive old reports
- Update documentation for changes

**Monthly:**
- Archive completed task docs
- Review and optimize imports
- Update dependency versions

**Quarterly:**
- Full documentation review
- Code quality audit
- Performance optimization

---

## 📝 Documentation Standards

**When to Document:**
- New feature added
- Architecture changed
- API modified
- Bug fix affecting behavior

**What to Document:**
- Feature overview
- API reference
- Integration points
- Known issues

**Where to Document:**
- Module docs: `docs/modules/`
- Architecture: `docs/architecture.md`
- API changes: Module doc + changelog

---

## 🚫 What NOT to Commit

**Never commit:**
- `test_*.txt`, `test_*.json`
- `*.log` files
- `*.isar-lck` files
- Old APK files
- Sample reports/PDFs
- Temporary scripts

**Use .gitignore for:**
- Build outputs
- IDE configs (except shared)
- Local test files
- Sensitive data

---

## 📊 Scalability Checklist

**Before Adding Feature:**
- [ ] Check existing patterns
- [ ] Plan module structure
- [ ] Design database schema
- [ ] Consider offline support
- [ ] Plan testing strategy

**After Adding Feature:**
- [ ] Write tests
- [ ] Update documentation
- [ ] Add to navigation
- [ ] Update RBAC if needed
- [ ] Archive old related docs

---

## 🎯 Code Organization

**Service Layer:**
- One service per domain
- Extend `BaseService` for CRUD
- Use delegates for sync
- Keep services focused

**Screen Layer:**
- One screen per route
- Extract complex widgets
- Use providers for state
- Keep screens thin

**Model Layer:**
- Types in `models/types/`
- Entities in `data/local/entities/`
- Keep models immutable
- Use freezed/json_serializable

---

## 🔄 Refactoring Guidelines

**When to Refactor:**
- File > 500 lines
- Duplicate code (3+ times)
- Complex nested logic
- Poor performance

**How to Refactor:**
1. Write tests first
2. Extract to smaller files
3. Update documentation
4. Verify tests pass
5. Archive old docs

---

## 📈 Growth Strategy

**Current Capacity:**
- 50+ concurrent users
- 1000+ products
- 500+ daily transactions

**Scaling Plan:**
- Optimize queries (indexes)
- Implement pagination
- Cache frequently used data
- Background sync optimization

---

## 🛡️ Quality Gates

**Before Merge:**
- [ ] `flutter analyze` passes
- [ ] Tests pass
- [ ] Documentation updated
- [ ] No temp files added
- [ ] RBAC verified

**Before Release:**
- [ ] Full test suite passes
- [ ] Documentation complete
- [ ] Performance tested
- [ ] Security reviewed
- [ ] Changelog updated

---

## 📁 Folder Limits

**Keep folders manageable:**
- Max 20 files per folder
- Max 3 levels deep
- Split large modules
- Use subfolders for categories

**Example:**
```
lib/screens/inventory/
├── dialogs/           # Inventory dialogs
├── widgets/           # Inventory widgets
├── inventory_screen.dart
└── stock_screen.dart
```

---

## 🔍 Code Review Checklist

**Structure:**
- [ ] Files in correct folders
- [ ] Naming conventions followed
- [ ] No duplicate code
- [ ] Proper imports

**Documentation:**
- [ ] Code comments for complex logic
- [ ] Module docs updated
- [ ] API changes documented
- [ ] README updated if needed

**Testing:**
- [ ] Unit tests added
- [ ] Integration tests if needed
- [ ] Edge cases covered
- [ ] Tests pass

---

## 🎨 UI/UX Standards

**Follow Theme System:**
- Use `Theme.of(context)`
- No hardcoded colors
- Consistent spacing
- Mobile-first design

**Accessibility:**
- Touch targets ≥ 44x44px
- Proper contrast ratios
- Screen reader support
- Keyboard navigation

---

## 🚀 Performance Guidelines

**Optimize:**
- Use `const` constructors
- Lazy load large lists
- Cache network responses
- Debounce user input

**Avoid:**
- Rebuilding entire tree
- Synchronous heavy operations
- Large images without optimization
- Unnecessary network calls

---

## 📞 Support & Escalation

**Issues:**
- Check documentation first
- Search archived docs
- Review similar modules
- Ask team if stuck

**Escalation Path:**
1. Team lead
2. Technical architect
3. Project manager

---

## ✅ Quick Reference

**Add New Feature:**
1. Plan structure
2. Create files in correct folders
3. Write code + tests
4. Update documentation
5. Submit for review

**Fix Bug:**
1. Write failing test
2. Fix bug
3. Verify test passes
4. Update docs if behavior changed
5. Archive related old docs

**Refactor Code:**
1. Ensure tests exist
2. Refactor incrementally
3. Keep tests passing
4. Update documentation
5. Review performance

---

**Maintained by:** DattSoap Development Team  
**Review:** Quarterly  
**Next Review:** June 2026
