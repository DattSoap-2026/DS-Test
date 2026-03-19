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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'phone': phone,
      'status': status,
      'assignedRoutes': assignedRoutes,
      'passwordHash': passwordHash,
      'permissions': permissions,
      'department': department,
      'designation': designation,
      'departments': _decodeJsonObject(departmentsJson),
      'departmentsJson': departmentsJson,
      'allocatedStock': _decodeJsonObject(allocatedStockJson),
      'allocatedStockJson': allocatedStockJson,
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
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'isSynced': isSynced,
      'lastSynced': lastSynced?.toIso8601String(),
      'version': version,
      'deviceId': deviceId,
    };
  }

  static UserEntity fromJson(Map<String, dynamic> json) {
    final entity = UserEntity()
      ..id = json['id']?.toString() ?? ''
      ..name = json['name']?.toString()
      ..email = json['email']?.toString()
      ..role = json['role']?.toString()
      ..isActive = json['isActive'] != false
      ..phone = json['phone']?.toString()
      ..status = json['status']?.toString()
      ..assignedRoutes = (json['assignedRoutes'] as List?)
          ?.map((item) => item.toString())
          .toList()
      ..passwordHash = json['passwordHash']?.toString()
      ..permissions = (json['permissions'] as List?)
          ?.map((item) => item.toString())
          .toList()
      ..department = json['department']?.toString()
      ..designation = json['designation']?.toString()
      ..departmentsJson = _encodeJsonValue(
        json['departments'],
        fallback: json['departmentsJson']?.toString(),
      )
      ..allocatedStockJson = _encodeJsonValue(
        json['allocatedStock'],
        fallback: json['allocatedStockJson']?.toString(),
      )
      ..assignedBhatti = json['assignedBhatti']?.toString()
      ..assignedBaseProductId = json['assignedBaseProductId']?.toString()
      ..assignedBaseProductName = json['assignedBaseProductName']?.toString()
      ..assignedVehicleId = json['assignedVehicleId']?.toString()
      ..assignedVehicleName = json['assignedVehicleName']?.toString()
      ..assignedVehicleNumber = json['assignedVehicleNumber']?.toString()
      ..assignedDeliveryRoute = json['assignedDeliveryRoute']?.toString()
      ..assignedSalesRoute = json['assignedSalesRoute']?.toString()
      ..assignedWarehouseId = json['assignedWarehouseId']?.toString()
      ..assignedWarehouseName = json['assignedWarehouseName']?.toString()
      ..updatedAt =
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now()
      ..deletedAt = DateTime.tryParse(json['deletedAt']?.toString() ?? '')
      ..isDeleted = json['isDeleted'] == true
      ..isSynced = json['isSynced'] == true
      ..lastSynced = DateTime.tryParse(json['lastSynced']?.toString() ?? '')
      ..version = (json['version'] as num? ?? 1).toInt()
      ..deviceId = json['deviceId']?.toString() ?? '';
    return entity;
  }

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
      } catch (_) {}
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

  static dynamic _decodeJsonObject(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static String? _encodeJsonValue(dynamic value, {String? fallback}) {
    if (value == null) {
      return fallback;
    }
    if (value is String) {
      return value;
    }
    try {
      return jsonEncode(value);
    } catch (_) {
      return fallback;
    }
  }
}
