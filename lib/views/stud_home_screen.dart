import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/routes/route_manager.dart';
import 'package:student_assistant/viewmodels/student_view_model.dart';

class StudHomeScreen extends StatefulWidget {
  const StudHomeScreen({super.key});

  @override
  State<StudHomeScreen> createState() => _StudHomeScreenState();
}

class _StudHomeScreenState extends State<StudHomeScreen> {
  @override
  void initState() {
    super.initState();
    //Load student data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentViewModel>().loadStudentData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Assistant'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Consumer<StudentViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    vm.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => vm.loadStudentData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          //No application found- show apply button
          if (vm.application == null) {
            return _buildNoApplicationView(context);
          }

          //Application exists-navigate to  details
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamed(
              context,
              RouteManager.applicationDetail,
              arguments: vm.application,
            );
          });
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildNoApplicationView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Application Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t submitted an application yet. Apply now to become a student assistant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, RouteManager.applicationForm);
              },
              icon: const Icon(Icons.add),
              label: const Text('Apply Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await context.read<StudentViewModel>().logout(context);
    } catch (e) {
      if (context.mounted) {
        Exceptionerror.snackBarError('Logout failed: ${e.toString()}');
      }
    }
  }
}
