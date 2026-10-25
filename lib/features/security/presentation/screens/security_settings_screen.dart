import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/security_provider.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  final _currentPinCtrl = TextEditingController();
  final _newPinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SecurityProvider>().fetchSettings();
    });
  }

  @override
  void dispose() {
    _currentPinCtrl.dispose();
    _newPinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SecurityProvider>();
    final settings = prov.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('নিরাপত্তা সেটিংস'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: prov.isLoading && settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ─── Status banner ────────────────────────────────────────
                if (prov.successMessage != null)
                  _banner(prov.successMessage!, isError: false),
                if (prov.errorMessage != null)
                  _banner(prov.errorMessage!, isError: true),

                // ─── Biometric toggle ─────────────────────────────────────
                _sectionCard(
                  icon: Icons.fingerprint_rounded,
                  title: 'বায়োমেট্রিক লগইন',
                  subtitle: 'ফিঙ্গারপ্রিন্ট / ফেস আনলক দিয়ে অ্যাপে প্রবেশ করুন',
                  trailing: Switch.adaptive(
                    value: settings?.biometricEnabled ?? false,
                    activeColor: AppColors.primary,
                    onChanged: prov.isLoading
                        ? null
                        : (val) async {
                            final ok = await prov.updateBiometric(enabled: val);
                            if (mounted && ok) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(val
                                      ? 'বায়োমেট্রিক লগইন চালু হয়েছে ✓'
                                      : 'বায়োমেট্রিক লগইন বন্ধ হয়েছে'),
                                  backgroundColor:
                                      val ? AppColors.success : Colors.grey.shade700,
                                ),
                              );
                            }
                          },
                  ),
                ),

                const SizedBox(height: 16),

                // ─── PIN change ───────────────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(Icons.pin_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            settings != null && settings.hasPin
                                ? 'লেনদেন PIN পরিবর্তন'
                                : 'লেনদেন PIN সেট করুন',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 4),
                        Text(
                          settings != null && settings.hasPin
                              ? 'দ্রুত লেনদেনের জন্য ৪-৬ সংখ্যার PIN পরিবর্তন করুন'
                              : 'দ্রুত লেনদেনের জন্য ৪-৬ সংখ্যার PIN সেট করুন',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 16),
                        if (settings != null && settings.hasPin) ...[
                          _pinField(
                            id: 'current_pin_field',
                            controller: _currentPinCtrl,
                            label: 'বর্তমান PIN',
                            hint: '••••',
                          ),
                          const SizedBox(height: 10),
                        ],
                        _pinField(
                          id: 'new_pin_field',
                          controller: _newPinCtrl,
                          label: 'নতুন PIN',
                          hint: '৪-৬ সংখ্যা',
                        ),
                        const SizedBox(height: 10),
                        _pinField(
                          id: 'confirm_pin_field',
                          controller: _confirmPinCtrl,
                          label: 'PIN নিশ্চিত করুন',
                          hint: '৪-৬ সংখ্যা',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: prov.isLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.lock_reset_rounded),
                            label: Text(
                              prov.isLoading
                                  ? 'অপেক্ষা করুন...'
                                  : (settings != null && settings.hasPin
                                      ? 'PIN পরিবর্তন করুন'
                                      : 'PIN সেট করুন'),
                              style: const TextStyle(fontSize: 15),
                            ),
                            onPressed: prov.isLoading ? null : _submitPin,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Info card ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.accentLight.withOpacity(0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'PIN শুধুমাত্র দ্রুত লেনদেন নিশ্চিতকরণের জন্য ব্যবহৃত হয়। '
                          'এটি আপনার লগইন পাসওয়ার্ড থেকে আলাদা।',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Helper widgets ──────────────────────────────────────────────────────

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentLight.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _pinField({
    required String id,
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextField(
      key: Key(id),
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 6,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.dialpad_rounded),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _banner(String message, {required bool isError}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isError
            ? AppColors.error.withOpacity(0.1)
            : AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isError ? AppColors.error : AppColors.success,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: isError ? AppColors.error : AppColors.success,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: TextStyle(
                      color: isError ? AppColors.error : AppColors.success,
                      fontSize: 13))),
        ],
      ),
    );
  }

  Future<void> _submitPin() async {
    final prov = context.read<SecurityProvider>();
    final settings = prov.settings;
    final hasPin = settings?.hasPin ?? false;

    if (_newPinCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN অবশ্যই ৪-৬ সংখ্যার হতে হবে।')));
      return;
    }
    if (_newPinCtrl.text != _confirmPinCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('নতুন PIN ও নিশ্চিত PIN মিলছে না।')));
      return;
    }

    final ok = await prov.changePin(
      currentPin: hasPin ? _currentPinCtrl.text : null,
      newPin: _newPinCtrl.text,
    );

    if (mounted && ok) {
      _currentPinCtrl.clear();
      _newPinCtrl.clear();
      _confirmPinCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN সফলভাবে আপডেট হয়েছে ✓')));
    }
  }
}

