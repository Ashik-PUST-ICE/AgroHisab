import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/stock_provider.dart';
import 'record_adjustment_screen.dart';

class StockSummaryScreen extends StatefulWidget {
  const StockSummaryScreen({super.key});

  @override
  State<StockSummaryScreen> createState() => _StockSummaryScreenState();
}

class _StockSummaryScreenState extends State<StockSummaryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StockProvider>(context, listen: false).fetchStockData();
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
        title: const Text('গুদাম ও মজুদ ব্যবস্থাপনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'বর্তমান স্টক'),
            Tab(text: 'ঘাটতি/পচন'),
            Tab(text: 'ওঠানামা খতিয়ান'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.remove_circle_outline),
        label: const Text('পচন / ঘাটতি এন্ট্রি'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RecordAdjustmentScreen()),
          );
        },
      ),
      body: Consumer<StockProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.balances.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildBalancesTab(provider),
              _buildAdjustmentsTab(provider),
              _buildMovementsTab(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBalancesTab(StockProvider provider) {
    if (provider.balances.isEmpty) {
      return const Center(child: Text('বর্তমানে গুদামে কোনো মজুদ ফসল নেই।', style: TextStyle(color: Colors.grey)));
    }

    final totalKg = provider.balances.fold<double>(0.0, (sum, b) => sum + b.currentStockKg);
    final totalBags = provider.balances.fold<int>(0, (sum, b) => sum + b.currentStockBags);

    return RefreshIndicator(
      onRefresh: () => provider.fetchStockData(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('মোট গুদাম স্টক (হাতে অবশিষ্ট)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${totalKg.toStringAsFixed(0)} কেজি',
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('$totalBags বস্তা', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('ফসল অনুযায়ী বিভাজন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...provider.balances.map((b) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.accentLight,
                child: const Icon(Icons.grass, color: AppColors.primary),
              ),
              title: Text(b.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('বস্তা: ${b.currentStockBags} টি'),
              trailing: Text(
                '${b.currentStockKg.toStringAsFixed(1)} কেজি',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAdjustmentsTab(StockProvider provider) {
    if (provider.adjustments.isEmpty) {
      return const Center(child: Text('কোনো ঘাটতি বা পচনের রেকর্ড নেই।', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchStockData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.adjustments.length,
        itemBuilder: (ctx, i) {
          final adj = provider.adjustments[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
              ),
              title: Text(adj.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${adj.reasonLabel} • ${adj.date}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${adj.quantityKg.toStringAsFixed(1)} কেজি',
                    style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (adj.bagCount > 0)
                    Text('-${adj.bagCount} বস্তা', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMovementsTab(StockProvider provider) {
    if (provider.movements.isEmpty) {
      return const Center(child: Text('কোনো স্টক ওঠানামার রেকর্ড পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
    }

    return RefreshIndicator(
      onRefresh: () => provider.fetchStockData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: provider.movements.length,
        itemBuilder: (ctx, i) {
          final mov = provider.movements[i];
          final isIn = mov.type == 'in';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isIn ? AppColors.accentLight : Colors.orange.shade50,
                child: Icon(
                  isIn ? Icons.south_west : Icons.north_east,
                  color: isIn ? AppColors.primary : Colors.orange.shade800,
                ),
              ),
              title: Text(mov.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${mov.referenceType} #${mov.referenceId} • ${mov.date}'),
              trailing: Text(
                '${isIn ? "+" : "-"}${mov.quantityKg.toStringAsFixed(1)} কেজি',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isIn ? AppColors.primary : Colors.orange.shade800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}