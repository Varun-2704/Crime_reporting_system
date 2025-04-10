import 'package:flutter/material.dart';
import 'package:flutter_apis/functions/authFunction.dart';
import 'package:flutter_apis/screens/civilian_home.dart';
import 'package:flutter_apis/screens/police_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  final String role;
  const MyHomePage({super.key, required this.role, required String title});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formkey = GlobalKey<FormState>();
  bool isLogin = false;
  String email = '';
  String password = '';
  String username = '';

  void _submitForm() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();

      try {
        if (isLogin) {
          await signin(email, password);
        } else {
          await signup(email, password);
        }

        // ✅ Save login status
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', widget.role);

        // ✅ Navigate based on role
        if (widget.role == 'police') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PoliceHome()),
          );
        } else if (widget.role == 'civilian') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CivilianHome()),
          );
        }
      } catch (e) {
        if (!mounted) return; // Prevent calling context if widget is no longer in tree
      ScaffoldMessenger.of(context).showSnackBar( 
  const SnackBar(content: Text("Complaint Registered")),
);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLogin ? 'Login' : 'Sign Up'),
      ),
      body: Form(
        key: _formkey,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isLogin)
                    TextFormField(
                      key: const ValueKey('username'),
                      decoration: InputDecoration(
                        hintText: 'Enter username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 3) {
                          return "Username too short";
                        }
                        return null;
                      },
                      onSaved: (value) => username = value!,
                    ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: const InputDecoration(hintText: "Enter email"),
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return "Invalid email";
                      }
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    key: const ValueKey('password'),
                    decoration: const InputDecoration(hintText: "Enter password"),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return "Password too short";
                      }
                      return null;
                    },
                    onSaved: (value) => password = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isLogin ? 'Login' : 'Signup'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        isLogin = !isLogin;
                      });
                    },
                    child: Text(isLogin
                        ? 'Create an account'
                        : 'Already have an account? Login'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
