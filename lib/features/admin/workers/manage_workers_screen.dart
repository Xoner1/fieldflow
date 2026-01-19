import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../services/database_service.dart';

class ManageWorkersScreen extends StatefulWidget {
  const ManageWorkersScreen({super.key});

  @override
  State<ManageWorkersScreen> createState() => _ManageWorkersScreenState();
}

class _ManageWorkersScreenState extends State<ManageWorkersScreen> {
  // Service instances
  final DatabaseService _dbService = DatabaseService();

  // Text controllers for the dialog input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Method to show the dialog for adding a new worker
 // Method to show the dialog for adding a new worker
  void _showAddWorkerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // We use StatefulBuilder to update the dialog state specifically
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Add New Worker'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Full Name'),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  // Disable button if loading
                  onPressed: _isLoading 
                      ? null 
                      : () async {
                          // Update dialog state to show loading
                          setStateDialog(() => _isLoading = true);
                          
                          // Perform action
                          await _addNewWorker();
                          
                          // Check if mounted before updating state
                          if (mounted) {
                             // Reset loading state (though dialog usually closes)
                             setStateDialog(() => _isLoading = false);
                             Navigator.pop(context);
                          }
                        },
                  // Show Progress Indicator if loading, else show Text
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        ) 
                      : const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Logic to add worker to Firestore
  Future<void> _addNewWorker() async {
    setState(() => _isLoading = true);

    try {
      // Generate a temporary ID based on time
      String tempId = DateTime.now().millisecondsSinceEpoch.toString(); 

      // Create the model using the correct 'id' parameter
      UserModel newWorker = UserModel(
        id: tempId, 
        email: _emailController.text.trim(),
        name: _nameController.text.trim(),
        role: 'worker',
      );

      // Call the service method (now it exists)
      await _dbService.createUser(newWorker);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Worker added successfully!')),
        );
      }
      
      // Clear inputs
      _nameController.clear();
      _emailController.clear();
      _passwordController.clear();

    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Workers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddWorkerDialog,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<UserModel>>(
        // Now this method exists in DatabaseService
        stream: _dbService.getWorkersStream(),
        builder: (context, snapshot) {
          // Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error State
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Empty State
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workers found.'));
          }

          // Data State
          final workers = snapshot.data!;
          return ListView.builder(
            itemCount: workers.length,
            itemBuilder: (context, index) {
              final worker = workers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(worker.name.isNotEmpty ? worker.name[0].toUpperCase() : '?'),
                ),
                title: Text(worker.name),
                subtitle: Text(worker.email),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
      ),
    );
  }
}