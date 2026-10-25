import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../security/presentation/screens/security_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Profile tab controllers
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  String _locale = 'bn';
  File? _pickedImage;
  bool _filled = false;

  // Password tab controllers
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.refreshProfile();
      if (mounted) _fillFromUser(auth);
    });
  }

  void _fillFromUser(AuthProvider auth) {
    if (_filled || auth.currentUser == null) return;
    final user = auth.currentUser!;
    _firstName.text = user.firstName ?? user.name;
    _lastName.text = user.lastName ?? '';
    _email.text = user.email ?? '';
    _mobile.text = user.phone ?? '';
    _locale = user.locale ?? 'bn';
    _filled = true;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (final c in [
      _firstName, _lastName, _email, _mobile,
      _currentPassword, _newPassword, _confirmPassword,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 800,
    );
    if (picked != null && mounted) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _fillFromUser(auth);
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('আমার প্রোফাইল'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.person_rounded), text: 'প্রোফাইল'),
            Tab(icon: Icon(Icons.lock_outline_rounded), text: 'পাসওয়ার্ড'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Profile ────────────────────────────────────────────
          _buildProfileTab(auth, user),
          // ── Tab 2: Change Password ────────────────────────────────────
          _buildPasswordTab(auth),
        ],
      ),
    );
  }

  // ── Profile Tab ────────────────────────────────────────────────────────

  Widget _buildProfileTab(AuthProvider auth, user) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Avatar
        Center(
          child: Stack(
            children: [
              CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.accentLight,
                backgroundImage:
                    _pickedImage != null ? FileImage(_pickedImage!) : null,
                child: _pickedImage == null
                    ? (user?.avatarUrl != null
                        ? null
                        : const Icon(Icons.person_rounded,
                            size: 54, color: AppColors.primary))
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_pickedImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Center(
              child: Text(
                'নতুন ছবি নির্বাচিত (সেভ করলে আপলোড হবে)',
                style: TextStyle(
                    fontSize: 12, color: AppColors.primary.withOpacity(0.8)),
              ),
            ),
          ),
        const SizedBox(height: 20),

        // Personal info card
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('ব্যক্তিগত তথ্য',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                CustomTextField(
                  label: 'প্রথম নাম',
                  controller: _firstName,
                  prefixIcon: const Icon(Icons.badge_rounded),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'শেষ নাম',
                  controller: _lastName,
                  prefixIcon: const Icon(Icons.badge_outlined),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'ইমেইল',
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_rounded),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  label: 'মোবাইল নম্বর',
                  controller: _mobile,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                const SizedBox(height: 14),

                // Locale selector
                const Text('ভাষা / Locale',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Row(children: [
                  _localeChip('bn', 'বাংলা', '🇧🇩'),
                  const SizedBox(width: 10),
                  _localeChip('en', 'English', '🇬🇧'),
                ]),
                const SizedBox(height: 16),

                CustomButton(
                  text: 'প্রোফাইল সেভ করুন',
                  icon: Icons.save_rounded,
                  isLoading: auth.isLoading,
                  onPressed: auth.isLoading ? null : _saveProfile,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Security settings shortcut
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: AppColors.accentLight, shape: BoxShape.circle),
              child:
                  const Icon(Icons.security_rounded, color: AppColors.primary),
            ),
            title: const Text('নিরাপত্তা সেটিংস'),
            subtitle:
                const Text('PIN পরিবর্তন ও বায়োমেট্রিক লগইন'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SecuritySettingsScreen()),
            ),
          ),
        ),

        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          _errorBanner(auth.errorMessage!),
        ],
      ],
    );
  }

  // ── Password Tab ───────────────────────────────────────────────────────

  Widget _buildPasswordTab(AuthProvider auth) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Strength guide card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'নতুন পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে এবং একটি বড় হাতের অক্ষর, সংখ্যা বা বিশেষ চিহ্ন থাকা বাঞ্ছনীয়।',
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('পাসওয়ার্ড পরিবর্তন',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),

                // Current password
                TextField(
                  key: const Key('current_password_field'),
                  controller: _currentPassword,
                  obscureText: !_showCurrent,
                  decoration: InputDecoration(
                    labelText: 'বর্তমান পাসওয়ার্ড',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(_showCurrent
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _showCurrent = !_showCurrent),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // New password
                TextField(
                  key: const Key('new_password_field'),
                  controller: _newPassword,
                  obscureText: !_showNew,
                  decoration: InputDecoration(
                    labelText: 'নতুন পাসওয়ার্ড',
                    prefixIcon: const Icon(Icons.lock_open_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(_showNew
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _showNew = !_showNew),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm new password
                TextField(
                  key: const Key('confirm_password_field'),
                  controller: _confirmPassword,
                  obscureText: !_showConfirm,
                  decoration: InputDecoration(
                    labelText: 'নতুন পাসওয়ার্ড নিশ্চিত করুন',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    suffixIcon: IconButton(
                      icon: Icon(_showConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _showConfirm = !_showConfirm),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('change_password_btn'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: auth.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.lock_rounded),
                    label: Text(
                      auth.isLoading ? 'অপেক্ষা করুন...' : 'পাসওয়ার্ড পরিবর্তন করুন',
                      style: const TextStyle(fontSize: 15),
                    ),
                    onPressed: auth.isLoading ? null : _submitPasswordChange,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (auth.errorMessage != null) ...[
          const SizedBox(height: 12),
          _errorBanner(auth.errorMessage!),
        ],
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _localeChip(String value, String label, String emoji) {
    final selected = _locale == value;
    return GestureDetector(
      onTap: () => setState(() => _locale = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$emoji  $label',
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.error, fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_firstName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('প্রথম নাম দেওয়া আবশ্যক।')));
      return;
    }
    final ok = await context.read<AuthProvider>().updateProfile(
          firstName: _firstName.text,
          lastName: _lastName.text,
          email: _email.text,
          mobile: _mobile.text,
          locale: _locale,
          image: _pickedImage,
        );
    if (mounted) {
      if (ok) {
        setState(() => _pickedImage = null);
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'প্রোফাইল সফলভাবে আপডেট হয়েছে ✓'
              : 'প্রোফাইল আপডেট ব্যর্থ হয়েছে।')));
    }
  }

  Future<void> _submitPasswordChange() async {
    if (_currentPassword.text.isEmpty ||
        _newPassword.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সব ঘর পূরণ করুন।')));
      return;
    }
    if (_newPassword.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('নতুন পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।')));
      return;
    }
    if (_newPassword.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('পাসওয়ার্ড নিশ্চিতকরণ মিলছে না।')));
      return;
    }
    final ok = await context.read<AuthProvider>().changePassword(
          currentPassword: _currentPassword.text,
          password: _newPassword.text,
          passwordConfirmation: _confirmPassword.text,
        );
    if (mounted) {
      if (ok) {
        _currentPassword.clear();
        _newPassword.clear();
        _confirmPassword.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ok
              ? 'পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে ✓'
              : 'পাসওয়ার্ড পরিবর্তন ব্যর্থ হয়েছে।')));
    }
  }
}

