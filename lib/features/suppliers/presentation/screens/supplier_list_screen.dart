import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/supplier_provider.dart';
import 'supplier_ledger_screen.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupplierProvider>(context, listen: false).ensureDefaultFarmer();
    });
  }

  void _showAddSupplierDialog() {
    final provider = Provider.of<SupplierProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final marketCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নতুন কৃষক যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'কৃষকের নাম *', hint: 'যেমন: রহিম মিয়া', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'মোবাইল নম্বর', hint: 'যেমন: 01712345678', controller: phoneCtrl, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              CustomTextField(label: 'মোকাম / হাট', hint: 'যেমন: শিবগঞ্জ হাট', controller: marketCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'গ্রাম / ঠিকানা', hint: 'যেমন: চণ্ডীপুর', controller: addressCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কৃষকের নাম লিখুন')));
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.createSupplier({
                'name': nameCtrl.text,
                'phone': phoneCtrl.text,
                'market': marketCtrl.text,
                'address': addressCtrl.text,
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('কৃষক সফলভাবে সংরক্ষিত হয়েছে!')));
              }
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কৃষকের খাতা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('নতুন কৃষক'),
        onPressed: _showAddSupplierDialog,
      ),
      body: Consumer<SupplierProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.suppliers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.suppliers.isEmpty) {
            return const Center(child: Text('কোনো কৃষকের রেকর্ড পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchSuppliers(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.suppliers.length,
              itemBuilder: (ctx, i) {
                final s = provider.suppliers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      provider.loadSupplierLedger(s);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SupplierLedgerScreen(supplier: s)),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.accentLight,
                            child: const Icon(Icons.person, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 14, color: Colors.grey.shade600),
                                    const SizedBox(width: 4),
                                    Text(s.phone ?? 'নম্বর নেই', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                                  ],
                                ),
                                if (s.market != null && s.market!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(s.market!, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                ],
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.accentLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text('খতিয়ান দেখুন >', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
