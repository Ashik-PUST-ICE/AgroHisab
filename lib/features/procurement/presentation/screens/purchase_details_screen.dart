import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/purchase_model.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final PurchaseModel purchase;

  const PurchaseDetailsScreen({super.key, required this.purchase});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(purchase.purchaseNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ক্রয়ের বিস্তারিত', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 5),
              Text(purchase.productName ?? 'কৃষি পণ্য', style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(purchase.purchaseDate.isEmpty ? 'তারিখ নেই' : purchase.purchaseDate, style: const TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 14),
          _section('কৃষকের তথ্য', [
            _row('নাম', purchase.supplierName ?? 'নির্বাচন করা হয়নি'),
            _row('ক্রয় নম্বর', purchase.purchaseNumber),
          ]),
          const SizedBox(height: 12),
          _section('ওজন ও হিসাব', [
            _row('মোট ওজন', '${purchase.actualWeight.toStringAsFixed(2)} কেজি'),
            _row('কাটতি', '${purchase.deductedWeight.toStringAsFixed(2)} কেজি'),
            _row('নিট ওজন', '${purchase.netWeight.toStringAsFixed(2)} কেজি'),
          ]),
          const SizedBox(height: 12),
          _section('টাকার হিসাব', [
            _row('মোট দাম', '৳ ${purchase.totalAmount.toStringAsFixed(2)}', bold: true),
            _row('পরিশোধ', '৳ ${purchase.paidAmount.toStringAsFixed(2)}'),
            _row('বাকি', '৳ ${purchase.dueAmount.toStringAsFixed(2)}', color: AppColors.error, bold: true),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 15)),
          const Divider(height: 20),
          ...children,
        ]),
      );

  Widget _row(String label, String value, {Color? color, bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Flexible(child: Text(value, textAlign: TextAlign.right, style: TextStyle(color: color ?? AppColors.textPrimary, fontWeight: bold ? FontWeight.bold : FontWeight.w600))),
        ]),
      );
}
