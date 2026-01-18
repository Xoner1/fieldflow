import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // For debugPrint
import '../models/user_model.dart'; // Import the new model

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Get User Role (Used in Login)
  Future<String?> getUserRole(String email) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        var userDoc = snapshot.docs.first;
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      } else {
        debugPrint('No user found with email: $email');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user role: $e');
      return null;
    }
  }

  // 2. Add User (Used for Setup & later for Admin to add workers)
  Future<void> addUser(String userId, Map<String, dynamic> userData) async {
    try {
      await _db.collection('users').doc(userId).set(userData);
      debugPrint('User added to Firestore: $userId');
   } catch (e) {
      debugPrint('Error adding user: $e');
      rethrow; 
    }
  }

  // 3. Get Workers Stream (New Feature 🌟)
  // This opens a live connection to the database
  Stream<List<UserModel>> getWorkersStream() {
    return _db
        .collection('users')
        .where('role', isEqualTo: 'worker') // Filter: Only workers
        .snapshots() // This makes it a Stream (Live updates)
        .map((snapshot) {
      // Convert the raw data (JSON) into a List of UserModels
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }
}