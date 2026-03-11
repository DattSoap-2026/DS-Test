# Salesman Target Report - Implementation Summary (Hindi)

## 🎯 Kya Banana Hai

### 1. Previous Month Ka Data Bhi Dikhana
**Abhi:** Sirf current month (JAN 2025) dikhta hai
**Chahiye:** Current + Previous month (DEC 2024 + JAN 2025) side-by-side

```
┌──────────────┬──────────────┐
│ DEC 2024     │ JAN 2025     │
│ Target: ₹95K │ Target: ₹100K│
│ Sale: ₹75K   │ Sale: ₹80K   │
│ Diff: -₹20K  │ Diff: -₹20K  │
└──────────────┴──────────────┘
```

### 2. Summary Ko Compact Banana (Single Row)
**Abhi:** 4 metrics ek ke niche ek (vertical)
**Chahiye:** 4 metrics ek line me (horizontal)

```
Abhi:
┌─────────────────────┐
│ Total Target  │ ₹0  │
│ Current Sold  │ ₹5K │
│ Prev Sold     │ ₹0  │
│ Remaining     │ ₹0  │
└─────────────────────┘

Chahiye:
┌────────────────────────────────────┐
│ Tgt: ₹100K │ Sold: ₹80K │ Prev: ₹75K │ Rem: ₹20K │
└────────────────────────────────────┘
```

### 3. Admin Settings Me Target Set Karne Ka Option
**Features:**
- Route-wise target manually set kar sake
- Auto-calculate option (previous target + 2%)
- Bulk update (sabhi routes ek saath)
- Target history dekh sake

## 🔧 Implementation Steps

### Step 1: Data Loading Fix (CRITICAL) ⚠️
**Problem:** Target ₹0 dikha raha hai

**Fix:**
```dart
// File: lib/screens/reports/target_achievement_report_screen.dart

// Line ~80-90 me yeh change karo:
final currentT = allTargets.cast<SalesTarget?>().firstWhere(
  (t) => t != null && 
         t.month == _selectedDate.month && 
         t.year == _selectedDate.year,
  orElse: () => null,
);
```

### Step 2: Compact Summary Row
**File:** `lib/screens/reports/target_achievement_report_screen.dart`

**Replace `_buildSummaryWrapGrid` method:**
```dart
Widget _buildCompactSummaryRow(ThemeData theme) {
  final totalTgt = (_currentTarget?.targetAmount ?? 0).toDouble();
  final currentSale = _currentSales.fold(0.0, (sum, s) => sum + s.totalAmount);
  final prevSale = _prevSales.fold(0.0, (sum, s) => sum + s.totalAmount);
  final remaining = max(0.0, totalTgt - currentSale);
  
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildMetric('Target', totalTgt, AppColors.info),
        _buildDivider(theme),
        _buildMetric('Sold', currentSale, AppColors.warning),
        _buildDivider(theme),
        _buildMetric('Prev', prevSale, Colors.grey[600]!),
        _buildDivider(theme),
        _buildMetric('Rem', remaining, AppColors.info),
      ],
    ),
  );
}

Widget _buildMetric(String label, double value, Color color) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
      ),
      SizedBox(height: 4),
      Text(
        '₹${NumberFormat.compact().format(value)}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    ],
  );
}

Widget _buildDivider(ThemeData theme) {
  return Container(
    width: 1,
    height: 30,
    color: theme.dividerColor,
  );
}
```

### Step 3: Previous Month Column
**Update `_buildRouteItem` method:**
```dart
Widget _buildRouteItemWithComparison(ThemeData theme, String route) {
  // Current month
  final currentTgt = (_currentTarget?.routeTargets?[route] ?? 0).toDouble();
  final currentSold = _currentSales
      .where((s) => s.route == route)
      .fold(0.0, (sum, s) => sum + s.totalAmount);
  final currentAch = currentTgt > 0 ? (currentSold / currentTgt * 100) : 0.0;
  
  // Previous month
  final prevTgt = (_prevTarget?.routeTargets?[route] ?? 0).toDouble();
  final prevSold = _prevSales
      .where((s) => s.route == route)
      .fold(0.0, (sum, s) => sum + s.totalAmount);
  final prevAch = prevTgt > 0 ? (prevSold / prevTgt * 100) : 0.0;
  
  return Container(
    margin: EdgeInsets.only(bottom: 12),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: theme.colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Route name
        Text(
          route,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        // Two columns
        Row(
          children: [
            Expanded(
              child: _buildMonthColumn(
                theme,
                DateFormat('MMM').format(
                  DateTime(_selectedDate.year, _selectedDate.month - 1),
                ),
                prevTgt,
                prevSold,
                prevAch,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildMonthColumn(
                theme,
                DateFormat('MMM').format(_selectedDate),
                currentTgt,
                currentSold,
                currentAch,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildMonthColumn(
  ThemeData theme,
  String month,
  double target,
  double sold,
  double achievement,
) {
  final diff = sold - target;
  final isPositive = diff >= 0;
  
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          month.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: 8),
        _buildRow('Target', '₹${NumberFormat.compact().format(target)}'),
        _buildRow('Sale', '₹${NumberFormat.compact().format(sold)}'),
        SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Diff',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            Text(
              '${isPositive ? '+' : ''}₹${NumberFormat.compact().format(diff.abs())}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (achievement / 100).clamp(0, 1),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            color: achievement >= 100 ? AppColors.success : AppColors.warning,
            minHeight: 4,
          ),
        ),
      ],
    ),
  );
}

Widget _buildRow(String label, String value) {
  return Padding(
    padding: EdgeInsets.only(bottom: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
```

