import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/dashboard/presentation/providers/dashboard_provider.dart';
import 'features/procurement/presentation/providers/procurement_provider.dart';

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
      ],
      child: MaterialApp(
        title: 'কৃষি বাণিজ্য সাথী',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}