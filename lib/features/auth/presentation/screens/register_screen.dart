import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;

  @override
  void dispose() { _first.dispose(); _last.dispose(); _email.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final service = Provider.of<AuthProvider>(context, listen: false);
    final result = await service.register(firstName: _first.text, lastName: _last.text, email: _email.text, password: _password.text, passwordConfirmation: _confirm.text);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result ? 'Account created successfully' : (service.errorMessage ?? 'Registration failed')), backgroundColor: result ? AppColors.success : AppColors.error));
    if (result) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Form(key: _formKey, child: Column(children: [
      const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 58),
      const SizedBox(height: 12),
      const Text('Create your business account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      CustomTextField(label: 'First name', controller: _first, validator: (v) => v == null || v.trim().isEmpty ? 'First name is required' : null),
      const SizedBox(height: 14),
      CustomTextField(label: 'Last name', controller: _last),
      const SizedBox(height: 14),
      CustomTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress, validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null),
      const SizedBox(height: 14),
      CustomTextField(label: 'Password', controller: _password, obscureText: true, validator: (v) => v == null || v.length < 8 ? 'Password must be at least 8 characters' : null),
      const SizedBox(height: 14),
      CustomTextField(label: 'Confirm password', controller: _confirm, obscureText: true, validator: (v) => v != _password.text ? 'Passwords do not match' : null),
      const SizedBox(height: 24),
      CustomButton(text: 'Create account', isLoading: _loading, onPressed: _submit),
    ])))),
  );
}
