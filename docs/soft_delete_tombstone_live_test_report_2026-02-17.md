# Soft Delete + Tombstone Hybrid - Live Scenario QA Report

## Run Metadata
- Date: 2026-02-17
- Generated At (UTC): 2026-02-17T06:00:08Z
- Run Started: 2026-02-17T11:26:21.282826
- Run Ended: 2026-02-17T11:26:38.010905
- Total Tests: 5
- Passed: 5
- Failed: 0
- Firebase UID: ZNxnFARE1MeVpk6fCFx5vJ6WfAk2
- Firebase Email: live.scenario.1771306532379@erp.local
- App Role: Admin
- Auth Mode: existing_session

## Final Result
All 5 live scenarios passed. Deletion consistency and ghost prevention validated for tested paths.

## TEST 1 - Soft Delete Flow
- Status: **PASS**
- Record ID: `5f2822ee-5b0e-41b6-b0b0-d21bba70d7ba`

### Before State
```json
{
    "server":  {
                   "exists":  true,
                   "isDeleted":  false,
                   "deletedAt":  null,
                   "updatedAt":  "2026-02-17T11:26:22.512350"
               },
    "local":  {
                  "exists":  true,
                  "isDeleted":  false,
                  "deletedAt":  null,
                  "updatedAt":  "2026-02-17T11:26:22.673093",
                  "syncStatus":  "synced",
                  "visibleInActiveList":  true
              }
}
```

### After State
```json
{
    "localAfterDelete":  {
                             "exists":  true,
                             "isDeleted":  true,
                             "deletedAt":  "2026-02-17T11:26:22.808099",
                             "updatedAt":  "2026-02-17T11:26:22.808099",
                             "syncStatus":  "pending",
                             "visibleInActiveList":  false
                         },
    "localAfterSync":  {
                           "exists":  true,
                           "isDeleted":  true,
                           "deletedAt":  "2026-02-17T11:26:22.808099",
                           "updatedAt":  "2026-02-17T11:26:22.874633",
                           "syncStatus":  "synced",
                           "visibleInActiveList":  false
                       },
    "serverAfterSync":  {
                            "exists":  true,
                            "isDeleted":  true,
                            "deletedAt":  "2026-02-17T11:26:22.808099",
                            "updatedAt":  "2026-02-17T11:26:22.808099"
                        }
}
```

### Sync Timestamps
```json
{
    "queueProcessAt":  "2026-02-17T11:26:22.949978"
}
```

### Assertions
- [x] `server_isDeleted_true` = `True`
- [x] `server_deletedAt_set` = `True`
- [x] `server_updatedAt_changed` = `True`
- [x] `local_hidden_after_sync` = `True`
- [x] `no_ghost_record` = `True`
- [x] `delete_event_was_queued` = `True`

### Conflicts
```json
{
    "detected":  false
}
```

### Queue Snapshot
```json
{
    "queueId":  "outbox_products_5f2822ee-5b0e-41b6-b0b0-d21bba70d7ba",
    "collection":  "products",
    "action":  "delete",
    "syncStatus":  "pending",
    "attemptCount":  0,
    "nextRetryAt":  null
}
```

## TEST 2 - Offline Delete
- Status: **PASS**
- Record ID: `de765cba-d85b-4afa-9910-a07b3d89c6d9`

### Before State
```json
{
    "local":  {
                  "exists":  true,
                  "isDeleted":  false,
                  "deletedAt":  null,
                  "updatedAt":  "2026-02-17T11:26:23.037478",
                  "syncStatus":  "synced",
                  "visibleInActiveList":  true
              },
    "server":  {
                   "exists":  true,
                   "isDeleted":  false,
                   "deletedAt":  null,
                   "updatedAt":  "2026-02-17T11:26:22.953009"
               },
    "queue":  [

              ]
}
```

