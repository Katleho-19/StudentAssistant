import 'package:flutter/material.dart';
import 'package:student_assistant/feature/auth/auth_service.dart';
import 'package:student_assistant/models/admin_model.dart';
import 'package:student_assistant/models/exceptionError.dart';
import 'package:student_assistant/models/student_model.dart';
import 'package:student_assistant/routes/route_manager.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  Admin admin = Admin(firstName: '', surname: '', email: '', password: '');
  Student student = Student(
    studentEmail: '',
    firstName: '',
    surname: '',
    password: '',
  );

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();

  void register() async {
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String firstName = _firstNameController.text;
    final String surname = _surnameController.text;

    try {
      await _authService.registerWithEmail(email, password);

      if (email.contains('@stud.cut.ac.za')) {
        student = Student(
          studentEmail: email,
          firstName: firstName,
          surname: surname,
          password: password,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.studHome,
          (route) => false,
        );
      } else if (email.contains('@cut.ac.za')) {
        admin = Admin(
          email: email,
          firstName: firstName,
          surname: surname,
          password: password,
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          RouteManager.adminHome,
          (route) => false,
        );
      } else {
        Exceptionerror.snackBarError(
          'Please use appropriate email to register.',
        );
      }
    } catch (e) {
      Exceptionerror.snackBarError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  icon: Icon(Icons.person),
                  hintText: 'Enter your first name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _surnameController,
                decoration: const InputDecoration(
                  labelText: 'Surname',
                  icon: Icon(Icons.person),
                  hintText: 'Enter your surname',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your surname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  icon: Icon(Icons.email),
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  icon: Icon(Icons.lock),
                  hintText: 'Enter your password',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 8) {
                    return 'Please enter your password (at least 8 characters)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  icon: Icon(Icons.lock),
                  hintText: 'Enter your password again',
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  }
                },
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              const Text('Already have an account?'),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteManager.login);
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

