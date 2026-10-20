import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/diary_provider.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DiaryProvider>(context, listen: false).fetchEntries();
    });
  }

  void _showAddEntryDialog() {
    final provider = Provider.of<DiaryProvider>(context, listen: false);
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ব্যবসায়িক ডায়েরি / নোট এন্ট্রি', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                label: 'শিরোনাম / বিষয় *',
                hint: 'যেমন: কারওয়ান বাজারে আলুর পাইকারি দর চড়া',
                controller: titleCtrl,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                label: 'বিস্তারিত নোট ও পরিকল্পনা',
                hint: 'যেমন: কাল সকালে ট্রাক ভাড়া করতে হবে...',
                controller: notesCtrl,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('বাতিল')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () async {
              if (titleCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('শিরোনাম লিখুন')));
                return;
              }
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              final ok = await provider.addEntry({
                'title': titleCtrl.text,
                'notes': notesCtrl.text,
                'event_type': 'general',
                'event_date': DateTime.now().toIso8601String().substring(0, 10),
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('নোট সফলভাবে ডায়েরিতে সংরক্ষিত হয়েছে!')));
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
        title: const Text('ব্যবসায়িক ডায়েরি ও নোটবুক', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note),
        label: const Text('নতুন নোট'),
        onPressed: _showAddEntryDialog,
      ),
      body: Consumer<DiaryProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.entries.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.entries.isEmpty) {
            return const Center(child: Text('ডায়েরিতে কোনো নোট পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchEntries(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.entries.length,
              itemBuilder: (ctx, i) {
                final e = provider.entries[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: AppColors.accentLight,
                              child: const Icon(Icons.event_note, size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(e.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            ),
                            Text(e.eventDate, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                        if (e.notes != null && e.notes!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Text(e.notes!, style: TextStyle(color: Colors.grey.shade800, fontSize: 13, height: 1.4)),
                        ],
                      ],
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