### Step 4: Admin Target Management (NEW SCREEN)
**File:** `lib/screens/management/route_targets_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sales_targets_service.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import '../../utils/app_toast.dart';

class RouteTargetsScreen extends StatefulWidget {
  const RouteTargetsScreen({super.key});

  @override
  State<RouteTargetsScreen> createState() => _RouteTargetsScreenState();
}

class _RouteTargetsScreenState extends State<RouteTargetsScreen> {
  late SalesTargetsService _targetsService;
  late UsersService _usersService;
  
  List<AppUser> _salesmen = [];
  String? _selectedSalesmanId;
  DateTime _selectedDate = DateTime.now();
  
  Map<String, TextEditingController> _controllers = {};
  Map<String, double> _previousTargets = {};
  List<String> _routes = [];
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _targetsService = context.read<SalesTargetsService>();
    _usersService = context.read<UsersService>();
    _loadData();
  }
  
  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load salesmen
      final salesmen = await _usersService.getUsers(role: UserRole.salesman);
      
      if (mounted) {
        setState(() {
          _salesmen = salesmen;
          if (salesmen.isNotEmpty) {
            _selectedSalesmanId = salesmen[0].id;
          }
          _isLoading = false;
        });
        
        if (_selectedSalesmanId != null) {
          await _loadRouteTargets();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading data: $e');
      }
    }
  }
  
  Future<void> _loadRouteTargets() async {
    if (_selectedSalesmanId == null) return;
    
    try {
      // Get salesman's routes
      final salesman = _salesmen.firstWhere((s) => s.id == _selectedSalesmanId);
      _routes = salesman.assignedRoutes ?? [];
      
      // Get previous month targets
      final prevDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      final targets = await _targetsService.getSalesTargets(_selectedSalesmanId);
      final prevTarget = targets.firstWhere(
        (t) => t.month == prevDate.month && t.year == prevDate.year,
        orElse: () => null,
      );
      
      // Initialize controllers
      _controllers.clear();
      _previousTargets.clear();
      
      for (var route in _routes) {
        final prevValue = prevTarget?.routeTargets?[route] ?? 0.0;
        _previousTargets[route] = prevValue;
        _controllers[route] = TextEditingController(
          text: prevValue > 0 ? prevValue.toStringAsFixed(0) : '',
        );
      }
      
      setState(() {});
    } catch (e) {
      AppToast.showError(context, 'Error loading targets: $e');
    }
  }
  
  void _autoCalculateTargets() {
    for (var route in _routes) {
      final prevTarget = _previousTargets[route] ?? 0.0;
      if (prevTarget > 0) {
        final newTarget = prevTarget * 1.02; // +2%
        _controllers[route]?.text = newTarget.toStringAsFixed(0);
      }
    }
    setState(() {});
  }
  
  Future<void> _saveTargets() async {
    if (_selectedSalesmanId == null) return;
    
    setState(() => _isSaving = true);
    try {
      final routeTargets = <String, double>{};
      double totalTarget = 0.0;
      
      for (var route in _routes) {
        final value = double.tryParse(_controllers[route]?.text ?? '0') ?? 0.0;
        routeTargets[route] = value;
        totalTarget += value;
      }
      
      await _targetsService.setSalesTarget(
        salesmanId: _selectedSalesmanId!,
        month: _selectedDate.month,
        year: _selectedDate.year,
        targetAmount: totalTarget,
        routeTargets: routeTargets,
      );
      
      if (mounted) {
        AppToast.showSuccess(context, 'Targets saved successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.showError(context, 'Error saving targets: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Route Targets'),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_fix_high),
            onPressed: _autoCalculateTargets,
            tooltip: 'Auto Calculate (+2%)',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isSaving ? null : _saveTargets,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Salesman selector
                Padding(
                  padding: EdgeInsets.all(16),
                  child: DropdownButtonFormField<String>(
                    value: _selectedSalesmanId,
                    decoration: InputDecoration(
                      labelText: 'Salesman',
                      border: OutlineInputBorder(),
                    ),
                    items: _salesmen.map((s) {
                      return DropdownMenuItem(
                        value: s.id,
                        child: Text(s.name),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() => _selectedSalesmanId = val);
                      _loadRouteTargets();
                    },
                  ),
                ),
                // Route targets list
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: _routes.length,
                    itemBuilder: (context, index) {
                      final route = _routes[index];
                      final prevTarget = _previousTargets[route] ?? 0.0;
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Previous: ₹${prevTarget.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 12),
                              TextField(
                                controller: _controllers[route],
                                decoration: InputDecoration(
                                  labelText: 'New Target',
                                  prefix: Text('₹'),
                                  border: OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.add_circle_outline),
                                    onPressed: () {
                                      final newTarget = prevTarget * 1.02;
                                      _controllers[route]?.text = 
                                          newTarget.toStringAsFixed(0);
                                    },
                                    tooltip: '+2%',
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
```

