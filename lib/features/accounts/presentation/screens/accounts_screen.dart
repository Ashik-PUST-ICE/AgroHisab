import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/account_provider.dart';
import 'account_ledger_screen.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchAccounts();
    });
  }

  void _showTransferDialog() {
    final provider = Provider.of<AccountProvider>(context, listen: false);
    if (provider.accounts.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অর্থ স্থানান্তরের জন্য কমপক্ষে দুটি একাউন্ট প্রয়োজন।')),
      );
      return;
    }

    int fromId = provider.accounts.first.id;
    int toId = provider.accounts[1].id;
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('অর্থ স্থানান্তর (Fund Transfer)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  value: fromId,
                  decoration: const InputDecoration(labelText: 'উৎস একাউন্ট (যেখান থেকে কাটবে)'),
                  items: provider.accounts.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => fromId = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: toId,
                  decoration: const InputDecoration(labelText: 'গন্তব্য একাউন্ট (যেখানে জমা হবে)'),
                  items: provider.accounts.map((a) => DropdownMenuItem(
                    value: a.id,
                    child: Text('${a.name} (৳${a.currentBalance.toStringAsFixed(0)})', style: const TextStyle(fontSize: 13)),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setDlgState(() => toId = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', hintText: 'যেমন: ৫০০০'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'বিবরণ / কারণ', hintText: 'যেমন: ব্যাংক থেকে ক্যাশ তোলা'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0 || fromId == toId) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('সঠিক পরিমাণ ও ভিন্ন একাউন্ট নির্বাচন করুন।')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await provider.transferFunds(
                  fromAccountId: fromId,
                  toAccountId: toId,
                  amount: amt,
                  notes: notesCtrl.text,
                );
                if (mounted && ok) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('অর্থ স্থানান্তর সফল হয়েছে!')),
                  );
                }
              },
              child: const Text('স্থানান্তর করুন'),
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
        title: const Text('ক্যাশ ও ব্যাংক খাতা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_alt),
            tooltip: 'টাকা স্থানান্তর',
            onPressed: _showTransferDialog,
          ),
        ],
      ),
      body: Consumer<AccountProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.accounts.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final totalBalance = provider.accounts.fold<double>(0.0, (sum, a) => sum + a.currentBalance);

          return RefreshIndicator(
            onRefresh: () => provider.fetchAccounts(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Total Cash & Bank Card
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
                      const Text('মোট কার্যকরী নগদ ও ব্যাংক উদ্বৃত্ত', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '৳ ${totalBalance.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.swap_horiz, size: 18),
                            label: const Text('অর্থ স্থানান্তর'),
                            onPressed: _showTransferDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('হাতে নগদ ও ব্যাংক একাউন্টসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                ...provider.accounts.map((acc) {
                  final isCash = acc.type == 'cash';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        provider.selectAccountAndLoadLedger(acc);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AccountLedgerScreen(account: acc)),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isCash ? AppColors.accentLight : Colors.blue.shade50,
                              child: Icon(
                                isCash ? Icons.account_balance_wallet : Icons.account_balance,
                                color: isCash ? AppColors.primary : Colors.blue.shade800,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      if (acc.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.accentLight,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text('প্রধান', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    acc.bankName ?? acc.typeLabel,
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '৳ ${acc.currentBalance.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('খতিয়ান', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                    const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}