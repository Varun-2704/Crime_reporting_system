import 'package:flutter/material.dart';
import 'package:flutter_apis/firebase_options.dart';
import 'package:flutter_apis/screens/city_reports_screen.dart';
import 'package:flutter_apis/screens/register_complaint.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_apis/screens/splash_scren.dart';
import 'package:flutter_apis/signupin.dart';
import 'package:flutter_apis/screens/civilian_home.dart';
import 'package:flutter_apis/screens/police_home.dart';
import 'package:flutter_apis/screens/role_selector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  final role = prefs.getString('role') ?? '';

  runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String role;

  const MyApp({super.key, required this.isLoggedIn, required this.role});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Crime Reporting App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.indigo,
  scaffoldBackgroundColor: Colors.grey[100],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigo,
    elevation: 4,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),

  // ✅ ElevatedButton style with white text
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white, // <-- White text
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontSize: 16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
    ),
  ),

  // ✅ TextButton style with white text
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color.fromARGB(255, 0, 0, 0), // <-- White text
    ),
  ),
  
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.indigo, width: 2),
    ),
    labelStyle: TextStyle(color: Colors.grey[800]),
  ),
),

      home: isLoggedIn
          ? (role == 'police' ? const PoliceHome() : const CivilianHome())
          : const RoleSelectionScreen(),
      routes: {
        '/login': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String;
          return MyHomePage(role: role, title: '');
        },
        '/civilian_home': (context) => const CivilianHome(),
        '/police_home': (context) => const PoliceHome(),
        '/registerComplaint': (context) => const RegisterComplaintScreen(),
        '/cityReports': (context) => CityReportsScreen(city: '', location: '',), // default, actual value passed via Navigator

      },
    );
  }
}
