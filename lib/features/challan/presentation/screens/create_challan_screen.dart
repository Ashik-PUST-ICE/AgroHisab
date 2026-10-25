import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../aratdar/presentation/providers/aratdar_provider.dart';
import '../../../crops/presentation/providers/crop_provider.dart';
import '../../../procurement/presentation/providers/procurement_provider.dart';
import '../../../transporters/presentation/providers/transporter_provider.dart';
import '../../data/models/shipment_model.dart';
import '../providers/challan_provider.dart';

class CreateChallanScreen extends StatefulWidget {
  const CreateChallanScreen({super.key});

  @override
  State<CreateChallanScreen> createState() => _CreateChallanScreenState();
}

class _CreateChallanScreenState extends State<CreateChallanScreen> {
  int? _selectedAratdarId;
  int? _selectedTransporterId;
  int? _selectedProductId;
  int? _selectedPurchaseItemId;

  final _vehicleCtrl = TextEditingController(text: 'ঢাকা মেট্রো-ট ১১-২২৩৩');
  final _driverNameCtrl = TextEditingController(text: 'রহিম মিয়া');
  final _driverPhoneCtrl = TextEditingController(text: '01712-123456');
  final _weightCtrl = TextEditingController(text: '1000');
  final _bagsCtrl = TextEditingController(text: '25');
  final _freightCtrl = TextEditingController(text: '3500');
  final _notesCtrl = TextEditingController();

  String _freightPaidBy = 'owner';
  DateTime _dispatchDate = DateTime.now();