### After State
```json
{
    "localAfterOfflineDelete":  {
                                    "exists":  true,
                                    "isDeleted":  true,
                                    "deletedAt":  "2026-02-17T11:26:23.169845",
                                    "updatedAt":  "2026-02-17T11:26:23.169845",
                                    "syncStatus":  "pending",
                                    "visibleInActiveList":  false
                                },
    "serverWhileOffline":  {
                               "exists":  true,
                               "isDeleted":  false,
                               "deletedAt":  null,
                               "updatedAt":  "2026-02-17T11:26:22.953009"
                           },
    "serverAfterReconnect":  {
                                 "exists":  true,
                                 "isDeleted":  true,
                                 "deletedAt":  "2026-02-17T11:26:23.169845",
                                 "updatedAt":  "2026-02-17T11:26:23.169845"
                             },
    "localAfterReconnect":  {
                                "exists":  true,
                                "isDeleted":  true,
                                "deletedAt":  "2026-02-17T11:26:23.169845",
                                "updatedAt":  "2026-02-17T11:26:25.269470",
                                "syncStatus":  "synced",
                                "visibleInActiveList":  false
                            },
    "localAfterRefresh":  {
                              "exists":  true,
                              "isDeleted":  true,
                              "deletedAt":  "2026-02-17T11:26:23.169845",
                              "updatedAt":  "2026-02-17T11:26:23.169845",
                              "syncStatus":  "synced",
                              "visibleInActiveList":  false
                          }
}
```

### Sync Timestamps
```json
{
    "syncAllCompletedAt":  "2026-02-17T11:26:27.594061",
    "lastSyncAllTime":  "2026-02-17T11:26:27.552606"
}
```

### Assertions
- [x] `record_marked_deleted_locally` = `True`
- [x] `sync_event_queued` = `True`
- [x] `server_soft_deleted_after_reconnect` = `True`
- [x] `record_hidden_after_refresh` = `True`

### Conflicts
```json
{
    "detected":  false,
    "unresolvedConflictCount":  0
}
```

### Sync Result
```json
{
    "executed":  true,
    "skipped":  false,
    "criticalErrors":  [

                       ],
    "outboxPendingCount":  0,
    "outboxPermanentFailureCount":  0,
    "unresolvedConflictCount":  0,
    "completedAt":  "2026-02-17T11:26:27.594061",
    "message":  null,
    "pendingByModule":  {
                            "customers":  0,
                            "dealers":  0,
                            "users":  0,
                            "custom_roles":  0,
                            "products":  0,
                            "attendances":  0,
                            "duty_sessions":  0,
                            "route_sessions":  0,
                            "customer_visits":  0,
                            "opening_stock_entries":  0,
                            "stock_ledger":  0,
                            "routes":  0,
                            "vehicles":  0,
                            "diesel_logs":  0,
                            "units":  0,
                            "product_categories":  0,
                            "product_types":  0,
                            "leave_requests":  0,
                            "advances":  0,
                            "performance_reviews":  0,
                            "employee_documents":  0,
                            "employees":  0,
                            "sales_targets":  0
                        }
}
```

## TEST 3 - Hard Delete + Tombstone
- Status: **PASS**
- Record ID: `f8f755eb-8eb5-4f30-b127-fa5723de6c61`
- Tombstone ID: `manual_tombstone_f8f755eb-8eb5-4f30-b127-fa5723de6c61_1771307787839`

### Before State
```json
{
    "local":  {
                  "exists":  true,
                  "isDeleted":  false,
                  "deletedAt":  null,
                  "updatedAt":  "2026-02-17T11:26:27.692556",
                  "syncStatus":  "synced",
                  "visibleInActiveList":  true
              },
    "server":  {
                   "exists":  true,
                   "isDeleted":  false,
                   "deletedAt":  null,
                   "updatedAt":  "2026-02-17T11:26:27.600554"
               },
    "queue":  [

              ]
}
```

