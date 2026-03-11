import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/settings_audit_log.dart';
import '../../services/settings_service.dart';

class SettingsAuditLogsScreen extends StatefulWidget {
  final bool showHeader;

  const SettingsAuditLogsScreen({super.key, this.showHeader = true});

  @override
  State<SettingsAuditLogsScreen> createState() =>
      _SettingsAuditLogsScreenState();
}

class _SettingsAuditLogsScreenState extends State<SettingsAuditLogsScreen> {
  bool _isLoading = true;
  List<SettingsAuditLog> _logs = [];

  DateTime? _fromDate;
  DateTime? _toDate;
  String _selectedModule = 'all';
  String _selectedUser = 'all';
  List<String> _availableModules = const ['all'];
  List<String> _availableUsers = const ['all'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final service = context.read<SettingsService>();
      final moduleFuture = service.getSettingsAuditModules();
      final userFuture = service.getSettingsAuditUsers();
      final logsFuture = service.getSettingsAuditLogs(
        fromDate: _fromDate,
        toDate: _toDate,
        module: _selectedModule == 'all' ? null : _selectedModule,
        userId: _selectedUser == 'all' ? null : _selectedUser,
      );

      final results = await Future.wait([moduleFuture, userFuture, logsFuture]);
      final modules = List<String>.from(results[0] as List);
      final users = List<String>.from(results[1] as List);
      final logs = List<SettingsAuditLog>.from(results[2] as List);

      final normalizedModules = ['all', ...modules];
      final normalizedUsers = ['all', ...users];

      if (mounted) {
        setState(() {
          _availableModules = normalizedModules;
          _availableUsers = normalizedUsers;
          if (!_availableModules.contains(_selectedModule)) {
            _selectedModule = 'all';
          }
          if (!_availableUsers.contains(_selectedUser)) {
            _selectedUser = 'all';
          }
          _logs = logs;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickDate({required bool isFromDate}) async {
    final now = DateTime.now();
    final initial = isFromDate ? (_fromDate ?? now) : (_toDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isFromDate) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
    });
    await _loadData();
  }

  void _clearFilters() {
    setState(() {
      _fromDate = null;
      _toDate = null;
      _selectedModule = 'all';
      _selectedUser = 'all';
    });
    _loadData();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Any';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTimestamp(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    return DateFormat('dd MMM yyyy, HH:mm:ss').format(parsed);
  }

  String _formatJsonValue(dynamic value) {
    if (value == null) return '-';
    if (value is String) return value;
    try {
      return const JsonEncoder.withIndent('  ').convert(value);
    } catch (_) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: widget.showHeader
          ? AppBar(
              title: const Text('Settings Audit Logs'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadData,
                  tooltip: 'Refresh',
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickDate(isFromDate: true),
                          icon: const Icon(Icons.date_range),
                          label: Text('From: ${_formatDate(_fromDate)}'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _pickDate(isFromDate: false),
                          icon: const Icon(Icons.event),
                          label: Text('To: ${_formatDate(_toDate)}'),
                        ),
                        SizedBox(
                          width: 210,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedModule,
                            decoration: const InputDecoration(
                              labelText: 'Module',
                              border: OutlineInputBorder(),
                            ),
                            items: _availableModules
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value == 'all' ? 'All modules' : value,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedModule = value);
                              _loadData();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 210,
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedUser,
                            decoration: const InputDecoration(
                              labelText: 'User',
                              border: OutlineInputBorder(),
                            ),
                            items: _availableUsers
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(
                                      value == 'all' ? 'All users' : value,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedUser = value);
                              _loadData();
                            },
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                ? const Center(child: Text('No settings audit logs found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _logs.length,
                    itemBuilder: (context, index) {
                      final item = _logs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ExpansionTile(
                          leading: const Icon(Icons.history_toggle_off),
                          title: Text(item.module),
                          subtitle: Text(
                            '${item.userId} | ${_formatTimestamp(item.timestamp)}',
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            12,
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Setting Key: ${item.settingKey}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Source: ${item.source}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildValueBlock(
                              context: context,
                              label: 'Old Value',
                              value: _formatJsonValue(item.oldValue),
                            ),
                            const SizedBox(height: 8),
                            _buildValueBlock(
                              context: context,
                              label: 'New Value',
                              value: _formatJsonValue(item.newValue),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueBlock({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ],
      ),
    );
  }
}
