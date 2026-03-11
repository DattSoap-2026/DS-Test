import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../services/reports_service.dart';
import '../../data/repositories/dealer_repository.dart';
import 'dealer_detail_history_screen.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/reports/report_date_range_buttons.dart';
import '../../widgets/reports/report_export_actions.dart';
import '../../utils/mixins/report_pdf_mixin.dart';
import '../../utils/app_toast.dart';
import 'package:flutter_app/core/theme/app_colors.dart';

class DealerReportScreen extends StatefulWidget {
  const DealerReportScreen({super.key});

  @override
  State<DealerReportScreen> createState() => _DealerReportScreenState();
}

class _DealerReportScreenState extends State<DealerReportScreen>
    with ReportPdfMixin<DealerReportScreen> {
  late ReportsService _reportsService;
  late DealerRepository _dealerRepository;

  bool _isLoading = true;
  bool _loadingDealers = true;

  // Data
  List<DealerPerformanceData> _reportData = [];
  DealerOverallStats _overallStats = DealerOverallStats();
  List<Map<String, dynamic>> _dealers = [];

  // Filters
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime(DateTime.now().year, DateTime.now().month, 1),
    end: DateTime.now(),
  );
  String _selectedDealerId = 'all';
  final TextEditingController _dealerSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _reportsService = context.read<ReportsService>();
    _dealerRepository = context.read<DealerRepository>();
    _loadDealers();
    _loadReport();
  }

  @override
  void dispose() {
    _dealerSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadDealers() async {
    try {
      setState(() {
        _loadingDealers = true;
      });
      final entities = await _dealerRepository.getAllDealers();
      setState(() {
        _dealers = entities.map((d) => {'id': d.id, 'name': d.name}).toList();
        _loadingDealers = false;
      });
    } catch (e) {
      debugPrint("Error loading dealers: $e");
      setState(() => _loadingDealers = false);
    }
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    try {
      final filters = FilterOptions(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
        dealerId: _selectedDealerId == 'all' ? null : _selectedDealerId,
      );

      final result = await _reportsService.getDealerPerformanceReport(filters);

      if (mounted) {
        setState(() {
          _reportData = (result['performanceData'] as List)
              .cast<DealerPerformanceData>();
          _overallStats = result['overallStats'] as DealerOverallStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.showError(context, 'Error loading report: $e');
      }
    }
  }

  void _selectDealer(String dealerId) {
    if (_selectedDealerId == dealerId) return;
    setState(() => _selectedDealerId = dealerId);
    _loadReport();
  }

  String _dealerNameById(String dealerId) {
    if (dealerId == 'all') return 'All Dealers';
    for (final dealer in _dealers) {
      if (dealer['id'] == dealerId) {
        return dealer['name'] as String? ?? 'Dealer';
      }
    }
    return 'All Dealers';
  }

  @override
  bool get hasExportData => _reportData.isNotEmpty;

  @override
  List<String> buildPdfHeaders() {
    return [
      'Dealer Name',
      'Total Orders',
      'Total Revenue (₹)',
      'Top Product',
      'Last Order',
    ];
  }

  @override
  List<List<dynamic>> buildPdfRows() {
    return _reportData.map((d) {
      return [
        d.dealerName,
        d.totalOrders.toString(),
        d.totalRevenue.toStringAsFixed(2),
        d.topProduct,
        d.lastOrderDate != null ? _formatDateSafe(d.lastOrderDate!) : '-',
      ];
    }).toList();
  }

  @override
  Map<String, String> buildFilterSummary() {
    return {
      'Date Range':
          '${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)}',
      'Dealer Filter': _dealerNameById(_selectedDealerId),
      'Total Revenue': '₹${_overallStats.totalRevenue.toStringAsFixed(2)}',
      'Total Orders': '${_overallStats.totalOrders}',
      'Active Dealers': '${_overallStats.activeDealers}',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dealer Performance'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        actions: [
          ReportExportActions(
            isLoading: isExporting,
            onExport: () => exportReport('Dealer Performance Report'),
            onPrint: () => printReport('Dealer Performance Report'),
            onRefresh: _loadReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            _buildStatsGrid(),
            const SizedBox(height: 24),
            const Text(
              "Dealer Performance",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildReportList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final theme = Theme.of(context);
    final dealerSearchQuery = _dealerSearchController.text.trim().toLowerCase();
    final filteredDealers = dealerSearchQuery.isEmpty
        ? _dealers
        : _dealers.where((dealer) {
            final name = (dealer['name'] as String? ?? '').toLowerCase();
            return name.contains(dealerSearchQuery);
          }).toList();
    final fromDateText = DateFormat('dd MMM yyyy').format(_dateRange.start);
    final toDateText = DateFormat('dd MMM yyyy').format(_dateRange.end);

    Widget dateRangeFilter = Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date Range: $fromDateText - $toDateText',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 8),
          ReportDateRangeButtons(
            margin: EdgeInsets.zero,
            value: _dateRange,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
            onChanged: (range) {
              setState(() {
                _dateRange = DateTimeRange(
                  start: DateTime(
                    range.start.year,
                    range.start.month,
                    range.start.day,
                  ),
                  end: DateTime(range.end.year, range.end.month, range.end.day),
                );
              });
              _loadReport();
            },
          ),
        ],
      ),
    );

    Widget dealerSearchField = TextFormField(
      controller: _dealerSearchController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Search Dealer',
        hintText: 'Type dealer name',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        filled: true,
        fillColor: theme.cardTheme.color,
        prefixIcon: const Icon(Icons.search, size: 18),
        suffixIcon: _dealerSearchController.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  setState(() {
                    _dealerSearchController.clear();
                  });
                },
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );

    Widget allDealersButton = SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: _loadingDealers
            ? null
            : () {
                setState(() {
                  _selectedDealerId = 'all';
                  _dealerSearchController.clear();
                });
                _loadReport();
              },
        child: const Text('All Dealers'),
      ),
    );

    Widget dealerSearchResults = const SizedBox.shrink();
    if (dealerSearchQuery.isNotEmpty) {
      if (filteredDealers.isEmpty) {
        dealerSearchResults = Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'No dealer found',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
        );
      } else {
        dealerSearchResults = Container(
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.primaryColor.withValues(alpha: 0.1),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: filteredDealers.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
              itemBuilder: (context, index) {
                final dealer = filteredDealers[index];
                final dealerId = dealer['id'] as String? ?? '';
                final dealerName = dealer['name'] as String? ?? 'Dealer';
                final isSelected = dealerId == _selectedDealerId;

                return ListTile(
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  title: Text(
                    dealerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle,
                          size: 18,
                          color: theme.primaryColor,
                        )
                      : null,
                  onTap: _loadingDealers ? null : () => _selectDealer(dealerId),
                );
              },
            ),
          ),
        );
      }
    }

    Widget dealerFilter = LayoutBuilder(
      builder: (context, constraints) {
        final stackControls = constraints.maxWidth < 430;

        final searchWithResults = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [dealerSearchField, dealerSearchResults],
        );

        final selectedLabel = Padding(
          padding: const EdgeInsets.only(top: 8, left: 4),
          child: Text(
            'Selected: ${_dealerNameById(_selectedDealerId)}',
            style: TextStyle(
              fontSize: 11,
              color: theme.textTheme.bodySmall?.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        );

        if (stackControls) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchWithResults,
              const SizedBox(height: 8),
              allDealersButton,
              selectedLabel,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: searchWithResults),
                const SizedBox(width: 8),
                allDealersButton,
              ],
            ),
            selectedLabel,
          ],
        );
      },
    );

    return UnifiedCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: theme.primaryColor.withValues(alpha: 0.05),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 720;
          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dateRangeFilter,
                const SizedBox(height: 12),
                dealerFilter,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: dateRangeFilter),
              const SizedBox(width: 12),
              Expanded(child: dealerFilter),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    final cards = <Widget>[
      _buildStatCard(
        'Total Revenue',
        '\u20B9${_overallStats.totalRevenue.toStringAsFixed(0)}',
        Icons.currency_rupee,
        AppColors.success,
      ),
      _buildStatCard(
        'Total Orders',
        _overallStats.totalOrders.toString(),
        Icons.shopping_bag,
        AppColors.info,
      ),
      _buildStatCard(
        'Active Dealers',
        _overallStats.activeDealers.toString(),
        Icons.store,
        AppColors.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        final width = constraints.maxWidth;
        final columns = width < 460 ? 2 : 3;
        final cardWidth = columns == 3
            ? (width - (spacing * 2)) / 3
            : (width - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map((card) => SizedBox(width: cardWidth, child: card))
              .toList(),
        );
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return UnifiedCard(
      onTap: null,
      backgroundColor: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportList() {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_reportData.isEmpty) {
      return const Center(child: Text("No data found for selected period"));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reportData.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final d = _reportData[index];
        return UnifiedCard(
          onTap: () => _openDealerDetail(d),
          backgroundColor: Theme.of(context).cardTheme.color,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _openDealerDetail(d),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).primaryColor.withValues(alpha: 0.1),
                                child: Text(
                                  d.dealerName.isNotEmpty
                                      ? d.dealerName[0].toUpperCase()
                                      : 'D',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      d.dealerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Last Order: ${d.lastOrderDate != null ? _formatDateSafe(d.lastOrderDate!, pattern: 'dd MMM yyyy') : '-'}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodySmall?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\u20B9${d.totalRevenue.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Text(
                          '${d.totalOrders} Orders',
                          style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      "Top Product: ",
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        d.topProduct,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDealerDetail(DealerPerformanceData dealer) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DealerDetailHistoryScreen(
          dealerId: dealer.dealerId,
          dealerName: dealer.dealerName,
        ),
      ),
    );
  }

  String _formatDateSafe(String iso, {String pattern = 'dd MMM yyyy'}) {
    final parsed = DateTime.tryParse(iso);
    if (parsed == null) return iso;
    return DateFormat(pattern).format(parsed);
  }
}