### After State
```json
{
    "localBeforeRefresh":  {
                               "exists":  true,
                               "isDeleted":  false,
                               "deletedAt":  null,
                               "updatedAt":  "2026-02-17T11:26:27.692556",
                               "syncStatus":  "synced",
                               "visibleInActiveList":  true
                           },
    "localAfterRefresh":  {
                              "exists":  true,
                              "isDeleted":  true,
                              "deletedAt":  "2026-02-17T11:26:27.839054",
                              "updatedAt":  "2026-02-17T11:26:27.839054",
                              "syncStatus":  "synced",
                              "visibleInActiveList":  false
                          },
    "serverAfterRefresh":  {
                               "exists":  false,
                               "isDeleted":  null,
                               "deletedAt":  null,
                               "updatedAt":  null
                           },
    "tombstoneProcessing":  {
                                "processedCount":  2,
                                "containsTombstone":  true
                            }
}
```

### Sync Timestamps
```json
{
    "hardDeleteAt":  "2026-02-17T11:26:27.839054",
    "syncAllCompletedAt":  "2026-02-17T11:26:29.683774"
}
```

### Assertions
- [x] `tombstone_pulled` = `True`
- [x] `local_record_pruned` = `True`
- [x] `no_ghost_data` = `True`
- [x] `server_doc_absent` = `True`

### Conflicts
```json
{
    "detected":  false,
    "unresolvedConflictCount":  0
}
```

### Sync Result
```json
{
    "executed":  true,
    "skipped":  false,
    "criticalErrors":  [

                       ],
    "outboxPendingCount":  0,
    "outboxPermanentFailureCount":  0,
    "unresolvedConflictCount":  0,
    "completedAt":  "2026-02-17T11:26:29.683774",
    "message":  null,
    "pendingByModule":  {
                            "customers":  0,
                            "dealers":  0,
                            "users":  0,
                            "custom_roles":  0,
                            "products":  0,
                            "attendances":  0,
                            "duty_sessions":  0,
                            "route_sessions":  0,
                            "customer_visits":  0,
                            "opening_stock_entries":  0,
                            "stock_ledger":  0,
                            "routes":  0,
                            "vehicles":  0,
                            "diesel_logs":  0,
                            "units":  0,
                            "product_categories":  0,
                            "product_types":  0,
                            "leave_requests":  0,
                            "advances":  0,
                            "performance_reviews":  0,
                            "employee_documents":  0,
                            "employees":  0,
                            "sales_targets":  0
                        }
}
```

## TEST 4 - Multi-Device Scenario
- Status: **PASS**
- Record ID: `829a9e26-1caa-41ee-83ea-267b636ba391`

### Before State
```json
{
    "deviceB":  {
                    "exists":  true,
                    "isDeleted":  false,
                    "deletedAt":  null,
                    "updatedAt":  "2026-02-17T11:26:29.821510",
                    "syncStatus":  "synced",
                    "visibleInActiveList":  true
                }
}
```

### After State
```json
{
    "deviceB":  {
                    "exists":  true,
                    "isDeleted":  true,
                    "deletedAt":  "2026-02-17T11:26:29.871078",
                    "updatedAt":  "2026-02-17T11:26:29.871078",
                    "syncStatus":  "synced",
                    "visibleInActiveList":  false
                },
    "server":  {
                   "exists":  true,
                   "isDeleted":  true,
                   "deletedAt":  "2026-02-17T11:26:29.871078",
                   "updatedAt":  "2026-02-17T11:26:29.871078"
               }
}
```

### Sync Timestamps
```json
{
    "deviceADeleteAt":  "2026-02-17T11:26:29.871078",
    "deviceBRefreshAt":  "2026-02-17T11:26:31.636411"
}
```

### Assertions
- [x] `record_disappears_on_device_b` = `True`
- [x] `server_marked_deleted` = `True`
- [x] `no_conflict_errors` = `True`

### Conflicts
```json
{
    "detected":  false,
    "unresolvedConflictCount":  0
}
```

