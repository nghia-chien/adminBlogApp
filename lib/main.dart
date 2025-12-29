import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'services/api_service.dart';
import 'models/user.dart' as models;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blog Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/dashboard': (context) => const DashboardPage(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Kiểm tra role admin
      models.User? userData;
      try {
        userData = await ApiService.getUser(user.uid);
      } catch (e) {
        userData = null;
      }
      
      if (mounted) {
        // Delay navigation để tránh lỗi setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            if (userData != null && userData.role == 'admin') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const DashboardPage()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }
        });
      }
    } else {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
