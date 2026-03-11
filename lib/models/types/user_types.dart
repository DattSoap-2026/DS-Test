enum UserRole {
  owner('Owner'),
  admin('Admin'),
  productionManager('Production Manager'),
  salesManager('Sales Manager'),
  accountant('Accountant'),
  dispatchManager('Dispatch Manager'),
  bhattiSupervisor('Bhatti Supervisor'),
  driver('Driver'),
  salesman('Salesman'),
  gateKeeper('Gate Keeper'),
  storeIncharge('Store Incharge'),
  productionSupervisor('Production Supervisor'),
  fuelIncharge('Fuel Incharge'),
  vehicleMaintenanceManager('Vehicle Maintenance Manager'),
  dealerManager('Dealer Manager');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    final cleanValue = value
        .replaceAll(' ', '')
        .replaceAll('_', '')
        .toLowerCase();
    return UserRole.values.firstWhere((role) {
      final cleanRole = role.value
          .replaceAll(' ', '')
          .replaceAll('_', '')
          .toLowerCase();
      final cleanName = role.name
          .replaceAll(' ', '')
          .replaceAll('_', '')
          .toLowerCase();
      return cleanRole == cleanValue || cleanName == cleanValue;
    }, orElse: () => throw ArgumentError('Invalid UserRole: $value'));
  }

  static List<String> get allValues =>
      UserRole.values.map((e) => e.value).toList();

  String get landingPath {
    switch (this) {
      case UserRole.admin:
      case UserRole.owner:
      case UserRole.storeIncharge:
        return '/dashboard'; // Performance Dashboard
      case UserRole.driver:
      case UserRole.productionManager:
      case UserRole.salesManager:
      case UserRole.dispatchManager:
      case UserRole.gateKeeper:
        return '/dashboard/coming-soon';
      case UserRole.bhattiSupervisor:
        return '/dashboard/bhatti/overview';
      case UserRole.productionSupervisor:
        return '/dashboard/production';
      case UserRole.dealerManager: // Added
        return '/dashboard/dealer/dashboard';
      case UserRole.salesman:
        return '/dashboard'; // Salesman Dashboard handled by DashboardScreen or root
      default:
        return '/dashboard';
    }
  }

  // Role-Based Access Control Extensions
  bool get canAccessBhatti {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.productionManager ||
        this == UserRole.bhattiSupervisor;
  }

  bool get canAccessProduction {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.productionManager ||
        this == UserRole.productionSupervisor;
  }

  bool get canAccessRawMaterials {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.storeIncharge ||
        this == UserRole.bhattiSupervisor;
  }

  bool get canAccessSemiFinished {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.storeIncharge ||
        this == UserRole.bhattiSupervisor ||
        this == UserRole.productionSupervisor;
  }

  bool get canAccessFinishedGoods {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.storeIncharge ||
        this == UserRole.productionSupervisor;
  }

  bool get canAccessPackaging {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.storeIncharge ||
        this == UserRole.productionSupervisor;
  }
}

enum DepartmentMain {
  production('production'),
  bhatti('bhatti'),
  warehouse('warehouse'),
  sales('sales'),
  admin('admin'),
  fuel('fuel'),
  vehicles('vehicles');

  final String value;
  const DepartmentMain(this.value);

  static DepartmentMain fromString(String value) {
    return DepartmentMain.values.firstWhere(
      (dept) => dept.value == value,
      orElse: () => throw ArgumentError('Invalid DepartmentMain: $value'),
    );
  }
}

enum TeamName {
  sona('sona'),
  gita('gita');

  final String value;
  const TeamName(this.value);

  static TeamName fromString(String value) {
    return TeamName.values.firstWhere(
      (team) => team.value == value,
      orElse: () => throw ArgumentError('Invalid TeamName: $value'),
    );
  }
}

class UserDepartment {
  final String main;
  final String? team;

  UserDepartment({required this.main, this.team});

