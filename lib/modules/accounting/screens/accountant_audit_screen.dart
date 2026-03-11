import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/firebase/firebase_config.dart';
import '../../../services/accounting_audit_service.dart';
import '../../../widgets/adaptive_card.dart';

class AccountantAuditScreen extends StatefulWidget {
  const AccountantAuditScreen({super.key});

  @override
  State<AccountantAuditScreen> createState() => _AccountantAuditScreenState();
}

class _AccountantAuditScreenState extends State<AccountantAuditScreen> {
  late AccountingAuditService _auditService;
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _auditService = AccountingAuditService(FirebaseServices());
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    final logs = await _auditService.getRecentAccountingAudits(limit: 100);
    setState(() {
      _logs = logs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accountant Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLogs,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
              ? const Center(child: Text('No audit logs found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    return AdaptiveCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: _getActionIcon(log['action']),
                        title: Text(
                          '${log['userName']} - ${log['action']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${log['collectionName']} / ${log['documentId']}'),
                            if (log['notes'] != null)
                              Text(
                                log['notes'],
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            Text(
                              _formatDate(log['createdAt']),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                        trailing: log['changes'] != null
                            ? IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () => _showDetails(context, log),
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }

  Widget _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'create':
        return const Icon(Icons.add_circle, color: Colors.green);
      case 'update':
        return const Icon(Icons.edit, color: Colors.orange);
      case 'delete':
        return const Icon(Icons.delete, color: Colors.red);
      default:
        return const Icon(Icons.circle, color: Colors.grey);
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return 'Unknown';
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return isoDate;
    }
  }

  void _showDetails(BuildContext context, Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Audit Log Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('User', log['userName']),
              _detailRow('Action', log['action']),
              _detailRow('Collection', log['collectionName']),
              _detailRow('Document ID', log['documentId']),
              if (log['notes'] != null) _detailRow('Notes', log['notes']),
              if (log['changes'] != null)
                _detailRow('Changes', log['changes'].toString()),
              _detailRow('Date', _formatDate(log['createdAt'])),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
