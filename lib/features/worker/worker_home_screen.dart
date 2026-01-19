import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart'; // For making calls (Need to add to pubspec later)

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Logout Function
  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  // Function to make a phone call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint("Could not launch $launchUri");
    }
  }

  @override
  Widget build(BuildContext context) {
    print("👷 Worker ID logged in: $currentUserId"); // DEBUG PRINT

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 🔍 Query: Give me tasks where 'workerId' equals MY ID
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('workerId', isEqualTo: currentUserId)
            .where('status', isEqualTo: 'pending') // Only show pending tasks
            .snapshots(),
        builder: (context, snapshot) {
          // 1. Loading State
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // 3. No Tasks Found
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "No pending tasks. Good job!",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          }

          // 4. Show Tasks List
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var task = snapshot.data!.docs[index];
              var data = task.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['title'] ?? 'Untitled Task',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                      const Divider(),

                      // Details: Address
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(data['address'] ?? 'No address'),
                          ),
                        ],
                      ),

                      // Details: Phone
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(data['clientPhone'] ?? 'No phone'),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Action Buttons (Call & Map)
                      Row(
                        children: [
                          // Call Button
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _makePhoneCall(data['clientPhone'] ?? ''),
                              icon: const Icon(Icons.call),
                              label: const Text("Call Client"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Map Button (Simple Placeholder for now)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final query = Uri.encodeComponent(
                                  data['address'],
                                );
                                final googleMapsUrl = Uri.parse(
                                  "https://www.google.com/maps/search/?api=1&query=$query",
                                );

                                if (await canLaunchUrl(googleMapsUrl)) {
                                  await launchUrl(
                                    googleMapsUrl,
                                    mode: LaunchMode.externalApplication,
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Could not open maps"),
                                    ),
                                  );
                                }
                              },

                              icon: const Icon(Icons.map),
                              label: const Text("Location"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
