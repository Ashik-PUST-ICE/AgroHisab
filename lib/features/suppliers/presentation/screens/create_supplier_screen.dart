import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/supplier_provider.dart';

class CreateSupplierScreen extends StatefulWidget {
  const CreateSupplierScreen({super.key});

  @override
  State<CreateSupplierScreen> createState() => _CreateSupplierScreenState();
}

class _CreateSupplierScreenState extends State<CreateSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _marketController = TextEditingController();
  final _districtController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _marketController.dispose();
    _districtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<SupplierProvider>();
    final ok = await provider.createSupplier({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
      'market': _marketController.text.trim(),
      'district': _districtController.text.trim(),
      'notes': _notesController.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      Navigator.pop(context, _nameController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage ?? 'কৃষক সংরক্ষণ করা যায়নি')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SupplierProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('নতুন কৃষক যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
                  SizedBox(width: 10),
                  Expanded(child: Text('কৃষকের তথ্য যোগ করুন। নাম দেওয়া বাধ্যতামূলক। Purchase করার সময় এই কৃষকটি সরাসরি নির্বাচন করতে পারবেন।', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
            const SizedBox(height: 18),
            CustomTextField(
              label: 'নাম *',
              hint: 'যেমন: রহিম মিয়া',
              controller: _nameController,
              validator: (value) => value == null || value.trim().isEmpty ? 'নাম লিখুন' : null,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            const SizedBox(height: 14),
            CustomTextField(
              label: 'মোবাইল নম্বর',
              hint: 'যেমন: 01712345678',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: CustomTextField(label: 'বাজার / মোকাম', controller: _marketController, prefixIcon: const Icon(Icons.storefront_outlined))),
                const SizedBox(width: 12),
                Expanded(child: CustomTextField(label: 'জেলা', controller: _districtController, prefixIcon: const Icon(Icons.location_on_outlined))),
              ],
            ),
            const SizedBox(height: 14),
            CustomTextField(label: 'ঠিকানা', controller: _addressController, prefixIcon: const Icon(Icons.home_outlined)),
            const SizedBox(height: 14),
            CustomTextField(label: 'নোট', controller: _notesController, prefixIcon: const Icon(Icons.notes_rounded)),
            const SizedBox(height: 24),
            CustomButton(text: 'কৃষক সংরক্ষণ করুন', icon: Icons.save_rounded, isLoading: provider.isLoading, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
