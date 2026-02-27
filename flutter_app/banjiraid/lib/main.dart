import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; 
import 'screens/auth/login_screen.dart';
import 'screens/citizen/citizen_home_screen.dart';
import 'screens/responder/responder_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

/// TEMPORARY: Set to "admin", "responder", or "citizen" to bypass auth logic.
/// Set to "null" (as a string) to use real Firestore/Email logic.
String kForceRole = "null";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BanjirAidApp());
}

class BanjirAidApp extends StatelessWidget {
  const BanjirAidApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BanjirAid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return RoleBasedRouter(user: snapshot.data!);
        }
        return const LoginScreen();
      },
    );
  }
}

class RoleBasedRouter extends StatelessWidget {
  final User user;
  const RoleBasedRouter({Key? key, required this.user}) : super(key: key);

  /// Logic to guess role from email if Firestore document is missing
  String _roleFromEmail(String? email) {
    final lowerEmail = (email ?? '').trim().toLowerCase();
    if (!lowerEmail.contains('@')) return 'citizen';

    // Strict domain checking to prevent "badminton_admin@gmail.com" exploits
    if (lowerEmail.contains('@admin.') || lowerEmail.endsWith('@admin.com')) return 'admin';
    if (lowerEmail.contains('@rescue.') || lowerEmail.endsWith('@rescue.com')) return 'responder';
    
    // Fallback search
    if (lowerEmail.contains('admin')) return 'admin';
    if (lowerEmail.contains('rescue')) return 'responder';
    
    return 'citizen';
  }

  /// Merges Firestore data with Email hints for a final decision
  String _resolveRole(Map<String, dynamic>? userData, String? email) {
    if (userData == null) return _roleFromEmail(email);

    final rawRole = userData['role']?.toString().toLowerCase();
    
    // Normalize 'rescue' to 'responder' for routing consistency
    if (rawRole == 'admin') return 'admin';
    if (rawRole == 'responder' || rawRole == 'rescue') return 'responder';
    
    return 'citizen';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Debug Overrides (Highest Priority)
    if (kForceRole == 'admin') return const AdminDashboard();
    if (kForceRole == 'responder') return const ResponderDashboard();
    if (kForceRole == 'citizen') return const CitizenHomeScreen();

    // 2. Real-time Role Resolution via Firestore
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle errors (Permission denied is common here)
        if (snapshot.hasError) {
          return FirestoreAccessErrorScreen(
            message: 'Database connection failed.',
            details: snapshot.error.toString(),
          );
        }

        // Resolve role using both Firestore data and Email as a backup
        final role = _resolveRole(snapshot.data?.data(), user.email);

        debugPrint('Routing User: ${user.email} as Role: $role');

        switch (role) {
          case 'admin':
            return const AdminDashboard();
          case 'responder':
            return const ResponderDashboard();
          case 'citizen':
          default:
            return const CitizenHomeScreen();
        }
      },
    );
  }
}

class FirestoreAccessErrorScreen extends StatelessWidget {
  final String message;
  final String? details;

  const FirestoreAccessErrorScreen({
    Key? key,
    required this.message,
    this.details,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Error')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_maybe_outlined, size: 80, color: Colors.orange),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (details != null) ...[
                const SizedBox(height: 10),
                Text(details!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                child: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}