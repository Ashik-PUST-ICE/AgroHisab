import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/expense_provider.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseProvider>(context, listen: false).fetchExpenses();
    });
  }

  void _openCreateExpenseDialog() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int? selectedCategory = provider.categories.isNotEmpty ? provider.categories.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('নতুন খরচ যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (provider.categories.isNotEmpty) ...[
                  DropdownButtonFormField<int>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'খরচের খাত / ক্যাটাগরি'),
                    items: provider.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                    onChanged: (val) => setDlgState(() => selectedCategory = val),
                  ),
                  const SizedBox(height: 12),
                ],
                CustomTextField(label: 'খরচের শিরোনাম *', hint: 'যেমন: ট্রাক লোডিং লেবার', controller: titleCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'পরিমাণ (৳) *', hint: 'যেমন: ১৫০০', controller: amountCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'মন্তব্য', hint: 'অতিরিক্ত বিবরণ', controller: notesCtrl),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0 || titleCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সঠিক শিরোনাম ও টাকার পরিমাণ লিখুন')));
                  return;
                }
                Navigator.pop(ctx);
                final messenger = ScaffoldMessenger.of(context);
                final ok = await provider.createExpense({
                  'title': titleCtrl.text,
                  'amount': amt,
                  'expense_category_id': selectedCategory,
                  'expense_date': DateTime.now().toIso8601String().substring(0, 10),
                  'paid_by': 'owner',
                  'notes': notesCtrl.text,
                });
                if (mounted && ok) {
                  messenger.showSnackBar(const SnackBar(content: Text('খরচ সফলভাবে এন্ট্রি হয়েছে!')));
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
        title: const Text('ব্যবসায়িক খরচ ব্যবস্থাপনা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('খরচ যুক্ত করুন'),
        onPressed: _openCreateExpenseDialog,
      ),
      body: Consumer<ExpenseProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.expenses.isEmpty) {
            return const Center(child: Text('কোনো খরচের রেকর্ড পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          final totalExpense = provider.expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

          return RefreshIndicator(
            onRefresh: () => provider.fetchExpenses(),
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
                      const Text('মোট নথিভুক্ত খরচ', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        '৳ ${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('খরচের তালিকা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...provider.expenses.map((e) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.shade50,
                      child: Icon(Icons.receipt, color: Colors.red.shade700),
                    ),
                    title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${e.categoryName ?? "সাধারণ খরচ"} • ${e.expenseDate}'),
                    trailing: Text(
                      '৳ ${e.amount.toStringAsFixed(0)}',
                      style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 16),
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