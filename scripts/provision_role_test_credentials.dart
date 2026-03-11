import 'dart:convert';
import 'dart:io';

class _ApiException implements Exception {
  _ApiException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HTTP $statusCode: $body';
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
    return _requestJson(
      'POST',
      uri,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey',
    );
    return _requestJson(
      'POST',
      uri,
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'returnSecureToken': true,
      },
    );
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

    if (responseBody.trim().isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }
}

class _MatrixRow {
  _MatrixRow({
    required this.role,
    required this.email,
    required this.uid,
    required this.status,
    required this.createdNow,
    required this.notes,
  });

  final String role;
  final String email;
  final String uid;
  final String status;
  final bool createdNow;
  final String notes;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'role': role,
    'email': email,
    'uid': uid,
    'status': status,
    'createdNow': createdNow,
    'notes': notes,
  };
}

String _slug(String role) {
  return role.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
}

String _extractErrorCode(Object error) {
  if (error is! _ApiException) {
    return '';
  }
  try {
    final decoded = jsonDecode(error.body);
    final code = (decoded['error']?['message'] ?? '').toString();
    return code;
  } catch (_) {
    return '';
  }
}

Future<void> _writeMarkdown({
  required List<_MatrixRow> rows,
  required String password,
  required String projectId,
}) async {
  final buffer = StringBuffer()
    ..writeln('# Role Test Credentials Matrix')
    ..writeln()
    ..writeln('- Project: `$projectId`')
    ..writeln(
      '- Generated (UTC): `${DateTime.now().toUtc().toIso8601String()}`',
    )
    ..writeln('- Shared Password: `$password`')
    ..writeln()
    ..writeln('## Accounts')
    ..writeln('| Role | Email | UID | Status | Created Now | Notes |')
    ..writeln('|---|---|---|---|---|---|');

  for (final row in rows) {
    buffer.writeln(
      '| ${row.role} | `${row.email}` | `${row.uid}` | `${row.status}` | `${row.createdNow}` | ${row.notes} |',
    );
  }

  buffer
    ..writeln()
    ..writeln('## Usage')
    ..writeln('```bash')
    ..writeln('dart run scripts/role_ui_walkthrough.dart')
    ..writeln('```')
    ..writeln()
    ..writeln(
      'Use the above accounts for manual role login checks and automated walkthrough runs.',
    );

  await File(
    'docs/role_test_credentials_matrix.md',
  ).writeAsString(buffer.toString());
}

Future<void> _writeJson({
  required List<_MatrixRow> rows,
  required String projectId,
  required String sharedPassword,
}) async {
  final payload = <String, dynamic>{
    'generatedAt': DateTime.now().toUtc().toIso8601String(),
    'projectId': projectId,
    'sharedPassword': sharedPassword,
    'rows': rows.map((row) => row.toJson()).toList(),
  };

  await File(
    'run_role_test_credentials_matrix.json',
  ).writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
}

Future<int> main() async {
  final env = Platform.environment;
  final apiKey =
      env['DATT_FIREBASE_API_KEY'] ?? 'AIzaSyAmh4Cue5tAHSbisTOKREORQmoJpEa9fXk';
  final projectId = env['DATT_FIREBASE_PROJECT_ID'] ?? 'dattsoap-6cf2a';
  final adminEmail = env['DATT_ADMIN_EMAIL'] ?? 'test@erp.local';
  final adminPassword =
      env['DATT_ADMIN_PASSWORD'] ??
      env['DATT_TEST_PASSWORD'] ??
      'Dattsoap@1212';
  final sharedPassword =
      env['DATT_MATRIX_PASSWORD'] ??
      env['DATT_SAMPLE_PASSWORD'] ??
      env['DATT_TEST_PASSWORD'] ??
      'Dattsoap@1212';

  const roles = <String>[
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

  final client = _FirebaseRestClient(apiKey: apiKey, projectId: projectId);
  stdout.writeln('[ROLE-MATRIX] Admin sign-in...');
  final adminAuth = await client.signIn(
    email: adminEmail,
    password: adminPassword,
  );
  final adminToken = (adminAuth['idToken'] ?? '').toString();
  if (adminToken.isEmpty) {
    stderr.writeln('[ROLE-MATRIX] Admin auth token missing.');
    return 1;
  }

  final rows = <_MatrixRow>[];
  var failedCount = 0;

  for (final role in roles) {
    final slug = _slug(role);
    final candidates = <String>[
      'qa.role.$slug.stable@erp.local',
      'qa.role.$slug.stable.v2@erp.local',
      'qa.role.$slug.stable.v3@erp.local',
    ];

    String? selectedEmail;
    String? uid;
    var createdNow = false;
    var notes = 'ready';
    var status = 'ready';
    Object? lastError;

    for (final email in candidates) {
      try {
        final signIn = await client.signIn(
          email: email,
          password: sharedPassword,
        );
        selectedEmail = email;
        uid = (signIn['localId'] ?? '').toString();
        createdNow = false;
        notes = 'existing qa account reused';
        break;
      } catch (e) {
        final signInCode = _extractErrorCode(e);
        if (signInCode.isNotEmpty &&
            signInCode != 'INVALID_LOGIN_CREDENTIALS' &&
            signInCode != 'EMAIL_NOT_FOUND') {
          lastError = e;
          continue;
        }
      }

      try {
        final signUp = await client.signUp(
          email: email,
          password: sharedPassword,
        );
        selectedEmail = email;
        uid = (signUp['localId'] ?? '').toString();
        createdNow = true;
        notes = 'new qa account created';
        break;
      } catch (e) {
        final code = _extractErrorCode(e);
        if (code == 'EMAIL_EXISTS') {
          lastError = e;
          continue;
        }
        lastError = e;
      }
    }

    if (selectedEmail == null || uid == null || uid.isEmpty) {
      failedCount += 1;
      final errText = lastError?.toString() ?? 'unknown error';
      rows.add(
        _MatrixRow(
          role: role,
          email: '',
          uid: '',
          status: 'failed',
          createdNow: false,
          notes: errText,
        ),
      );
      stderr.writeln('[ROLE-MATRIX] FAIL $role -> $errText');
      continue;
    }

    try {
      await client.upsertUserDocument(
        adminToken: adminToken,
        uid: uid,
        name: 'QA $role',
        email: selectedEmail,
        role: role,
      );

      // Verify login post-upsert
      await client.signIn(email: selectedEmail, password: sharedPassword);
      stdout.writeln(
        '[ROLE-MATRIX] READY $role -> $selectedEmail (${createdNow ? "created" : "existing"})',
      );
    } catch (e) {
      failedCount += 1;
      status = 'failed';
      notes = 'upsert/login verify failed: $e';
      stderr.writeln('[ROLE-MATRIX] FAIL $role -> $notes');
    }

    rows.add(
      _MatrixRow(
        role: role,
        email: selectedEmail,
        uid: uid,
        status: status,
        createdNow: createdNow,
        notes: notes,
      ),
    );
  }

  await _writeJson(
    rows: rows,
    projectId: projectId,
    sharedPassword: sharedPassword,
  );
  await _writeMarkdown(
    rows: rows,
    password: sharedPassword,
    projectId: projectId,
  );

  stdout.writeln(
    '[ROLE-MATRIX] Completed. total=${rows.length}, failed=$failedCount',
  );
  stdout.writeln(
    '[ROLE-MATRIX] Outputs: run_role_test_credentials_matrix.json, docs/role_test_credentials_matrix.md',
  );
  return failedCount == 0 ? 0 : 1;
}
