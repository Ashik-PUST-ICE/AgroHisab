import 'package:flutter/material.dart';
import '../../data/models/security_settings_model.dart';
import '../../data/services/security_api_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityApiService _service = SecurityApiService();

  SecuritySettingsModel? _settings;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  SecuritySettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  Future<void> fetchSettings() async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    try {
      _settings = await _service.getSecuritySettings();
    } catch (e) {
      _errorMessage = 'সিকিউরিটি সেটিংস লোড হয়নি।';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change or set the transaction PIN.
  /// [currentPin] is null when no PIN exists yet (first-time setup).
  Future<bool> changePin({String? currentPin, required String newPin}) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    final response = await _service.changePin(currentPin: currentPin, newPin: newPin);
    _isLoading = false;
    if (response.success) {
      _successMessage = 'PIN সফলভাবে পরিবর্তন হয়েছে।';
      if (_settings != null) {
        _settings = SecuritySettingsModel(
          hasPin: true,
          biometricEnabled: _settings!.biometricEnabled,
          randomizePinKeyboard: _settings!.randomizePinKeyboard,
          otpChannel: _settings!.otpChannel,
          mnpMasked: _settings!.mnpMasked,
        );
      }
    } else {
      _errorMessage = response.message.isNotEmpty
          ? response.message
          : 'PIN পরিবর্তন ব্যর্থ হয়েছে।';
    }
    notifyListeners();
    return response.success;
  }

  /// Toggle biometric (fingerprint / face) unlock.
  Future<bool> updateBiometric({required bool enabled}) async {
    _isLoading = true;
    _clearMessages();
    notifyListeners();
    final response = await _service.updateBiometric(enabled: enabled);
    _isLoading = false;
    if (response.success) {
      _successMessage =
          enabled ? 'বায়োমেট্রিক লগইন চালু হয়েছে।' : 'বায়োমেট্রিক লগইন বন্ধ হয়েছে।';
      if (_settings != null) {
        _settings = SecuritySettingsModel(
          hasPin: _settings!.hasPin,
          biometricEnabled: enabled,
          randomizePinKeyboard: _settings!.randomizePinKeyboard,
          otpChannel: _settings!.otpChannel,
          mnpMasked: _settings!.mnpMasked,
        );
      }
    } else {
      _errorMessage = response.message.isNotEmpty
          ? response.message
          : 'বায়োমেট্রিক আপডেট ব্যর্থ হয়েছে।';
    }
    notifyListeners();
    return response.success;
  }
}
