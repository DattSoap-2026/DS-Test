class WorldCurrency {
  final String code;
  final String name;
  final String symbol;

  const WorldCurrency({required this.code, required this.name, required this.symbol});
}

const List<WorldCurrency> worldCurrencies = [
  WorldCurrency(code: 'AED', name: 'United Arab Emirates Dirham', symbol: 'د.إ'),
  WorldCurrency(code: 'ARS', name: 'Argentine Peso', symbol: '\$'),
  WorldCurrency(code: 'AUD', name: 'Australian Dollar', symbol: '\$'),
  WorldCurrency(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳'),
  WorldCurrency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
  WorldCurrency(code: 'CAD', name: 'Canadian Dollar', symbol: '\$'),
  WorldCurrency(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF'),
  WorldCurrency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  WorldCurrency(code: 'EUR', name: 'Euro', symbol: '€'),
  WorldCurrency(code: 'GBP', name: 'British Pound Sterling', symbol: '£'),
  WorldCurrency(code: 'HKD', name: 'Hong Kong Dollar', symbol: '\$'),
  WorldCurrency(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp'),
  WorldCurrency(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪'),
  WorldCurrency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  WorldCurrency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  WorldCurrency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  WorldCurrency(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
  WorldCurrency(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM'),
  WorldCurrency(code: 'NGN', name: 'Nigerian Naira', symbol: '₦'),
  WorldCurrency(code: 'NZD', name: 'New Zealand Dollar', symbol: '\$'),
  WorldCurrency(code: 'PHP', name: 'Philippine Peso', symbol: '₱'),
  WorldCurrency(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs'),
  WorldCurrency(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
  WorldCurrency(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼'),
  WorldCurrency(code: 'SGD', name: 'Singapore Dollar', symbol: '\$'),
  WorldCurrency(code: 'THB', name: 'Thai Baht', symbol: '฿'),
  WorldCurrency(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
  WorldCurrency(code: 'USD', name: 'United States Dollar', symbol: '\$'),
  WorldCurrency(code: 'VND', name: 'Vietnamese Dong', symbol: '₫'),
  WorldCurrency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
];
