import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../aratdar/presentation/providers/aratdar_provider.dart';
import '../providers/remittance_provider.dart';

class RemittanceListScreen extends StatefulWidget {
  const RemittanceListScreen({super.key});

  @override
  State<RemittanceListScreen> createState() => _RemittanceListScreenState();
}

class _RemittanceListScreenState extends State<RemittanceListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RemittanceProvider>(context, listen: false).fetchRemittances();
      Provider.of<AratdarProvider>(context, listen: false).fetchAratdars();
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
  }

  void _showAddRemittanceDialog() {
    final remittanceProvider = Provider.of<RemittanceProvider>(context, listen: false);
    final aratdarProvider = Provider.of<AratdarProvider>(context, listen: false);
    final accountProvider = Provider.of<AccountProvider>(context, listen: false);

    int? selectedAratdar = aratdarProvider.aratdars.isNotEmpty ? aratdarProvider.aratdars.first.id : 1;
    int? selectedAccount = accountProvider.accounts.isNotEmpty ? accountProvider.accounts.first.id : 1;
    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('আড়তদার থেকে টাকা প্রাপ্তি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: selectedAratdar,
                  decoration: const InputDecoration(labelText: 'আড়তদার সিলেক্ট করুন'),
                  items: aratdarProvider.aratdars.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                  onChanged: (val) => setDlgState(() => selectedAratdar = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedAccount,
                  decoration: const InputDecoration(labelText: 'টাকা জমা হওয়ার একাউন্ট'),
                  items: accountProvider.accounts.map((acc) => DropdownMenuItem(value: acc.id, child: Text(acc.name))).toList(),
                  onChanged: (val) => setDlgState(() => selectedAccount = val),
                ),
                const SizedBox(height: 12),
                CustomTextField(label: 'প্রাপ্ত টাকার পরিমাণ (৳) *', hint: 'যেমন: ৫০,০০০', controller: amountCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'রেফারেন্স / ব্যাংক স্লিপ নং', hint: 'যেমন: bKash TrxID বা চেক নং', controller: refCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'মন্তব্য / নোট', hint: 'যেমন: আলু চালানের বিক্রির টাকা পাঠিয়েছেন', controller: notesCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক টাকার পরিমাণ দিন')));
                  return;
                }
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await remittanceProvider.recordRemittance({
                  'aratdar_id': selectedAratdar,
                  'account_id': selectedAccount,
                  'amount': amt,
                  'payment_date': DateTime.now().toIso8601String().substring(0, 10),
                  'payment_method': 'bank_transfer',
                  'reference_number': refCtrl.text,
                  'notes': notesCtrl.text,
                });
                if (mounted && ok) {
                  messenger.showSnackBar(const SnackBar(content: Text('আড়তদারের টাকা প্রাপ্তি সফলভাবে যুক্ত হয়েছে!')));
                }
              },
              child: const Text('সংরক্ষণ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('আড়তের টাকা প্রাপ্তি (Remittance)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('টাকা জমা এন্ট্রি'),
        onPressed: _showAddRemittanceDialog,
      ),
      body: Consumer<RemittanceProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.remittances.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.remittances.isEmpty) {
            return const Center(child: Text('কোনো টাকা প্রাপ্তির রেকর্ড পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          final totalReceived = provider.remittances.fold<double>(0.0, (sum, r) => sum + r.amount);

          return RefreshIndicator(
            onRefresh: () => provider.fetchRemittances(),
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
                      const Text('মোট আড়তদার রেমিট্যান্স প্রাপ্তি', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '৳ ${totalReceived.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('প্রাপ্তির তালিকা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...provider.remittances.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentLight,
                      child: const Icon(Icons.arrow_downward, color: AppColors.primary),
                    ),
                    title: Text(r.aratdarName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('জমা: ${r.accountName} • ${r.paymentDate}'),
                    trailing: Text(
                      '+৳ ${r.amount.toStringAsFixed(0)}',
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}