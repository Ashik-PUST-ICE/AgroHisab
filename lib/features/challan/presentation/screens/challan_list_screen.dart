import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/challan_provider.dart';
import 'create_challan_screen.dart';
import 'challan_details_screen.dart';

class ChallanListScreen extends StatefulWidget {
  const ChallanListScreen({super.key});

  @override
  State<ChallanListScreen> createState() => _ChallanListScreenState();
}

class _ChallanListScreenState extends State<ChallanListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<ChallanProvider>(context, listen: false);
      p.fetchShipments();
      p.fetchExpenseHeads();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallanProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('চালান (Challan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'নতুন চালান'),
            Tab(text: 'চালান তালিকা'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: New Challan Form
          const CreateChallanScreen(),

          // Tab 2: Challan List
          RefreshIndicator(
            onRefresh: () => provider.fetchShipments(),
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : provider.shipments.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.local_shipping_outlined, size: 54, color: AppColors.textSecondary),
                              SizedBox(height: 12),
                              Text('কোনো চালান পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.shipments.length,
                        itemBuilder: (ctx, idx) {
                          final s = provider.shipments[idx];
                          return _buildChallanCard(s);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallanCard(dynamic shipment) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChallanDetailsScreen(shipment: shipment)),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'চালান নং: ${shipment.shipmentNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shipment.statusLabel,
                    style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'গন্তব্য: ${shipment.aratdarName} (${shipment.destinationMarket}) • ${shipment.dispatchDate}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'গাড়ি: ${shipment.vehicleNumber ?? "ট্রাক"}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                Text(
                  'মোট মাল: ${shipment.totalDispatchedWeight} কেজি',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}