  factory UserDepartment.fromJson(Map<String, dynamic> json) {
    return UserDepartment(
      main: json['main'] as String? ?? '',
      team: json['team'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'main': main, if (team != null) 'team': team};
  }
}

class AllocatedStockItem {
  final String name;
  final int quantity;
  final String productId;
  final double price;
  final double? secondaryPrice;
  final String baseUnit;
  final String? secondaryUnit;
  final double conversionFactor;
  final int? freeQuantity;
  final double? defaultDiscount;
  final String? itemType;

  AllocatedStockItem({
    required this.name,
    required this.quantity,
    required this.productId,
    required this.price,
    this.secondaryPrice,
    required this.baseUnit,
    this.secondaryUnit,
    required this.conversionFactor,
    this.freeQuantity,
    this.defaultDiscount,
    this.itemType,
  });

  factory AllocatedStockItem.fromJson(Map<String, dynamic> json) {
    return AllocatedStockItem(
      name: json['name']?.toString() ?? 'Unknown Product',
      quantity: (json['quantity'] as num? ?? 0).toInt(),
      productId: json['productId']?.toString() ?? '',
      price: (json['price'] as num? ?? 0.0).toDouble(),
      secondaryPrice: (json['secondaryPrice'] as num?)?.toDouble(),
      baseUnit: json['baseUnit']?.toString() ?? '',
      secondaryUnit: json['secondaryUnit']?.toString(),
      conversionFactor: (json['conversionFactor'] as num? ?? 1.0).toDouble(),
      freeQuantity: (json['freeQuantity'] as num? ?? 0).toInt(),
      defaultDiscount: (json['defaultDiscount'] as num?)?.toDouble(),
      itemType: json['itemType']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'productId': productId,
      'price': price,
      'secondaryPrice': secondaryPrice,
      'baseUnit': baseUnit,
      'secondaryUnit': secondaryUnit,
      'conversionFactor': conversionFactor,
      'freeQuantity': freeQuantity,
      'defaultDiscount': defaultDiscount,
      'itemType': itemType,
    };
  }

  AllocatedStockItem copyWith({
    String? name,
    int? quantity,
    String? productId,
    double? price,
    double? secondaryPrice,
    String? baseUnit,
    String? secondaryUnit,
    double? conversionFactor,
    int? freeQuantity,
    double? defaultDiscount,
    String? itemType,
  }) {
    return AllocatedStockItem(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      secondaryPrice: secondaryPrice ?? this.secondaryPrice,
      baseUnit: baseUnit ?? this.baseUnit,
      secondaryUnit: secondaryUnit ?? this.secondaryUnit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      freeQuantity: freeQuantity ?? this.freeQuantity,
      defaultDiscount: defaultDiscount ?? this.defaultDiscount,
      itemType: itemType ?? this.itemType,
    );
  }
}

class UserPreferences {
  final String theme; // 'light', 'dark', 'system'
  final bool notificationsEnabled;
  final String language;

  UserPreferences({
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      theme: json['theme'] ?? 'light',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      language: json['language'] ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
    };
  }
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? phone;
  final String? secondaryPhone;
  final List<UserDepartment> departments;
  final List<String>? assignedRoutes;
  final String? assignedBhatti;
  final String? assignedBaseProductId;
  final String? assignedBaseProductName;
  final String? assignedVehicleId;
  final String? assignedVehicleName;
  final String? assignedVehicleNumber;
  final String? assignedDeliveryRoute;
  final String? assignedSalesRoute;
  final String? assignedWarehouseId; // For Production Supervisors
  final String? assignedWarehouseName;
  final String? status;
  final bool isActive;
  final String createdAt;
  final Map<String, AllocatedStockItem>? allocatedStock;
  final String? customRoleId;
  final String? passwordResetAt;
  final UserPreferences preferences;

