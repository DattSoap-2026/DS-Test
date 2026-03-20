// import 'package:firebase_auth/firebase_auth.dart';
import '../core/sync/sync_queue_service.dart';
import '../core/sync/sync_service.dart';
import 'base_service.dart';

const incentivesDocId =
    'reports_preferences'; // Matches TS: 'reports_preferences'
const settingsCollection = 'public_settings'; // Matches TS: 'public_settings'

class IncentiveSettings {
  final int requiredMonthlyWorkDays;
  final int dailyCounterTarget;
  final double dailyIncentiveAmount;
  final double newCustomerIncentive;
  final double mileagePenaltyAmount;

  IncentiveSettings({
    this.requiredMonthlyWorkDays = 18,
    this.dailyCounterTarget = 10,
    this.dailyIncentiveAmount = 0,
    this.newCustomerIncentive = 0,
    this.mileagePenaltyAmount = 0,
  });

  factory IncentiveSettings.fromJson(Map<String, dynamic> json) {
    return IncentiveSettings(
      requiredMonthlyWorkDays:
          (json['requiredMonthlyWorkDays'] as num?)?.toInt() ?? 18,
      dailyCounterTarget: (json['dailyCounterTarget'] as num?)?.toInt() ?? 10,
      dailyIncentiveAmount:
          (json['dailyIncentiveAmount'] as num?)?.toDouble() ?? 0,
      newCustomerIncentive:
          (json['newCustomerIncentive'] as num?)?.toDouble() ?? 0,
      mileagePenaltyAmount:
          (json['mileagePenaltyAmount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requiredMonthlyWorkDays': requiredMonthlyWorkDays,
      'dailyCounterTarget': dailyCounterTarget,
      'dailyIncentiveAmount': dailyIncentiveAmount,
      'newCustomerIncentive': newCustomerIncentive,
      'mileagePenaltyAmount': mileagePenaltyAmount,
    };
  }
}

class IncentivesService extends BaseService {
  IncentivesService(super.firebase);

  Future<IncentiveSettings> getIncentives() async {
    try {
      final firestore = db;
      if (firestore == null) return IncentiveSettings();

      final docSnap = await firestore
          .collection(settingsCollection)
          .doc(incentivesDocId)
          .get();
      if (docSnap.exists) {
        return IncentiveSettings.fromJson(docSnap.data() ?? {});
      }
      return IncentiveSettings(); // Defaults
    } catch (e) {
      handleError(e, 'getIncentives');
      return IncentiveSettings();
    }
  }

  Future<bool> saveIncentives(IncentiveSettings settings) async {
    try {
      final payload = <String, dynamic>{
        'id': incentivesDocId,
        ...settings.toJson(),
      };
      await SyncQueueService.instance.addToQueue(
        collectionName: settingsCollection,
        documentId: incentivesDocId,
        operation: 'set',
        payload: payload,
      );
      if (db != null) {
        await SyncService.instance.trySync();
      }
      return true;
    } catch (e) {
      handleError(e, 'saveIncentives');
      return false;
    }
  }
}
