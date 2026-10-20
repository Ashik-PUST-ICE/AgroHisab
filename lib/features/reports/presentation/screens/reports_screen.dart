import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/reports_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportsProvider>(context, listen: false).fetchReports();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('রিপোর্ট ও ব্যবসায়িক লাভ-ক্ষতি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'লাভ-ক্ষতি বিবরণী'),
            Tab(text: 'গুদাম স্টক মূল্য'),
          ],
        ),
      ),
      body: Consumer<ReportsProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.profitability == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildProfitabilityTab(provider),
              _buildInventoryValuationTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfitabilityTab(ReportsProvider provider) {
    final p = provider.profitability;
    if (p == null) {
      return const Center(child: Text('রিপোর্ট পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
    }

    final isProfit = p.netProfit >= 0;

    return RefreshIndicator(
      onRefresh: () => provider.fetchReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isProfit
                    ? [AppColors.primary, AppColors.secondary]
                    : [Colors.red.shade700, Colors.red.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('মোট অর্জিত লাভ / ক্ষতি (Net Profit)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Text(
                  '৳ ${p.netProfit.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isProfit ? 'আলহামদুলিল্লাহ, সামগ্রিক ব্যবসায় মুনাফা রয়েছে' : 'সতর্কতা: সামগ্রিক হিসাবে ক্ষতি রয়েছে',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildMetricRow('মোট বিক্রয় আয় (Revenue):', '৳ ${p.totalRevenue.toStringAsFixed(0)}', Colors.blue.shade800),
                  const Divider(),
                  _buildMetricRow('মাল কেনার খরচ (COGS):', '৳ ${p.totalCogs.toStringAsFixed(0)}', Colors.black87),
                  const Divider(),
                  _buildMetricRow('মোট মোট লাভ (Gross Profit):', '৳ ${p.grossProfit.toStringAsFixed(0)}', AppColors.primary),
                  const Divider(),
                  _buildMetricRow('মোট পরিচালন ব্যয় (Expenses):', '৳ ${p.totalExpenses.toStringAsFixed(0)}', Colors.red.shade700),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryValuationTab(ReportsProvider provider) {
    if (provider.inventoryValuation.isEmpty) {
      return const Center(child: Text('কোনো গুদাম ভ্যালুয়েশন পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
    }

    final totalVal = provider.inventoryValuation.fold<double>(0.0, (sum, i) => sum + i.totalValue);

    return RefreshIndicator(
      onRefresh: () => provider.fetchReports(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory, color: AppColors.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('মোট গুদাম পণ্যের আনুমানিক বাজার মূল্য', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text(
                      '৳ ${totalVal.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...provider.inventoryValuation.map((item) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentLight,
                child: const Icon(Icons.grass, color: AppColors.primary),
              ),
              title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('মজুদ: ${item.currentStockKg.toStringAsFixed(1)} কেজি • গড় দর: ৳${item.averageRate.toStringAsFixed(1)}/কেজি'),
              trailing: Text(
                '৳ ${item.totalValue.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String title, String val, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
        ],
      ),
    );
  }
}