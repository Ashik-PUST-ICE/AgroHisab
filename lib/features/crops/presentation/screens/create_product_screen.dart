import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/crop_provider.dart';

class CreateProductScreen extends StatefulWidget {
  const CreateProductScreen({super.key});

  @override
  State<CreateProductScreen> createState() => _CreateProductScreenState();
}

class _CreateProductScreenState extends State<CreateProductScreen> {
  final _name = TextEditingController();
  final _variety = TextEditingController();
  final _description = TextEditingController();
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<CropProvider>().fetchCategories());
  }

  @override
  void dispose() {
    _name.dispose();
    _variety.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CropProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('নতুন পণ্য তৈরি করুন', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('পণ্যের তথ্য', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          CustomTextField(label: 'পণ্যের নাম *', hint: 'যেমন: পেঁয়াজ, আলু, ধান', controller: _name),
          const SizedBox(height: 12),
          CustomTextField(label: 'জাত / ভ্যারাইটি', controller: _variety),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _categoryId,
            decoration: const InputDecoration(labelText: 'পণ্যের ক্যাটাগরি', prefixIcon: Icon(Icons.category_outlined), border: OutlineInputBorder()),
            items: provider.categories.map((category) => DropdownMenuItem(value: category.id, child: Text(category.name))).toList(),
            onChanged: (value) => setState(() => _categoryId = value),
          ),
          const SizedBox(height: 12),
          CustomTextField(label: 'বিবরণ', controller: _description),
          const SizedBox(height: 20),
          CustomButton(text: 'পণ্য সংরক্ষণ করুন', icon: Icons.save_rounded, isLoading: provider.isLoading, onPressed: provider.isLoading ? null : _save),
          if (provider.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
          ],
        ]))),
      ]),
    );
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পণ্যের নাম লিখুন')));
      return;
    }
    final ok = await context.read<CropProvider>().addCrop({
      'name': _name.text.trim(),
      if (_variety.text.trim().isNotEmpty) 'variety': _variety.text.trim(),
      if (_description.text.trim().isNotEmpty) 'description': _description.text.trim(),
      if (_categoryId != null) 'category_id': _categoryId,
    });
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
    else ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('পণ্য সংরক্ষণ করা যায়নি')));
  }
}
