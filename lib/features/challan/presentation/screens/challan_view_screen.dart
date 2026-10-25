import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/shipment_model.dart';
import '../providers/challan_provider.dart';

class ChallanViewScreen extends StatefulWidget {
  final ShipmentModel shipment;

  const ChallanViewScreen({super.key, required this.shipment});

  @override
  State<ChallanViewScreen> createState() => _ChallanViewScreenState();
}

class _ChallanViewScreenState extends State<ChallanViewScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChallanProvider>(context, listen: false).fetchChallanPrintData(widget.shipment.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChallanProvider>(context);
    final data = provider.challanPrintData;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('ডেলিভারি চালান #${widget.shipment.shipmentNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isActionLoading && data == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: [
                          const Text('কৃষি হিসাব (AgroHisab)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          const SizedBox(height: 4),
                          const Text('কাঁচামাল চালান ও পরিবহন রসিদ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'চালান নং: ${widget.shipment.shipmentNumber}',
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('তারিখ: ${widget.shipment.dispatchDate}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    const Divider(height: 30),

                    // Two Column party info
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('প্রাপক (আড়তদার বিবরণ)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text(widget.shipment.aratdarName ?? 'আড়তদার', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('মোকাম: ${widget.shipment.destinationMarket ?? "ঢাকা"}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('পরিবহন বিবরণ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('গাড়ির নম্বর: ${widget.shipment.vehicleNumber ?? "ট্রাক"}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              Text('ভাড়া: ৳ ${widget.shipment.freightAmount.toStringAsFixed(0)} (${widget.shipment.freightPaidBy == "owner" ? "নগদ পরিশোধ" : "আড়তদার দেবে"})', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Goods Table
                    const Text('চালানকৃত মালের বিবরণ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 8),
                    Table(
                      border: TableBorder.all(color: AppColors.border, width: 1),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Color(0xFFF1F8E9)),
                          children: [
                            Padding(padding: EdgeInsets.all(8), child: Text('পণ্যের বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('বস্তা', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                            Padding(padding: EdgeInsets.all(8), child: Text('ওজন', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          ],
                        ),
                        ...widget.shipment.items.map((i) => TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(8), child: Text(i.productName, style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${i.bagCount}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${i.dispatchedWeight} ${i.unitName}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
                          ],
                        )),
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFFAFAFA)),
                          children: [
                            const Padding(padding: EdgeInsets.all(8), child: Text('মোট:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${widget.shipment.totalBags}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                            Padding(padding: const EdgeInsets.all(8), child: Text('${widget.shipment.totalDispatchedWeight} কেজি', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary))),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // Signatures
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('_________________', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('প্রেরকের স্বাক্ষর', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('_________________', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('চালকের স্বাক্ষর', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('_________________', style: TextStyle(color: Colors.grey)),
                            SizedBox(height: 4),
                            Text('আড়তদারের রসিদ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}