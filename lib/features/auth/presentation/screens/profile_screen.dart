import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _filled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.refreshProfile();
      if (mounted) _fill(auth);
    });
  }

  void _fill(AuthProvider auth) {
    if (_filled || auth.currentUser == null) return;
    final user = auth.currentUser!;
    _firstName.text = user.firstName ?? user.name;
    _lastName.text = user.lastName ?? '';
    _email.text = user.email ?? '';
    _mobile.text = user.phone ?? '';
    _filled = true;
  }

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _email, _mobile, _currentPassword, _newPassword, _confirmPassword]) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _fill(auth);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile'), backgroundColor: AppColors.primary, foregroundColor: Colors.white),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(child: CircleAvatar(radius: 38, backgroundColor: AppColors.accentLight, child: const Icon(Icons.person, size: 44, color: AppColors.primary))),
        const SizedBox(height: 18),
        _section('Personal information', [
          CustomTextField(label: 'First name', controller: _firstName),
          const SizedBox(height: 10),
          CustomTextField(label: 'Last name', controller: _lastName),
          const SizedBox(height: 10),
          CustomTextField(label: 'Email', controller: _email, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 10),
          CustomTextField(label: 'Phone number', controller: _mobile, keyboardType: TextInputType.phone),
          const SizedBox(height: 14),
          CustomButton(text: 'Save profile', icon: Icons.save_rounded, isLoading: auth.isLoading, onPressed: auth.isLoading ? null : _saveProfile),
        ]),
        const SizedBox(height: 16),
        _section('Change password', [
          CustomTextField(label: 'Current password', controller: _currentPassword, obscureText: true),
          const SizedBox(height: 10),
          CustomTextField(label: 'New password', controller: _newPassword, obscureText: true),
          const SizedBox(height: 10),
          CustomTextField(label: 'Confirm new password', controller: _confirmPassword, obscureText: true),
          const SizedBox(height: 14),
          CustomButton(text: 'Update password', icon: Icons.lock_outline_rounded, isOutline: true, isLoading: auth.isLoading, onPressed: auth.isLoading ? null : _changePassword),
        ]),
        if (auth.errorMessage != null) ...[const SizedBox(height: 12), Text(auth.errorMessage!, style: const TextStyle(color: AppColors.error))],
      ]),
    );
  }

  Widget _section(String title, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 14), ...children])));

  Future<void> _saveProfile() async {
    final ok = await context.read<AuthProvider>().updateProfile(firstName: _firstName.text, lastName: _lastName.text, email: _email.text, mobile: _mobile.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Profile updated successfully.' : 'Profile update failed.')));
  }

  Future<void> _changePassword() async {
    if (_newPassword.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New password confirmation does not match.')));
      return;
    }
    final ok = await context.read<AuthProvider>().changePassword(currentPassword: _currentPassword.text, password: _newPassword.text, confirmation: _confirmPassword.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Password changed successfully.' : 'Password change failed.')));
  }
}
