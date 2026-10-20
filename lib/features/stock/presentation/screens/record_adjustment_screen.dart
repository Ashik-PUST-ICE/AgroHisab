import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/stock_provider.dart';

class RecordAdjustmentScreen extends StatefulWidget {
  const RecordAdjustmentScreen({super.key});

  @override
  State<RecordAdjustmentScreen> createState() => _RecordAdjustmentScreenState();
}

class _RecordAdjustmentScreenState extends State<RecordAdjustmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  String _selectedReason = 'spoilage';
  final _kgController = TextEditingController();
  final _bagController = TextEditingController();
  final _remarksController = TextEditingController();

  final List<Map<String, String>> _reasons = [
    {'value': 'spoilage', 'label': 'পচন / নষ্ট মাল'},
    {'value': 'shrinkage', 'label': 'শুকিয়ে ওজন হ্রাস (শুকতি)'},
    {'value': 'sorting_waste', 'label': 'বাছাই ঘাটতি'},
    {'value': 'damage', 'label': 'পরিবহন / লোডিং ড্যামেজ'},
    {'value': 'theft_shortage', 'label': 'অন্যান্য ঘাটতি'},
  ];

  @override
  void dispose() {
    _kgController.dispose();
    _bagController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<StockProvider>(context, listen: false);

    final body = {
      'product_id': _selectedProductId ?? 1,
      'reason': _selectedReason,
      'quantity_kg': double.parse(_kgController.text),
      'bag_count': int.tryParse(_bagController.text) ?? 0,
      'remarks': _remarksController.text.trim(),
    };

    final ok = await provider.recordAdjustment(body);
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ঘাটতি ও সমন্বয় সফলভাবে সংরক্ষিত হয়েছে!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সংরক্ষণে সমস্যা হয়েছে, পুনরায় চেষ্টা করুন।')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stockProvider = Provider.of<StockProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('পচন ও ঘাটতি এন্ট্রি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.red.shade700),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'কাঁচামাল কখনো ফেরত হয় না। পচন, শুকিয়ে ওজন হ্রাস ও বাছাই ঘাটতি এখান থেকে সমন্বয় করলে স্বয়ংক্রিয়ভাবে স্টক হ্রাস পাবে।',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('ফসল নির্বাচন করুন', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _selectedProductId ?? (stockProvider.balances.isNotEmpty ? stockProvider.balances.first.productId : 1),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: stockProvider.balances.map((b) => DropdownMenuItem(
                  value: b.productId,
                  child: Text('${b.productName} (মজুদ: ${b.currentStockKg} কেজি)'),
                )).toList(),
                onChanged: (val) => setState(() => _selectedProductId = val),
              ),
              const SizedBox(height: 16),
              const Text('ঘাটতি / সমন্বয়ের কারণ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _reasons.map((r) => DropdownMenuItem(
                  value: r['value']!,
                  child: Text(r['label']!),
                )).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedReason = val);
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'ঘাটতি / নষ্ট পরিমাণ (কেজি) *',
                hint: 'যেমন: ১৫.৫',
                controller: _kgController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'কেজি লিখুন';
                  if (double.tryParse(v) == null) return 'সঠিক সংখ্যা দিন';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'নষ্ট বস্তার সংখ্যা (ঐচ্ছিক)',
                hint: 'যেমন: ১',
                controller: _bagController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'মন্তব্য / বিবরণ',
                hint: 'যেমন: বস্তার নিচের আলু পচে নষ্ট হয়েছে',
                controller: _remarksController,
                
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'সমন্বয় সংরক্ষণ করুন',
                isLoading: stockProvider.isLoading,
                onPressed: stockProvider.isLoading ? null : _handleSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}