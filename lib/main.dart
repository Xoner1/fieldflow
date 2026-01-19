import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// Import Screens
import 'features/shared/auth/login_screen.dart';
import 'features/admin/admin_home_screen.dart';
import 'features/worker/worker_home_screen.dart'; // Import Worker Screen
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FieldFlowApp());
}

class FieldFlowApp extends StatelessWidget {
  const FieldFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FieldFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseService dbService = DatabaseService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Check connection status
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If no user is logged in, show Login Screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        final User user = snapshot.data!;

        // 3. If user is logged in, check their role
        return FutureBuilder<String?>(
          future: dbService.getUserRole(user.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final String? role = roleSnapshot.data;

            if (role == 'admin') {
              return const AdminHomeScreen();
            } else if (role == 'worker') {
              return const WorkerHomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        );
      },
    );
  }
}
