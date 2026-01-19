import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection References
  final String _usersCollection = 'users';

  // 1. Create or Update User Data
  Future<void> createUser(UserModel user) async {
    try {
      await _db.collection(_usersCollection).doc(user.id).set(user.toMap());
    } catch (e) {
      // In production, use a logger instead of print
      print("Error creating user: $e"); 
      rethrow;
    }
  }

  // 2. Get Real-time Stream of Workers only
  Stream<List<UserModel>> getWorkersStream() {
    return _db
        .collection(_usersCollection)
        .where('role', isEqualTo: 'worker')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // 3. Get User Role (Fixing the undefined_method error)
  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(_usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
      return null;
    } catch (e) {
      print("Error getting user role: $e");
      return null;
    }
  }
}