### Step 5: Add Route in Router
**File:** `lib/routers/app_router.dart`

```dart
// Add this route
GoRoute(
  path: 'route-targets',
  name: 'route_targets',
  builder: (context, state) => const RouteTargetsScreen(),
),
```

### Step 6: Add Link in Settings
**File:** `lib/screens/settings/general_settings_screen.dart`

```dart
// Add this ListTile in settings
ListTile(
  leading: Icon(Icons.flag),
  title: Text('Route Targets'),
  subtitle: Text('Manage sales targets for routes'),
  trailing: Icon(Icons.chevron_right),
  onTap: () => context.pushNamed('route_targets'),
)
```

## 🎨 Final UI Look

### Mobile View:
```
┌─────────────────────────────────────┐
│ Target Achievement                  │
├─────────────────────────────────────┤
│ [DEC] [JAN] [FEB] [MAR]            │ ← Month selector
├─────────────────────────────────────┤
│ Overall Achievement          78%    │
│ ↑ 5.2% vs Prev 72.8%               │
│ [████████████░░░░░░░░]             │ ← Progress bar
├─────────────────────────────────────┤
│ Tgt: ₹100K │ Sold: ₹78K │ Prev: ₹75K │ Rem: ₹22K │
├─────────────────────────────────────┤
│ Route Breakdown                     │
│                                     │
│ Akole                               │
│ ┌──────────┬──────────┐            │
│ │ DEC 2024 │ JAN 2025 │            │
│ ├──────────┼──────────┤            │
│ │ Tgt: ₹468K│ Tgt: ₹477K│           │
│ │ Sale: ₹482K│ Sale: ₹113K│          │
│ │ Diff: +₹14K│ Diff: -₹364K│         │
│ │ [████] 103%│ [██] 24%│            │
│ └──────────┴──────────┘            │
│                                     │
│ Ambad                               │
│ ┌──────────┬──────────┐            │
│ │ DEC 2024 │ JAN 2025 │            │
│ └──────────┴──────────┘            │
└─────────────────────────────────────┘
```

## ✅ Testing Checklist

1. [ ] Data loading fix - Target ₹0 nahi dikhna chahiye
2. [ ] Previous month data load ho raha hai
3. [ ] Compact summary row single line me hai
4. [ ] Route breakdown me 2 columns hai (prev + current)
5. [ ] Admin target set kar sakta hai
6. [ ] Auto-calculate (+2%) kaam kar raha hai
7. [ ] Save button targets save kar raha hai
8. [ ] Mobile pe UI clean aur readable hai

## 🚀 Priority Order

### P0 (Abhi karo):
1. Data loading fix
2. Compact summary row

### P1 (Is week):
1. Previous month column
2. Route comparison UI

### P2 (Next week):
1. Admin target management screen
2. Auto-calculate feature

## 📞 Help Needed?

Agar koi problem aaye to:
1. Check console for errors
2. Verify target data in Firebase
3. Test with real salesman account
4. Check route assignments

Sab kuch step-by-step implement karo aur test karte jao! 🎯
