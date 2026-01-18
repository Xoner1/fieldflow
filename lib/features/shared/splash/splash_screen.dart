import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  /// Starts a timer for 3 seconds then navigates to the Login Screen
  void _startTimer() {
    Timer(const Duration(seconds: 3), () {
      // Navigate to LoginScreen and remove the Splash from the back stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use the company primary color for the background
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Display Company Logo (Placeholder icon if image not found yet)
            // Later we will use Image.asset(AppConfig.appLogoPath)
            const Icon(
              Icons.business,
              size: 100,
              color: AppConfig.primaryColor,
            ),

            const SizedBox(height: 20),

            // 2. Display Company Name from AppConfig
            Text(
              AppConfig.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConfig.primaryColor,
              ),
            ),

            const SizedBox(height: 20),

            // 3. Simple loading indicator
            const CircularProgressIndicator(color: AppConfig.accentColor),
          ],
        ),
      ),
    );
  }
}
