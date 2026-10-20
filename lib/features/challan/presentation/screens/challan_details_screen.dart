import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/shipment_model.dart';
import '../../../settlement/presentation/screens/settlement_screen.dart';

class ChallanDetailsScreen extends StatelessWidget {
  final ShipmentModel shipment;

  const ChallanDetailsScreen({super.key, required this.shipment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('চালান বিস্তারিত - ${shipment.shipmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
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
                      Text(shipment.shipmentNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(shipment.statusLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('গন্তব্য: ${shipment.aratdarName} (${shipment.destinationMarket})', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
                  Text('তারিখ: ${shipment.dispatchDate} • গাড়ি: ${shipment.vehicleNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Goods list
            const Text('পণ্যের তালিকা', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                children: shipment.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(i.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('${i.dispatchedWeight} ${i.unitName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Expense Breakdown
            const Text('পরিবহন ও আনুষঙ্গিক খরচসমূহ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ট্রাক / পিকআপ ভাড়া', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('৳ ${shipment.freightAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 12),
                  ...shipment.expenses.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${e.head} (${e.paidBy == "owner" ? "মালিক" : "আড়তদার"})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('৳ ${e.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট খরচ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('৳ ${shipment.totalExpenses.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button: View Settlement / Profit Loss
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics_rounded, color: Colors.white),
              label: const Text('বিক্রি ও লাভ-ক্ষতির হিসাব দেখুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettlementScreen(shipmentId: shipment.id)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}