import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/settings_service.dart';
import '../../widgets/ui/custom_card.dart';
import '../../widgets/ui/custom_text_field.dart';
import '../../widgets/ui/custom_button.dart';
import '../../widgets/ui/themed_tab_bar.dart';
import '../../utils/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CompanyProfileScreen extends StatefulWidget {
  final bool showHeader;

  const CompanyProfileScreen({super.key, this.showHeader = true});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen>
    with SingleTickerProviderStateMixin {
  late final SettingsService _settingsService;
  late TabController _tabController;

  bool _isLoading = true;
  bool _isSaving = false;

  // Controllers
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();

  // Bank Details Controllers
  final _bankNameController = TextEditingController();
  final _accHolderController = TextEditingController();
  final _accNumberController = TextEditingController();
  final _ifscController = TextEditingController();
  final _branchController = TextEditingController();

  String? _logoUrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      animationDuration: const Duration(milliseconds: 200),
    );
    _settingsService = context.read<SettingsService>();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _taglineController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _accHolderController.dispose();
    _accNumberController.dispose();
    _ifscController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _settingsService.getCompanyProfileClient();
      if (mounted && data != null) {
        setState(() {
          _nameController.text = data.name ?? '';
          _taglineController.text = data.tagline ?? '';
          _addressController.text = data.address ?? '';
          _phoneController.text = data.phone ?? '';
          _emailController.text = data.email ?? '';
          _websiteController.text = data.website ?? '';
          _gstinController.text = data.gstin ?? '';
          _panController.text = data.pan ?? '';

          if (data.bankDetails != null) {
            _bankNameController.text = data.bankDetails!.bankName ?? '';
            _accHolderController.text =
                data.bankDetails!.accountHolderName ?? '';
            _accNumberController.text = data.bankDetails!.accountNumber ?? '';
            _ifscController.text = data.bankDetails!.ifscCode ?? '';
            _branchController.text = data.bankDetails!.branchName ?? '';
          }

          _logoUrl = data.logoUrl;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _handleSave() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final success = await _settingsService.updateCompanyProfileClient(
        name: _nameController.text,
        tagline: _taglineController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        gstin: _gstinController.text,
        pan: _panController.text,
        bankDetails: BankDetails(
          bankName: _bankNameController.text,
          accountHolderName: _accHolderController.text,
          accountNumber: _accNumberController.text,
          ifscCode: _ifscController.text,
          branchName: _branchController.text,
        ),
        userId: user.id,
        userName: user.name,
      );

      if (mounted) {
        setState(() => _isSaving = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company profile updated')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() => _isSaving = true);
      try {
        final url = await _settingsService.uploadCompanyLogo(
          File(pickedFile.path),
        );
        if (url != null) {
          final success = await _settingsService.updateCompanyProfileLogo(url);
          if (mounted) {
            if (success) {
              setState(() => _logoUrl = url);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logo updated successfully')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update logo URL')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to upload image')),
            );
          }
        }
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Header
          Container(
            padding: EdgeInsets.fromLTRB(24, widget.showHeader ? 16 : 8, 24, 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.showHeader) ...[
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 20,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Company Profile',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: ThemedTabBar(
                      controller: _tabController,
                      isScrollable: false,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.zero,
                      indicatorBorderColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'General Info'),
                        Tab(text: 'Legal Details'),
                        Tab(text: 'Banking Info'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(),
                _buildLegalTab(),
                _buildBankingTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: CustomButton(
            label: 'SAVE ALL CHANGES',
            icon: Icons.check_circle_rounded,
            isLoading: _isSaving,
            onPressed: _handleSave,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Basic Information',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Company Name',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Tagline / Slogan',
                  controller: _taglineController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Full Address',
                  controller: _addressController,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 650;
                    final phoneField = CustomTextField(
                      label: 'Phone',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    );
                    final emailField = CustomTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                    );
                    if (isNarrow) {
                      return Column(
                        children: [
                          phoneField,
                          const SizedBox(height: 16),
                          emailField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: phoneField),
                        const SizedBox(width: 16),
                        Expanded(child: emailField),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Website',
                  controller: _websiteController,
                  keyboardType: TextInputType.url,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Branding',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        height: Responsive.clamp(
                          context,
                          min: 96,
                          max: 140,
                          ratio: 0.22,
                        ),
                        width: Responsive.clamp(
                          context,
                          min: 96,
                          max: 140,
                          ratio: 0.22,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color:
                                Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                        child: _logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(23),
                                child: Image.network(
                                  _logoUrl!,
                                  fit: BoxFit.contain,
                                ),
                              )
                            : Icon(
                                Icons.business_rounded,
                                size: 48,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withValues(
                                      alpha: 0.6,
                                    ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickLogo,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.upload_rounded),
                        label: const Text('UPLOAD NEW LOGO'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalTab() {
    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Statutory Information',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  'Documents and tax identifiers for official use',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'GSTIN',
                  controller: _gstinController,
                  hintText: '27ABCDE1234F1Z5',
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'PAN',
                  controller: _panController,
                  hintText: 'ABCDE1234F',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankingTab() {
    return SingleChildScrollView(
      padding: Responsive.screenPadding(context),
      child: Column(
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bank Account Details',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                ),
                Text(
                  'Details for invoices and digital payments',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  label: 'Bank Name',
                  controller: _bankNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Account Holder Name',
                  controller: _accHolderController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Account Number',
                  controller: _accNumberController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 650;
                    final ifscField = CustomTextField(
                      label: 'IFSC Code',
                      controller: _ifscController,
                    );
                    final branchField = CustomTextField(
                      label: 'Branch Name',
                      controller: _branchController,
                    );
                    if (isNarrow) {
                      return Column(
                        children: [
                          ifscField,
                          const SizedBox(height: 16),
                          branchField,
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: ifscField),
                        const SizedBox(width: 16),
                        Expanded(child: branchField),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
