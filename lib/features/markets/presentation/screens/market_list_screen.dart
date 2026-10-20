import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/market_provider.dart';

class MarketListScreen extends StatefulWidget {
  const MarketListScreen({super.key});

  @override
  State<MarketListScreen> createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MarketProvider>(context, listen: false).fetchMarkets();
    });
  }

  void _showAddMarketDialog() {
    final provider = Provider.of<MarketProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final districtCtrl = TextEditingController();
    final addressCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নতুন মোকাম / পাইকারি হাট যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'হাটের নাম *', hint: 'যেমন: কারওয়ান বাজার, শিবগঞ্জ হাট', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'জেলা', hint: 'যেমন: বগুড়া, ঢাকা', controller: districtCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'ঠিকানা / বিবরণ', hint: 'যেমন: পাইকারি আড়ত পট্টি', controller: addressCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('হাটের নাম লিখুন')));
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.addMarket({
                'name': nameCtrl.text,
                'district': districtCtrl.text,
                'address': addressCtrl.text,
                'type': 1,
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('মোকাম সফলভাবে সংরক্ষিত হয়েছে!')));
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
        title: const Text('মোকাম ও পাইকারি হাট তালিকা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text('নতুন মোকাম'),
        onPressed: _showAddMarketDialog,
      ),
      body: Consumer<MarketProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.markets.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.markets.isEmpty) {
            return const Center(child: Text('কোনো মোকাম বা হাটের তথ্য পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchMarkets(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.markets.length,
              itemBuilder: (ctx, i) {
                final m = provider.markets[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Icon(Icons.store, color: Colors.teal.shade800),
                    ),
                    title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${m.district ?? "অজ্ঞাত জেলা"} • ${m.typeLabel}'),
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
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