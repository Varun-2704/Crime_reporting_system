// lib/screens/police_login.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_apis/screens/crime_reports.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // adjust if needed

class PoliceLoginScreen extends StatefulWidget {
  const PoliceLoginScreen({super.key});

  @override
  State<PoliceLoginScreen> createState() => _PoliceLoginScreenState();
}

class _PoliceLoginScreenState extends State<PoliceLoginScreen> {
  final TextEditingController stationIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  final String loginUrl = 'https://crimereportingsystem-production.up.railway.app/api/admin/login';

  Future<void> loginPolice() async {
    final stationId = stationIdController.text.trim();
    final password = passwordController.text.trim();

    if (stationId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter Station ID and Password")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'stationId': stationId, 'password': password}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setString('role', 'police');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CrimeReportsPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['error'] ?? 'Login failed')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Police Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: stationIdController,
              decoration: const InputDecoration(labelText: "Station ID"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: loginPolice,
                    child: const Text("Login"),
                  ),
          ],
        ),
      ),
    );
  }
}
