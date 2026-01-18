import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../shared/auth/login_screen.dart';
// Import the ManageWorkersScreen
import '../workers/manage_workers_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Top Bar ---
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.green,
        actions: [
          // Logout Button (Only this stays in the App Bar)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),

      // --- Main Content ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.admin_panel_settings, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Welcome, System Admin!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text("Here you will manage tasks and workers."),
            
            const SizedBox(height: 40), // Space before the button

            // --- Manage Workers Button (MOVED HERE) ---
            ElevatedButton.icon(
              icon: const Icon(Icons.people),
              label: const Text("Manage Workers"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                // Navigate to the Workers List Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageWorkersScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}