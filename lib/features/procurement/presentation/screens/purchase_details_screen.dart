import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../data/models/purchase_model.dart';
import '../providers/procurement_provider.dart';

class PurchaseDetailsScreen extends StatefulWidget {
  final PurchaseModel purchase;

  const PurchaseDetailsScreen({super.key, required this.purchase});

  @override
  State<PurchaseDetailsScreen> createState() => _PurchaseDetailsScreenState();
}

class _PurchaseDetailsScreenState extends State<PurchaseDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProcurementProvider>(context, listen: false).fetchPurchasePayments(widget.purchase.id);
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
  }

  void _showPayFarmerDialog(PurchaseModel purchase) {
    final accountProv = Provider.of<AccountProvider>(context, listen: false);
    int? selectedAccountId = accountProv.accounts.isNotEmpty ? accountProv.accounts.first.id : null;
    final amountCtrl = TextEditingController(text: purchase.dueAmount.toStringAsFixed(0));
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime payDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('কৃষককে মূল্য পরিশোধ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('কৃষক: ${purchase.supplierName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('বাকি পাওনা: ৳ ${purchase.dueAmount.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (accountProv.accounts.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedAccountId,
                    decoration: const InputDecoration(labelText: 'টাকা প্রদানের অ্যাকাউন্ট *'),
                    items: accountProv.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (val) => setDlgState(() => selectedAccountId = val),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'পরিশোধের পরিমাণ (৳) *'),
                ),
                const SizedBox(height: 12),
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'রসিদ / ভাউচার নং (ঐচ্ছিক)')),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'মন্তব্য (ঐচ্ছিক)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0 || selectedAccountId == null) return;
                if (amt > purchase.dueAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppColors.error, content: Text('পরিশোধের পরিমাণ মোট বকেয়া টাকার বেশি হতে পারে না')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final prov = Provider.of<ProcurementProvider>(context, listen: false);
                final ok = await prov.storePurchasePayment(
                  purchase.id,
                  accountId: selectedAccountId!,
                  amount: amt,
                  paymentDate: DateFormat('yyyy-MM-dd').format(payDate),
                  referenceNumber: refCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'কৃষককে মূল্য পরিশোধ সফলভাবে সম্পন্ন হয়েছে!' : (prov.errorMessage ?? 'পরিশোধে ত্রুটি হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('টাকা পরিশোধ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final procProv = Provider.of<ProcurementProvider>(context);
    final curPurchases = procProv.purchases.where((p) => p.id == widget.purchase.id);
    final PurchaseModel purchase = curPurchases.isNotEmpty ? curPurchases.first : widget.purchase;
    final List<PurchasePaymentModel> payments = procProv.purchasePayments;

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
          _section('টাকার হিসাব ও পাওনা', [
            _row('মোট দাম', '৳ ${purchase.totalAmount.toStringAsFixed(2)}', bold: true),
            _row('পরিশোধ', '৳ ${purchase.paidAmount.toStringAsFixed(2)}', color: Colors.teal),
            _row('বাকি পাওনা', '৳ ${purchase.dueAmount.toStringAsFixed(2)}', color: purchase.dueAmount > 0 ? AppColors.error : Colors.grey, bold: true),
          ]),

          if (purchase.dueAmount > 0) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.payment_rounded, color: Colors.white),
              label: Text('কৃষককে মূল্য পরিশোধ করুন (৳ ${purchase.dueAmount.toStringAsFixed(0)})', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _showPayFarmerDialog(purchase),
            ),
          ],

          const SizedBox(height: 18),
          _section('টাকা পরিশোধের রসিদ ও ট্রানজাকশন', [
            if (procProv.isPaymentLoading && payments.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
            else if (payments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text('এই ক্রয়ের অধীনে এখনো কোনো অতিরিক্ত পেমেন্ট ট্রানজাকশন যুক্ত হয়নি।', style: TextStyle(color: Colors.grey, fontSize: 13)),
              )
            else
              ...payments.map((PurchasePaymentModel pmt) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pmt.accountName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('৳ ${pmt.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 14)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('তারিখ: ${pmt.paymentDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        if (pmt.referenceNumber != null && pmt.referenceNumber!.isNotEmpty)
                          Text('রসিদ: ${pmt.referenceNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                    const Divider(height: 12),
                  ],
                ),
              )),
          ]),
          const SizedBox(height: 30),
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