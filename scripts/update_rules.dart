// ignore_for_file: avoid_print
import 'dart:io';

void main() {
  final file = File('firestore.rules');
  var content = file.readAsStringSync();

  // 1. Add missing helpers IF they don't exist
  if (!content.contains('function roleAccessLevel()')) {
    final newHelpers = '''
    function roleAccessLevel() {
      let role = normalizedRole();
      return (role == 'admin' || role == 'owner') ? 5
           : (role == 'factory manager' || role == 'production manager' || role == 'production supervisor' || role == 'bhatti supervisor') ? 4
           : (role == 'dispatch manager' || role == 'dispatch') ? 3
           : (role == 'delivery' || role == 'driver') ? 2
           : (role == 'sales manager' || role == 'salesman' || role == 'dealer manager') ? 1
           : 0;
    }

    function isOwner(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }

    function isSelf(uid) {
      return isAuthenticated() && request.auth.uid == uid;
    }
''';
    // insert right after hasRole
    final insertIdx = content.indexOf('function hasRole');
    if (insertIdx != -1) {
      final endOfHasRole = content.indexOf('}', insertIdx) + 1;
      content =
          '${content.substring(0, endOfHasRole)}\n\n$newHelpers${content.substring(endOfHasRole)}';
    }
  }

  // 2. Define the exact rules block for each collection requested by the user
  final rules = {
    'products': '''
    match /products/{docId} {
      allow read: if isAuthenticated();
      allow create: if isAdminOrManager();
      allow update: if isAdminOrManager();
      allow delete: if false;
    }''',
    'users': '''
    match /users/{docId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin() || isOwner(docId);
      allow delete: if false;
    }''',
    'sales': '''
    match /sales/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || isSelf(resource.data.salesmanId));
      allow create: if isAuthenticated() && (isAdminOrManager() || isSelf(request.resource.data.salesmanId));
      allow update: if isAuthenticated() && isAdminOrManager();
      allow delete: if false;
    }''',
    'dispatches': '''
    match /dispatches/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 2);
      allow create: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 3);
      allow update: if isAuthenticated() && isAdminOrManager();
      allow delete: if false;
    }''',
    'production_logs': '''
    match /production_logs/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 4);
      allow create: if isAuthenticated() && isSelf(request.resource.data.userId);
      allow update: if isAuthenticated() && isAdminOrManager();
      allow delete: if false;
    }''',
    'bhatti_batches': '''
    match /bhatti_batches/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 4);
      allow create: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 5);
      allow update: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 5);
      allow delete: if false;
    }''',
    'cutting_batches': '''
    match /cutting_batches/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 4);
      allow create: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 5);
      allow update: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 5);
      allow delete: if false;
    }''',
    'department_stocks': '''
    match /department_stocks/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 4);
      allow create: if isAuthenticated() && isAdmin();
      allow update: if isAuthenticated() && isAdmin();
      allow delete: if false;
    }''',
    'stock_ledger': '''
    match /stock_ledger/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || roleAccessLevel() >= 4);
      allow create: if isAuthenticated() && isAdmin();
      allow update: if isAuthenticated() && isAdmin();
      allow delete: if false;
    }''',
    'messages': '''
    match /messages/{docId} {
      allow read: if isAuthenticated() && (isSelf(resource.data.senderId) || isSelf(resource.data.recipientId));
      allow create: if isAuthenticated() && isSelf(request.resource.data.senderId);
      allow update: if isAuthenticated() && isSelf(resource.data.senderId);
      allow delete: if false;
    }''',
    'outbox_queue': '''
    match /outbox_queue/{docId} {
      allow read: if isAuthenticated() && isSelf(resource.data.userId);
      allow create: if isAuthenticated() && isSelf(request.resource.data.userId);
      allow update: if isAuthenticated() && isSelf(resource.data.userId);
      allow delete: if false;
    }''',
    'route_orders': '''
    match /route_orders/{docId} {
      allow read: if isAuthenticated() && (isAdminOrManager() || isSelf(resource.data.salesmanId));
      allow create: if isAuthenticated() && (isAdminOrManager() || isSelf(request.resource.data.salesmanId));
      allow update: if isAuthenticated() && isAdminOrManager();
      allow delete: if false;
    }''',
  };

  for (final entry in rules.entries) {
    final col = entry.key;
    final newRule = entry.value;

    final regex = RegExp(
      'match /$col/\\{[^\\]]*\\} \\{[\\s\\S]*?\\n\\s*\\}',
      multiLine: true,
    );

    if (regex.hasMatch(content)) {
      content = content.replaceFirst(regex, newRule.trim());
    } else {
      final catchAllIndex = content.lastIndexOf('match /{document=**}');
      if (catchAllIndex != -1) {
        content =
            '${content.substring(0, catchAllIndex)}\n    ${newRule.trim()}\n\n    ${content.substring(catchAllIndex)}';
      } else {
        final lastBrace = content.lastIndexOf('}');
        final secondLastBrace = content.lastIndexOf('}', lastBrace - 1);
        content =
            '${content.substring(0, secondLastBrace)}\n    ${newRule.trim()}\n  ${content.substring(secondLastBrace)}';
      }
    }
  }

  // Double check catch all rule
  if (!content.contains('match /{document=**}')) {
    final lastBrace = content.lastIndexOf('}');
    final secondLastBrace = content.lastIndexOf('}', lastBrace - 1);
    final catchAll = '''
    match /{document=**} {
      allow read, write: if false;
    }
''';
    content =
        '${content.substring(0, secondLastBrace)}\n$catchAll\n  ${content.substring(secondLastBrace)}';
  }

  file.writeAsStringSync(content);
  print('Updated firestore.rules');
}
