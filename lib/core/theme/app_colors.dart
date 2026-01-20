import 'package:flutter/material.dart';

/// App color palette for LeadX CRM.
///
/// Colors are organized by semantic meaning to ensure
/// consistent usage throughout the app.
abstract class AppColors {
  // ============================================
  // PRIMARY COLORS
  // ============================================
  
  /// Primary brand color - Blue
  static const Color primary = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryContainer = Color(0xFFDBEAFE);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1E3A8A);

  // ============================================
  // SECONDARY COLORS
  // ============================================
  
  /// Secondary color - Teal
  static const Color secondary = Color(0xFF0D9488);
  static const Color secondaryLight = Color(0xFF14B8A6);
  static const Color secondaryDark = Color(0xFF0F766E);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF0F766E);

  // ============================================
  // TERTIARY COLORS
  // ============================================
  
  /// Tertiary color - Amber
  static const Color tertiary = Color(0xFFD97706);
  static const Color tertiaryLight = Color(0xFFF59E0B);
  static const Color tertiaryDark = Color(0xFFB45309);
  static const Color tertiaryContainer = Color(0xFFFEF3C7);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onTertiaryContainer = Color(0xFF92400E);

  // ============================================
  // SEMANTIC COLORS
  // ============================================
  
  /// Success - Green
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successDark = Color(0xFF15803D);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Warning - Orange/Amber
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color onWarning = Color(0xFF000000);

  /// Error - Red
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onError = Color(0xFFFFFFFF);

  /// Info - Blue
  static const Color info = Color(0xFF0284C7);
  static const Color infoLight = Color(0xFF0EA5E9);
  static const Color infoDark = Color(0xFF0369A1);
  static const Color infoContainer = Color(0xFFE0F2FE);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ============================================
  // NEUTRAL COLORS
  // ============================================
  
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);

  // ============================================
  // BACKGROUND & SURFACE (Light Theme)
  // ============================================
  
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);
  static const Color outlineLight = Color(0xFFE2E8F0);
  static const Color outlineVariantLight = Color(0xFFCBD5E1);

  // ============================================
  // BACKGROUND & SURFACE (Dark Theme)
  // ============================================
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);
  static const Color outlineDark = Color(0xFF475569);
  static const Color outlineVariantDark = Color(0xFF64748B);

  // ============================================
  // TEXT COLORS
  // ============================================
  
  /// Light theme text colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color textDisabledLight = Color(0xFFCBD5E1);

  /// Dark theme text colors
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color textDisabledDark = Color(0xFF475569);

  // ============================================
  // PIPELINE STAGE COLORS
  // ============================================
  
  static const Color stageNew = Color(0xFF6366F1);      // Indigo
  static const Color stageP3 = Color(0xFF8B5CF6);       // Purple
  static const Color stageP2 = Color(0xFFF59E0B);       // Amber
  static const Color stageP1 = Color(0xFFEF4444);       // Red (Hot)
  static const Color stageAccepted = Color(0xFF22C55E); // Green (Won)
  static const Color stageDeclined = Color(0xFF6B7280); // Gray (Lost)

  // ============================================
  // ACTIVITY STATUS COLORS
  // ============================================
  
  static const Color activityPlanned = Color(0xFF3B82F6);    // Blue
  static const Color activityInProgress = Color(0xFFF59E0B); // Amber
  static const Color activityCompleted = Color(0xFF22C55E);  // Green
  static const Color activityCancelled = Color(0xFF6B7280);  // Gray
  static const Color activityOverdue = Color(0xFFEF4444);    // Red

  // ============================================
  // SYNC STATUS COLORS
  // ============================================
  
  static const Color syncSynced = Color(0xFF22C55E);   // Green
  static const Color syncPending = Color(0xFFF59E0B); // Amber
  static const Color syncFailed = Color(0xFFEF4444);  // Red
  static const Color syncOffline = Color(0xFF6B7280); // Gray
}