### Sync Result
```json
{
    "executed":  true,
    "skipped":  false,
    "criticalErrors":  [

                       ],
    "outboxPendingCount":  0,
    "outboxPermanentFailureCount":  0,
    "unresolvedConflictCount":  0,
    "completedAt":  "2026-02-17T11:26:31.636411",
    "message":  null,
    "pendingByModule":  {
                            "customers":  0,
                            "dealers":  0,
                            "users":  0,
                            "custom_roles":  0,
                            "products":  0,
                            "attendances":  0,
                            "duty_sessions":  0,
                            "route_sessions":  0,
                            "customer_visits":  0,
                            "opening_stock_entries":  0,
                            "stock_ledger":  0,
                            "routes":  0,
                            "vehicles":  0,
                            "diesel_logs":  0,
                            "units":  0,
                            "product_categories":  0,
                            "product_types":  0,
                            "leave_requests":  0,
                            "advances":  0,
                            "performance_reviews":  0,
                            "employee_documents":  0,
                            "employees":  0,
                            "sales_targets":  0
                        }
}
```

## TEST 5 - Critical Collection Reconcile
- Status: **PASS**
- Record ID: `7f1bf459-11f1-4654-a788-3e623c6f88a8`

### Before State
```json
{
    "local":  {
                  "exists":  true,
                  "isDeleted":  false,
                  "deletedAt":  null,
                  "updatedAt":  "2026-02-17T11:26:31.765876",
                  "syncStatus":  "synced",
                  "visibleInActiveList":  true
              },
    "server":  {
                   "exists":  true,
                   "isDeleted":  false,
                   "deletedAt":  null,
                   "updatedAt":  "2026-02-17T11:26:31.685463"
               },
    "queue":  [

              ]
}
```

### After State
```json
{
    "localBeforeReconcile":  {
                                 "exists":  true,
                                 "isDeleted":  false,
                                 "deletedAt":  null,
                                 "updatedAt":  "2026-02-17T11:26:31.765876",
                                 "syncStatus":  "synced",
                                 "visibleInActiveList":  true
                             },
    "localAfterReconcile":  {
                                "exists":  true,
                                "isDeleted":  true,
                                "deletedAt":  "2026-02-17T11:26:37.306514",
                                "updatedAt":  "2026-02-17T11:26:37.306514",
                                "syncStatus":  "synced",
                                "visibleInActiveList":  false
                            },
    "serverAfterReconcile":  {
                                 "exists":  false,
                                 "isDeleted":  null,
                                 "deletedAt":  null,
                                 "updatedAt":  null
                             }
}
```

### Sync Timestamps
```json
{
    "serverHardDeleteAt":  "2026-02-17T11:26:31.885287",
    "forceRefreshCompletedAt":  "2026-02-17T11:26:37.819027"
}
```

### Assertions
- [x] `local_orphan_pruned` = `True`
- [x] `local_hidden_after_reconcile` = `True`
- [x] `server_doc_absent` = `True`

### Conflicts
```json
{
    "detected":  false,
    "unresolvedConflictCount":  0
}
```

### Sync Result
```json
{
    "executed":  true,
    "skipped":  false,
    "criticalErrors":  [

                       ],
    "outboxPendingCount":  0,
    "outboxPermanentFailureCount":  0,
    "unresolvedConflictCount":  0,
    "completedAt":  "2026-02-17T11:26:37.819027",
    "message":  null,
    "pendingByModule":  {
                            "customers":  0,
                            "dealers":  0,
                            "users":  0,
                            "custom_roles":  0,
                            "products":  0,
                            "attendances":  0,
                            "duty_sessions":  0,
                            "route_sessions":  0,
                            "customer_visits":  0,
                            "opening_stock_entries":  0,
                            "stock_ledger":  0,
                            "routes":  0,
                            "vehicles":  0,
                            "diesel_logs":  0,
                            "units":  0,
                            "product_categories":  0,
                            "product_types":  0,
                            "leave_requests":  0,
                            "advances":  0,
                            "performance_reviews":  0,
                            "employee_documents":  0,
                            "employees":  0,
                            "sales_targets":  0
                        }
}
```

## Artifacts
- Raw JSON: `run_live_soft_delete_report.json`
- Live Run Logs: terminal output from `flutter run -d windows -t scripts/live_soft_delete_tombstone_scenario.dart`
