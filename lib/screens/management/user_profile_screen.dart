import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/types/user_types.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/sync_manager.dart';
import '../../services/users_service.dart';
import '../../widgets/dialogs/responsive_alert_dialog.dart';
import '../../widgets/ui/custom_card.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class UserProfileScreen extends StatefulWidget {
  final AppUser? user;

  const UserProfileScreen({super.key, this.user});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _passwordFormKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isUploadingAvatar = false;
  bool _isChangingPassword = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _profileImagePath;
  bool _isLocalProfileImage = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  @override
  void didUpdateWidget(covariant UserProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _loadProfileImage();
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileImage() async {
    final displayUser = widget.user ?? context.read<AuthProvider>().state.user;
    if (displayUser == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final localPath = prefs.getString(_avatarStorageKey(displayUser.id));
      if (localPath != null && localPath.trim().isNotEmpty) {
        final localFile = File(localPath.trim());
        if (await localFile.exists()) {
          if (!mounted) return;
          setState(() {
            _profileImagePath = localFile.path;
            _isLocalProfileImage = true;
          });
          return;
        }
      }

      final authPhoto = FirebaseAuth.instance.currentUser?.photoURL;
      if (!mounted) return;
      setState(() {
        final trimmed = authPhoto?.trim();
        _profileImagePath = (trimmed != null && trimmed.isNotEmpty)
            ? trimmed
            : null;
        _isLocalProfileImage = false;
      });
    } catch (_) {}
  }

  bool _isPasswordProviderUser() {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) return false;
    return authUser.providerData.any(
      (provider) => provider.providerId == EmailAuthProvider.PROVIDER_ID,
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final authProvider = context.read<AuthProvider>();
    final appUser = authProvider.state.user;
    if (appUser == null) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.single.path;
    if (path == null || path.trim().isEmpty) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final extension = (result.files.single.extension ?? 'jpg').toLowerCase();
      final safeExt = extension == 'png' || extension == 'webp'
          ? extension
          : 'jpg';

      final sourceFile = File(path);
      if (!await sourceFile.exists()) {
        throw Exception('Selected image file not found');
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final userDir = Directory(p.join(docsDir.path, 'user_profiles', appUser.id));
      if (!await userDir.exists()) {
        await userDir.create(recursive: true);
      }

      final targetPath = p.join(userDir.path, 'avatar.$safeExt');
      await sourceFile.copy(targetPath);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarStorageKey(appUser.id), targetPath);

      if (!mounted) return;
      setState(() {
        _profileImagePath = targetPath;
        _isLocalProfileImage = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile image updated locally')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile image: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  String _avatarStorageKey(String userId) => 'user_profile_avatar_path_$userId';

  Future<void> _handleChangePassword() async {
    final authProvider = context.read<AuthProvider>();
    final usersService = context.read<UsersService>();
    if (!_passwordFormKey.currentState!.validate()) return;
    if (!_isPasswordProviderUser()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password change is available only for email/password login accounts.',
          ),
        ),
      );
      return;
    }

    final authUser = FirebaseAuth.instance.currentUser;
    final email = authUser?.email;
    if (authUser == null || email == null || email.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please login again.')),
      );
      return;
    }

    setState(() => _isChangingPassword = true);
    try {
      final credential = EmailAuthProvider.credential(
        email: email.trim(),
        password: _currentPasswordController.text.trim(),
      );
      await authUser.reauthenticateWithCredential(credential);
      await authUser.updatePassword(_newPasswordController.text.trim());

      final appUser = authProvider.state.user;
      if (appUser != null) {
        await usersService.requestPasswordReset(appUser.id);
      }

      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'Failed to change password.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Current password is incorrect.';
      } else if (e.code == 'weak-password') {
        message = 'New password is too weak.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many attempts. Please try again later.';
      } else if (e.code == 'network-request-failed') {
        message = 'Network error. Check internet and retry.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to change password: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isChangingPassword = false);
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ResponsiveAlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      context.read<SyncManager>().stopUserListener();
      await context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().state.user;
    final displayUser = widget.user ?? currentUser;
    if (displayUser == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isOwnProfile = widget.user == null || widget.user?.id == currentUser?.id;
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1060;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwnProfile ? 'My Profile' : '${displayUser.name} Profile',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildHeaderCard(context, displayUser, isOwnProfile),
                    const SizedBox(height: 14),
                    if (isDesktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: Column(
                              children: [
                                _buildPersonalDetails(context, displayUser),
                                _buildAssignments(context, displayUser),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                _buildDepartmentAccess(context, displayUser),
                                _buildMetadata(context, displayUser),
                                if (isOwnProfile) _buildPasswordCard(context),
                              ],
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildPersonalDetails(context, displayUser),
                          _buildAssignments(context, displayUser),
                          _buildDepartmentAccess(context, displayUser),
                          _buildMetadata(context, displayUser),
                          if (isOwnProfile) _buildPasswordCard(context),
                        ],
                      ),
                    if (isOwnProfile) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: isDesktop
                            ? Alignment.centerRight
                            : Alignment.center,
                        child: SizedBox(
                          width: isDesktop ? 300 : double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleLogout,
                            icon: const Icon(Icons.logout_rounded, size: 18),
                            label: const Text(
                              'SIGN OUT',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.errorContainer
                                  .withValues(alpha: 0.6),
                              foregroundColor: theme.colorScheme.error,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: theme.colorScheme.error.withValues(
                                    alpha: 0.25,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(
    BuildContext context,
    AppUser user,
    bool isOwnProfile,
  ) {
    final theme = Theme.of(context);
    final hasImage = _profileImagePath != null && _profileImagePath!.trim().isNotEmpty;
    final ImageProvider? imageProvider = hasImage
        ? (_isLocalProfileImage
              ? FileImage(File(_profileImagePath!))
              : NetworkImage(_profileImagePath!))
        : null;
    final initials = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

    Widget avatar = CircleAvatar(
      radius: 36,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.18),
      foregroundImage: imageProvider,
      child: hasImage
          ? null
          : Text(
              initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
              ),
            ),
    );

    if (isOwnProfile) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: -2,
            bottom: -2,
            child: Tooltip(
              message: 'Change profile image',
              child: InkWell(
                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                  child: _isUploadingAvatar
                      ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.edit_rounded,
                          size: 12,
                          color: theme.colorScheme.onPrimary,
                        ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final roleText = user.role.value.toUpperCase();

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatar,
                const SizedBox(height: 10),
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  roleText,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusChip(theme, user.isActive),
              ],
            );
          }

          return Row(
            children: [
              avatar,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      roleText,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.7,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusChip(theme, user.isActive),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, bool isActive) {
    final chipColor = isActive ? AppColors.success : theme.colorScheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: chipColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: chipColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            isActive ? 'ACTIVE' : 'INACTIVE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(BuildContext context, AppUser user) {
    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, Icons.person_outline_rounded, 'Personal Details'),
          const Divider(height: 18),
          _buildInfoRow(context, Icons.email_outlined, 'Email', user.email),
          _buildInfoRow(
            context,
            Icons.phone_outlined,
            'Phone',
            user.phone ?? 'Not provided',
          ),
          if (user.secondaryPhone != null)
            _buildInfoRow(
              context,
              Icons.phone_android_outlined,
              'Secondary Phone',
              user.secondaryPhone!,
            ),
        ],
      ),
    );
  }

  Widget _buildAssignments(BuildContext context, AppUser user) {
    final items = <Widget>[];

    if (user.role == UserRole.salesman && user.assignedRoutes != null) {
      items.add(
        _buildInfoRow(
          context,
          Icons.map_outlined,
          'Routes',
          user.assignedRoutes!.join(', '),
        ),
      );
    }

    if (user.role == UserRole.bhattiSupervisor && user.assignedBhatti != null) {
      items.add(
        _buildInfoRow(
          context,
          Icons.local_fire_department_outlined,
          'Bhatti',
          user.assignedBhatti!,
        ),
      );
    }

    if (user.assignedVehicleName != null) {
      items.add(
        _buildInfoRow(
          context,
          Icons.local_shipping_outlined,
          'Vehicle',
          '${user.assignedVehicleName} (${user.assignedVehicleNumber})',
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, Icons.assignment_outlined, 'Assignments'),
          const Divider(height: 18),
          ...items,
        ],
      ),
    );
  }

  Widget _buildDepartmentAccess(BuildContext context, AppUser user) {
    if (user.departments.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            Icons.business_outlined,
            'Department Access',
          ),
          const Divider(height: 18),
          ...user.departments.map((dept) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              minVerticalPadding: 0,
              leading: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppColors.success,
                size: 18,
              ),
              title: Text(
                dept.main.toUpperCase(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: dept.team != null
                  ? Text('Team: ${dept.team}', style: theme.textTheme.bodySmall)
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, AppUser user) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            context,
            Icons.security_outlined,
            'Account Security & History',
          ),
          const Divider(height: 18),
          _buildInfoRow(context, Icons.badge_outlined, 'User ID', user.id),
          _buildInfoRow(
            context,
            Icons.calendar_today_outlined,
            'Member Since',
            _formatDateSafe(user.createdAt, dateFormat),
          ),
          if (user.passwordResetAt != null)
            _buildInfoRow(
              context,
              Icons.lock_reset_outlined,
              'Last Password Reset',
              _formatDateSafe(user.passwordResetAt!, dateFormat),
            ),
        ],
      ),
    );
  }

  Widget _buildPasswordCard(BuildContext context) {
    final theme = Theme.of(context);
    return CustomCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Form(
        key: _passwordFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, Icons.lock_outline_rounded, 'Change Password'),
            const SizedBox(height: 6),
            Text(
              'Use your current password to set a new secure password.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 14),
            _buildPasswordField(
              context: context,
              controller: _currentPasswordController,
              label: 'Current Password',
              visible: _showCurrentPassword,
              onToggle: () => setState(() => _showCurrentPassword = !_showCurrentPassword),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildPasswordField(
              context: context,
              controller: _newPasswordController,
              label: 'New Password',
              visible: _showNewPassword,
              onToggle: () => setState(() => _showNewPassword = !_showNewPassword),
              validator: (value) {
                final input = value?.trim() ?? '';
                if (input.isEmpty) return 'Enter new password';
                if (input.length < 8) return 'Use at least 8 characters';
                if (!RegExp(r'[A-Z]').hasMatch(input)) {
                  return 'Add at least 1 uppercase letter';
                }
                if (!RegExp(r'[a-z]').hasMatch(input)) {
                  return 'Add at least 1 lowercase letter';
                }
                if (!RegExp(r'[0-9]').hasMatch(input)) {
                  return 'Add at least 1 number';
                }
                if (input == _currentPasswordController.text.trim()) {
                  return 'New password must be different';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildPasswordField(
              context: context,
              controller: _confirmPasswordController,
              label: 'Confirm New Password',
              visible: _showConfirmPassword,
              onToggle: () =>
                  setState(() => _showConfirmPassword = !_showConfirmPassword),
              validator: (value) {
                if ((value ?? '').trim() != _newPasswordController.text.trim()) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isChangingPassword ? null : _handleChangePassword,
                icon: _isChangingPassword
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.lock_reset_rounded, size: 18),
                label: Text(_isChangingPassword ? 'Updating...' : 'Update Password'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool visible,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateSafe(String iso, DateFormat format) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return format.format(parsed);
  }
}
