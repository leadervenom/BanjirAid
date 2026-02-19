import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart'; // ADD THIS LINE
import 'screens/auth/login_screen.dart';
import 'screens/citizen/citizen_home_screen.dart';
import 'screens/responder/responder_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ADD THIS LINE
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

  @override
  Widget build(BuildContext context) {
    final email = user.email?.toLowerCase() ?? '';
    final role = AuthService.getUserRole(email);

    switch (role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.rescuer:
        return const ResponderDashboard();
      case UserRole.citizen:
        return const CitizenHomeScreen();
    }
  }
}


