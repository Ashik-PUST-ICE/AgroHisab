import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/crop_provider.dart';

class CropListScreen extends StatefulWidget {
  const CropListScreen({super.key});

  @override
  State<CropListScreen> createState() => _CropListScreenState();
}

class _CropListScreenState extends State<CropListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CropProvider>(context, listen: false).fetchCrops();
    });
  }

  void _showAddCropDialog() {
    final provider = Provider.of<CropProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final varietyCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নতুন ফসল / শস্য যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'ফসলের নাম *', hint: 'যেমন: গোল আলু, পেঁয়াজ, রসুন', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'জাত / ভ্যারাইটি', hint: 'যেমন: ডায়মন্ড, লাল পাকড়ি', controller: varietyCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'বিবরণ', hint: 'যেমন: শিবগঞ্জের স্থানীয় ভালো জাত', controller: descCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ফসলের নাম লিখুন')));
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.addCrop({
                'name': nameCtrl.text,
                'variety': varietyCtrl.text,
                'description': descCtrl.text,
                'category_id': 1,
                'default_unit_id': 1,
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('ফসল সফলভাবে যুক্ত হয়েছে!')));
              }
            },
            child: const Text('সংরক্ষণ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ফসল ও শস্য তালিকা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('নতুন ফসল'),
        onPressed: _showAddCropDialog,
      ),
      body: Consumer<CropProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.crops.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.crops.isEmpty) {
            return const Center(child: Text('কোনো ফসলের তথ্য পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchCrops(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.crops.length,
              itemBuilder: (ctx, i) {
                final c = provider.crops[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accentLight,
                      child: const Icon(Icons.grass, color: AppColors.primary),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text(c.variety != null && c.variety!.isNotEmpty ? 'জাত: ${c.variety}' : (c.description ?? 'সক্রিয় ফসল')),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(c.statusLabel, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}