import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../providers/storage_provider.dart';

class StorageSettingsScreen extends StatefulWidget {
  const StorageSettingsScreen({super.key});

  @override
  State<StorageSettingsScreen> createState() => _StorageSettingsScreenState();
}

class _StorageSettingsScreenState extends State<StorageSettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StorageProvider>(context, listen: false).fetchStorageInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('স্টোরেজ ও ক্লাউড ড্রাইভ সেটিংস', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<StorageProvider>(
        builder: (ctx, provider, _) {
          final info = provider.info;
          final test = provider.testResult;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cloud_done, color: AppColors.primary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('সক্রিয় স্টোরেজ ড্রাইভ', style: TextStyle(color: Colors.black54, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(
                            (info?.provider ?? 'local').toUpperCase() == 'LOCAL' ? 'Local Public Disk (সার্ভার মেমরি)' : 'Cloud Storage (S3/Spaces)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('সক্রিয়', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
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
                      const Text('স্টোরেজ কনফিগারেশন বিবরণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 12),
                      _buildRow('প্রোভাইডার:', info?.provider ?? 'local'),
                      _buildRow('স্টোরেজ অবস্থা:', (info?.enabled ?? true) ? 'এনাবল্ড (Enabled)' : 'ডিজেবল্ড'),
                      _buildRow('রুট ফোল্ডার:', info?.root ?? 'Default (storage/app/public)'),
                      _buildRow('পাবলিক ডোমেইন:', info?.publicUrl ?? 'App Host URL'),
                      _buildRow('সমর্থিত ক্লাউড:', 'AWS S3, DigitalOcean, Wasabi, Cloudflare R2, MinIO'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (test != null) ...[
                Card(
                  color: test.status == 'success' ? Colors.green.shade50 : Colors.red.shade50,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              test.status == 'success' ? Icons.check_circle : Icons.error,
                              color: test.status == 'success' ? Colors.green.shade800 : Colors.red.shade800,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'কানেক্টিভিটি টেস্ট: ${test.status.toUpperCase()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: test.status == 'success' ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                            const Spacer(),
                            Text('${test.latencyMs} ms', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(test.message, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              CustomButton(
                text: 'স্টোরেজ কানেকশন টেস্ট করুন',
                isLoading: provider.isLoading,
                onPressed: provider.isLoading ? null : () => provider.testConnection(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13))),
          Expanded(child: Text(val, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ],
      ),
    );
  }
}