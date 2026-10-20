import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Exact match from UI Showcase mockup
  static const Color primary = Color(0xFF006E38);       // #00D63B adjusted deep forest green
  static const Color primaryDark = Color(0xFF00572C);
  static const Color secondary = Color(0xFF16A34A);     // #16A34A Vibrant Green
  static const Color accentLight = Color(0xFFE8F5EC);   // #E9F8F4 Soft Green Background
  static const Color primaryLight = Color(0xFF4CAF7D);  // Lighter green for gradients

  // Neutral Palette
  static const Color background = Color(0xFFF8FAFC);     // #F8FAFC Page Background
  static const Color cardBackground = Color(0xFFF8FAFC); // Card background
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);   // #1F2937 Dark Slate Text
  static const Color textSecondary = Color(0xFF6B7280); // #6B7280 Caption/Subtext
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFE5E7EB);

  // Status & Feedback Colors - exact from mockup palette
  static const Color success = Color(0xFF10B991);       // #10B991 Success Green
  static const Color warning = Color(0xFFF59E0B);       // #F59E0B Warning Amber
  static const Color error = Color(0xFFEF4444);         // #EF4444 Error Red
  static const Color info = Color(0xFF3B82F6);          // Blue Info

  // Status chip colors matching mockup
  static const Color chipSent = Color(0xFF10B991);       // পাঠানো - success
  static const Color chipReceived = Color(0xFF3B82F6);   // পৌঁছেছে - blue
  static const Color chipPending = Color(0xFFF59E0B);    // বিক্রির অপেক্ষায় - warning
  static const Color chipCancelled = Color(0xFFEF4444);  // বাতিল - error

  // Quick Action Card Colors - from mockup
  static const Color cardOrange = Color(0xFFF97316);    // ক্রয় icon
  static const Color cardGreen = Color(0xFF10B991);     // Stock/চালান icon
  static const Color cardBlue = Color(0xFF3B82F6);      // হিসাব icon
  static const Color cardBrown = Color(0xFFD97706);     // রিপোর্ট icon
  static const Color cardCyan = Color(0xFF06B6D4);      // আড়তদার icon
  static const Color cardIndigo = Color(0xFF6366F1);    // Documents icon
  static const Color cardPurple = Color(0xFF8B5CF6);    // Settings icon
  static const Color cardRed = Color(0xFFEF4444);       // Expense icon
}
