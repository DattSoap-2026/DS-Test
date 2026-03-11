import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/firebase/firebase_config.dart';
import '../../../widgets/ui/master_screen_header.dart';
import '../../../widgets/ui/unified_card.dart';
import '../accounts_repository.dart';
import '../voucher_repository.dart';

class LedgerDrilldownScreen extends StatefulWidget {
  final String accountCode;

  const LedgerDrilldownScreen({super.key, required this.accountCode});

  @override
  State<LedgerDrilldownScreen> createState() => _LedgerDrilldownScreenState();
}

class _LedgerDrilldownScreenState extends State<LedgerDrilldownScreen> {
  late final VoucherRepository _voucherRepository;
  late final AccountsRepository _accountsRepository;

  final List<Map<String, dynamic>> _entries = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  final int _limit = 50;

  double _currentBalance = 0.0;
  String _accountName = '';

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _voucherRepository = VoucherRepository(firebaseServices);
    _accountsRepository = AccountsRepository(firebaseServices);
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEntries();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Get Account Details
      final accounts = await _accountsRepository.getAccounts();
      final account = accounts.firstWhere(
        (a) => (a['code'] ?? '').toString() == widget.accountCode,
        orElse: () => {
          'code': widget.accountCode,
          'name': widget.accountCode, // Fallback
        },
      );
      _accountName = (account['name'] ?? widget.accountCode).toString();

      // 2. Get Balance
      _currentBalance = await _voucherRepository.getAccountBalance(
        widget.accountCode,
      );

      // 3. Get Initial Entries
      final entries = await _voucherRepository.getLedgerEntries(
        accountCode: widget.accountCode,
        offset: 0,
        limit: _limit,
      );

      setState(() {
        _entries.clear();
        _entries.addAll(entries);
        _offset = entries.length;
        _hasMore = entries.length >= _limit;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading ledger: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMoreEntries() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    try {
      final entries = await _voucherRepository.getLedgerEntries(
        accountCode: widget.accountCode,
        offset: _offset,
        limit: _limit,
      );
      setState(() {
        _entries.addAll(entries);
        _offset += entries.length;
        _hasMore = entries.length >= _limit;
      });
    } catch (e) {
      // Handle error silently or show toast
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: MasterScreenHeader(
              title: _accountName,
              subtitle: 'Ledger: ${widget.accountCode}',
              icon: Icons.menu_book,
              color: theme.colorScheme.primary,
              onBack: () => context.pop(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(
              child: UnifiedCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Net Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '₹ ${_currentBalance.abs().toStringAsFixed(2)} ${_currentBalance >= 0 ? 'Dr' : 'Cr'}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _currentBalance >= 0
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(top: 16)),
          if (_entries.isEmpty && !_isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No entries found')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  if (index == _entries.length) {
                    return _hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }
                  final entry = _entries[index];
                  final date =
                      DateTime.tryParse(entry['date'] ?? '') ?? DateTime.now();
                  final debit = (entry['debit'] as num?)?.toDouble() ?? 0.0;
                  final credit = (entry['credit'] as num?)?.toDouble() ?? 0.0;
                  final type = (entry['transactionType'] ?? 'Unknown')
                      .toString();
                  final ref = (entry['transactionRefId'] ?? '').toString();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: UnifiedCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormat.format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            entry['narration'] ?? 'No narration',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (ref.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Ref: $ref',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Amount'),
                              if (debit > 0)
                                Text(
                                  '₹ ${debit.toStringAsFixed(2)} Dr',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                )
                              else
                                Text(
                                  '₹ ${credit.toStringAsFixed(2)} Cr',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.error,
                                    fontSize: 15,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: _entries.length + 1),
              ),
            ),
        ],
      ),
    );
  }
}
