import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../data/models/aratdar_model.dart';
import '../providers/aratdar_provider.dart';

class AratdarAgreementScreen extends StatefulWidget {
  final AratdarModel aratdar;

  const AratdarAgreementScreen({super.key, required this.aratdar});

  @override
  State<AratdarAgreementScreen> createState() => _AratdarAgreementScreenState();
}

class _AratdarAgreementScreenState extends State<AratdarAgreementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AratdarProvider>(context, listen: false)
          .fetchAgreement(widget.aratdar.id);
    });
  }

  void _showEditAgreementDialog() {
    final prov = Provider.of<AratdarProvider>(context, listen: false);
    final cur = prov.currentAgreement;

    int commissionType = cur?.commissionType ?? widget.aratdar.commissionType;
    final valueCtrl = TextEditingController(
      text: (cur?.commissionValue ?? widget.aratdar.commissionValue).toString(),
    );
    DateTime startDate = cur?.agreementStart != null
        ? DateTime.tryParse(cur!.agreementStart!) ?? DateTime.now()
        : DateTime.now();
    DateTime? endDate = cur?.agreementEnd != null
        ? DateTime.tryParse(cur!.agreementEnd!)
        : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.handshake_outlined, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.aratdar.name} - কমিশন চুক্তি',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('কমিশনের ধরন নির্ধারণ করুন *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),

                    // Radio 1: Percentage
                    RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('শতকরা কমিশন (%)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('মোট বিক্রয়মূল্যের উপর নির্দিষ্ট শতাংশ হার (যেমন: ৩.৫%, ৫%)',
                          style: TextStyle(fontSize: 12)),
                      value: 1,
                      groupValue: commissionType,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setDialogState(() => commissionType = val!);
                      },
                    ),

                    // Radio 2: Fixed per bag
                    RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text('প্রতি বস্তা নির্দিষ্ট ফি (৳)',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('বিক্রিত প্রতিটি বস্তা বা খাঁচার উপর নির্দিষ্ট টাকা (যেমন: ২০ ৳/বস্তা)',
                          style: TextStyle(fontSize: 12)),
                      value: 2,
                      groupValue: commissionType,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        setDialogState(() => commissionType = val!);
                      },
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: commissionType == 2
                          ? 'প্রতি বস্তার কমিশন হার (৳) *'
                          : 'শতকরা কমিশন হার (%) *',
                      hint: commissionType == 2 ? 'যেমন: ২০.০০' : 'যেমন: ৫.০০',
                      controller: valueCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 14),

                    // Agreement Start Date
                    const Text('চুক্তি কার্যকরের তারিখ *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: startDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => startDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(startDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Agreement End Date (Optional)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('চুক্তি সমাপ্তির তারিখ (ঐচ্ছিক)',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        if (endDate != null)
                          TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact),
                            onPressed: () => setDialogState(() => endDate = null),
                            child: const Text('মুছে ফেলুন',
                                style: TextStyle(fontSize: 11, color: Colors.red)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? startDate.add(const Duration(days: 365)),
                          firstDate: startDate,
                          lastDate: DateTime(2035),
                        );
                        if (picked != null) {
                          setDialogState(() => endDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(endDate != null
                                ? DateFormat('yyyy-MM-dd').format(endDate!)
                                : 'সীমাহীন / অনির্দিষ্ট মেয়াদ'),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('বাতিল'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final val = double.tryParse(valueCtrl.text);
                  if (val == null || val <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('সঠিক কমিশন হার লিখুন')),
                    );
                    return;
                  }

                  final body = <String, dynamic>{
                    'commission_type': commissionType,
                    'commission_value': val,
                    'agreement_start': DateFormat('yyyy-MM-dd').format(startDate),
                  };
                  if (endDate != null) {
                    body['agreement_end'] = DateFormat('yyyy-MM-dd').format(endDate!);
                  }

                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await prov.updateAgreement(widget.aratdar.id, body);
                  if (mounted && ok) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('কমিশন চুক্তি সফলভাবে আপডেট করা হয়েছে!')),
                    );
                  } else if (mounted && prov.agreementError != null) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('ব্যর্থ: ${prov.agreementError}')),
                    );
                  }
                },
                child: const Text('আপডেট করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${widget.aratdar.name} - চুক্তি',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('চুক্তির শর্ত পরিবর্তন / আপডেট করুন',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            onPressed: _showEditAgreementDialog,
          ),
        ),
      ),
      body: Consumer<AratdarProvider>(
        builder: (ctx, prov, _) {
          if (prov.isAgreementLoading && prov.currentAgreement == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final ag = prov.currentAgreement;
          final typeTitle = ag != null
              ? ag.typeTitle
              : (widget.aratdar.commissionType == 2
                  ? 'প্রতি বস্তা নির্দিষ্ট ফি'
                  : 'বিক্রয় মূল্যের শতকরা (%)');
          final displayRate = ag != null
              ? ag.displayRate
              : (widget.aratdar.commissionType == 2
                  ? '৳${widget.aratdar.commissionValue.toStringAsFixed(0)} / বস্তা'
                  : '${widget.aratdar.commissionValue.toStringAsFixed(1)}%');
          final isActive = ag?.isActive ?? true;

          return RefreshIndicator(
            onRefresh: () => prov.fetchAgreement(widget.aratdar.id),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Aratdar Profile Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.accentLight,
                        child: Icon(Icons.storefront_rounded,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.aratdar.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.aratdar.businessName ?? "আড়ত"} • ${widget.aratdar.market ?? widget.aratdar.district}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                            if (widget.aratdar.phone != null &&
                                widget.aratdar.phone!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.aratdar.phone!,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Agreement Details Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'সক্রিয় কমিশন চুক্তি',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.accentLight
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isActive ? 'সক্রিয় (Active)' : 'মেয়াদোত্তীর্ণ (Expired)',
                              style: TextStyle(
                                color: isActive
                                    ? AppColors.primaryDark
                                    : Colors.red.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Highlight Rate Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('নির্ধারিত কমিশন রেট',
                                    style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                const SizedBox(height: 4),
                                Text(
                                  displayRate,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const Icon(Icons.percent_rounded,
                                size: 36, color: AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Attributes list
                      _buildInfoRow(
                          'কমিশনের ধরন', typeTitle, Icons.category_outlined),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'কার্যকরের তারিখ',
                        ag?.agreementStart ?? 'উল্লেখ নেই (শুরু থেকে)',
                        Icons.play_circle_outline_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        'সমাপ্তির মেয়াদ',
                        ag?.agreementEnd ?? 'সীমাহীন / অনির্দিষ্ট',
                        Icons.stop_circle_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Helpful note card
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline,
                          size: 20, color: Colors.blue.shade800),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'চালানের কাঁচামাল আড়তে বিক্রির পর ফাইনাল কনসাইনমেন্ট নিষ্পত্তিতে (Settlement) এই চুক্তি অনুযায়ী স্বয়ংক্রিয়ভাবে আড়তদারের কমিশন ও খরচ হিসাব করা হবে।',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                              height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 13)),
      ],
    );
  }
}