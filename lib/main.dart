import 'package:flutter/material.dart';
import 'package:student_assistant/models/repository.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';
import 'package:student_assistant/viewmodels/admin_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kqoxlwqssuhqctrljftg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtxb3hsd3Fzc3VocWN0cmxqZnRnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzkxNzc1OTEsImV4cCI6MjA5NDc1MzU5MX0.PtxlJQSxVsrPfxZnuZFsrqDhK679mOmO6DY6hj4j5MI',
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentViewModel(Repository()),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminViewModel(Supabase.instance.client),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Student Assistant',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder(), filled: true,fillColor: Color(0xFFF5F5F5),),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 34, 241, 110),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
          ),
        ),
        ),
        initialRoute: RouteManager.authGate,
        onGenerateRoute: RouteManager.generateRoute,
      ),
    );
  }
}

