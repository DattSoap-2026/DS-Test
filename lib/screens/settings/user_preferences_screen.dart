import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/users_service.dart';
import '../../models/types/user_types.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class UserPreferencesScreen extends StatefulWidget {
  final bool showHeader;

  const UserPreferencesScreen({super.key, this.showHeader = true});

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  late final UsersService _usersService;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usersService = context.read<UsersService>();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.state.user;
    
    if (user == null) return const Center(child: Text('User not found'));

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showHeader) ...[
              Text(
                'App Preferences',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Personalize your experience within the app',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
            ],
            
            _buildPreferenceTile(
              title: 'Theme Mode',
              subtitle: 'Choose between Light, Dark or System',
              icon: Icons.palette_outlined,
              trailing: DropdownButton<String>(
                value: user.preferences.theme,
                underline: const SizedBox(),
                items: ['light', 'dark', 'system'].map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e.toUpperCase()),
                )).toList(),
                onChanged: (val) {
                  if (val != null) _updatePref(user, theme: val);
                },
              ),
            ),
            
            const Divider(height: 32),
            
            _buildPreferenceTile(
              title: 'Notifications',
              subtitle: 'Enable or disable push notifications',
              icon: Icons.notifications_none,
              trailing: Switch(
                value: user.preferences.notificationsEnabled,
                onChanged: (val) => _updatePref(user, notifications: val),
              ),
            ),
            
            const Divider(height: 32),
            
            _buildPreferenceTile(
              title: 'Language',
              subtitle: 'Select your preferred language',
              icon: Icons.language,
              trailing: DropdownButton<String>(
                value: user.preferences.language,
                underline: const SizedBox(),
                items: ['en', 'hi'].map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e == 'en' ? 'English' : 'Hindi'),
                )).toList(),
                onChanged: (val) {
                  if (val != null) _updatePref(user, language: val);
                },
              ),
            ),
            
            if (_isSaving) 
              const Padding(
                padding: EdgeInsets.only(top: 24),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.info),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: trailing,
    );
  }

  Future<void> _updatePref(
    AppUser user, {
    String? theme,
    bool? notifications,
    String? language,
  }) async {
    final newPrefs = UserPreferences(
      theme: theme ?? user.preferences.theme,
      notificationsEnabled: notifications ?? user.preferences.notificationsEnabled,
      language: language ?? user.preferences.language,
    );

    setState(() => _isSaving = true);
    try {
      final success = await _usersService.updateUserPreferences(user.id, newPrefs);

      if (!mounted) return;
      if (success) {
        // Keep local state in sync with latest profile snapshot.
        context.read<AuthProvider>().refreshUser();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update preferences right now')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preference update failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
