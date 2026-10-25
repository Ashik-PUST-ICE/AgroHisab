import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/procurement/presentation/providers/procurement_provider.dart';
import 'features/challan/presentation/providers/challan_provider.dart';
import 'features/aratdar/presentation/providers/aratdar_provider.dart';
import 'features/settlement/presentation/providers/settlement_provider.dart';
import 'features/stock/presentation/providers/stock_provider.dart';
import 'features/accounts/presentation/providers/account_provider.dart';
import 'features/storage/presentation/providers/storage_provider.dart';
import 'features/expenses/presentation/providers/expense_provider.dart';
import 'features/reports/presentation/providers/reports_provider.dart';
import 'features/suppliers/presentation/providers/supplier_provider.dart';
import 'features/diary/presentation/providers/diary_provider.dart';
import 'features/remittances/presentation/providers/remittance_provider.dart';
import 'features/transporters/presentation/providers/transporter_provider.dart';
import 'features/documents/presentation/providers/document_provider.dart';
import 'features/crops/presentation/providers/crop_provider.dart';
import 'features/markets/presentation/providers/market_provider.dart';
import 'features/units/presentation/providers/unit_provider.dart';
import 'features/notifications/presentation/providers/notification_provider.dart';
import 'features/security/presentation/providers/security_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AgroHisabApp());
}

class AgroHisabApp extends StatelessWidget {
  const AgroHisabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProcurementProvider()),
        ChangeNotifierProvider(create: (_) => ChallanProvider()),
        ChangeNotifierProvider(create: (_) => AratdarProvider()),
        ChangeNotifierProvider(create: (_) => SettlementProvider()),
        ChangeNotifierProvider(create: (_) => StockProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => StorageProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ChangeNotifierProvider(create: (_) => SupplierProvider()),
        ChangeNotifierProvider(create: (_) => DiaryProvider()),
        ChangeNotifierProvider(create: (_) => RemittanceProvider()),
        ChangeNotifierProvider(create: (_) => TransporterProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => UnitProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SecurityProvider()),
      ],
      child: MaterialApp(
        title: 'AgroHisab - à¦•à§ƒà¦·à¦¿ à¦¬à¦¾à¦£à¦¿à¦œà§à¦¯ à¦¸à¦¾à¦¥à§€',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}
