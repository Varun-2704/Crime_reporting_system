// lib/screens/police_login.dart

import 'package:flutter/material.dart';
import 'package:flutter_apis/screens/city_reports_screen.dart';
import 'package:flutter_apis/screens/crime_list_page.dart';

class PoliceLoginScreen extends StatefulWidget {
  const PoliceLoginScreen({super.key});

  @override
  State<PoliceLoginScreen> createState() => _PoliceLoginScreenState();
}

class _PoliceLoginScreenState extends State<PoliceLoginScreen> {
  final TextEditingController _stationIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Police Login")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _stationIdController,
              decoration: const InputDecoration(labelText: "Station ID"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CityCrimeReportsPage(),
                  ),
                );
              },
              child: const Text("Go to Reports"),
            ),
          ],
        ),
      ),
    );
  }
}
