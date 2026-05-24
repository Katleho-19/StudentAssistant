import 'package:flutter/material.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  Future<String> _resolveRoute(String userId, String? email) async {
    final client = Supabase.instance.client;

    final admin = await client
        .from('admin')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();
    if (admin != null) return RouteManager.adminHome;

    final learner = await client
        .from('learner')
        .select('user_id')
        .eq('user_id', userId)
        .maybeSingle();

    if (learner != null) return RouteManager.studHome;

    // New user — create learner profile row once
    await client.from('learner').insert({
      'user_id': userId,
      'studentEmail': email,
    });
    return RouteManager.studHome;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.pushReplacementNamed(context, RouteManager.login),
          );
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return FutureBuilder<String>(
          future: _resolveRoute(session.user.id, session.user.email),
          builder: (context, routeSnapshot) {
            if (routeSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (routeSnapshot.hasData) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pushReplacementNamed(
                  context,
                  routeSnapshot.data!,
                ),
              );
            }
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          },
        );
      },
    );
  }
}
