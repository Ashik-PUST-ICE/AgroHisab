import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/settlement_provider.dart';

class SettlementScreen extends StatefulWidget {
  final int shipmentId;

  const SettlementScreen({super.key, required this.shipmentId});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SettlementProvider>(context, listen: false).fetchPreview(widget.shipmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SettlementProvider>(context);
    final p = provider.preview;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('বিক্রি ও লাভ-ক্ষতির হিসাব', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : p == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 50, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(provider.errorMessage ?? 'সেটেলমেন্ট প্রিভিউ পাওয়া যায়নি', style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.fetchPreview(widget.shipmentId),
                          child: const Text('পুনরায় চেষ্টা করুন'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Realized Profit Big Highlight Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: p.realizedProfit >= 0
                                ? [const Color(0xFF0D6E3B), const Color(0xFF16A34A)]
                                : [const Color(0xFFDC2626), const Color(0xFFEF4444)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: (p.realizedProfit >= 0 ? AppColors.primary : AppColors.error).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              p.realizedProfit >= 0 ? 'চালানের মোট আসল লাভ (Net Profit)' : 'চালানের মোট লোকসান (Net Loss)',
                              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '৳ ${p.realizedProfit.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sales & Commission Breakdown
                      const Text('আড়তে বিক্রি ও কমিশন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: [
                            _buildRow('মোট বিক্রি (Gross Sales):', '৳ ${p.grossSales.toStringAsFixed(2)}'),
                            _buildRow('আড়তদার কমিশন (Commission):', '- ৳ ${p.commissionAmount.toStringAsFixed(2)}', color: AppColors.error),
                            const Divider(height: 16),
                            _buildRow('নিট বিক্রয়মূল্য (Net Proceeds):', '৳ ${p.netSalesProceeds.toStringAsFixed(2)}', isBold: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Cost & Expense Breakdown
                      const Text('কেনার আসল দাম ও খরচ কর্তন', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Column(
                          children: [
                            _buildRow('মালের আসল কেনা দাম (COGS):', '- ৳ ${p.allocatedCogs.toStringAsFixed(2)}', color: AppColors.error),
                            _buildRow('মালিকের পরিবহন ও কুলি খরচ:', '- ৳ ${p.totalOwnerExpenses.toStringAsFixed(2)}', color: AppColors.error),
                            _buildRow('আড়তের কুলি ও খাজনা খরচ:', '- ৳ ${p.totalAratdarDeductions.toStringAsFixed(2)}', color: AppColors.error),
                            const Divider(height: 16),
                            _buildRow('প্রকৃত লাভ / লোকসান:', '৳ ${p.realizedProfit.toStringAsFixed(2)}', isBold: true, color: p.realizedProfit >= 0 ? AppColors.primary : AppColors.error),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Aratdar Remittance Status
                      const Text('আড়তদারের কাছে নগদ পাওনা', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
                        child: Column(
                          children: [
                            _buildRow('আড়তদার থেকে মোট প্রাপ্য:', '৳ ${p.expectedNetProceeds.toStringAsFixed(2)}'),
                            _buildRow('ইতিমধ্যে প্রাপ্ত টাকা (Remitted):', '৳ ${p.totalRemitted.toStringAsFixed(2)}'),
                            const Divider(height: 16),
                            _buildRow('বাকি পাওনা (Outstanding Due):', '৳ ${p.outstandingReceivable.toStringAsFixed(2)}', isBold: true, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}