import 'package:isar/isar.dart';

import '../data/local/entities/vehicle_entity.dart';
import 'base_service.dart';
import 'database_service.dart';

class ComplianceNotification {
  final String id;
  final String vehicleId;
  final String vehicleName;
  final String vehicleNumber;
  final String type; // 'compliance'
  final String category; // 'PUC' | 'Permit' | 'Fitness' | 'Insurance'
  final String priority; // 'medium' | 'high'
  final int dueInDays;
  final String expiryDate;
  final String message;
  final String status; // 'pending'
  final String createdAt;

  ComplianceNotification({
    required this.id,
    required this.vehicleId,
    required this.vehicleName,
    required this.vehicleNumber,
    required this.type,
    required this.category,
    required this.priority,
    required this.dueInDays,
    required this.expiryDate,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory ComplianceNotification.fromJson(Map<String, dynamic> json) {
    return ComplianceNotification(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      vehicleName: json['vehicleName'] as String,
      vehicleNumber: json['vehicleNumber'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      priority: json['priority'] as String,
      dueInDays: (json['dueInDays'] as num).toInt(),
      expiryDate: json['expiryDate'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
    );
  }
}

class ComplianceService extends BaseService {
  final DatabaseService _dbService;

  ComplianceService(super.firebase, [DatabaseService? dbService])
    : _dbService = dbService ?? DatabaseService.instance;

  List<ComplianceNotification> _buildNotifications(VehicleEntity vehicle) {
    final now = DateTime.now();
    final reminders = <ComplianceNotification>[];

    final checks = <String, DateTime?>{
      'PUC': vehicle.pucExpiryDate,
      'Permit': vehicle.permitExpiryDate,
      'Fitness': vehicle.fitnessExpiryDate,
      'Insurance': vehicle.insuranceExpiryDate,
    };

    for (final entry in checks.entries) {
      final category = entry.key;
      final expiry = entry.value;
      if (expiry == null) continue;

      final difference = expiry.difference(now).inDays;
      if (difference > 30 || difference < 0) continue;

      final priority = difference <= 15 ? 'high' : 'medium';
      final message = priority == 'high'
          ? 'URGENT: $category expires in $difference days for ${vehicle.name}'
          : '$category expires in $difference days for ${vehicle.name}';

      reminders.add(
        ComplianceNotification(
          id: '${vehicle.id}_${category}_${expiry.toIso8601String()}',
          vehicleId: vehicle.id,
          vehicleName: vehicle.name,
          vehicleNumber: vehicle.number,
          type: 'compliance',
          category: category,
          priority: priority,
          dueInDays: difference,
          expiryDate: expiry.toIso8601String(),
          message: message,
          status: 'pending',
          createdAt: now.toIso8601String(),
        ),
      );
    }

    return reminders;
  }

  Future<void> generateComplianceReminders(Map<String, dynamic> vehicle) async {
    // Legacy entry point retained for compatibility.
    // Compliance reminders are computed on-demand from local vehicles.
    try {
      // No-op: data is computed locally in getters.
    } catch (e) {
      handleError(e, 'generateComplianceReminders');
    }
  }

  Future<List<ComplianceNotification>>
  getPendingComplianceNotifications() async {
    try {
      final vehicles = await _dbService.vehicles.where().findAll();
      if (vehicles.isEmpty) return [];

      final notifications = <ComplianceNotification>[];
      for (final v in vehicles) {
        if (v.status != 'active') continue;
        notifications.addAll(_buildNotifications(v));
      }
      return notifications;
    } catch (e) {
      handleError(e, 'getPendingComplianceNotifications');
      return [];
    }
  }

  Future<List<ComplianceNotification>> getVehicleComplianceNotifications(
    String vehicleId,
  ) async {
    try {
      final vehicle = await _dbService.vehicles
          .filter()
          .idEqualTo(vehicleId)
          .findFirst();
      if (vehicle == null) return [];

      return _buildNotifications(vehicle);
    } catch (e) {
      handleError(e, 'getVehicleComplianceNotifications');
      return [];
    }
  }
}
