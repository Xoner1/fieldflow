import 'package:flutter/material.dart';
import 'core/config/app_config.dart'; // Import AppConfig
import 'features/shared/splash/splash_screen.dart'; // Import SplashScreen

void main() {
  runApp(const FieldFlowApp());
}

class FieldFlowApp extends StatelessWidget {
  const FieldFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName, // Use dynamic name
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConfig.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor),
        useMaterial3: true,
      ),
      // Start with the Splash Screen
      home: const SplashScreen(),
    );
  }
}
