import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth/auth_provider.dart';
import '../../services/customers_service.dart';
import '../../data/repositories/customer_repository.dart';
import 'customer_form_dialog.dart';
import '../../services/settings_service.dart';
import '../../widgets/ui/master_screen_header.dart';
import '../../widgets/ui/unified_card.dart';
import '../../widgets/ui/shimmer_list_loader.dart';
import '../../utils/debouncer.dart';

class CustomerManagementScreen extends StatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  State<CustomerManagementScreen> createState() =>
      _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends State<CustomerManagementScreen> {
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedRoute = 'all';
  String _selectedStatus = 'all';
  late final SettingsService _settingsService;
  List<String> _allRoutes = [];
  final Debouncer _debouncer = Debouncer(milliseconds: 300);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _settingsService = context.read<SettingsService>();
    _loadCustomers();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final user = context.read<AuthProvider>().state.user;
    if (user == null) return;

    try {
      if (mounted) setState(() => _isLoading = true);
      final customerRepo = context.read<CustomerRepository>();
      final customerEntities = await customerRepo.getAllCustomers();
      final customers = customerEntities
          .map((entity) => entity.toDomain())
          .toList();

      List<String> routes = [];
      try {
        routes = await _settingsService.getRoutes();
      } catch (e) {
        debugPrint('Error fetching routes: $e');
      }

      if (mounted) {
        setState(() {
          _allCustomers = customers;
          _allRoutes = routes;
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading customers: $e')));
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredCustomers = _allCustomers.where((customer) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            customer.shopName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            customer.ownerName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            customer.mobile.contains(_searchQuery);

        final customerRoute = customer.route;
        final customerStatus = customer.status;
        final matchesRoute =
            _selectedRoute == 'all' || customerRoute == _selectedRoute;
        final matchesStatus =
            _selectedStatus == 'all' || customerStatus == _selectedStatus;

        return matchesSearch && matchesRoute && matchesStatus;
      }).toList();
    });
  }

  void _showCustomerForm({Customer? customer}) {
    showDialog(
      context: context,
      builder: (context) => CustomerFormDialog(
        customer: customer,
        allRoutes: _allRoutes,
        onSaved: () {
          _loadCustomers();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().state.user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to continue')),
      );
    }
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            MasterScreenHeader(
              title: 'Customers',
              subtitle: 'Manage your client base',
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      decoration: InputDecoration(
                        hintText: 'Search customer name...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: _searchQuery.isEmpty
                            ? IconButton(
                                icon: const Icon(Icons.search_rounded),
                                onPressed: () {
                                  _searchFocusNode.requestFocus();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        _debouncer.run(() {
                          setState(() {
                            _searchQuery = value;
                          });
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            'All Routes',
                            _selectedRoute,
                            _allRoutes,
                            (val) => setState(() {
                              _selectedRoute = val;
                              _applyFilters();
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            'All Status',
                            _selectedStatus,
                            ['active', 'inactive'],
                            (val) => setState(() {
                              _selectedStatus = val!;
                              _applyFilters();
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const ShimmerListLoader(itemCount: 15)
                        : RefreshIndicator(
                            onRefresh: _loadCustomers,
                            child: _filteredCustomers.isEmpty
                                ? _buildEmptyState()
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    itemCount: _filteredCustomers.length,
                                    itemBuilder: (context, index) {
                                      return _buildCustomerItem(
                                        _filteredCustomers[index],
                                      );
                                    },
                                  ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customer_management_fab',
        onPressed: () => _showCustomerForm(),
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add_rounded, color: theme.colorScheme.onPrimary),
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);
    return UnifiedCard(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : 'all',
          isExpanded: true,
          hint: Text(label),
          onChanged: onChanged,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: theme.colorScheme.primary,
          ),
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem(value: 'all', child: Text(label)),
            ...items.map(
              (item) => DropdownMenuItem(value: item, child: Text(item)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerItem(Customer customer) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: UnifiedCard(
        padding: EdgeInsets.zero,
        onTap: () {
          context.pushNamed(
            'customer_details',
            pathParameters: {'customerId': customer.id},
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          leading: CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              customer.shopName.isNotEmpty
                  ? customer.shopName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            customer.shopName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${customer.route} • ${customer.city ?? "No City"}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.primary.withValues(alpha: 0.7),
              size: 20,
            ),
            onPressed: () => _showCustomerForm(customer: customer),
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No customers found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
