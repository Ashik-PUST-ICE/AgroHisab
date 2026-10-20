import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/transporter_provider.dart';

class TransporterListScreen extends StatefulWidget {
  const TransporterListScreen({super.key});

  @override
  State<TransporterListScreen> createState() => _TransporterListScreenState();
}

class _TransporterListScreenState extends State<TransporterListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransporterProvider>(context, listen: false).fetchTransporters();
    });
  }

  void _showAddTransporterDialog() {
    final provider = Provider.of<TransporterProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final truckCtrl = TextEditingController();
    final driverCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নতুন ট্রাক ও ড্রাইভার যুক্ত করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'ট্রান্সপোর্ট / এজেন্সির নাম *', hint: 'যেমন: ভাই ভাই পরিবহন', controller: nameCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'ট্রাক নম্বর *', hint: 'যেমন: ঢাকা মেট্রো-ট ১১-২২৩৩', controller: truckCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'ড্রাইভারের নাম', hint: 'যেমন: মো: সেলিম', controller: driverCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'ড্রাইভারের মোবাইল নম্বর', hint: 'যেমন: 01711223344', controller: phoneCtrl, keyboardType: TextInputType.phone),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || truckCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নাম ও ট্রাক নম্বর আবশ্যক')));
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.createTransporter({
                'name': nameCtrl.text,
                'truck_number': truckCtrl.text,
                'driver_name': driverCtrl.text,
                'driver_phone': phoneCtrl.text,
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('ট্রাক সফলভাবে সংরক্ষিত হয়েছে!')));
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
        title: const Text('ট্রাক ও পরিবহন তালিকা', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.local_shipping),
        label: const Text('নতুন ট্রাক'),
        onPressed: _showAddTransporterDialog,
      ),
      body: Consumer<TransporterProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.transporters.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.transporters.isEmpty) {
            return const Center(child: Text('কোনো ট্রাকের রেকর্ড পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchTransporters(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.transporters.length,
              itemBuilder: (ctx, i) {
                final t = provider.transporters[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: Icon(Icons.local_shipping, color: Colors.blue.shade800),
                    ),
                    title: Text(t.truckNumber ?? t.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('ড্রাইভার: ${t.driverName ?? "নাম নেই"} • ${t.driverPhone ?? t.phone ?? "নম্বর নেই"}'),
                    trailing: Text(t.name, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
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