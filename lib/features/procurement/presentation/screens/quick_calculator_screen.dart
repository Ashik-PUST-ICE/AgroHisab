import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/procurement_provider.dart';
import '../../../crops/presentation/providers/crop_provider.dart';
import '../../../suppliers/presentation/providers/supplier_provider.dart';

class QuickCalculatorScreen extends StatefulWidget {
  const QuickCalculatorScreen({super.key});

  @override
  State<QuickCalculatorScreen> createState() => _QuickCalculatorScreenState();
}

class _QuickCalculatorScreenState extends State<QuickCalculatorScreen> {
  int? _productId;
  int? _supplierId;
  final _actualWeightCtrl = TextEditingController(text: '46');
  final _deductedWeightCtrl = TextEditingController(text: '1');
  final _monRateCtrl = TextEditingController(text: '122');
  final _monSizeCtrl = TextEditingController(text: '40');
  final _paidAmountCtrl = TextEditingController(text: '100');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().fetchCrops();
      context.read<CropProvider>().fetchCategories();
      context.read<SupplierProvider>().fetchSuppliers();
    });
  }

  @override
  void dispose() {
    _actualWeightCtrl.dispose();
    _deductedWeightCtrl.dispose();
    _monRateCtrl.dispose();
    _monSizeCtrl.dispose();
    _paidAmountCtrl.dispose();
    super.dispose();
  }

  void _calculate({bool savePurchase = false}) async {
    final actual = double.tryParse(_actualWeightCtrl.text) ?? 0;
    final deducted = double.tryParse(_deductedWeightCtrl.text) ?? 0;
    final monRate = double.tryParse(_monRateCtrl.text) ?? 0;
    final monSize = double.tryParse(_monSizeCtrl.text) ?? 40;
    final paid = double.tryParse(_paidAmountCtrl.text) ?? 0;

    if (actual <= 0 || monRate <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('কাঁচা ওজন ও মণের দর প্রদান করুন')),
      );
      return;
    }
    if (savePurchase && (_productId == null || _supplierId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select product and supplier before saving the purchase.')));
      return;
    }

    final provider = Provider.of<ProcurementProvider>(context, listen: false);
    final result = await provider.calculate(
      actualWeight: actual,
      deductedWeight: deducted,
      monRate: monRate,
      monSize: monSize,
      paidAmount: paid,
      productId: _productId,
      supplierId: _supplierId,
      savePurchase: savePurchase,
    );

    if (mounted && result != null && savePurchase) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(backgroundColor: AppColors.success, content: Text('ক্রয় হিসাব ডাটাবেজে সংরক্ষিত হয়েছে!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProcurementProvider>(context);
    final crops = context.watch<CropProvider>().crops;
    final suppliers = context.watch<SupplierProvider>().suppliers;
    final result = provider.calculationResult;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('কাঁচামাল ক্রয় ক্যালকুলেটর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Input Card
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
                  const Text('মাঠের কাঁচা মালের পরিমাপ ও দর', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          label: 'কাঁচা ওজন (কেজি)',
                          hint: 'যেমন: ৪৬',
                          controller: _actualWeightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          label: 'কাটতি বাদ (কেজি)',
                          hint: 'যেমন: ১',
                          controller: _deductedWeightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          label: 'মণের দর (টাকা/মণ)',
                          hint: 'যেমন: ১২২',
                          controller: _monRateCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: CustomTextField(
                          label: 'মণ সাইজ (কেজি)',
                          hint: '৪০',
                          controller: _monSizeCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  CustomTextField(
                    label: 'নগদ প্রদান (টাকা)',
                    hint: 'যেমন: ১০০',
                    controller: _paidAmountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 18),

                  CustomButton(
                    text: 'দ্রুত হিসাব বের করুন',
                    icon: Icons.calculate_rounded,
                    isLoading: provider.isLoading,
                    onPressed: () => _calculate(savePurchase: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Result Display Card
            if (result != null) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  DropdownButtonFormField<int>(
                    value: _productId,
                    decoration: const InputDecoration(labelText: 'Product', prefixIcon: Icon(Icons.grass_rounded), border: OutlineInputBorder()),
                    items: crops.map((crop) => DropdownMenuItem(value: crop.id, child: Text(crop.name))).toList(),
                    onChanged: (value) => setState(() => _productId = value),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _supplierId,
                    decoration: const InputDecoration(labelText: 'Supplier / Farmer', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                    items: suppliers.map((supplier) => DropdownMenuItem(value: supplier.id, child: Text(supplier.name))).toList(),
                    onChanged: (value) => setState(() => _supplierId = value),
                  ),
                  const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('হিসাবের ফলাফল', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                      ],
                    ),
                    const Divider(height: 22),

                    _buildResultRow('কাঁচা মোট ওজন:', '${result.actualWeight} কেজি'),
                    _buildResultRow('কাটতি বাদ দেওয়া ওজন:', '${result.deductedWeight} কেজি (কৃষক টাকা পাবে না)'),
                    _buildResultRow('হিসাবি প্রদেয় ওজন:', '${result.payableWeight} কেজি (${(result.payableWeight / result.monSize).toStringAsFixed(2)} মণ)', isBold: true),
                    _buildResultRow('মণের দর:', '৳ ${result.monRate} / মণ (${result.monSize} কেজি)'),
                    _buildResultRow('প্রতি কেজি হিসাবের দর:', '৳ ${result.ratePerKg.toStringAsFixed(2)} / কেজি'),
                    const Divider(height: 16),
                    _buildResultRow('মালের মোট দাম (কৃষকের পাওনা):', '৳ ${result.totalProduceValue.toStringAsFixed(2)}', isBold: true, highlightColor: AppColors.primary),
                    _buildResultRow('নগদ পরিশোধ:', '৳ ${result.paidAmount.toStringAsFixed(2)}'),
                    _buildResultRow('বাকি টাকা:', '৳ ${result.dueAmount.toStringAsFixed(2)}', highlightColor: AppColors.error, isBold: true),

                    const SizedBox(height: 16),
                    CustomButton(
                      text: '১-ক্লিকে ক্রয় হিসেবে সেভ করুন',
                      icon: Icons.save_rounded,
                      onPressed: () => _calculate(savePurchase: true),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isBold = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: isBold ? FontWeight.w600 : FontWeight.normal)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: highlightColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
