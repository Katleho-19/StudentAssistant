import 'package:flutter/material.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        //loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        //check current session
        final session = snapshot.data?.session;

        if (session == null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => Navigator.pushReplacementNamed(context, RouteManager.login),
          );
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        //Check if user exists in admin table
        return FutureBuilder<Map<String, dynamic>?>(
          future: Supabase.instance.client
              .from('admin')
              .select()
              .eq('user_id', session.user.id)
              .maybeSingle(),
          builder: (context, adminSnapShot) {
            if (adminSnapShot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            //if found in admin table
            if (adminSnapShot.data != null) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => Navigator.pushReplacementNamed(
                  context,
                  RouteManager.adminHome,
                ),
              );
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            //otherwise
            return FutureBuilder(
              future: Supabase.instance.client
                  .from('learner')
                  .select()
                  .eq('user_id', session.user.id)
                  .maybeSingle(),
              builder: (context, learnerSnapShot) {
                if (learnerSnapShot.connectionState ==
                    ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                //if learner profile exists
                if (learnerSnapShot.data != null) {
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => Navigator.pushReplacementNamed(
                      context,
                      RouteManager.studHome,
                    ),
                  );
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                //new user( create learner profile then go to student home )
                return FutureBuilder(
                  future: Supabase.instance.client.from('learner').insert({
                    'user_id': session.user.id,
                    'studentEmail': session.user.email,
                  }),
                  builder: (context, _) {
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => Navigator.pushReplacementNamed(
                        context,
                        RouteManager.studHome,
                      ),
                    );
                    return const Scaffold(
                      body: Center(child: CircularProgressIndicator()),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

