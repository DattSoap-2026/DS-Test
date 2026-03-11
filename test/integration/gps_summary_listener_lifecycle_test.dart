import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/screens/gps/gps_tracking_screen.dart';
import 'package:flutter_app/services/duty_service.dart';
import 'package:flutter_app/services/gps_service.dart';
import 'package:flutter_app/services/visit_service.dart';

void main() {
  testWidgets('summary listeners stay stable across repeated tab switches', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    int routeListenCount = 0;
    int dutyListenCount = 0;
    final lifecycleLogs = <String>[];

    final routeController = StreamController<List<RouteSession>>.broadcast(
      onListen: () => routeListenCount++,
    );
    final dutyController = StreamController<List<DutySession>>.broadcast(
      onListen: () => dutyListenCount++,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: GPSTrackingScreen(
          liveLocationStreamFactory: () =>
              const Stream<List<LocationData>>.empty(),
          routeSummaryStreamFactory: (_) => routeController.stream,
          dutySummaryStreamFactory: (_) => dutyController.stream,
          historyLoader: (userId, startDate, endDate) async =>
              const <LocationHistoryPoint>[],
          lifecycleLogger: lifecycleLogs.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dynamic initialState = tester.state(find.byType(GPSTrackingScreen));
    final beforeRouteAttach = initialState.debugRouteSummaryAttachCount as int;
    final beforeDutyAttach = initialState.debugDutySummaryAttachCount as int;

    expect(routeListenCount, 1);
    expect(dutyListenCount, 1);
    expect(beforeRouteAttach, 1);
    expect(beforeDutyAttach, 1);

    // Repeated tab flips should not duplicate summary listener attach for same date.
    for (var i = 0; i < 4; i++) {
      await tester.tap(find.text('Route Replay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Live Tracking'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Daily Summary'));
      await tester.pumpAndSettle();
    }

    final dynamic switchedState = tester.state(find.byType(GPSTrackingScreen));
    expect(routeListenCount, 1);
    expect(dutyListenCount, 1);
    expect(switchedState.debugRouteSummaryAttachCount, beforeRouteAttach);
    expect(switchedState.debugDutySummaryAttachCount, beforeDutyAttach);

    routeController.add(<RouteSession>[_routeSession()]);
    dutyController.add(<DutySession>[_dutySession()]);
    await tester.pump();

    expect(switchedState.debugRouteSummaryCallbackCount, 1);
    expect(switchedState.debugDutySummaryCallbackCount, 1);

    // Switch again and emit again; callback counters must grow linearly (no duplicate listeners).
    await tester.tap(find.text('Live Tracking'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Daily Summary'));
    await tester.pumpAndSettle();

    routeController.add(<RouteSession>[_routeSession(id: 'r2')]);
    dutyController.add(<DutySession>[_dutySession(id: 'd2')]);
    await tester.pump();

    final dynamic finalState = tester.state(find.byType(GPSTrackingScreen));
    expect(finalState.debugRouteSummaryCallbackCount, 2);
    expect(finalState.debugDutySummaryCallbackCount, 2);
    expect(routeListenCount, 1);
    expect(dutyListenCount, 1);

    // Memory-safety proof: before/after counters remain stable across tab switches.
    expect(
      lifecycleLogs
          .where((l) => l.contains('summary_attach_skip_same_date'))
          .isNotEmpty,
      true,
    );
    expect(
      lifecycleLogs.where((l) => l.contains('routeAttach=1')).isNotEmpty,
      true,
    );
    expect(
      lifecycleLogs.where((l) => l.contains('dutyAttach=1')).isNotEmpty,
      true,
    );

    await routeController.close();
    await dutyController.close();
  });
}

RouteSession _routeSession({String id = 'r1'}) {
  final nowIso = DateTime(2026, 2, 19, 10, 0, 0).toIso8601String();
  return RouteSession(
    id: id,
    salesmanId: 'u1',
    salesmanName: 'Sales One',
    routeId: 'route-1',
    routeName: 'Morning Route',
    date: '2026-02-19',
    startTime: nowIso,
    status: 'active',
    totalDistance: 12.5,
    plannedStops: 10,
    completedStops: 6,
    skippedStops: 0,
    totalSales: 1000,
    totalCollection: 750,
    createdAt: nowIso,
    updatedAt: nowIso,
  );
}

DutySession _dutySession({String id = 'd1'}) {
  final nowIso = DateTime(2026, 2, 19, 10, 0, 0).toIso8601String();
  return DutySession(
    id: id,
    userId: 'u1',
    userName: 'Sales One',
    userRole: 'Salesman',
    status: 'active',
    date: '2026-02-19',
    loginTime: nowIso,
    loginLatitude: 23.0,
    loginLongitude: 72.0,
    gpsEnabled: true,
    alerts: const <DutyAlert>[],
    createdAt: nowIso,
    updatedAt: nowIso,
  );
}
