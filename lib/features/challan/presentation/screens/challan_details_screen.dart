import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../settlement/presentation/screens/settlement_screen.dart';
import '../../data/models/shipment_model.dart';
import '../providers/challan_provider.dart';
import 'challan_view_screen.dart';

class ChallanDetailsScreen extends StatefulWidget {
  final ShipmentModel shipment;

  const ChallanDetailsScreen({super.key, required this.shipment});

  @override
  State<ChallanDetailsScreen> createState() => _ChallanDetailsScreenState();
}

class _ChallanDetailsScreenState extends State<ChallanDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallanProvider>(context, listen: false).fetchShipmentDetails(widget.shipment.id);
    });
  }

  void _showDispatchDialog(ShipmentModel s) {
    final vehicleCtrl = TextEditingController(text: s.vehicleNumber);
    final notesCtrl = TextEditingController();
    DateTime dispatchDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('ট্রাকে মাল রওনা করান (Dispatch)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('মাল ট্রাকে লোড করে রওনা করিয়ে দিলে স্ট্যাটাস "Dispatched" হবে এবং ওয়্যারহাউস স্টক কর্তন হবে।', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: dispatchDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setDlgState(() => dispatchDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'রওয়ানা তারিখ'),
                  child: Text(DateFormat('dd MMM yyyy').format(dispatchDate)),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(label: 'গাড়ির নম্বর', controller: vehicleCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'মন্তব্য (ঐচ্ছিক)', controller: notesCtrl),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final prov = Provider.of<ChallanProvider>(context, listen: false);
                final ok = await prov.dispatchShipment(
                  s.id,
                  dispatchDate: DateFormat('yyyy-MM-dd').format(dispatchDate),
                  vehicleNumber: vehicleCtrl.text.trim(),
                  notes: notesCtrl.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'মাল সফলভাবে প্রেরিত হয়েছে (In-Transit)!' : (prov.errorMessage ?? 'রওয়ানা করাতে ত্রুটি হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('কনফার্ম রওনা', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiveDialog(ShipmentModel s) {
    if (s.items.isEmpty) return;
    final firstItem = s.items.first;
    final weightCtrl = TextEditingController(text: firstItem.dispatchedWeight.toString());
    final reasonCtrl = TextEditingController();
    DateTime recDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('আড়তে মাল গ্রহণ (Goods Receipt)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('প্রেরিত ওজন: ${firstItem.dispatchedWeight} কেজি', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: recDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setDlgState(() => recDate = picked);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'আড়তে পৌঁছার তারিখ'),
                  child: Text(DateFormat('dd MMM yyyy').format(recDate)),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(label: 'আড়তে পাওয়া মোট ওজন (কেজি) *', controller: weightCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              CustomTextField(label: 'ওজন কম / ঘাটতির কারণ (যদি থাকে)', controller: reasonCtrl),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final recWeight = double.tryParse(weightCtrl.text) ?? 0;
                if (recWeight <= 0) return;
                Navigator.pop(ctx);

                final prov = Provider.of<ChallanProvider>(context, listen: false);
                final ok = await prov.receiveShipment(
                  s.id,
                  receivedDate: DateFormat('yyyy-MM-dd').format(recDate),
                  items: [
                    {
                      'shipment_item_id': firstItem.id,
                      'received_weight': recWeight,
                      if (reasonCtrl.text.isNotEmpty) 'shortage_reason': reasonCtrl.text.trim(),
                    }
                  ],
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'আড়তে মাল গ্রহণ ও ওজন রেকর্ড হয়েছে!' : (prov.errorMessage ?? 'গ্রহণে সমস্যা হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('গ্রহণ রেকর্ড করুন', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecordSaleDialog(ShipmentModel s) {
    if (s.items.isEmpty) return;
    final firstItem = s.items.first;

    final qtyCtrl = TextEditingController(text: '200');
    final rateCtrl = TextEditingController(text: '35');
    final commRateCtrl = TextEditingController(text: '5.0');
    final buyerCtrl = TextEditingController(text: 'কাসেম ব্যাপারি');
    final buyerPhoneCtrl = TextEditingController();
    DateTime saleDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('দৈনিক আড়ত বিক্রি রেকর্ড', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: saleDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setDlgState(() => saleDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'বিক্রির তারিখ'),
                    child: Text(DateFormat('dd MMM yyyy').format(saleDate)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: CustomTextField(label: 'বিক্রি ওজন (কেজি) *', controller: qtyCtrl, keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: CustomTextField(label: 'দর/রেট (৳/কেজি) *', controller: rateCtrl, keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 12),
                CustomTextField(label: 'আড়ত কমিশন (%)', controller: commRateCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                CustomTextField(label: 'ক্রেতা / ব্যাপারীর নাম', controller: buyerCtrl),
                const SizedBox(height: 12),
                CustomTextField(label: 'মোবাইল (ঐচ্ছিক)', controller: buyerPhoneCtrl, keyboardType: TextInputType.phone),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                final qty = double.tryParse(qtyCtrl.text) ?? 0;
                final rate = double.tryParse(rateCtrl.text) ?? 0;
                final comm = double.tryParse(commRateCtrl.text) ?? 5.0;
                if (qty <= 0 || rate <= 0) return;
                Navigator.pop(ctx);

                final prov = Provider.of<ChallanProvider>(context, listen: false);
                final ok = await prov.recordSale(s.id, {
                  'shipment_item_id': firstItem.id,
                  'product_id': firstItem.productId,
                  'sale_date': DateFormat('yyyy-MM-dd').format(saleDate),
                  'quantity': qty,
                  'unit_rate': rate,
                  'commission_type': 1,
                  'commission_rate': comm,
                  'buyer_name': buyerCtrl.text.trim(),
                  if (buyerPhoneCtrl.text.isNotEmpty) 'buyer_phone': buyerPhoneCtrl.text.trim(),
                });

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: ok ? AppColors.success : AppColors.error,
                      content: Text(ok ? 'আড়ত বিক্রি সফলভাবে রেকর্ড হয়েছে!' : (prov.errorMessage ?? 'বিক্রি রেকর্ডে ত্রুটি হয়েছে')),
                    ),
                  );
                }
              },
              child: const Text('বিক্রি সংরক্ষণ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallanProvider>(context);
    final shipment = provider.selectedShipment ?? widget.shipment;
    final sales = provider.shipmentSales;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('চালান বিবরণ - ${shipment.shipmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined),
            tooltip: 'চালান প্রিন্ট ভিউ',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChallanViewScreen(shipment: shipment)),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
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
                      Text(shipment.shipmentNumber, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(6)),
                        child: Text(shipment.statusLabel, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('আড়তদার: ${shipment.aratdarName} (${shipment.destinationMarket})', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('তারিখ: ${shipment.dispatchDate} • গাড়ি: ${shipment.vehicleNumber ?? "ট্রাক"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  if (shipment.notes != null && shipment.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('মন্তব্য: ${shipment.notes}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Lifecycle Action Buttons
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('চালান লাইফসাইকেল অ্যাকশন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Action 1: Dispatch
                      if (shipment.status == 0) // Draft
                        ElevatedButton.icon(
                          icon: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                          label: const Text('ট্রাকে রওনা করান (Dispatch)'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          onPressed: () => _showDispatchDialog(shipment),
                        ),

                      // Action 2: Goods Receipt
                      if (shipment.status == 1) // Dispatched
                        ElevatedButton.icon(
                          icon: const Icon(Icons.where_to_vote_rounded, size: 16, color: Colors.white),
                          label: const Text('আড়তে মাল গ্রহণ (Receive)'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                          onPressed: () => _showReceiveDialog(shipment),
                        ),

                      // Action 3: Record Daily Sale
                      if (shipment.status == 2 || shipment.status == 3) // Received or Selling
                        ElevatedButton.icon(
                          icon: const Icon(Icons.point_of_sale_rounded, size: 16, color: Colors.white),
                          label: const Text('আড়ত বিক্রি রেকর্ড (+Sale)'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                          onPressed: () => _showRecordSaleDialog(shipment),
                        ),

                      // Action 4: Printable challan
                      OutlinedButton.icon(
                        icon: const Icon(Icons.receipt_long_rounded, size: 16),
                        label: const Text('ডেলিভারি চালান ভিউ'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ChallanViewScreen(shipment: shipment)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Goods list
            const Text('চালানের মালামালের বিবরণ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                children: shipment.items.map((i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(i.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('বস্তা: ${i.bagCount}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${i.dispatchedWeight} ${i.unitName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          if (i.receivedWeight > 0)
                            Text('আড়তে প্রাপ্ত: ${i.receivedWeight} ${i.unitName}', style: const TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold)),
                          if (i.shortageWeight > 0)
                            Text('ঘাটতি: ${i.shortageWeight} ${i.unitName}', style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // Sales breakdown (if any)
            if (sales.isNotEmpty) ...[
              const Text('আড়তে আংশিক বিক্রি বিবরণী', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                child: Column(
                  children: sales.map((sale) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(sale.saleNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary)),
                            Text('তারিখ: ${sale.saleDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${sale.quantity} ${sale.unitName} @ ৳${sale.unitRate.toStringAsFixed(1)}', style: const TextStyle(fontSize: 13)),
                            Text('৳ ${sale.grossAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('কমিশন (${sale.commissionRate}%): ৳${sale.commissionAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, color: AppColors.error)),
                            Text('নিট আদায়: ৳ ${sale.netProceeds.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal)),
                          ],
                        ),
                        const Divider(height: 14),
                      ],
                    ),
                  )).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Expense Breakdown
            const Text('পরিবহন ও আনুষঙ্গিক খরচসমূহ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('গাড়ি ভাড়া (${shipment.freightPaidBy == "owner" ? "মালিক" : "আড়তদার"})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      Text('৳ ${shipment.freightAmount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(height: 12),
                  ...shipment.expenses.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${e.head} (${e.paidBy == "owner" ? "মালিক" : "আড়তদার"})', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text('৳ ${e.amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট খরচ:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Text('৳ ${shipment.totalExpenses.toStringAsFixed(0)}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button: View Settlement / Profit Loss
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics_rounded, color: Colors.white),
              label: const Text('হিসাব নিষ্পত্তি ও লাভ/ক্ষতি (P&L)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettlementScreen(shipmentId: shipment.id)),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}