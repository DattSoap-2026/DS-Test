class SettingsModule {
  final String key;
  final String title;
  final String routePath;
  final String canonicalScreen;
  final List<String> legacyScreens;
  final bool offlineFirst;

  const SettingsModule({
    required this.key,
    required this.title,
    required this.routePath,
    required this.canonicalScreen,
    this.legacyScreens = const [],
    this.offlineFirst = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'title': title,
      'route_path': routePath,
      'canonical_screen': canonicalScreen,
      'legacy_screens': legacyScreens,
      'offline_first': offlineFirst,
    };
  }
}

const Map<String, SettingsModule> settingsRegistry = {
  'company_profile': SettingsModule(
    key: 'company_profile',
    title: 'Company Profile',
    routePath: '/dashboard/settings/company-profile',
    canonicalScreen: 'CompanyProfileScreen',
  ),
  'general_settings': SettingsModule(
    key: 'general_settings',
    title: 'General Settings',
    routePath: '/dashboard/settings/general',
    canonicalScreen: 'GeneralSettingsScreen',
  ),
  'preferences': SettingsModule(
    key: 'preferences',
    title: 'My Preferences',
    routePath: '/dashboard/settings/preferences',
    canonicalScreen: 'UserPreferencesScreen',
  ),
  'taxation': SettingsModule(
    key: 'taxation',
    title: 'Taxation Management',
    routePath: '/dashboard/settings/gst',
    canonicalScreen: 'TaxationScreen',
    legacyScreens: ['GstSettingsScreen'],
  ),
  'transaction_series': SettingsModule(
    key: 'transaction_series',
    title: 'Transaction Series',
    routePath: '/dashboard/settings/transaction-series',
    canonicalScreen: 'TransactionSeriesScreen',
  ),
  'fuel_settings': SettingsModule(
    key: 'fuel_settings',
    title: 'Fuel Settings',
    routePath: '/dashboard/settings/fuel',
    canonicalScreen: 'FuelSettingsScreen',
  ),
  'schemes': SettingsModule(
    key: 'schemes',
    title: 'Schemes & Offers',
    routePath: '/dashboard/settings/schemes',
    canonicalScreen: 'SchemesScreen',
  ),
  'system_data': SettingsModule(
    key: 'system_data',
    title: 'System Data',
    routePath: '/dashboard/settings/data-management',
    canonicalScreen: 'SystemDataScreen',
    legacyScreens: ['DataManagementScreen'],
  ),
  'incentives': SettingsModule(
    key: 'incentives',
    title: 'Incentives & Commission',
    routePath: '/dashboard/settings/incentives',
    canonicalScreen: 'IncentivesScreen',
    legacyScreens: ['IncentivesManagementScreen'],
  ),
  'audit_logs': SettingsModule(
    key: 'audit_logs',
    title: 'Activity History',
    routePath: '/dashboard/settings/audit-logs',
    canonicalScreen: 'AuditLogsScreen',
    legacyScreens: ['AuditLogScreen'],
  ),
  'pdf_templates': SettingsModule(
    key: 'pdf_templates',
    title: 'PDF Templates',
    routePath: '/dashboard/settings/pdf-templates',
    canonicalScreen: 'PdfTemplatesScreen',
  ),
  'whatsapp': SettingsModule(
    key: 'whatsapp',
    title: 'WhatsApp Integration',
    routePath: '/dashboard/settings/whatsapp',
    canonicalScreen: 'WhatsAppSettingsScreen',
  ),
};
