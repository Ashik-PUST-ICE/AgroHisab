class SecuritySettingsModel {
  final bool hasPin;
  final bool biometricEnabled;
  final bool randomizePinKeyboard;
  final String? otpChannel;
  final String? mnpMasked;

  const SecuritySettingsModel({
    required this.hasPin,
    required this.biometricEnabled,
    required this.randomizePinKeyboard,
    this.otpChannel,
    this.mnpMasked,
  });

  factory SecuritySettingsModel.fromJson(Map<String, dynamic> json) {
    return SecuritySettingsModel(
      hasPin: json['has_pin'] == true,
      biometricEnabled: json['biometric_enabled'] == true,
      randomizePinKeyboard: json['randomize_pin_keyboard'] == true,
      otpChannel: json['otp_channel'] as String?,
      mnpMasked: json['mnp'] as String?,
    );
  }
}
