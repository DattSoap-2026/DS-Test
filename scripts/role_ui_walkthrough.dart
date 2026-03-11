import 'dart:async';
import 'dart:convert';
import 'dart:io';

class _ApiException implements Exception {
  _ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HTTP $statusCode: $body';
}

class _CommandResult {
  _CommandResult({
    required this.label,
    required this.command,
    required this.exitCode,
    required this.durationMs,
    required this.stdoutText,
    required this.stderrText,
  });

  final String label;
  final String command;
  final int exitCode;
  final int durationMs;
  final String stdoutText;
  final String stderrText;

  bool get passed => exitCode == 0;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'label': label,
    'command': command,
    'exitCode': exitCode,
    'durationMs': durationMs,
    'passed': passed,
    'stdout': stdoutText,
    'stderr': stderrText,
  };
}

class _FirebaseRestClient {
  _FirebaseRestClient({
    required this.apiKey,
    required this.projectId,
    HttpClient? httpClient,
  }) : _http = httpClient ?? HttpClient();

  final String apiKey;
  final String projectId;
  final HttpClient _http;

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey',
    );
    final response = await _requestJson(
      'POST',
      uri,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    final response = await _requestJson(
      'POST',
      uri,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
    return response;
  }

  Future<void> deleteAccount({required String idToken}) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:delete?key=$apiKey',
    );
    await _requestJson(
      'POST',
      uri,
      body: <String, dynamic>{'idToken': idToken},
    );
  }

  Future<List<Map<String, dynamic>>> listUsersDocuments({
    required String idToken,
    int pageSize = 200,
  }) async {
    final allDocs = <Map<String, dynamic>>[];
    String? pageToken;

    while (true) {
      final query = <String, String>{'pageSize': '$pageSize'};
      if (pageToken != null && pageToken.isNotEmpty) {
        query['pageToken'] = pageToken;
      }
      final uri = Uri.https(
        'firestore.googleapis.com',
        '/v1/projects/$projectId/databases/(default)/documents/users',
        query,
      );

      final json = await _requestJson(
        'GET',
        uri,
        headers: <String, String>{'Authorization': 'Bearer $idToken'},
      );
      final docs = (json['documents'] as List<dynamic>? ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .toList();
      allDocs.addAll(docs);

      final next = (json['nextPageToken'] ?? '').toString();
      if (next.isEmpty) break;
      pageToken = next;
    }

    return allDocs;
  }

  Future<void> upsertUserDocument({
    required String adminToken,
    required String uid,
    required String name,
    required String email,
    required String role,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$uid',
    );
    final body = <String, dynamic>{
      'fields': <String, dynamic>{
        'id': <String, dynamic>{'stringValue': uid},
        'name': <String, dynamic>{'stringValue': name},
        'email': <String, dynamic>{'stringValue': email},
        'role': <String, dynamic>{'stringValue': role},
        'isActive': <String, dynamic>{'booleanValue': true},
        'status': <String, dynamic>{'stringValue': 'Active'},
        'departments': <String, dynamic>{
          'arrayValue': <String, dynamic>{'values': <dynamic>[]},
        },
        'createdAt': <String, dynamic>{'stringValue': now},
        'updatedAt': <String, dynamic>{'stringValue': now},
      },
    };

    await _requestJson(
      'PATCH',
      uri,
      headers: <String, String>{'Authorization': 'Bearer $adminToken'},
      body: body,
    );
  }

  Future<void> deleteUserDocument({
    required String adminToken,
    required String uid,
  }) async {
    final uri = Uri.parse(
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/users/$uid',
    );
    await _requestJson(
      'DELETE',
      uri,
      headers: <String, String>{'Authorization': 'Bearer $adminToken'},
    );
  }

  Future<Map<String, dynamic>> _requestJson(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final request = await _http.openUrl(method, uri);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    (headers ?? const <String, String>{}).forEach(request.headers.set);
    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _ApiException(response.statusCode, responseBody);
    }
    if (responseBody.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{'data': decoded};
  }
}

