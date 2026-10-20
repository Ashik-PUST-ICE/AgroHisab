import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/shipment_model.dart';
import '../providers/challan_provider.dart';

class CreateChallanScreen extends StatefulWidget {
  const CreateChallanScreen({super.key});

  @override
  State<CreateChallanScreen> createState() => _CreateChallanScreenState();
}

class _CreateChallanScreenState extends State<CreateChallanScreen> {
  final _vehicleCtrl = TextEditingController(text: 'ঢাকা মেট্রো-ট ১১-২২৩৩');
  final _driverNameCtrl = TextEditingController(text: 'রহিম মিয়া');
  final _driverPhoneCtrl = TextEditingController(text: '01712-123456');
  final _weightCtrl = TextEditingController(text: '1000');
  final _freightCtrl = TextEditingController(text: '4000');
  final _notesCtrl = TextEditingController();

  final List<ShipmentExpenseItem> _dynamicExpenses = [
    ShipmentExpenseItem(type: 1, head: 'বস্তা ও প্যাকিং খরচ', amount: 1500, paidBy: 'owner'),
    ShipmentExpenseItem(type: 2, head: 'লোডিং কুলি খরচ', amount: 800, paidBy: 'owner'),
    ShipmentExpenseItem(type: 5, head: 'টোল ও সেতু খরচ', amount: 600, paidBy: 'owner'),
  ];

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _weightCtrl.dispose();
    _freightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addExpenseDialog() {
    final challanProvider = Provider.of<ChallanProvider>(context, listen: false);
    final heads = challanProvider.expenseHeads;
    int selectedType = heads.isNotEmpty ? heads.first.id : 1;
    final amountCtrl = TextEditingController();
    String paidBy = 'owner';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('নতুন খরচ যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'খরচের খাত সিলেক্ট করুন'),
                items: heads.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDlgState(() {
                      selectedType = val;
                      final h = heads.firstWhere((e) => e.id == val);
                      paidBy = h.defaultPaidBy;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: paidBy,
                decoration: const InputDecoration(labelText: 'কে বহন করবে?'),
                items: const [
                  DropdownMenuItem(value: 'owner', child: Text('মালিক (Owner)')),
                  DropdownMenuItem(value: 'aratdar', child: Text('আড়তদার (Aratdar বিক্রি থেকে কাটবে)')),
                ],
                onChanged: (val) => setDlgState(() => paidBy = val ?? 'owner'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0) return;
                final h = heads.firstWhere((e) => e.id == selectedType);
                setState(() {
                  _dynamicExpenses.add(ShipmentExpenseItem(
                    type: selectedType,
                    head: h.name,
                    amount: amt,
                    paidBy: paidBy,
                  ));
                });
                Navigator.pop(ctx);
              },
              child: const Text('যোগ করুন'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitChallan() async {
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final freight = double.tryParse(_freightCtrl.text) ?? 0;

    final body = {
      'aratdar_id': 1,
      'vehicle_number': _vehicleCtrl.text,
      'freight_amount': freight,
      'freight_paid_by': 'owner',
      'items': [
        {
          'purchase_item_id': 1,
          'bag_count': 50,
          'dispatched_weight': weight,
        }
      ],
      'expenses': _dynamicExpenses.map((e) => e.toJson()).toList(),
      'notes': _notesCtrl.text,
    };

    final provider = Provider.of<ChallanProvider>(context, listen: false);
    final success = await provider.createShipment(body);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.success, content: Text('নতুন চালান সফলভাবে তৈরি হয়েছে!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text(provider.errorMessage ?? 'চালান তৈরিতে সমস্যা হয়েছে')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallanProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('গাড়ির তথ্য ও পরিবহন বিবরণী', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                const SizedBox(height: 12),
                CustomTextField(label: 'ট্রাক / পিকআপ নম্বর', controller: _vehicleCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'চালকের নাম', controller: _driverNameCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'মোবাইল', controller: _driverPhoneCtrl, keyboardType: TextInputType.phone)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'পাঠানো ওজন (কেজি)', controller: _weightCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'গাড়ি ভাড়া (৳)', controller: _freightCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Dynamic Expenses (Add More system)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('চালানের আনুষঙ্গিক খরচসমূহ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('খরচ যোগ (+)', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _addExpenseDialog,
                    ),
                  ],
                ),
                const Divider(),
                if (_dynamicExpenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('কোনো খরচ যোগ করা হয়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  )
                else
                  ..._dynamicExpenses.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final exp = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${exp.head} (${exp.paidBy == "owner" ? "মালিক" : "আড়তদার"})',
                              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                            ),
                          ),
                          Text('৳ ${exp.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 18),
                            onPressed: () => setState(() => _dynamicExpenses.removeAt(idx)),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 22),

          CustomButton(
            text: 'চালান তৈরি ও সংরক্ষণ করুন',
            icon: Icons.check_circle_rounded,
            isLoading: provider.isLoading,
            onPressed: _submitChallan,
          ),
        ],
      ),
    );
  }
}