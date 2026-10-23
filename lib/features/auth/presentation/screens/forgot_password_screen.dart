import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  @override
  void dispose() { _email.dispose(); super.dispose(); }

  Future<void> _submit() async {
    if (!_email.text.contains('@')) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email'))); return; }
    setState(() => _loading = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final ok = await auth.forgotPassword(_email.text);
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Password reset link sent' : (auth.errorMessage ?? 'Request failed')), backgroundColor: ok ? AppColors.success : AppColors.error));
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Forgot password')), body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Icon(Icons.lock_reset_rounded, color: AppColors.primary, size: 58),
    const SizedBox(height: 16),
    const Text('Reset your password', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    const Text('Enter the email connected to your account. We will send you a reset link.', style: TextStyle(color: AppColors.textSecondary)),
    const SizedBox(height: 24),
    CustomTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
    const SizedBox(height: 20),
    CustomButton(text: 'Send reset link', isLoading: _loading, onPressed: _submit),
  ]))));
}
