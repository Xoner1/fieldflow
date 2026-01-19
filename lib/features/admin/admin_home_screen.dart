import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import Map Package
import 'package:latlong2/latlong.dart'; // Import Coordinates Package
import 'package:firebase_auth/firebase_auth.dart';
import 'workers/manage_workers_screen.dart'; // Import Workers List
import 'tasks/add_task_screen.dart';
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  // 1. Index to track selected tab (0 = Map, 1 = List)
  int _selectedIndex = 0;

  // 2. List of screens to switch between
  final List<Widget> _screens = [
    const AdminMapTab(), // We will define this widget below
    const ManageWorkersScreen(), // Existing screen we built
  ];

  // 3. Handle Tab Selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 4. Logout Function
  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar remains constant
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),

      // Body switches based on selection
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Workers'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

// --- NEW WIDGET: THE MAP TAB ---
class AdminMapTab extends StatelessWidget {
  const AdminMapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        // Default center location (e.g., Cairo, Tunis, or any default)
        // You can change these coordinates to your city
        initialCenter: const LatLng(36.8065, 10.1815), // Tunis as example
        initialZoom: 13.0,
      ),
      children: [
        // Layer 1: The Map Tiles (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.fieldflow.app', // Best practice
        ),

        // Layer 2: Markers (Pins)
        const MarkerLayer(
          markers: [
            // Example Static Marker (We will make this dynamic later)
            Marker(
              point: LatLng(36.8065, 10.1815),
              width: 80,
              height: 80,
              child: Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          ],
        ),
      ],
    );
  }
}
