import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/unit_provider.dart';

class UnitConversionScreen extends StatefulWidget {
  const UnitConversionScreen({super.key});

  @override
  State<UnitConversionScreen> createState() => _UnitConversionScreenState();
}

class _UnitConversionScreenState extends State<UnitConversionScreen> {
  final _monCtrl = TextEditingController();
  final _kgCtrl = TextEditingController();
  double _monToKgResult = 0;
  double _kgToMonResult = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UnitProvider>(context, listen: false).fetchUnits();
    });
  }

  void _calculateMonToKg(String val) {
    final m = double.tryParse(val) ?? 0;
    setState(() {
      _monToKgResult = m * 40.0;
    });
  }

  void _calculateKgToMon(String val) {
    final k = double.tryParse(val) ?? 0;
    setState(() {
      _kgToMonResult = k / 40.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ওজন একক ও পরিমাপ ক্যালকুলেটর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<UnitProvider>(
        builder: (ctx, provider, _) {
          return ListView(
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
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('কাঁচামাল ওজন পরিমাপ সূত্রাবলী', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('১ মণ = ৪০ কেজি (Standard Maund)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 4),
                    Text('১ বস্তা = গড়ে ৬৫-৮৫ কেজি (ফসলভেদে)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('মণ থেকে কেজিতে রূপান্তর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'মণের সংখ্যা লিখুন',
                        hint: 'যেমন: ৫.৫',
                        controller: _monCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: _calculateMonToKg,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('মোট ওজন:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('${_monToKgResult.toStringAsFixed(1)} কেজি', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('কেজি থেকে মণে রূপান্তর', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      CustomTextField(
                        label: 'কেজির ওজন লিখুন',
                        hint: 'যেমন: ২২০',
                        controller: _kgCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: _calculateKgToMon,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('মোট মণ:', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text('${_kgToMonResult.toStringAsFixed(2)} মণ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}