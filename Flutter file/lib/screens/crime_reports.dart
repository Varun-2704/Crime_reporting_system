import 'package:flutter/material.dart';

class CrimeReportsPage extends StatelessWidget {
  const CrimeReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Later, fetch reports from backend using user's location
    return Scaffold(
      appBar: AppBar(title: const Text('Crime Reports in Your Area')),
      body: const Center(
        child: Text(
          'Crime reports will be shown here based on your location.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