  final List<ShipmentExpenseItem> _dynamicExpenses = [
    ShipmentExpenseItem(type: 1, head: 'বস্তা ও প্যাকিং খরচ', amount: 1200, paidBy: 'owner'),
    ShipmentExpenseItem(type: 2, head: 'লোডিং কুলি খরচ', amount: 600, paidBy: 'owner'),
    ShipmentExpenseItem(type: 5, head: 'টোল ও সেতু খরচ', amount: 450, paidBy: 'owner'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AratdarProvider>(context, listen: false).fetchAratdars();
      Provider.of<TransporterProvider>(context, listen: false).fetchTransporters();
      Provider.of<CropProvider>(context, listen: false).fetchCrops();
      Provider.of<ProcurementProvider>(context, listen: false).fetchPurchases();
      Provider.of<ChallanProvider>(context, listen: false).fetchExpenseHeads();
    });
  }

  @override
  void dispose() {
    _vehicleCtrl.dispose();
    _driverNameCtrl.dispose();
    _driverPhoneCtrl.dispose();
    _weightCtrl.dispose();
    _bagsCtrl.dispose();
    _freightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _addExpenseDialog() {
    final challanProvider = Provider.of<ChallanProvider>(context, listen: false);
    final heads = challanProvider.expenseHeads;
    int selectedType = heads.isNotEmpty ? heads.first.id : 1;
    final amountCtrl = TextEditingController();
    String paidBy = heads.isNotEmpty ? heads.first.defaultPaidBy : 'owner';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('চালানে খরচ যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<int>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'খরচের খাত সিলেক্ট করুন'),
                items: heads.map((h) => DropdownMenuItem(value: h.id, child: Text(h.name, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDlgState(() {
                      selectedType = val;
                      final h = heads.firstWhere((e) => e.id == val, orElse: () => heads.first);
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
                  DropdownMenuItem(value: 'shared', child: Text('যৌথ (Shared)')),
                ],
                onChanged: (val) => setDlgState(() => paidBy = val ?? 'owner'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (amt <= 0) return;
                final h = heads.firstWhere((e) => e.id == selectedType, orElse: () => heads.first);
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
              child: const Text('যোগ করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _submitChallan() async {
    final aratdarProvider = Provider.of<AratdarProvider>(context, listen: false);
    final cropProvider = Provider.of<CropProvider>(context, listen: false);

    int aratdarId = _selectedAratdarId ?? (aratdarProvider.aratdars.isNotEmpty ? aratdarProvider.aratdars.first.id : 1);
    int productId = _selectedProductId ?? (cropProvider.crops.isNotEmpty ? cropProvider.crops.first.id : 1);

    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final bags = int.tryParse(_bagsCtrl.text) ?? 0;
    final freight = double.tryParse(_freightCtrl.text) ?? 0;

    if (weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.error, content: Text('দয়া করে সঠিক চালান ওজন লিখুন')),
      );
      return;
    }

    final body = {
      'aratdar_id': aratdarId,
      if (_selectedTransporterId != null) 'transporter_id': _selectedTransporterId,
      'dispatch_date': DateFormat('yyyy-MM-dd').format(_dispatchDate),
      'vehicle_number': _vehicleCtrl.text.trim(),
      'freight_amount': freight,
      'freight_paid_by': _freightPaidBy,
      'items': [
        {
          if (_selectedPurchaseItemId != null) 'purchase_item_id': _selectedPurchaseItemId,
          'product_id': productId,
          'bag_count': bags,
          'dispatched_weight': weight,
        }
      ],
      'expenses': _dynamicExpenses.map((e) => e.toJson()).toList(),
      if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

    final challanProvider = Provider.of<ChallanProvider>(context, listen: false);
    final success = await challanProvider.createShipment(body);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: AppColors.success, content: Text('নতুন চালান সফলভাবে তৈরি ও সংরক্ষিত হয়েছে!')),
        );
        _notesCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: AppColors.error, content: Text(challanProvider.errorMessage ?? 'চালান তৈরিতে ত্রুটি হয়েছে')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final challanProvider = Provider.of<ChallanProvider>(context);
    final aratdarProvider = Provider.of<AratdarProvider>(context);
    final transporterProvider = Provider.of<TransporterProvider>(context);
    final cropProvider = Provider.of<CropProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section 1: Aratdar & Destination
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
                const Row(
                  children: [
                    Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('প্রাপক আড়তদার ও মোকাম', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                if (aratdarProvider.aratdars.isEmpty)
                  TextFormField(
                    initialValue: 'মেসার্স ভাই ভাই এন্টারপ্রাইজ (কাওরান বাজার)',
                    decoration: const InputDecoration(labelText: 'আড়তদারের নাম (ডিফল্ট)'),
                    enabled: false,
                  )
                else
                  DropdownButtonFormField<int>(
                    value: _selectedAratdarId ?? aratdarProvider.aratdars.first.id,
                    decoration: const InputDecoration(labelText: 'আড়তদার নির্বাচন করুন *'),
                    items: aratdarProvider.aratdars.map((a) => DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.name} (${a.market ?? a.district ?? "মোকাম"})'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedAratdarId = val),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _dispatchDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) setState(() => _dispatchDate = picked);
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'চালানের তারিখ'),
                          child: Text(DateFormat('dd MMM yyyy').format(_dispatchDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 2: Product & Quantity
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
                const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('চালানের পণ্যের বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                if (cropProvider.crops.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: _selectedProductId ?? cropProvider.crops.first.id,
                    decoration: const InputDecoration(labelText: 'কৃষিপণ্য নির্বাচন করুন *'),
                    items: cropProvider.crops.map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.name} ${c.variety != null ? "(${c.variety})" : ""}'),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedProductId = val),
                  )
                else
                  TextFormField(
                    initialValue: 'আলু (ডায়মন্ড জাত)',
                    decoration: const InputDecoration(labelText: 'পণ্য (ডিফল্ট)'),
                    enabled: false,
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'বস্তার সংখ্যা', controller: _bagsCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'মোট ওজন (কেজি) *', controller: _weightCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: Transport & Freight
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
                const Row(
                  children: [
                    Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 8),
                    Text('গাড়ি ও পরিবহন বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                if (transporterProvider.transporters.isNotEmpty)
                  DropdownButtonFormField<int>(
                    value: _selectedTransporterId,
                    decoration: const InputDecoration(labelText: 'ট্রান্সপোর্টার সিলেক্ট করুন (ঐচ্ছিক)'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('সরাসরি ট্রাক নম্বর লিখুন')),
                      ...transporterProvider.transporters.map((t) => DropdownMenuItem(
                        value: t.id,
                        child: Text('${t.name} (${t.truckNumber ?? ""})'),
                      )),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedTransporterId = val;
                        if (val != null) {
                          final t = transporterProvider.transporters.firstWhere((e) => e.id == val);
                          if (t.truckNumber != null) _vehicleCtrl.text = t.truckNumber!;
                          if (t.driverName != null) _driverNameCtrl.text = t.driverName!;
                          if (t.driverPhone != null) _driverPhoneCtrl.text = t.driverPhone!;
                        }
                      });
                    },
                  ),
                const SizedBox(height: 12),
                CustomTextField(label: 'ট্রাক / পিকআপ নম্বর', controller: _vehicleCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'চালক নাম', controller: _driverNameCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'মোবাইল', controller: _driverPhoneCtrl, keyboardType: TextInputType.phone)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'গাড়ি ভাড়া (৳)', controller: _freightCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _freightPaidBy,
                        decoration: const InputDecoration(labelText: 'ভাড়া পরিশোধ'),
                        items: const [
                          DropdownMenuItem(value: 'owner', child: Text('মালিক (নগদ)')),
                          DropdownMenuItem(value: 'aratdar', child: Text('আড়তদার দেবে')),
                        ],
                        onChanged: (val) => setState(() => _freightPaidBy = val ?? 'owner'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section 4: Dynamic Expenses
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
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('খরচ যোগ (+)', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: _addExpenseDialog,
                    ),
                  ],
                ),
                const Divider(),
                if (_dynamicExpenses.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('কোনো আনুষঙ্গিক খরচ যোগ করা হয়নি', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
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
          const SizedBox(height: 16),

          CustomTextField(label: 'বিশেষ দ্রষ্টব্য / মন্তব্য (ঐচ্ছিক)', controller: _notesCtrl),
          const SizedBox(height: 22),

          CustomButton(
            text: 'চালান তৈরি ও সংরক্ষণ করুন',
            icon: Icons.check_circle_rounded,
            isLoading: challanProvider.isActionLoading,
            onPressed: _submitChallan,
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}