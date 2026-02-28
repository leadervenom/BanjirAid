import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, responder, citizen }

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // STABLE ROLE ENGINE: Used by both Auth and UI
  static UserRole getUserRole(String email) {
    final lowerEmail = email.trim().toLowerCase();
    if (!lowerEmail.contains('@')) return UserRole.citizen;

    // Use endsWith for safer domain checking
    if (lowerEmail.endsWith('@admin.com') || lowerEmail.contains('.admin@')) {
      return UserRole.admin;
    } else if (lowerEmail.endsWith('@rescue.com') || lowerEmail.contains('.rescue@')) {
      return UserRole.responder;
    }

    // Backup "contains" logic
    if (lowerEmail.contains('admin')) return UserRole.admin;
    if (lowerEmail.contains('rescue')) return UserRole.responder;

    return UserRole.citizen;
  }

  String _roleStringFromEnum(UserRole role) {
    switch (role) {
      case UserRole.admin: return 'admin';
      case UserRole.responder: return 'responder';
      default: return 'citizen';
    }
  }

  // SIGN IN
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // We call this but don't AWAIT it if we want the UI to pop immediately, 
      // OR we await it to ensure DB is ready. Let's await for stability.
      await _ensureUserProfile(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Login Error: $e';
    }
  }

  // REGISTER
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _ensureUserProfile(credential.user);
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Registration Error: $e';
    }
  }

  // DATABASE SYNC: This ensures the Firestore 'role' matches the login
  Future<void> _ensureUserProfile(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final computedRole = _roleStringFromEnum(getUserRole(user.email ?? ''));

    try {
      final userDoc = await userRef.get();
      
      if (!userDoc.exists) {
        // Create new profile
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'role': computedRole,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update existing if role is 'rescue' (legacy) or needs promotion
        final data = userDoc.data();
        final currentRole = data?['role']?.toString().toLowerCase();

        if (currentRole == 'rescue' || (currentRole == 'citizen' && computedRole != 'citizen')) {
          await userRef.update({
            'role': computedRole,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (e) {
      print("Error ensuring user profile: $e");
      // Don't throw here, otherwise the user can't log in at all 
      // just because a Firestore write failed.
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'No user found with this email.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'Account already exists.';
      case 'network-request-failed': return 'Check your emulator network connection.';
      default: return e.message ?? 'An unknown error occurred.';
    }
  }
}