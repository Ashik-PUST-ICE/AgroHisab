class ApiEndpoints {
  // Base URL - defaults to local API gateway or service
  // For Android Emulator use 10.0.2.2, for real phone use your machine's LAN IP
  // Local Laravel Herd gateway. The gateway exposes service routes under
  // /p (public) and /u (authenticated user), not directly under /v1.
  static const String defaultBaseUrl = 'http://192.168.0.102:8000/api';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String me = '/me';
  static const String logout = '/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String changePassword = '/auth/change-password';
  static const String profile = '/profile';

  // Purchases & Farmer Calculator
  static const String purchases = '/purchases';
  static const String calculateProcurement = '/purchases/calculate';
  static const String suppliers = '/suppliers';

  // Shipments (মাল চালান) & Expenses
  static const String shipments = '/shipments';
  static const String shipmentExpenseHeads = '/shipments/expense-heads';

  // Aratdar & Consignment Sales
  static const String aratdars = '/aratdars';

  // Stock & Loss Adjustments
  static const String stockMovements = '/stock-movements';
  static const String stockBalance = '/stock-movements/balance';
  static const String stockAdjustments = '/stock-adjustments';

  // Accounts & Dashboard
  static const String accounts = '/accounts';
  static const String dashboardMetrics = '/dashboard/metrics';
  static const String reportsProfitability = '/reports/profitability';
}
