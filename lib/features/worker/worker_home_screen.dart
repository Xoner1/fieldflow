import 'dart:io';
import 'dart:async'; // For managing continuous updates
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart'; // ✅ New GPS library

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  StreamSubscription<Position>? _positionStream; // Variable to monitor location

  @override
  void initState() {
    super.initState();
    _initLocationTracking(); // ✅ Start tracking when app opens
  }

  @override
  void dispose() {
    _positionStream?.cancel(); // Stop tracking when closing app to save battery
    super.dispose();
  }

  // 🌍 Function to setup and start GPS
  Future<void> _initLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Ensure location services are enabled on the phone
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return;
    }

    // 2. Request permission from user
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied.');
      return;
    }

    // 3. Start tracking location (updates every time worker moves 100 meters)
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every 100 meters (to reduce load on database)
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (Position position) {
            _updateLocationInFirestore(position);
          },
        );
  }

  // 💾 Update location in database
  Future<void> _updateLocationInFirestore(Position position) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lastLocationUpdate':
                FieldValue.serverTimestamp(), // To know when was last seen
          });
      debugPrint(
        "📍 Location Updated: ${position.latitude}, ${position.longitude}",
      );
    } catch (e) {
      debugPrint("Error updating location: $e");
    }
  }

  // ... (Rest of functions: _logout, _makePhoneCall, _openMap, _startTask, etc.. remain same)
  // Rewriting them here to ensure old code isn't lost

  void _logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) await launchUrl(launchUri);
  }

  Future<void> _openMap(String address) async {
    final query = Uri.encodeComponent(address);
    final googleMapsUrl = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$query",
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _startTask(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': 'in_progress',
    });
  }

  Future<void> _finishTask(String taskId) async {
    await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
      'status': 'done',
    });
  }

  Future<void> _uploadImage(String taskId) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _isUploading = true);
    try {
      File file = File(image.path);
      String fileName =
          'tasks/$taskId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(fileName)
          .putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({
        'images': FieldValue.arrayUnion([downloadUrl]),
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Image uploaded! 📸')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tasks')
                .where('workerId', isEqualTo: currentUserId)
                .where('status', whereIn: ['pending', 'in_progress'])
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text("No active tasks. Good job! ☕"),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var taskDoc = snapshot.data!.docs[index];
                  var data = taskDoc.data() as Map<String, dynamic>;
                  String status = data['status'] ?? 'pending';
                  String taskId = taskDoc.id;

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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['title'] ?? 'Task',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _buildStatusBadge(status),
                            ],
                          ),
                          const Divider(),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                            ),
                            title: Text(data['address'] ?? 'No Address'),
                            trailing: IconButton(
                              icon: const Icon(Icons.map, color: Colors.blue),
                              onPressed: () => _openMap(data['address']),
                            ),
                          ),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(
                              Icons.phone,
                              color: Colors.green,
                            ),
                            title: Text(data['clientPhone'] ?? 'No Phone'),
                            trailing: IconButton(
                              icon: const Icon(Icons.call, color: Colors.green),
                              onPressed: () =>
                                  _makePhoneCall(data['clientPhone']),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (status == 'pending') ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _startTask(taskId),
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Start Task"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ] else if (status == 'in_progress') ...[
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _uploadImage(taskId),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text("Add Photo"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey[800],
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _finishTask(taskId),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text("Finish"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (data['images'] != null &&
                                (data['images'] as List).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  "📸 ${(data['images'] as List).length} photos attached",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = status == 'in_progress' ? Colors.orange : Colors.grey;
    String text = status == 'in_progress' ? 'In Progress ⏳' : 'Pending 🛑';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
