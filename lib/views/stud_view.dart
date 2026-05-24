import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/routes/route_manager.dart';

class Studview extends StatefulWidget {
  const Studview({super.key});

  @override
  State<Studview> createState() => _StudviewState();
}

class _StudviewState extends State<Studview> {
  //get AuthService instance
  final AuthService _authService = AuthService();

  //LOGOUT FUNCTION
  void _logout() async {
    await _authService.signOut();
    if (!mounted) {
      return;
    }
    // Navigate to login screen after logout
    Navigator.pushReplacementNamed(context, RouteManager.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student View'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      // Placeholder content for the student view-KING
      body: const Center(child: Text('Welcome to the Student View!')),
    );
  }
}
