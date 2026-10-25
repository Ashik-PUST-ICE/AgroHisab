import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../accounts/presentation/providers/account_provider.dart';
import '../../../aratdar/presentation/providers/aratdar_provider.dart';
import '../../../challan/presentation/providers/challan_provider.dart';
import '../../data/models/remittance_model.dart';
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
      Provider.of<ChallanProvider>(context, listen: false).fetchShipments();
    });
  }

  void _showAddRemittanceDialog() {
    final aratdarProv = Provider.of<AratdarProvider>(context, listen: false);
    final accountProv = Provider.of<AccountProvider>(context, listen: false);

    int? selectedAratdarId = aratdarProv.aratdars.isNotEmpty ? aratdarProv.aratdars.first.id : null;
    int? selectedAccountId = accountProv.accounts.isNotEmpty ? accountProv.accounts.first.id : null;

    final amountCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String method = 'bank';
    DateTime paymentDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('আড়তদার থেকে টাকা প্রাপ্তি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (aratdarProv.aratdars.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedAratdarId,
                    decoration: const InputDecoration(labelText: 'আড়তদার নির্বাচন করুন *'),
                    items: aratdarProv.aratdars.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (val) => setDlgState(() => selectedAratdarId = val),
                  ),
                const SizedBox(height: 12),
                if (accountProv.accounts.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedAccountId,
                    decoration: const InputDecoration(labelText: 'জমার অ্যাকাউন্ট *'),
                    items: accountProv.accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))).toList(),
                    onChanged: (val) => setDlgState(() => selectedAccountId = val),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳) *'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: method,
                  decoration: const InputDecoration(labelText: 'পদ্ধতি'),
                  items: const [
                    DropdownMenuItem(value: 'bank', child: Text('ব্যাংক জমা / ট্রান্সফার')),
                    DropdownMenuItem(value: 'bkash', child: Text('বিকাশ (bKash)')),
                    DropdownMenuItem(value: 'nagad', child: Text('নগদ (Nagad)')),
                    DropdownMenuItem(value: 'cash', child: Text('সরাসরি ক্যাশ')),
                  ],
                  onChanged: (val) => setDlgState(() => method = val ?? 'bank'),
                ),
                const SizedBox(height: 12),
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'টিআরএক্স / রেফারেন্স নং')),
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
                if (amt <= 0 || selectedAratdarId == null || selectedAccountId == null) return;
                Navigator.pop(ctx);

                final prov = Provider.of<RemittanceProvider>(context, listen: false);
                final ok = await prov.createRemittance({
                  'aratdar_id': selectedAratdarId,
                  'account_id': selectedAccountId,
                  'amount': amt,
                  'payment_date': DateFormat('yyyy-MM-dd').format(paymentDate),
                  'payment_method': method,
                  'reference_number': refCtrl.text.trim(),
                  'notes': notesCtrl.text.trim(),
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'আড়তদারের টাকা প্রাপ্তি এন্ট্রি সম্পন্ন হয়েছে!' : (prov.errorMessage ?? 'এন্ট্রি ব্যর্থ হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('সংরক্ষণ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllocateDialog(AratdarRemittanceModel r) {
    final challanProv = Provider.of<ChallanProvider>(context, listen: false);
    // Find shipments matching aratdar
    final shipments = challanProv.shipments.where((s) => s.aratdarId == r.aratdarId || r.aratdarId == 0).toList();

    int? selectedShipmentId = shipments.isNotEmpty ? shipments.first.id : (challanProv.shipments.isNotEmpty ? challanProv.shipments.first.id : null);
    final amountCtrl = TextEditingController(text: r.unallocatedAmount.toStringAsFixed(0));
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('চালানে টাকা বরাদ্দ (Allocate)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('রেমিট্যান্স নং: ${r.remittanceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                Text('বাকি অবরাদ্দকৃত টাকা: ৳ ${r.unallocatedAmount.toStringAsFixed(0)}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                if (challanProv.shipments.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: selectedShipmentId,
                    decoration: const InputDecoration(labelText: 'কোন চালানে বরাদ্দ করবেন? *'),
                    items: (shipments.isNotEmpty ? shipments : challanProv.shipments).map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.shipmentNumber} (${s.destinationMarket ?? "ঢাকা"})'),
                    )).toList(),
                    onChanged: (val) => setDlgState(() => selectedShipmentId = val),
                  )
                else
                  const Text('কোনো সক্রিয় চালান পাওয়া যায়নি। আগে চালান তৈরি করুন।', style: TextStyle(color: AppColors.error, fontSize: 12)),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'বরাদ্দের পরিমাণ (৳) *'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'মন্তব্য (ঐচ্ছিক)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0 || selectedShipmentId == null) return;
                if (amt > r.unallocatedAmount) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: AppColors.error, content: Text('বরাদ্দ টাকার পরিমাণ অবরাদ্দকৃত টাকার চেয়ে বেশি হতে পারে না')),
                  );
                  return;
                }
                Navigator.pop(ctx);

                final prov = Provider.of<RemittanceProvider>(context, listen: false);
                final ok = await prov.allocateRemittance(
                  r.id,
                  selectedShipmentId!,
                  amt,
                  notes: notesCtrl.text.trim(),
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'চালানে টাকা সফলভাবে বরাদ্দ হয়েছে!' : (prov.errorMessage ?? 'বরাদ্দকরণে সমস্যা হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('বরাদ্দ করুন', style: TextStyle(color: Colors.white)),
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
        title: const Text('আড়তের টাকা প্রাপ্তি ও চালান বরাদ্দ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
          final totalAllocated = provider.remittances.fold<double>(0.0, (sum, r) => sum + r.allocatedAmount);

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
                        '৳ ${totalReceived.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('চালানে বরাদ্দ: ৳ ${totalAllocated.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          Text('অবশিষ্ট: ৳ ${(totalReceived - totalAllocated).toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text('প্রাপ্তির তালিকা ও চালান বরাদ্দ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                ...provider.remittances.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
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
                          Text(r.remittanceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary)),
                          Text(
                            '+৳ ${r.amount.toStringAsFixed(0)}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('আড়তদার: ${r.aratdarName} • জমা: ${r.accountName}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
                      Text('তারিখ: ${r.paymentDate} • মাধ্যম: ${r.paymentMethod.toUpperCase()}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('বরাদ্দকৃত: ৳ ${r.allocatedAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.w600)),
                              Text('অবরাদ্দকৃত: ৳ ${r.unallocatedAmount.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: r.unallocatedAmount > 0 ? AppColors.error : Colors.grey, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          if (r.unallocatedAmount > 0)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.assignment_turned_in_outlined, size: 15, color: Colors.white),
                              label: const Text('চালানে বরাদ্দ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _showAllocateDialog(r),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                              child: const Text('সম্পূর্ণ বরাদ্দকৃত', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
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