import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.checkAuthStatus();
      if (mounted && isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              // Logo & App Name
              Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      color: AppColors.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.eco_rounded,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'কৃষি বাণিজ্য সাথী',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'আপনার কৃষিপণ্য ব্যবসার\nসম্পূর্ণ হিসাব এখন এক অ্যাপে',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),

              // Visual Illustration Box (Vegetables & Truck representation)
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_shipping_rounded,
                      size: 90,
                      color: AppColors.primary.withOpacity(0.85),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded, color: AppColors.secondary, size: 28),
                        SizedBox(width: 14),
                        Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                        SizedBox(width: 14),
                        Icon(Icons.currency_exchange_rounded, color: AppColors.warning, size: 28),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Buttons & Tagline
              Column(
                children: [
                  CustomButton(
                    text: 'লগইন',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'নতুন অ্যাকাউন্ট তৈরি করুন',
                    isOutline: true,
                    onPressed: () {
                      // Navigate to Register or Show info
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('অ্যাকাউন্ট খুলতে এডমিনের সাথে যোগাযোগ করুন অথবা লগইন করুন')),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'স্মার্ট হিসাব  |  নিরাপদ ব্যবসা  |  উন্নত ভবিষ্যৎ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}