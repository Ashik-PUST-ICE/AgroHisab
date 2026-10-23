import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _tokenStorage = TokenStorage();

  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    _loadSavedLogin();
  }

  Future<void> _loadSavedLogin() async {
    final saved = await _tokenStorage.getSavedLogin();
    if (saved != null && saved.isNotEmpty) {
      setState(() {
        _loginController.text = saved;
      });
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      emailOrPhone: _loginController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    if (mounted) {
      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(authProvider.errorMessage ?? 'লগইন ব্যর্থ হয়েছে'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Leaf Logo Icon
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: AppColors.accentLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.eco_rounded, size: 44, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'কৃষি বাণিজ্য সাথী',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'লগইন করুন',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Email / Mobile Input
                CustomTextField(
                  label: 'মোবাইল নম্বর / ইমেইল',
                  hint: 'যেমন: 01711223344 অথবা ইমেইল',
                  controller: _loginController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'মোবাইল নম্বর বা ইমেইল প্রদান করুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Password Input with Eye Toggle
                CustomTextField(
                  label: 'পাসওয়ার্ড',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'পাসওয়ার্ড প্রদান করুন';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Remember Me & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setState(() => _rememberMe = val ?? false),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'আমাকে মনে রাখুন',
                          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                        return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('পাসওয়ার্ড রিসেট করতে অ্যাডমিনের সাথে যোগাযোগ করুন')),
                        );
                      },
                      child: const Text(
                        'পাসওয়ার্ড ভুলে গেছেন?',
                        style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Login Button
                CustomButton(
                  text: 'লগইন',
                  isLoading: authProvider.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 20),

                // Divider Or
                Row(
                  children: const [
                    Expanded(child: Divider(color: AppColors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('অথবা', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 20),

                // Create Account Button
                CustomButton(
                  text: 'নতুন অ্যাকাউন্ট তৈরি করুন',
                  isOutline: true,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                    return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('নতুন অ্যাকাউন্ট খুলতে অ্যাডমিনের সহায়তা নিন')),
                    );
                  },
                ),
                const SizedBox(height: 36),

                // Help footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('ব্যবহার করতে সমস্যা? ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      'যোগাযোগ করুন',
                      style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