class _Runner {
  _Runner({
    required this.apiKey,
    required this.projectId,
    required this.adminEmail,
    required this.adminPassword,
    required this.samplePassword,
    required this.skipLiveChecks,
  });

  final String apiKey;
  final String projectId;
  final String adminEmail;
  final String adminPassword;
  final String samplePassword;
  final bool skipLiveChecks;

  static const List<String> _allRoles = <String>[
    'Owner',
    'Admin',
    'Production Manager',
    'Sales Manager',
    'Accountant',
    'Dispatch Manager',
    'Bhatti Supervisor',
    'Driver',
    'Salesman',
    'Gate Keeper',
    'Store Incharge',
    'Production Supervisor',
    'Fuel Incharge',
    'Vehicle Maintenance Manager',
    'Dealer Manager',
  ];

  Future<int> run() async {
    final startedAt = DateTime.now().toUtc();
    _printInfo('Starting role walkthrough runner...');

    final commandResults = <_CommandResult>[];
    commandResults.add(
      await _runCommand(
        label: 'RBAC test suite',
        executable: 'flutter',
        arguments: <String>[
          'test',
          'test/services/permission_service_test.dart',
          'test/constants/nav_items_rbac_test.dart',
          'test/constants/role_access_matrix_test.dart',
        ],
      ),
    );
    commandResults.add(
      await _runCommand(
        label: 'Bhatti smoke guard',
        executable: 'dart',
        arguments: <String>[
          'run',
          'scripts/bhatti_supervisor_smoke_guard.dart',
        ],
      ),
    );

    final localFailures = commandResults.where((c) => !c.passed).length;
    final liveSection = skipLiveChecks
        ? <String, dynamic>{
            'skipped': true,
            'reason': 'DATT_SKIP_LIVE_ROLE_QA=true',
          }
        : await _runLiveChecks();

    final findings = _buildFindings(
      localFailures: localFailures,
      liveSection: liveSection,
    );

    final endedAt = DateTime.now().toUtc();
    final report = <String, dynamic>{
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt.toIso8601String(),
      'config': <String, dynamic>{
        'projectId': projectId,
        'adminEmail': adminEmail,
        'skipLiveChecks': skipLiveChecks,
      },
      'localChecks': commandResults.map((c) => c.toJson()).toList(),
      'liveChecks': liveSection,
      'findings': findings,
      'summary': <String, dynamic>{
        'criticalOpen': findings['criticalOpen'],
        'normalOpen': findings['normalOpen'],
        'lowOpen': findings['lowOpen'],
      },
    };

    final jsonFile = File('run_role_ui_walkthrough_report.json');
    await jsonFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(report),
    );

    final markdownPath = await _writeMarkdownReport(report);
    _printInfo('JSON report written: ${jsonFile.path}');
    _printInfo('Markdown report written: $markdownPath');

