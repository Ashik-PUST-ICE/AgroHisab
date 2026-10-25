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
  final List<int> _selectedPurchaseItemIds = [];

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
      Provider.of<ChallanProvider>(context, listen: false).fetchDispatchPurchaseItems();
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
    final heads = context.read<ChallanProvider>().expenseHeads;
    if (heads.isEmpty) return;
    int selectedType = heads.first.id;
    String paidBy = heads.first.defaultPaidBy;
    final amountCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedHead = heads.firstWhere((head) => head.id == selectedType, orElse: () => heads.first);
          return SafeArea(
            child: Container(
              height: MediaQuery.of(context).size.height * .72,
              padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 16),
              decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
                const SizedBox(height: 16),
                Row(children: [
                  const Expanded(child: Text('খরচ যোগ করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
                  IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close)),
                ]),
                const Text('চালানের এই খরচটি সঠিক খাত ও বহনকারী অনুযায়ী দিন', style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 20),
                const Text('খরচের খাত', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Expanded(child: ListView.separated(
                  itemCount: heads.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (_, index) {
                    final head = heads[index];
                    final selected = head.id == selectedType;
                    return InkWell(
                      onTap: () => setSheetState(() { selectedType = head.id; paidBy = head.defaultPaidBy; }),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(color: selected ? AppColors.accentLight : AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primary : AppColors.border)),
                        child: Row(children: [Expanded(child: Text(head.name, maxLines: 2, overflow: TextOverflow.ellipsis)), Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? AppColors.primary : AppColors.textSecondary)]),
                      ),
                    );
                  },
                )),
                const SizedBox(height: 12),
                TextField(controller: amountCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'টাকার পরিমাণ (৳)', prefixIcon: Icon(Icons.payments_outlined))),
                const SizedBox(height: 12),
                Row(children: [
                  const Text('কে বহন করবে?', style: TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  ChoiceChip(label: const Text('মালিক'), selected: paidBy == 'owner', onSelected: (_) => setSheetState(() => paidBy = 'owner')),
                  const SizedBox(width: 6),
                  ChoiceChip(label: const Text('আড়তদার'), selected: paidBy == 'aratdar', onSelected: (_) => setSheetState(() => paidBy = 'aratdar')),
                ]),
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: const Icon(Icons.add), label: const Text('খরচ যোগ করুন'),
                  onPressed: () {
                    final amount = double.tryParse(amountCtrl.text) ?? 0;
                    if (amount <= 0) return;
                    setState(() => _dynamicExpenses.add(ShipmentExpenseItem(type: selectedType, head: selectedHead.name, amount: amount, paidBy: paidBy)));
                    Navigator.pop(sheetContext);
                  },
                )),
              ]),
            ),
          );
        },
      ),
    ).whenComplete(amountCtrl.dispose);
  }

  void _submitChallan() async {
    final aratdarProvider = Provider.of<AratdarProvider>(context, listen: false);
    final cropProvider = Provider.of<CropProvider>(context, listen: false);
    final challanProvider = Provider.of<ChallanProvider>(context, listen: false);

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
    final selectedItems = challanProvider.dispatchPurchaseItems.where((item) => _selectedPurchaseItemIds.contains(item.id)).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: AppColors.error, content: Text('কমপক্ষে একটি ক্রয়কৃত পণ্য নির্বাচন করুন')));
      return;
    }

    final body = {
      'aratdar_id': aratdarId,
      if (_selectedTransporterId != null) 'transporter_id': _selectedTransporterId,
      'dispatch_date': DateFormat('yyyy-MM-dd').format(_dispatchDate),
      'vehicle_number': _vehicleCtrl.text.trim(),
      'freight_amount': freight,
      'freight_paid_by': _freightPaidBy,
      'items': selectedItems.map((item) => {
        'purchase_item_id': item.id,
        'bag_count': item.bagCount,
        'dispatched_weight': item.availableWeight,
      }).toList(),
      'expenses': _dynamicExpenses.map((e) => e.toJson()).toList(),
      if (_notesCtrl.text.isNotEmpty) 'notes': _notesCtrl.text.trim(),
    };

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
  Future<int?> _openFullPagePicker(String title, List<MapEntry<int, String>> options, {int? selectedId}) async {
    return showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height * .72,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)))),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
              IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 8),
            Expanded(child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final selected = options[index].key == selectedId;
                return InkWell(
                onTap: () => Navigator.pop(sheetContext, options[index].key),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(color: selected ? AppColors.accentLight : AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: selected ? AppColors.primary : AppColors.border)),
                  child: Row(children: [Expanded(child: Text(options[index].value, maxLines: 2, overflow: TextOverflow.ellipsis)), Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked, color: selected ? AppColors.primary : AppColors.textSecondary)]),
                ),
              );
              },
            )),
          ]),
        ),
      ),
    );
  }

  Future<List<int>?> _openMultiPicker(String title, List<DispatchPurchaseItemModel> items) async {
    final selected = {..._selectedPurchaseItemIds};
    return showModalBottomSheet<List<int>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(builder: (context, setSheetState) => SafeArea(child: Container(
        height: MediaQuery.of(context).size.height * .72,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close))]),
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 19), const SizedBox(width: 8), Text('এই চালানের তারিখ: ${DateFormat('dd MMMM yyyy').format(_dispatchDate)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))])),
          const SizedBox(height: 12),
          Expanded(child: ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, index) {
              final item = items[index];
              final checked = selected.contains(item.id);
              return InkWell(
                onTap: () => setSheetState(() => checked ? selected.remove(item.id) : selected.add(item.id)),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: checked ? AppColors.accentLight : AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: checked ? AppColors.primary : AppColors.border)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), const SizedBox(height: 4), Text('ক্রয় নং: ${item.purchaseNumber}', style: const TextStyle(fontSize: 12)), Text('কৃষক: ${item.supplierName}', style: const TextStyle(fontSize: 12)), const SizedBox(height: 6), Row(children: [const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary), const SizedBox(width: 4), Text('ক্রয়ের তারিখ: ${_displayDate(item.purchaseDate)}', style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)), const Spacer(), Text('${item.availableWeight.toStringAsFixed(2)} ${item.unitName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))])])), const SizedBox(width: 10), Icon(checked ? Icons.check_circle : Icons.radio_button_unchecked, color: checked ? AppColors.primary : AppColors.textSecondary)]),
                ),
              );
            },
          )),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(sheetContext, selected.toList()), child: Text('${selected.length}টি পণ্য নির্বাচন করুন'))),
        ]),
      ))),
    );
  }

  String _displayDate(String raw) {
    final date = DateTime.tryParse(raw);
    return date == null ? (raw.isEmpty ? 'তারিখ নেই' : raw) : DateFormat('dd MMM yyyy').format(date);
  }

  Widget _pickerField({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 7),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
            const SizedBox(height: 3),
            Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ])),
          const Icon(Icons.expand_more_rounded, color: AppColors.textSecondary, size: 19),
        ]),
      ),
    );
  }

  Widget build(BuildContext context) {
    final challanProvider = Provider.of<ChallanProvider>(context);
    final aratdarProvider = Provider.of<AratdarProvider>(context);
    final transporterProvider = Provider.of<TransporterProvider>(context);
    final cropProvider = Provider.of<CropProvider>(context);
    final dispatchDate = DateFormat('yyyy-MM-dd').format(_dispatchDate);
    final dispatchItems = challanProvider.dispatchPurchaseItems.where((item) => item.purchaseDate.isEmpty || item.purchaseDate.length < 10 || item.purchaseDate.substring(0, 10) == dispatchDate).toList();

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
                  _pickerField(
                    label: 'আড়তদার নির্বাচন করুন *',
                    value: _selectedAratdarId == null
                        ? 'নির্বাচন করুন'
                        : aratdarProvider.aratdars.firstWhere((a) => a.id == _selectedAratdarId).name,
                    onTap: () async {
                      final id = await _openFullPagePicker('আড়তদার নির্বাচন করুন', aratdarProvider.aratdars.map((a) => MapEntry(a.id, a.name)).toList(), selectedId: _selectedAratdarId);
                      if (id != null && mounted) setState(() => _selectedAratdarId = id);
                    },
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
                if (dispatchItems.isNotEmpty)
                  _pickerField(
                    label: 'চালানের পণ্য নির্বাচন করুন *',
                    value: _selectedPurchaseItemIds.isEmpty ? 'পণ্য নির্বাচন করুন' : '${_selectedPurchaseItemIds.length}টি পণ্য নির্বাচিত',
                    onTap: () async {
                      final ids = await _openMultiPicker('চালানের পণ্য নির্বাচন করুন', dispatchItems);
                      if (ids != null && mounted) setState(() { _selectedPurchaseItemIds..clear()..addAll(ids); });
                    },
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
                  _pickerField(
                    label: 'ট্রান্সপোর্টার নির্বাচন করুন (ঐচ্ছিক)',
                    value: _selectedTransporterId == null ? 'নির্বাচন করুন' : transporterProvider.transporters.firstWhere((t) => t.id == _selectedTransporterId).name,
                    onTap: () async {
                      final id = await _openFullPagePicker('ট্রান্সপোর্টার নির্বাচন করুন', transporterProvider.transporters.map((t) => MapEntry(t.id, '${t.name} (${t.truckNumber ?? ''})')).toList(), selectedId: _selectedTransporterId);
                      if (id == null || !mounted) return;
                      final t = transporterProvider.transporters.firstWhere((item) => item.id == id);
                      setState(() {
                        _selectedTransporterId = id;
                        if (t.truckNumber != null) _vehicleCtrl.text = t.truckNumber!;
                        if (t.driverName != null) _driverNameCtrl.text = t.driverName!;
                        if (t.driverPhone != null) _driverPhoneCtrl.text = t.driverPhone!;
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
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        dropdownColor: Colors.white,
                        menuMaxHeight: 220,
                        borderRadius: BorderRadius.circular(14),
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
