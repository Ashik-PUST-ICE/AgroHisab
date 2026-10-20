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
      ],
      child: MaterialApp(
        title: 'AgroHisab - কৃষি বাণিজ্য সাথী',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}