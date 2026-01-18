import 'package:flutter/material.dart';

/// This class holds the specific configuration for the current company using the app.
/// Change these values to rebrand the application for a different client.
class AppConfig {
  // Prevent instantiation
  AppConfig._();

  // --- Company Identity ---

  /// The name of the company/app displayed on the login screen and headers
  static const String appName = "FieldFlow Demo";

  /// The path to the company logo asset
  // We will create this folder in the next step
  static const String appLogoPath = "assets/images/logo.png";

  // --- Theme Colors ---

  /// The primary color of the company brand
  static const Color primaryColor = Color(0xFF2196F3); // Default Blue

  /// The accent color for buttons and interactive elements
  static const Color accentColor = Color(0xFFFFC107); // Amber for visibility

  // --- Backend Configuration (Placeholder) ---

  /// In the future, this will hold the specific Firebase URL or Collection prefix for the company
  static const String companyId = "demo_company_01";
}