  final String? department; // [NEW] Single department assignment

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
    this.phone,
    this.secondaryPhone,
    required this.departments,
    this.assignedRoutes,
    this.assignedBhatti,
    this.assignedBaseProductId,
    this.assignedBaseProductName,
    this.assignedVehicleId,
    this.assignedVehicleName,
    this.assignedVehicleNumber,
    this.assignedDeliveryRoute,
    this.assignedSalesRoute,
    this.assignedWarehouseId,
    this.assignedWarehouseName,
    this.status,
    this.isActive = true,
    required this.createdAt,
    this.allocatedStock,
    this.customRoleId,
    this.passwordResetAt,
    UserPreferences? preferences,
  }) : preferences = preferences ?? UserPreferences();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    var departmentsList = <UserDepartment>[];
    if (json['departments'] != null) {
      departmentsList = (json['departments'] as List)
          .map((e) => UserDepartment.fromJson(e))
          .toList();
    }

    Map<String, AllocatedStockItem>? stockMap;
    if (json['allocatedStock'] != null) {
      stockMap = {};
      (json['allocatedStock'] as Map<String, dynamic>).forEach((key, value) {
        stockMap![key] = AllocatedStockItem.fromJson(value);
      });
    }

    return AppUser(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: UserRole.fromString(json['role'] as String? ?? 'Salesman'),
      department: json['department'] as String?,
      phone: json['phone'] as String?,
      secondaryPhone: json['secondaryPhone'] as String?,
      departments: departmentsList,
      assignedRoutes: json['assignedRoutes'] != null
          ? List<String>.from(json['assignedRoutes'] as List)
          : null,
      assignedBhatti: json['assignedBhatti'] as String?,
      assignedBaseProductId: json['assignedBaseProductId'] as String?,
      assignedBaseProductName: json['assignedBaseProductName'] as String?,
      assignedVehicleId: json['assignedVehicleId'] as String?,
      assignedVehicleName: json['assignedVehicleName'] as String?,
      assignedVehicleNumber: json['assignedVehicleNumber'] as String?,
      assignedDeliveryRoute: json['assignedDeliveryRoute'] as String?,
      assignedSalesRoute: json['assignedSalesRoute'] as String?,
      assignedWarehouseId: json['assignedWarehouseId'] as String?,
      assignedWarehouseName: json['assignedWarehouseName'] as String?,
      status: json['status'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt:
          json['createdAt'] as String? ?? DateTime.now().toIso8601String(),
      allocatedStock: stockMap,
      customRoleId: json['customRoleId'] as String?,
      passwordResetAt: json['passwordResetAt'] as String?,
      preferences: json['preferences'] != null
          ? UserPreferences.fromJson(
              json['preferences'] as Map<String, dynamic>,
            )
          : UserPreferences(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.value,
      'department': department,
      'phone': phone,
      'secondaryPhone': secondaryPhone,
      'departments': departments.map((e) => e.toJson()).toList(),
      'assignedRoutes': assignedRoutes,
      'assignedBhatti': assignedBhatti,
      'assignedBaseProductId': assignedBaseProductId,
      'assignedBaseProductName': assignedBaseProductName,
      'assignedVehicleId': assignedVehicleId,
      'assignedVehicleName': assignedVehicleName,
      'assignedVehicleNumber': assignedVehicleNumber,
      'assignedDeliveryRoute': assignedDeliveryRoute,
      'assignedSalesRoute': assignedSalesRoute,
      'assignedWarehouseId': assignedWarehouseId,
      'assignedWarehouseName': assignedWarehouseName,
      'status': status,
      'isActive': isActive,
      'createdAt': createdAt,
      'allocatedStock': allocatedStock?.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
      'customRoleId': customRoleId,
      'passwordResetAt': passwordResetAt,
      'preferences': preferences.toJson(),
    };
  }

  // Role Helpers (Matching Firestore Rules logic)
  bool get isAdmin => role == UserRole.admin || role == UserRole.owner;
  bool get isStoreIncharge => role == UserRole.storeIncharge;
  bool get isSalesman => role == UserRole.salesman;
  bool get isProductionSupervisor => role == UserRole.productionSupervisor;
  bool get isBhattiSupervisor => role == UserRole.bhattiSupervisor;
  bool get isDriver => role == UserRole.driver;
  bool get isFuelIncharge => role == UserRole.fuelIncharge;
  bool get isDealerManager => role == UserRole.dealerManager;

  bool get hasAdminOrStoreAccess => isAdmin || isStoreIncharge;

  // Manager roles for notification routing
  bool get isManager =>
      role == UserRole.productionManager ||
      role == UserRole.salesManager ||
      role == UserRole.dispatchManager ||
      role == UserRole.dealerManager ||
      role == UserRole.vehicleMaintenanceManager;

  bool get isAdminOrManager => isAdmin || isManager;

  bool isFullyConfigured(String authEmail) {
    if (email != authEmail) return false;
    if (name.isEmpty) return false;
    if (status != 'active' && !isAdmin) return false;

    // Admins and owners don't need department
    if (isAdmin) return true;

    // Others need department
    if (department == null && departments.isEmpty) return false;

    // Bhatti supervisor needs assigned bhatti
    if (role == UserRole.bhattiSupervisor && assignedBhatti == null) {
      return false;
    }

    return true;
  }
}

