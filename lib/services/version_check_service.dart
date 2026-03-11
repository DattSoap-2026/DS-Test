import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VersionCheckService {
  static const String _lastVersionKey = 'last_run_version';

  /// Checks if the application has been updated since the last run.
  /// Returns `true` if it's a new version (or first run ever).
  /// Also updates the stored version to the current one.
  Future<bool> checkNewVersion() async {
    final prefs = await SharedPreferences.getInstance();
    final packageInfo = await PackageInfo.fromPlatform();

    final currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final lastVersion = prefs.getString(_lastVersionKey);

    if (lastVersion == null) {
      // First run ever.
      // Depending on preference, we might show "Welcome" instead of "What's New".
      // For now, let's assume we treat it as an update/install confirmation.
      await prefs.setString(_lastVersionKey, currentVersion);
      return true; // Use this to show a Welcome/Intro
    }

    if (currentVersion != lastVersion) {
      // Version changed
      await prefs.setString(_lastVersionKey, currentVersion);
      return true;
    }

    return false;
  }

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }
}
