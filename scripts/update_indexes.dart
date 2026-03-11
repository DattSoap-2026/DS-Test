// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('firestore.indexes.json');
  final jsonString = file.readAsStringSync();
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final indexes = data['indexes'] as List<dynamic>;

  final requiredIndexes = [
    {
      'col': 'sales',
      'fields': ['salesmanId', 'createdAt'],
    },
    {
      'col': 'sales',
      'fields': ['recipientId', 'createdAt'],
    },
    {
      'col': 'dispatches',
      'fields': ['salesmanId', 'dispatchDate'],
    },
    {
      'col': 'dispatches',
      'fields': ['routeOrderId', 'status'],
    },
    {
      'col': 'production_logs',
      'fields': ['userId', 'createdAt'],
    },
    {
      'col': 'bhatti_batches',
      'fields': ['status', 'createdAt'],
    },
    {
      'col': 'cutting_batches',
      'fields': ['status', 'createdAt'],
    },
    {
      'col': 'department_stocks',
      'fields': ['departmentId', 'productId'],
    },
    {
      'col': 'stock_ledger',
      'fields': ['productId', 'timestamp'],
    },
    {
      'col': 'stock_ledger',
      'fields': ['type', 'timestamp'],
    },
    {
      'col': 'messages',
      'fields': ['recipientId', 'createdAt'],
    },
    {
      'col': 'messages',
      'fields': ['conversationId', 'createdAt'],
    },
    {
      'col': 'outbox_queue',
      'fields': ['userId', 'status', 'createdAt'],
    },
    {
      'col': 'route_orders',
      'fields': ['salesmanId', 'status'],
    },
  ];

  final newIndexesList = <Map<String, dynamic>>[];

  bool matchesRequired(Map<String, dynamic> existing) {
    final col = existing['collectionGroup'];
    final fields = existing['fields'] as List;
    for (final req in requiredIndexes) {
      if (req['col'] == col &&
          (req['fields'] as List).length == fields.length) {
        bool match = true;
        for (int i = 0; i < fields.length; i++) {
          if (fields[i]['fieldPath'] != (req['fields'] as List)[i]) {
            match = false;
            break;
          }
        }
        if (match) return true;
      }
    }
    return false;
  }

  for (final req in requiredIndexes) {
    final col = req['col'] as String;
    final fields = req['fields'] as List<String>;

    final indexObj = <String, dynamic>{
      "collectionGroup": col,
      "queryScope": "COLLECTION",
      "fields": fields
          .map(
            (f) => <String, dynamic>{
              "fieldPath": f,
              "order":
                  f == 'createdAt' || f == 'timestamp' || f == 'dispatchDate'
                  ? "DESCENDING"
                  : "ASCENDING",
            },
          )
          .toList(),
    };

    if (col == 'outbox_queue') {
      (indexObj['fields'] as List)[2]['order'] = "ASCENDING";
    }

    newIndexesList.add(indexObj);
  }

  for (final ext in indexes) {
    final extMap = ext as Map<String, dynamic>;
    if (!matchesRequired(extMap)) {
      newIndexesList.add(extMap);
    }
  }

  final uniqueList = [];
  final seen = <String>{};
  for (final idx in newIndexesList) {
    final key = jsonEncode(idx);
    if (!seen.contains(key)) {
      seen.add(key);
      uniqueList.add(idx);
    }
  }

  data['indexes'] = uniqueList;
  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  print('Updated firestore.indexes.json');
}
