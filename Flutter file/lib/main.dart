import 'package:flutter/material.dart';
import 'package:flutter_apis/firebase_options.dart';
import 'package:flutter_apis/screens/register_complaint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_apis/screens/splash_scren.dart';
import 'package:flutter_apis/signupin.dart';
import 'package:flutter_apis/screens/civilian_home.dart';
import 'package:flutter_apis/screens/police_home.dart';
import 'package:flutter_apis/screens/role_selector.dart'; // ✅ Add this
//to avoid any reverse process
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // 🔑 This line is essential for web
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role') ?? '';

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primarySwatch: Colors.indigo),
    home: isLoggedIn
        ? (role == 'police' ? const PoliceHome() : const CivilianHome())
        : const RoleSelectionScreen(), // ✅ Now works because it's imported
    routes: {
      '/login': (context) {
        final role = ModalRoute.of(context)!.settings.arguments as String;
        return MyHomePage(role: role, title: '');
      },
      '/civilian_home': (context) => const CivilianHome(),
      '/police_home': (context) => const PoliceHome(),
      '/registerComplaint': (context) => const RegisterComplaintScreen(),
      
    },
  ));
}