import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_apis/screens/civilian_home.dart';
import 'package:flutter_apis/screens/police_home.dart';
import 'package:flutter_apis/screens/role_selector.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), checkLoginStatus);
  }

  Future<void> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final role = prefs.getString('role') ?? '';

    if (isLoggedIn) {
      if (role == 'police') {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PoliceHome()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const CivilianHome()));
      }
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelectionScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png"),
            const SizedBox(height: 20),
            const Text(
              'Crime Reporter',
              style: TextStyle(
                fontSize: 26,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
