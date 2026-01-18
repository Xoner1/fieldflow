import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

import '../../features/admin/dashboard/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthService _authService = AuthService();
  final DatabaseService _databaseService = DatabaseService();

  bool _isObscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      try {
        // 1. Authenticate
        await _authService.signIn(email, password);

        // 2. Get Role
        final role = await _databaseService.getUserRole(email);

        if (!mounted) return;

        // 3. Navigate based on Role
        if (role == 'admin') {
          // Success Message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome Admin!'), backgroundColor: Colors.green),
          );

          // NAVIGATE TO ADMIN DASHBOARD (Replace current screen)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
          );

        } else if (role == 'worker') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Welcome Worker!'), backgroundColor: Colors.blue),
          );
          // TODO: Navigate to Worker Home (We will build this later)
          
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No Role Found.'), backgroundColor: Colors.red),
          );
          await _authService.signOut();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Login Failed: ${e.toString()}"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.business, size: 80, color: AppConfig.primaryColor),
                const SizedBox(height: 16),
                Text(
                  AppConfig.appName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConfig.primaryColor),
                ),
                const SizedBox(height: 8),
                const Text("Sign in to your account", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Valid email required' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    labelText: "Password",
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isObscure = !_isObscure),
                    ),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Password required' : null,
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}