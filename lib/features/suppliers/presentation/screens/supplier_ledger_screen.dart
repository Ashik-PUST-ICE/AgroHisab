import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/supplier_model.dart';
import '../providers/supplier_provider.dart';

class SupplierLedgerScreen extends StatelessWidget {
  final SupplierModel supplier;

  const SupplierLedgerScreen({super.key, required this.supplier});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${supplier.name} - হিসাব খাতা', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SupplierProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.ledger == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final ledger = provider.ledger;
          if (ledger == null) {
            return const Center(child: Text('এই কৃষকের কোনো লেনদেনের তথ্য নেই।', style: TextStyle(color: Colors.grey)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
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
                    const Text('বর্তমান বকেয়া / পাওনা (Due Balance)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '৳ ${ledger.balanceDue.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('মোট ক্রয়: ৳${ledger.totalPurchases.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        Text('মোট পরিশোধ: ৳${ledger.totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('মাল ক্রয়ের হিসাব', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              if (ledger.purchases.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('কোনো ক্রয়ের হিস্ট্রি নেই।', style: TextStyle(color: Colors.grey)),
                )
              else
                ...ledger.purchases.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentLight,
                      child: const Icon(Icons.shopping_bag, color: AppColors.primary),
                    ),
                    title: Text('চালান/ক্রয় #${p.purchaseNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(p.purchaseDate),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('৳ ${p.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (p.dueAmount > 0)
                          Text('বাকি: ৳${p.dueAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                )),
            ],
          );
        },
      ),
    );
  }
}