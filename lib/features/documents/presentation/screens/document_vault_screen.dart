import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/document_provider.dart';

class DocumentVaultScreen extends StatefulWidget {
  const DocumentVaultScreen({super.key});

  @override
  State<DocumentVaultScreen> createState() => _DocumentVaultScreenState();
}

class _DocumentVaultScreenState extends State<DocumentVaultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DocumentProvider>(context, listen: false).fetchDocuments();
    });
  }

  void _showAddDocumentDialog() {
    final provider = Provider.of<DocumentProvider>(context, listen: false);
    final titleCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('নতুন ভাউচার / ডকুমেন্ট সংরক্ষণ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'ডকুমেন্টের শিরোনাম *', hint: 'যেমন: চালান #CH-001 ওজন স্লিপ', controller: titleCtrl),
              const SizedBox(height: 12),
              CustomTextField(label: 'মন্তব্য / বিবরণ', hint: 'যেমন: মোকামে মালের ওজন পরিমাপের রসিদ', controller: notesCtrl),
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
              final ok = await provider.addDocument({
                'title': titleCtrl.text,
                'document_type': 'receipt',
                'file_path': 'uploads/documents/placeholder.pdf',
                'file_name': '${titleCtrl.text}.pdf',
                'file_size': 1024,
                'notes': notesCtrl.text,
              });
              if (mounted && ok) {
                messenger.showSnackBar(const SnackBar(content: Text('ডকুমেন্ট সফলভাবে সংরক্ষিত হয়েছে!')));
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
        title: const Text('ডকুমেন্ট ও রসিদ ভল্ট', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text('ডকুমেন্ট যোগ করুন'),
        onPressed: _showAddDocumentDialog,
      ),
      body: Consumer<DocumentProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading && provider.documents.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (provider.documents.isEmpty) {
            return const Center(child: Text('কোনো সংরক্ষিত ডকুমেন্ট পাওয়া যায়নি।', style: TextStyle(color: Colors.grey)));
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchDocuments(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.documents.length,
              itemBuilder: (ctx, i) {
                final d = provider.documents[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.amber.shade50,
                      child: Icon(Icons.picture_as_pdf, color: Colors.amber.shade900),
                    ),
                    title: Text(d.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(d.fileName ?? d.documentType ?? 'ডকুমেন্ট'),
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