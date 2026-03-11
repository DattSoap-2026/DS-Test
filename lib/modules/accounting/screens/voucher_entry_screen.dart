import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/firebase/firebase_config.dart';
import '../../../models/types/user_types.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../widgets/ui/master_screen_header.dart';
import '../../../widgets/ui/unified_card.dart';
import '../accounts_repository.dart';
import '../posting_service.dart';
import '../widgets/accounting_shortcuts_scope.dart';
import '../widgets/searchable_account_dropdown.dart';

class VoucherEntryScreen extends StatefulWidget {
  final String voucherType;

  const VoucherEntryScreen({super.key, required this.voucherType});

  @override
  State<VoucherEntryScreen> createState() => _VoucherEntryScreenState();
}

class _VoucherEntryScreenState extends State<VoucherEntryScreen> {
  late final PostingService _postingService;
  late final AccountsRepository _accountsRepository;

  final TextEditingController _narrationController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyIdController = TextEditingController();
  final List<_VoucherLineDraft> _lines = [
    _VoucherLineDraft(),
    _VoucherLineDraft(),
  ];
  List<Map<String, dynamic>> _accounts = [];

  DateTime _voucherDate = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _postingService = PostingService(firebaseServices);
    _accountsRepository = AccountsRepository(firebaseServices);
    _loadAccounts();
  }

  @override
  void dispose() {
    _narrationController.dispose();
    _partyNameController.dispose();
    _partyIdController.dispose();
    for (final line in _lines) {
      line.dispose();
    }
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    await _accountsRepository.ensureDefaultAccounts();
    final accounts = await _accountsRepository.getAccounts();
    if (!mounted) return;
    setState(() {
      _accounts = accounts;
    });
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _voucherDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _voucherDate = selected;
    });
  }

  void _addLine() {
    setState(() {
      _lines.add(_VoucherLineDraft());
    });
  }

  void _removeLine(int index) {
    if (_lines.length <= 2) return;
    setState(() {
      final removed = _lines.removeAt(index);
      removed.dispose();
    });
  }

  double get _totalDebit => _lines.fold(
    0,
    (sum, line) => sum + (double.tryParse(line.debitController.text) ?? 0),
  );

  double get _totalCredit => _lines.fold(
    0,
    (sum, line) => sum + (double.tryParse(line.creditController.text) ?? 0),
  );

  bool get _isBalanced => (_totalDebit - _totalCredit).abs() < 0.01;

  Future<void> _saveVoucher() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;
    if (user.role != UserRole.accountant) {
      _showMessage('Voucher creation is restricted to accountant role.');
      return;
    }
    if (_saving) return;

    final entries = <Map<String, dynamic>>[];
    for (final line in _lines) {
      final accountCode = line.accountCode?.trim().toUpperCase() ?? '';
      if (accountCode.isEmpty) continue;
      final debit = double.tryParse(line.debitController.text.trim()) ?? 0;
      final credit = double.tryParse(line.creditController.text.trim()) ?? 0;
      if (debit <= 0 && credit <= 0) continue;
      final account = _accounts.firstWhere(
        (item) => (item['code'] ?? '').toString().toUpperCase() == accountCode,
        orElse: () => {'code': accountCode, 'name': accountCode},
      );
      entries.add({
        'accountCode': accountCode,
        'accountName': (account['name'] ?? accountCode).toString(),
        'debit': debit,
        'credit': credit,
      });
    }

    if (entries.length < 2) {
      _showMessage('At least two ledger lines are required.');
      return;
    }

    if (!_isBalanced) {
      _showMessage('Voucher is not balanced. Debit and credit must match.');
      return;
    }

    setState(() => _saving = true);
    try {
      final transactionRefId =
          'manual_${widget.voucherType}_${DateTime.now().microsecondsSinceEpoch}';
      final result = await _postingService.createManualVoucher(
        voucherType: widget.voucherType,
        transactionRefId: transactionRefId,
        date: _voucherDate,
        entries: entries,
        postedByUserId: user.id,
        postedByName: user.name,
        narration: _narrationController.text.trim(),
        partyId: _partyIdController.text.trim(),
        partyName: _partyNameController.text.trim(),
      );

      if (!mounted) return;
      if (!result.success) {
        _showMessage(result.errorMessage ?? 'Voucher save failed');
        return;
      }
      _showMessage('Voucher saved');
      context.go('/dashboard/accounting');
    } catch (e) {
      _showMessage('Voucher save failed: $e');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().state.user;
    if (user == null || user.role != UserRole.accountant) {
      return const Scaffold(
        body: Center(child: Text('Authorized access only.')),
      );
    }

    return AccountingShortcutsScope(
      currentRole: user.role,
      onChangeDate: _pickDate,
      onSaveVoucher: _saveVoucher,
      onCancel: () => context.go('/dashboard/accounting'),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: MasterScreenHeader(
                title: '${widget.voucherType.toUpperCase()} Voucher',
                subtitle: 'Create new manual voucher',
                icon: Icons.note_add,
                color: theme.colorScheme.primary,
                onBack: () => context.go('/dashboard/accounting'),
                actions: [
                  TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(
                      '${_voucherDate.day.toString().padLeft(2, '0')}/${_voucherDate.month.toString().padLeft(2, '0')}/${_voucherDate.year}',
                    ),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  UnifiedCard(
                    title: 'Voucher Details',
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _partyNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Party Name',
                                  hintText: 'e.g. Supplier Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextField(
                                controller: _partyIdController,
                                decoration: const InputDecoration(
                                  labelText: 'Party ID (Optional)',
                                  prefixIcon: Icon(Icons.numbers),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _narrationController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            labelText: 'Narration',
                            hintText: 'Enter transaction details...',
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Ledger Entries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._buildLineRows(),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _addLine,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Entry Line'),
                  ),
                  const SizedBox(height: 24),
                  _buildTotalsCard(),
                  const SizedBox(height: 80), // Bottom padding for floating bar
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving
                        ? null
                        : () => context.go('/dashboard/accounting'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _saveVoucher,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isBalanced
                          ? null
                          : theme.colorScheme.tertiary,
                    ),
                    icon: _saving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(_isBalanced ? Icons.check : Icons.warning_amber),
                    label: Text(
                      _saving
                          ? 'Saving...'
                          : (_isBalanced ? 'Save Voucher' : 'Not Balanced'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLineRows() {
    return List<Widget>.generate(_lines.length, (index) {
      final line = _lines[index];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: UnifiedCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchableAccountDropdown(
                      accounts: _accounts,
                      selectedAccountCode: line.accountCode,
                      onChanged: (val) =>
                          setState(() => line.accountCode = val),
                    ),
                  ),
                  if (_lines.length > 2)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () => _removeLine(index),
                      tooltip: 'Remove Line',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: line.debitController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Debit',
                        prefixText: '₹ ',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: line.creditController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Credit',
                        prefixText: '₹ ',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTotalsCard() {
    final theme = Theme.of(context);
    final diff = (_totalDebit - _totalCredit).abs();
    final isBalanced = diff < 0.01;

    return UnifiedCard(
      title: 'Totals',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _TotalItem(
                label: 'Total Debit',
                value: _totalDebit,
                color: theme.colorScheme.onSurface,
              ),
              _TotalItem(
                label: 'Total Credit',
                value: _totalCredit,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Difference',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '₹ ${diff.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBalanced
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (!isBalanced)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Debit and Credit must match to save.',
                style: TextStyle(color: theme.colorScheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _TotalItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '₹ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _VoucherLineDraft {
  String? accountCode;
  final TextEditingController debitController = TextEditingController();
  final TextEditingController creditController = TextEditingController();

  void dispose() {
    debitController.dispose();
    creditController.dispose();
  }
}
