import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../crops/presentation/providers/crop_provider.dart';
import '../../../units/presentation/providers/unit_provider.dart';
import '../../data/models/market_model.dart';
import '../providers/market_provider.dart';

class MarketPriceObservationsScreen extends StatefulWidget {
  final MarketModel market;

  const MarketPriceObservationsScreen({super.key, required this.market});

  @override
  State<MarketPriceObservationsScreen> createState() =>
      _MarketPriceObservationsScreenState();
}

class _MarketPriceObservationsScreenState
    extends State<MarketPriceObservationsScreen> {
  int? _selectedFilterProductId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final marketProv = Provider.of<MarketProvider>(context, listen: false);
      final cropProv = Provider.of<CropProvider>(context, listen: false);
      final unitProv = Provider.of<UnitProvider>(context, listen: false);

      marketProv.fetchPriceObservations(widget.market.id);
      if (cropProv.crops.isEmpty) {
        cropProv.fetchCrops();
      }
      if (unitProv.units.isEmpty) {
        unitProv.fetchUnits();
      }
    });
  }

  void _applyFilter(int? productId) {
    setState(() {
      _selectedFilterProductId = productId;
    });
    Provider.of<MarketProvider>(context, listen: false).fetchPriceObservations(
      widget.market.id,
      productId: productId,
    );
  }

  void _showAddObservationDialog() {
    final marketProv = Provider.of<MarketProvider>(context, listen: false);
    final cropProv = Provider.of<CropProvider>(context, listen: false);
    final unitProv = Provider.of<UnitProvider>(context, listen: false);

    int? selectedProductId =
        cropProv.crops.isNotEmpty ? cropProv.crops.first.id : null;
    int? selectedUnitId =
        unitProv.units.isNotEmpty ? unitProv.units.first.id : null;
    DateTime selectedDate = DateTime.now();

    final minPriceCtrl = TextEditingController();
    final maxPriceCtrl = TextEditingController();
    final avgPriceCtrl = TextEditingController();
    final sourceCtrl = TextEditingController(text: 'আড়তের পাইকারি দর');
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          void updateAvg() {
            final min = double.tryParse(minPriceCtrl.text);
            final max = double.tryParse(maxPriceCtrl.text);
            if (min != null && max != null) {
              avgPriceCtrl.text = ((min + max) / 2).toStringAsFixed(1);
            }
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                const Icon(Icons.add_chart, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.market.name} - বাজারদর এন্ট্রি',
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
                    // Crop selection
                    const Text('ফসল / পণ্য নির্বাচন *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedProductId,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: cropProv.crops.map((c) {
                        return DropdownMenuItem<int>(
                          value: c.id,
                          child: Text(c.name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedProductId = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Unit selection
                    const Text('পরিমাপের একক',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<int>(
                      value: selectedUnitId,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      items: unitProv.units.map((u) {
                        return DropdownMenuItem<int>(
                          value: u.id,
                          child: Text('${u.name} (${u.code})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setDialogState(() => selectedUnitId = val);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Date picker
                    const Text('পর্যবেক্ষণ তারিখ *',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Prices row
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            label: 'সর্বনিম্ন দর (৳)',
                            hint: '০.০০',
                            controller: minPriceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => updateAvg(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            label: 'সর্বোচ্চ দর (৳)',
                            hint: '০.০০',
                            controller: maxPriceCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => updateAvg(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'গড় দর (৳)',
                      hint: '০.০০',
                      controller: avgPriceCtrl,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Source & Quick chips
                    CustomTextField(
                      label: 'তথ্যের উৎস',
                      hint: 'যেমন: আড়তের পাইকারি দর',
                      controller: sourceCtrl,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      children: [
                        'আড়তের পাইকারি দর',
                        'মোকাম বাজার',
                        'ব্যবসায়ী সমিতি',
                        'বিপণন অধিদপ্তর',
                      ].map((src) {
                        return ActionChip(
                          label: Text(src, style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: AppColors.accentLight,
                          onPressed: () {
                            setDialogState(() => sourceCtrl.text = src);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      label: 'মন্তব্য / নোট (ঐচ্ছিক)',
                      hint: 'যেমন: সরবরাহ প্রচুর ছিল',
                      controller: notesCtrl,
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  if (selectedProductId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('অনুগ্রহ করে ফসল নির্বাচন করুন')),
                    );
                    return;
                  }

                  final body = <String, dynamic>{
                    'product_id': selectedProductId,
                    'observed_date': DateFormat('yyyy-MM-dd').format(selectedDate),
                  };

                  if (selectedUnitId != null) {
                    body['unit_id'] = selectedUnitId;
                  }
                  if (minPriceCtrl.text.isNotEmpty) {
                    body['min_price'] = double.tryParse(minPriceCtrl.text);
                  }
                  if (maxPriceCtrl.text.isNotEmpty) {
                    body['max_price'] = double.tryParse(maxPriceCtrl.text);
                  }
                  if (avgPriceCtrl.text.isNotEmpty) {
                    body['avg_price'] = double.tryParse(avgPriceCtrl.text);
                  }
                  if (sourceCtrl.text.isNotEmpty) {
                    body['source'] = sourceCtrl.text;
                  }
                  if (notesCtrl.text.isNotEmpty) {
                    body['notes'] = notesCtrl.text;
                  }

                  Navigator.pop(ctx);
                  final messenger = ScaffoldMessenger.of(context);
                  final ok = await marketProv.addPriceObservation(
                      widget.market.id, body);
                  if (mounted && ok) {
                    messenger.showSnackBar(
                      const SnackBar(
                          content: Text('বাজারদর সফলভাবে এন্ট্রি করা হয়েছে!')),
                    );
                  }
                },
                child: const Text('সংরক্ষণ করুন'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cropProv = Provider.of<CropProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.market.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('বাজারদর এন্ট্রি'),
        onPressed: _showAddObservationDialog,
      ),
      body: Consumer<MarketProvider>(
        builder: (ctx, prov, _) {
          return RefreshIndicator(
            onRefresh: () => prov.fetchPriceObservations(
              widget.market.id,
              productId: _selectedFilterProductId,
            ),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Market Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: AppColors.accentLight,
                        child: Icon(Icons.storefront,
                            color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.market.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${widget.market.district ?? "অজ্ঞাত জেলা"} • ${widget.market.typeLabel}',
                              style: const TextStyle(
                                  color: AppColors.textSecondary, fontSize: 13),
                            ),
                            if (widget.market.address != null &&
                                widget.market.address!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  widget.market.address!,
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

                // Crop Filter Chips
                if (cropProv.crops.isNotEmpty) ...[
                  SizedBox(
                    height: 38,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('সকল ফসল'),
                            selected: _selectedFilterProductId == null,
                            selectedColor: AppColors.accentLight,
                            checkmarkColor: AppColors.primary,
                            onSelected: (_) => _applyFilter(null),
                          ),
                        ),
                        ...cropProv.crops.map((c) {
                          final isSelected = _selectedFilterProductId == c.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(c.name),
                              selected: isSelected,
                              selectedColor: AppColors.accentLight,
                              checkmarkColor: AppColors.primary,
                              onSelected: (_) =>
                                  _applyFilter(isSelected ? null : c.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Observations Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'দৈনিক বাজারদর পর্যবেক্ষণ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      'মোট: ${prov.priceObservations.length} টি',
                      style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Loading State
                if (prov.isObsLoading && prov.priceObservations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  )
                // Empty State
                else if (prov.priceObservations.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.insert_chart_outlined,
                            size: 54, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'কোনো বাজারদর রেকর্ড করা হয়নি',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'এই মোকামের জন্য প্রতিদিনের পাইকারি ফসলের দর রেকর্ড করে রাখুন।',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('প্রথম দর এন্ট্রি করুন'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                          ),
                          onPressed: _showAddObservationDialog,
                        ),
                      ],
                    ),
                  )
                // List of Observations
                else
                  ...prov.priceObservations.map((obs) {
                    final unitStr =
                        obs.unitSymbol != null && obs.unitSymbol!.isNotEmpty
                            ? ' / ${obs.unitSymbol}'
                            : '';
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.accentLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_today,
                                              size: 13,
                                              color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text(
                                            obs.observedDate,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.primaryDark),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (obs.source != null &&
                                        obs.source!.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          obs.source!,
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.blue.shade800,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 20, color: Colors.redAccent),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('বাজারদর মুছবেন?'),
                                        content: const Text(
                                            'এই বাজারদর রেকর্ডটি ডিলিট করতে চান?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('বাতিল'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white),
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: const Text('মুছে ফেলুন'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await prov.deletePriceObservation(
                                          obs.id, widget.market.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        obs.productName ??
                                            'ফসল # ${obs.productId}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'দর পরিসীমা: ${obs.priceSummary}$unitStr',
                                        style: TextStyle(
                                          color: Colors.teal.shade900,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (obs.avgPrice != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: AppColors.secondary
                                              .withOpacity(0.3)),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text('গড় রেট',
                                            style: TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textSecondary)),
                                        Text(
                                          '৳${obs.avgPrice!.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppColors.primary),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            if (obs.notes != null && obs.notes!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'নোট: ${obs.notes!}',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                const SizedBox(height: 60),
              ],
            ),
          );
        },
      ),
    );
  }
}