    final criticalOpen = (findings['criticalOpen'] as int?) ?? 0;
    final normalOpen = (findings['normalOpen'] as int?) ?? 0;
    return (criticalOpen > 0 || normalOpen > 0) ? 1 : 0;
  }

  Future<Map<String, dynamic>> _runLiveChecks() async {
    _printInfo('Running live Firebase role checks...');
    final client = _FirebaseRestClient(apiKey: apiKey, projectId: projectId);

    final adminAuth = await client.signIn(
      email: adminEmail,
      password: adminPassword,
    );
    final adminToken = (adminAuth['idToken'] ?? '').toString();
    if (adminToken.isEmpty) {
      throw StateError('Admin auth token missing.');
    }

    final baselineDocs = await client.listUsersDocuments(idToken: adminToken);
    final baselineCount = baselineDocs.length;

    final existingSample = await _probeExistingRoleSamples(
      client: client,
      adminToken: adminToken,
      usersDocs: baselineDocs,
    );

    final temporaryWalkthrough = await _runTemporaryRoleWalkthrough(
      client: client,
      adminToken: adminToken,
    );

    final finalDocs = await client.listUsersDocuments(idToken: adminToken);
    return <String, dynamic>{
      'skipped': false,
      'existingSamples': existingSample,
      'temporaryRoleWalkthrough': temporaryWalkthrough,
      'postCleanupUsersCount': finalDocs.length,
      'baselineUsersCount': baselineCount,
    };
  }

  Future<Map<String, dynamic>> _probeExistingRoleSamples({
    required _FirebaseRestClient client,
    required String adminToken,
    required List<Map<String, dynamic>> usersDocs,
  }) async {
    final usersByRole = <String, List<String>>{};
    for (final doc in usersDocs) {
      final fields =
          (doc['fields'] as Map<String, dynamic>? ?? const <String, dynamic>{});
      final role = _stringField(fields, 'role');
      final email = _stringField(fields, 'email');
      final isActive = _boolField(fields, 'isActive') ?? true;
      if (role == null || role.isEmpty || email == null || email.isEmpty) {
        continue;
      }
      if (!isActive) continue;
      usersByRole.putIfAbsent(role, () => <String>[]).add(email);
    }

    final results = <Map<String, dynamic>>[];
    final sortedRoles = usersByRole.keys.toList()..sort();
    for (final role in sortedRoles) {
      final emails = usersByRole[role] ?? const <String>[];
      final qaPreferred = emails
          .where((e) => e.startsWith('qa.role.') && e.endsWith('@erp.local'))
          .toList();
      final selected = qaPreferred.isNotEmpty
          ? qaPreferred.first
          : emails.first;

      try {
        final auth = await client.signIn(
          email: selected,
          password: samplePassword,
        );
        results.add(<String, dynamic>{
          'role': role,
          'email': selected,
          'login': true,
          'uid': auth['localId'],
        });
      } catch (e) {
        results.add(<String, dynamic>{
          'role': role,
          'email': selected,
          'login': false,
          'error': e.toString(),
        });
      }
    }

    final passed = results.where((r) => r['login'] == true).length;
    final failed = results.length - passed;
    return <String, dynamic>{
      'sampledRoles': results.length,
      'passed': passed,
      'failed': failed,
      'results': results,
    };
  }

  Future<Map<String, dynamic>> _runTemporaryRoleWalkthrough({
    required _FirebaseRestClient client,
    required String adminToken,
  }) async {
    final rows = <Map<String, dynamic>>[];
    final stamp = DateTime.now().toUtc().millisecondsSinceEpoch;

    var index = 0;
    for (final role in _allRoles) {
      index += 1;
      final slug = role.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
      final email = 'role.walk.$slug.$stamp.$index@erp.local';
      String? uid;
      String? signUpToken;
      String? signInToken;
      final cleanupErrors = <String>[];
      String? errorText;
      var login = false;

      try {
        final signUp = await client.signUp(
          email: email,
          password: samplePassword,
        );
        uid = (signUp['localId'] ?? '').toString();
        signUpToken = (signUp['idToken'] ?? '').toString();

        if (uid.isEmpty) {
          throw StateError('Signup succeeded but uid missing for role $role.');
        }

        await client.upsertUserDocument(
          adminToken: adminToken,
          uid: uid,
          name: 'Role Walkthrough - $role',
          email: email,
          role: role,
        );

        final signIn = await client.signIn(
          email: email,
          password: samplePassword,
        );
        login = true;
        signInToken = (signIn['idToken'] ?? '').toString();
      } catch (e) {
        errorText = e.toString();
      } finally {
        if (uid != null && uid.isNotEmpty) {
          try {
            await client.deleteUserDocument(adminToken: adminToken, uid: uid);
          } catch (e) {
            cleanupErrors.add('delete_user_doc_failed: $e');
          }
        }

        final tokenForDelete = (signInToken != null && signInToken.isNotEmpty)
            ? signInToken
            : signUpToken;
        if (tokenForDelete != null && tokenForDelete.isNotEmpty) {
          try {
            await client.deleteAccount(idToken: tokenForDelete);
          } catch (e) {
            cleanupErrors.add('delete_auth_user_failed: $e');
          }
        }
      }

      rows.add(<String, dynamic>{
        'role': role,
        'email': email,
        'login': login,
        'error': errorText,
        'cleanupErrors': cleanupErrors,
      });
    }

    final passed = rows.where((r) => r['login'] == true).length;
    final failed = rows.length - passed;
    final cleanupIssueRoles = rows
        .where((r) => (r['cleanupErrors'] as List<dynamic>).isNotEmpty)
        .length;
    return <String, dynamic>{
      'totalRoles': _allRoles.length,
      'passed': passed,
      'failed': failed,
      'cleanupIssueRoles': cleanupIssueRoles,
      'results': rows,
    };
  }

  Map<String, dynamic> _buildFindings({
    required int localFailures,
    required Map<String, dynamic> liveSection,
  }) {
    final critical = <Map<String, dynamic>>[];
    final normal = <Map<String, dynamic>>[];
    final low = <Map<String, dynamic>>[];

    if (localFailures > 0) {
      critical.add(<String, dynamic>{
        'title': 'Local RBAC validation failures',
        'details': '$localFailures local command(s) failed.',
      });
    }

    if (liveSection['skipped'] != true) {
      final temp =
          liveSection['temporaryRoleWalkthrough'] as Map<String, dynamic>;
      final tempFailed = (temp['failed'] as int?) ?? 0;
      final cleanupIssues = (temp['cleanupIssueRoles'] as int?) ?? 0;
      if (tempFailed > 0 || cleanupIssues > 0) {
        critical.add(<String, dynamic>{
          'title': 'Temporary role walkthrough failures',
          'details':
              'failed=$tempFailed, cleanupIssueRoles=$cleanupIssues (expected 0).',
        });
      }

      final baseline = (liveSection['baselineUsersCount'] as int?) ?? -1;
      final post = (liveSection['postCleanupUsersCount'] as int?) ?? -1;
      if (baseline >= 0 && post >= 0 && baseline != post) {
        normal.add(<String, dynamic>{
          'title': 'User cleanup count drift',
          'details':
              'baselineUsersCount=$baseline, postCleanupUsersCount=$post',
        });
      }

      final existing = liveSection['existingSamples'] as Map<String, dynamic>;
      final existingFailed = (existing['failed'] as int?) ?? 0;
      if (existingFailed > 0) {
        low.add(<String, dynamic>{
          'title': 'Existing sample credentials mismatch',
          'details':
              '$existingFailed active role sample login(s) failed with provided test password.',
        });
      }
    }

    return <String, dynamic>{
      'critical': critical,
      'normal': normal,
      'low': low,
      'criticalOpen': critical.length,
      'normalOpen': normal.length,
      'lowOpen': low.length,
    };
  }

  Future<String> _writeMarkdownReport(Map<String, dynamic> report) async {
    final start = DateTime.parse(report['startedAt'] as String).toUtc();
    final dateStr = start.toIso8601String().split('T').first;
    final filePath = 'docs/role_ui_walkthrough_report_$dateStr.md';

    final localChecks = (report['localChecks'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();
    final liveChecks = report['liveChecks'] as Map<String, dynamic>;
    final findings = report['findings'] as Map<String, dynamic>;

    final buffer = StringBuffer()
      ..writeln('# Role UI Walkthrough Report')
      ..writeln()
      ..writeln('## Metadata')
      ..writeln('- Started (UTC): `${report['startedAt']}`')
      ..writeln('- Ended (UTC): `${report['endedAt']}`')
      ..writeln('- Project: `$projectId`')
      ..writeln('- Admin Email: `$adminEmail`')
      ..writeln('- Live Checks Skipped: `${liveChecks['skipped'] == true}`')
      ..writeln()
      ..writeln('## Local Checks');

    for (final check in localChecks) {
      final status = check['passed'] == true ? 'PASS' : 'FAIL';
      buffer.writeln(
        '- `$status` ${check['label']} (`${check['durationMs']}ms`)',
      );
    }

    if (liveChecks['skipped'] != true) {
      final existing = liveChecks['existingSamples'] as Map<String, dynamic>;
      final temp =
          liveChecks['temporaryRoleWalkthrough'] as Map<String, dynamic>;
      buffer
        ..writeln()
        ..writeln('## Live Checks')
        ..writeln(
          '- Existing samples: `${existing['passed']}/${existing['sampledRoles']}` login pass',
        )
        ..writeln(
          '- Temporary role walkthrough: `${temp['passed']}/${temp['totalRoles']}` login pass',
        )
        ..writeln('- Cleanup issues: `${temp['cleanupIssueRoles']}` role(s)')
        ..writeln(
          '- Users count baseline/post-cleanup: `${liveChecks['baselineUsersCount']}` / `${liveChecks['postCleanupUsersCount']}`',
        );
    }

    buffer
      ..writeln()
      ..writeln('## Findings')
      ..writeln('- Critical Open: `${findings['criticalOpen']}`')
      ..writeln('- Normal Open: `${findings['normalOpen']}`')
      ..writeln('- Low Open: `${findings['lowOpen']}`');

    final critical = (findings['critical'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();
    final normal = (findings['normal'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();
    final low = (findings['low'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();

    if (critical.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### Critical');
      for (final item in critical) {
        buffer.writeln('- ${item['title']}: ${item['details']}');
      }
    }
    if (normal.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### Normal');
      for (final item in normal) {
        buffer.writeln('- ${item['title']}: ${item['details']}');
      }
    }
    if (low.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('### Low');
      for (final item in low) {
        buffer.writeln('- ${item['title']}: ${item['details']}');
      }
    }

    await File(filePath).writeAsString(buffer.toString());
    return filePath;
  }

  Future<_CommandResult> _runCommand({
    required String label,
    required String executable,
    required List<String> arguments,
  }) async {
    _printInfo('Running: $label');
    final started = DateTime.now();
    final process = await Process.start(
      executable,
      arguments,
      runInShell: true,
    );

    final stdoutFuture = process.stdout.transform(utf8.decoder).join();
    final stderrFuture = process.stderr.transform(utf8.decoder).join();
    final exitCode = await process.exitCode;
    final stdoutText = await stdoutFuture;
    final stderrText = await stderrFuture;
    final durationMs = DateTime.now().difference(started).inMilliseconds;

    if (stdoutText.trim().isNotEmpty) {
      stdout.writeln(stdoutText.trim());
    }
    if (stderrText.trim().isNotEmpty) {
      stderr.writeln(stderrText.trim());
    }

    final command = '$executable ${arguments.join(' ')}';
    return _CommandResult(
      label: label,
      command: command,
      exitCode: exitCode,
      durationMs: durationMs,
      stdoutText: stdoutText,
      stderrText: stderrText,
    );
  }

  static String? _stringField(Map<String, dynamic> fields, String key) {
    final raw = fields[key];
    if (raw is Map<String, dynamic>) {
      final value = raw['stringValue'];
      if (value is String) return value;
    }
    return null;
  }

  static bool? _boolField(Map<String, dynamic> fields, String key) {
    final raw = fields[key];
    if (raw is Map<String, dynamic>) {
      final value = raw['booleanValue'];
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == 'true';
    }
    return null;
  }

  void _printInfo(String text) {
    stdout.writeln('[ROLE-QA] $text');
  }
}

void main() async {
  final env = Platform.environment;
  final skipLive = env['DATT_SKIP_LIVE_ROLE_QA']?.toLowerCase() == 'true';
  final runner = _Runner(
    apiKey:
        env['DATT_FIREBASE_API_KEY'] ??
        'AIzaSyAmh4Cue5tAHSbisTOKREORQmoJpEa9fXk',
    projectId: env['DATT_FIREBASE_PROJECT_ID'] ?? 'dattsoap-6cf2a',
    adminEmail: env['DATT_ADMIN_EMAIL'] ?? 'test@erp.local',
    adminPassword:
        env['DATT_ADMIN_PASSWORD'] ??
        env['DATT_TEST_PASSWORD'] ??
        'Dattsoap@1212',
    samplePassword:
        env['DATT_SAMPLE_PASSWORD'] ??
        env['DATT_TEST_PASSWORD'] ??
        'Dattsoap@1212',
    skipLiveChecks: skipLive,
  );

  final code = await runner.run();
  exitCode = code;
}
