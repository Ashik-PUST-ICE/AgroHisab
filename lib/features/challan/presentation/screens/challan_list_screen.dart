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
        title: const Text('মাল চালান (Challan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'নতুন চালান তৈরি'),
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
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_shipping_outlined, size: 54, color: AppColors.textSecondary),
                              SizedBox(height: 12),
                              Text('কোনো চালান পাওয়া যায়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                              SizedBox(height: 6),
                              Text('নতুন চালান তৈরি করতে পাশের ট্যাবে যান', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
    Color badgeColor = AppColors.primary;
    Color badgeBg = AppColors.accentLight;

    switch (shipment.status) {
      case 0: // Draft
        badgeColor = Colors.orange.shade800;
        badgeBg = Colors.orange.shade50;
        break;
      case 1: // Dispatched
        badgeColor = Colors.blue.shade800;
        badgeBg = Colors.blue.shade50;
        break;
      case 2: // Received
        badgeColor = Colors.teal.shade800;
        badgeBg = Colors.teal.shade50;
        break;
      case 3: // Selling
        badgeColor = Colors.purple.shade800;
        badgeBg = Colors.purple.shade50;
        break;
      case 5: // Settled
        badgeColor = Colors.green.shade800;
        badgeBg = Colors.green.shade50;
        break;
    }

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
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
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
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    shipment.statusLabel,
                    style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'আড়তদার: ${shipment.aratdarName} (${shipment.destinationMarket}) • ${shipment.dispatchDate}',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'গাড়ি: ${shipment.vehicleNumber.isNotEmpty ? shipment.vehicleNumber : "ট্রাক"}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                ),
                Text(
                  'প্রেরিত: ${shipment.totalDispatchedWeight} কেজি (${shipment.totalBags} বস্তা)',
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