// Custom Roles & Permissions
enum PermissionModule {
  sales('sales'),
  inventory('inventory'),
  production('production'),
  reports('reports'),
  users('users'),
  customers('customers'),
  vehicles('vehicles'),
  settings('settings');

  final String value;
  const PermissionModule(this.value);

  static PermissionModule fromString(String value) {
    return PermissionModule.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid PermissionModule: $value'),
    );
  }
}

enum PermissionAction {
  create('create'),
  read('read'),
  update('update'),
  delete('delete'),
  approve('approve'),
  export('export');

  final String value;
  const PermissionAction(this.value);

  static PermissionAction fromString(String value) {
    return PermissionAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => throw ArgumentError('Invalid PermissionAction: $value'),
    );
  }
}

class Permission {
  final String id;
  final PermissionModule module;
  final PermissionAction action;
  final String label;
  final String? description;

  Permission({
    required this.id,
    required this.module,
    required this.action,
    required this.label,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      module: PermissionModule.fromString(json['module']),
      action: PermissionAction.fromString(json['action']),
      label: json['label'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'module': module.value,
      'action': action.value,
      'label': label,
      'description': description,
    };
  }
}

class CustomRole {
  final String id;
  final String name;
  final String description;
  final List<Permission> permissions;
  final bool isActive;
  final String createdAt;
  final String createdBy;
  final String? updatedAt;

  CustomRole({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
  });

  factory CustomRole.fromJson(Map<String, dynamic> json) {
    return CustomRole(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: (json['permissions'] as List)
          .map((e) => Permission.fromJson(e))
          .toList(),
      isActive: json['isActive'],
      createdAt: json['createdAt'],
      createdBy: json['createdBy'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions.map((e) => e.toJson()).toList(),
      'isActive': isActive,
      'createdAt': createdAt,
      'createdBy': createdBy,
      'updatedAt': updatedAt,
    };
  }
}

class AuditLog {
  final String id;
  final String collectionName;
  final String docId;
  final String action; // create, update, delete
  final Map<String, dynamic> changes; // map of field -> {oldValue, newValue}
  final String userId;
  final String? userName;
  final String timestamp;

  AuditLog({
    required this.id,
    required this.collectionName,
    required this.docId,
    required this.action,
    required this.changes,
    required this.userId,
    this.userName,
    required this.timestamp,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'],
      collectionName: json['collectionName'] ?? '',
      docId: json['docId'] ?? '',
      action: json['action'] ?? '',
      changes: json['changes'] != null
          ? Map<String, dynamic>.from(json['changes'])
          : {},
      userId: json['userId'] ?? '',
      userName: json['userName'],
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collectionName': collectionName,
      'docId': docId,
      'action': action,
      'changes': changes,
      'userId': userId,
      'userName': userName,
      'timestamp': timestamp,
    };
  }
}
