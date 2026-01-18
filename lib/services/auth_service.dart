import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart'; // Required for temporary app
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Sign In Method
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Error: ${e.message}');
      throw e.message ?? 'An unknown error occurred';
    } catch (e) {
      debugPrint('General Error: $e');
      throw 'System Error: Could not login.';
    }
  }

  // 2. Sign Out Method
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }

  // 3. Get Current User
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 4. Create Worker (The "Backdoor" Method) 🌟
  // This creates a user WITHOUT logging out the current Admin
  Future<User?> createWorker(String email, String password) async {
    FirebaseApp? tempApp;
    try {
      // Initialize a secondary Firebase App instance
      // We use the same options (keys) as the main app
      tempApp = await Firebase.initializeApp(
        name: 'tempWorkerApp', 
        options: Firebase.app().options,
      );

      // Get the Auth instance of this secondary app
      FirebaseAuth tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      // Create the user using the secondary connection
      UserCredential result = await tempAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("Worker created successfully: ${result.user?.uid}");
      return result.user;

    } on FirebaseAuthException catch (e) {
      debugPrint('Error creating worker: ${e.message}');
      throw e.message ?? 'Failed to create worker';
    } finally {
      // CRITICAL: Delete the temp app to free resources
      // If we don't do this, the app will crash on the second try
      await tempApp?.delete();
    }
  }
}