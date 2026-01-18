import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/database_service.dart';

class ManageWorkersScreen extends StatefulWidget {
  const ManageWorkersScreen({super.key});

  @override
  State<ManageWorkersScreen> createState() => _ManageWorkersScreenState();
}

class _ManageWorkersScreenState extends State<ManageWorkersScreen> {
  // Services
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  // Controllers for the Add Worker Form
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isCreating = false; // To show loading spinner inside dialog

 // --- FUNCTION: Open the "Add Worker" Dialog ---
  void _showAddWorkerDialog() {
    _nameController.clear();
    _emailController.clear();
    _passwordController.clear();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Add New Worker"),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: "Full Name", prefixIcon: Icon(Icons.person)),
                        validator: (v) => v!.isEmpty ? "Name required" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                        validator: (v) => !v!.contains('@') ? "Valid email required" : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
                        obscureText: true,
                        validator: (v) => v!.length < 6 ? "Min 6 chars" : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isCreating ? null : () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: _isCreating
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setStateDialog(() => _isCreating = true);

                            // 1. CAPTURE TOOLS HERE (Before await) 🛡️
                            // We grab the navigator and messenger NOW, while the screen is definitely there.
                            final navigator = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);

                            try {
                              final user = await _authService.createWorker(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );

                              if (user != null) {
                                await _databaseService.addUser(
                                  user.uid,
                                  UserModel(
                                    id: user.uid,
                                    email: _emailController.text.trim(),
                                    name: _nameController.text.trim(),
                                    role: 'worker',
                                  ).toMap(),
                                );

                                // 2. USE CAPTURED TOOLS (Safe execution)
                                navigator.pop(); // Close Dialog safely
                                messenger.showSnackBar(
                                  const SnackBar(content: Text("Worker Added Successfully!"), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                               // Use captured messenger for error too
                               messenger.showSnackBar(
                                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                                );
                            } finally {
                              if(mounted) {
                                setStateDialog(() => _isCreating = false);
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: _isCreating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
} 