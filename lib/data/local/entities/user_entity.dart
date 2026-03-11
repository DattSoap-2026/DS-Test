// [HARD LOCKED] - Authentication & Authorization Module
//
// CRITICAL: This file contains core security and access control logic.
// - NO modification allowed without explicit AUTH_LOCK_OVERRIDE.
// - NO refactoring or optimization allowed.
// - ALL changes must be documented for security review.
//
// Strict Contract: Online-only login, Firestore-verified roles.
// Security Source: Firebase Auth & Firestore 'users' collection.

import 'dart:convert';
import 'package:isar/isar.dart';
import '../base_entity.dart';
import 'package:flutter_app/models/types/user_types.dart';

part 'user_entity.g.dart';

@Collection()
class UserEntity extends BaseEntity {
  String? name;
  String? email;
  String? role; // 'admin', 'salesman', etc.
  bool isActive = true;

  String? phone;
  String? status;
  List<String>? assignedRoutes;

  // For offline auth check
  String? passwordHash;

  // Store permissions as JSON string or list of strings
  List<String>? permissions;

  // Additional fields for profile
  String? department;
  String? designation;
  String? departmentsJson;

  // Dispatch & Allocation (Offline Support)
  String? allocatedStockJson; // Stored as JSON string
  String? assignedBhatti;
  String? assignedBaseProductId;
  String? assignedBaseProductName;
  String? assignedVehicleId;
  String? assignedVehicleName;
  String? assignedVehicleNumber;
  String? assignedDeliveryRoute;
  String? assignedSalesRoute;
  String? assignedWarehouseId; // For Production Supervisors
  String? assignedWarehouseName;

  AppUser toDomain() {
    UserRole resolvedRole;
    if (email?.toLowerCase() == 'admin@dattsoap.com') {
      resolvedRole = UserRole.admin;
    } else {
      try {
        resolvedRole = UserRole.fromString(role ?? 'Salesman');
      } catch (e) {
        resolvedRole = UserRole.salesman;
      }
    }

    List<UserDepartment> depts = [];
    if (departmentsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(departmentsJson!);
        depts = decoded.map((e) => UserDepartment.fromJson(e)).toList();
      } catch (e) {
        // print('Error decoding user departments json: $e');
      }
    }

    final resolvedStatus =
        (status != null && status!.trim().isNotEmpty)
        ? status!.trim()
        : (isActive ? 'active' : 'inactive');

    return AppUser(
      id: id,
      name: name ?? 'Unknown',
      email: email ?? '',
      role: resolvedRole,
      department: department,
      phone: phone,
      departments: depts,
      assignedRoutes: assignedRoutes,
      assignedBhatti: assignedBhatti,
      assignedBaseProductId: assignedBaseProductId,
      assignedBaseProductName: assignedBaseProductName,
      assignedVehicleId: assignedVehicleId,
      assignedVehicleName: assignedVehicleName,
      assignedVehicleNumber: assignedVehicleNumber,
      assignedDeliveryRoute: assignedDeliveryRoute,
      assignedSalesRoute: assignedSalesRoute,
      assignedWarehouseId: assignedWarehouseId,
      assignedWarehouseName: assignedWarehouseName,
      allocatedStock: allocatedStockJson != null
          ? _parseAllocatedStock(allocatedStockJson!)
          : null,
      createdAt: updatedAt.toIso8601String(),
      status: resolvedStatus,
      isActive: isActive,
    );
  }

  Map<String, AllocatedStockItem> getAllocatedStock() {
    if (allocatedStockJson == null) return {};
    return _parseAllocatedStock(allocatedStockJson!);
  }

  void setAllocatedStock(Map<String, AllocatedStockItem> stock) {
    // Convert Map<String, AllocatedStockItem> to Map<String, dynamic>
    final jsonMap = stock.map((key, value) => MapEntry(key, value.toJson()));
    allocatedStockJson = jsonEncode(jsonMap);
  }

  Map<String, AllocatedStockItem> _parseAllocatedStock(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map(
        (key, value) => MapEntry(key, AllocatedStockItem.fromJson(value)),
      );
    } catch (e) {
      return {};
    }
  }
}
