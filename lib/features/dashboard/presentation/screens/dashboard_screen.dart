import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../presentation/providers/dashboard_provider.dart';
import '../../../procurement/presentation/screens/purchase_list_screen.dart';
import '../../../procurement/presentation/screens/quick_calculator_screen.dart';
import '../../../challan/presentation/screens/challan_list_screen.dart';
import '../../../aratdar/presentation/screens/aratdar_list_screen.dart';
import '../../../stock/presentation/screens/stock_summary_screen.dart';
import '../../../accounts/presentation/screens/accounts_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../diary/presentation/screens/diary_screen.dart';
import '../../../documents/presentation/screens/document_vault_screen.dart';
import '../../../crops/presentation/screens/crop_list_screen.dart';
import '../../../markets/presentation/screens/market_list_screen.dart';
import '../../../units/presentation/screens/unit_conversion_screen.dart';
import '../../../notifications/presentation/screens/notification_screen.dart';
import '../../../storage/presentation/screens/storage_settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dashProvider = Provider.of<DashboardProvider>(context);
    final user = authProvider.currentUser;
    final m = dashProvider.metrics;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.accentLight,
              child: Icon(Icons.person, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'সুপ্রভাত,',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                Text(
                  user?.name ?? 'Md. Ashikur Rahman',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Badge(
              label: Text('৩'),
              child: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(authProvider),
      body: RefreshIndicator(
        onRefresh: () => dashProvider.fetchMetrics(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Green Investment Summary Banner (Live API values)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0D6E3B), Color(0xFF15803D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 18),
                            SizedBox(width: 6),
                            Text('মোট বিনিয়োগ ও ব্যবসা', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '৳ ${m != null ? m.totalInvested.toStringAsFixed(0) : "২,৪৫,০০০"}',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.white.withOpacity(0.18)),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('হাতে নগদ', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '৳ ${m != null ? m.totalLiquidBalance.toStringAsFixed(0) : "৬৮,৫০০"}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(height: 28, width: 1, color: Colors.white.withOpacity(0.2)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('মোট পাওনা', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              '৳ ${m != null ? m.netReceivableDue.toStringAsFixed(0) : "১,২০,০০০"}',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Quick Action Grid (6 Cards - Linked to Screens)
              const Text(
                'মূল সেবা ও হিসাব',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: [
                  _buildActionCard(
                    title: 'ক্রয়',
                    subtitle: '(Purchase)',
                    icon: Icons.shopping_basket_rounded,
                    color: AppColors.cardOrange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PurchaseListScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'চালান',
                    subtitle: '(Challan)',
                    icon: Icons.local_shipping_rounded,
                    color: AppColors.cardGreen,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ChallanListScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'ক্যালকুলেটর',
                    subtitle: '(Calculator)',
                    icon: Icons.calculate_rounded,
                    color: AppColors.cardBlue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickCalculatorScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'আড়তদার',
                    subtitle: '(Aratdar)',
                    icon: Icons.storefront_rounded,
                    color: AppColors.cardBrown,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AratdarListScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'হিসাব',
                    subtitle: '(Accounts)',
                    icon: Icons.account_balance_rounded,
                    color: AppColors.cardCyan,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'রিপোর্ট',
                    subtitle: '(Reports)',
                    icon: Icons.analytics_rounded,
                    color: AppColors.cardIndigo,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'ফসল',
                    subtitle: '(Crops)',
                    icon: Icons.grass_rounded,
                    color: AppColors.cardGreen,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CropListScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'মোকাম',
                    subtitle: '(Markets)',
                    icon: Icons.store_rounded,
                    color: AppColors.cardOrange,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MarketListScreen()));
                    },
                  ),
                  _buildActionCard(
                    title: 'ওজন একক',
                    subtitle: '(Units)',
                    icon: Icons.scale_rounded,
                    color: AppColors.cardCyan,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const UnitConversionScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Recent Activity Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'সাম্প্রতিক কার্যক্রম',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('সব দেখুন >', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              _buildActivityItem(
                title: 'CH-2025-0003 ঢাকা আড়ত',
                subtitle: 'পাঠানো হয়েছে',
                time: '২ ঘণ্টা আগে',
                icon: Icons.local_shipping_rounded,
                iconColor: AppColors.primary,
              ),
              _buildActivityItem(
                title: 'ক্রয় #P-0056 পেঁয়াজ',
                subtitle: '৳ ৪৫,০০০',
                time: '৪ ঘণ্টা আগে',
                icon: Icons.shopping_bag_rounded,
                iconColor: AppColors.cardOrange,
              ),
              _buildActivityItem(
                title: 'পেমেন্ট পাওয়া আড়তদার',
                subtitle: '৳ ২৫,০০০ • ৩ ঘণ্টা আগে',
                time: '৬ ঘণ্টা আগে',
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.success,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseListScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const StockSummaryScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DocumentVaultScreen()));
          } else if (index == 4) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const DiaryScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'লেনদেন'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'স্টক'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), label: 'ডকুমেন্ট'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'প্রোফাইল'),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withOpacity(0.12),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDrawer(AuthProvider authProvider) {
    final items = [
      ('Purchases', Icons.shopping_basket_rounded, const PurchaseListScreen()),
      ('Challan', Icons.local_shipping_rounded, const ChallanListScreen()),
      ('Calculator', Icons.calculate_rounded, const QuickCalculatorScreen()),
      ('Aratdar', Icons.storefront_rounded, const AratdarListScreen()),
      ('Accounts', Icons.account_balance_rounded, const AccountsScreen()),
      ('Reports', Icons.analytics_rounded, const ReportsScreen()),
      ('Storage settings', Icons.cloud_sync_rounded, const StorageSettingsScreen()),
    ];
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: AppColors.primary,
              child: Row(children: [
                const CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(Icons.person, color: AppColors.primary, size: 28)),
                const SizedBox(width: 12),
                Expanded(child: Text(authProvider.currentUser?.name ?? 'Md. Ashikur Rahman', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              ]),
            ),
            Expanded(
              child: ListView(
                children: items.map((item) => ListTile(
                  leading: Icon(item.$2, color: AppColors.primary),
                  title: Text(item.$1),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => item.$3));
                  },
                )).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await authProvider.logout();
                if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}


