import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign In Method (FIXED: Added this method back)
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      // It's better to rethrow so the UI can handle the error message
      rethrow;
    }
  }

  // 2. Sign Out Method
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // 3. Get Current User ID
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }
}
