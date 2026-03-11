import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/holiday_service.dart';
import '../models/holiday_model.dart';
import '../../../utils/ui_notifier.dart';

class HolidayManagementScreen extends StatefulWidget {
  const HolidayManagementScreen({super.key});

  @override
  State<HolidayManagementScreen> createState() => _HolidayManagementScreenState();
}

class _HolidayManagementScreenState extends State<HolidayManagementScreen> {
  bool _isLoading = true;
  List<Holiday> _holidays = [];

  @override
  void initState() {
    super.initState();
    _loadHolidays();
  }

  Future<void> _loadHolidays() async {
    setState(() => _isLoading = true);
    try {
      final holidayService = context.read<HolidayService>();
      final holidays = await holidayService.getAllHolidays();
      // Sort by date approaching
      holidays.sort((a, b) => a.date.compareTo(b.date));
      setState(() => _holidays = holidays);
    } catch (e) {
      debugPrint('Error loading holidays: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHoliday(Holiday holiday) async {
    final holidayService = context.read<HolidayService>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Holiday'),
        content: Text('Are you sure you want to delete "${holiday.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (confirmed == true) {
      try {
        await holidayService.deleteHoliday(holiday.id);
        UINotifier.showSuccess('Holiday deleted');
        _loadHolidays();
      } catch (e) {
        UINotifier.showError('Failed to delete holiday');
      }
    }
  }

  void _showAddHolidayDialog() {
    final holidayService = context.read<HolidayService>();
    final nameController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    bool isRecurring = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add New Holiday'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Holiday Name',
                    hintText: 'e.g. Diwali, Independence Day',
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(DateFormat('EEEE, MMM d, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Recurring Annualy'),
                  value: isRecurring,
                  onChanged: (val) => setDialogState(() => isRecurring = val ?? false),
                ),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _addIndianHolidays(setDialogState),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Add Indian Holidays 2026'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty) {
                  UINotifier.showError('Holiday name is required');
                  return;
                }
                
                final holiday = Holiday(
                  id: '', // Service handles ID generation if empty
                  name: nameController.text,
                  date: selectedDate,
                  isRecurring: isRecurring,
                  description: descController.text,
                );

                try {
                  await holidayService.addHoliday(holiday);
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  UINotifier.showSuccess('Holiday added successfully');
                  _loadHolidays();
                } catch (e) {
                  UINotifier.showError('Failed to add holiday');
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addIndianHolidays(StateSetter setDialogState) async {
    final holidayService = context.read<HolidayService>();
    final indianHolidays = [
      Holiday(id: '', name: 'Republic Day', date: DateTime(2026, 1, 26), isRecurring: true, description: 'National Holiday'),
      Holiday(id: '', name: 'Maha Shivratri', date: DateTime(2026, 2, 26), isRecurring: true, description: 'Hindu Festival'),
      Holiday(id: '', name: 'Holi', date: DateTime(2026, 3, 14), isRecurring: true, description: 'Festival of Colors'),
      Holiday(id: '', name: 'Gudi Padwa', date: DateTime(2026, 3, 22), isRecurring: true, description: 'Marathi New Year'),
      Holiday(id: '', name: 'Ram Navami', date: DateTime(2026, 4, 2), isRecurring: true, description: 'Hindu Festival'),
      Holiday(id: '', name: 'Mahavir Jayanti', date: DateTime(2026, 4, 2), isRecurring: true, description: 'Jain Festival'),
      Holiday(id: '', name: 'Good Friday', date: DateTime(2026, 4, 3), isRecurring: true, description: 'Christian Holiday'),
      Holiday(id: '', name: 'Maharashtra Day', date: DateTime(2026, 5, 1), isRecurring: true, description: 'State Foundation Day'),
      Holiday(id: '', name: 'Buddha Purnima', date: DateTime(2026, 5, 11), isRecurring: true, description: 'Buddhist Festival'),
      Holiday(id: '', name: 'Eid al-Fitr', date: DateTime(2026, 5, 24), isRecurring: true, description: 'Islamic Festival'),
      Holiday(id: '', name: 'Independence Day', date: DateTime(2026, 8, 15), isRecurring: true, description: 'National Holiday'),
      Holiday(id: '', name: 'Janmashtami', date: DateTime(2026, 8, 25), isRecurring: true, description: 'Krishna Birthday'),
      Holiday(id: '', name: 'Ganesh Chaturthi', date: DateTime(2026, 9, 5), isRecurring: true, description: 'Ganesh Festival'),
      Holiday(id: '', name: 'Gandhi Jayanti', date: DateTime(2026, 10, 2), isRecurring: true, description: 'National Holiday'),
      Holiday(id: '', name: 'Dussehra', date: DateTime(2026, 10, 12), isRecurring: true, description: 'Hindu Festival'),
      Holiday(id: '', name: 'Diwali', date: DateTime(2026, 10, 30), isRecurring: true, description: 'Festival of Lights'),
      Holiday(id: '', name: 'Guru Nanak Jayanti', date: DateTime(2026, 11, 19), isRecurring: true, description: 'Sikh Festival'),
      Holiday(id: '', name: 'Christmas', date: DateTime(2026, 12, 25), isRecurring: true, description: 'Christian Holiday'),
    ];

    try {
      for (var holiday in indianHolidays) {
        await holidayService.addHoliday(holiday);
      }
      if (!mounted) return;
      Navigator.pop(context);
      UINotifier.showSuccess('${indianHolidays.length} Indian holidays added');
      _loadHolidays();
    } catch (e) {
      UINotifier.showError('Failed to add holidays');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holiday Management'),
        actions: [
          IconButton(
            onPressed: _loadHolidays,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _holidays.isEmpty
              ? _buildEmptyState()
              : _buildHolidayList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddHolidayDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Holiday'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.beach_access_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No holidays defined',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          const Text('Define holidays to track them in payroll and attendance.'),
        ],
      ),
    );
  }

  Widget _buildHolidayList() {
    // Group holidays by year
    final grouped = <int, List<Holiday>>{};
    for (var h in _holidays) {
      grouped.putIfAbsent(h.date.year, () => []).add(h);
    }

    final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: years.length,
      itemBuilder: (context, index) {
        final year = years[index];
        final yearHolidays = grouped[year]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                year.toString(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            ...yearHolidays.map((h) => _buildHolidayCard(h)),
          ],
        );
      },
    );
  }

  Widget _buildHolidayCard(Holiday holiday) {
    final isUpcoming = holiday.date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
    final theme = Theme.of(context);
    final hasDescription = holiday.description != null && holiday.description!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isUpcoming ? Colors.orange[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('MMM').format(holiday.date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isUpcoming ? Colors.orange[900] : Colors.grey[700],
                    ),
                  ),
                  Text(
                    holiday.date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUpcoming ? Colors.orange[900] : Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holiday.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('EEEE').format(holiday.date),
                    style: TextStyle(fontSize: 13, color: theme.hintColor),
                  ),
                  if (hasDescription)
                    Text(
                      holiday.description!,
                      style: TextStyle(fontSize: 11, color: theme.hintColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (holiday.isRecurring)
              const Icon(Icons.repeat, size: 16, color: Colors.blue),
            if (holiday.isRecurring) const SizedBox(width: 4),
            IconButton(
              onPressed: () => _deleteHoliday(holiday),
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              padding: const EdgeInsets.all(8),
            ),
          ],
        ),
      ),
    );
  }
}
