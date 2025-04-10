import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_apis/screens/role_selector.dart';
import 'package:flutter_apis/screens/sos_screen.dart'; 
import 'package:flutter_apis/screens/register_complaint.dart';
import 'package:flutter_apis/screens/crime_reports.dart'; 

class CivilianHome extends StatelessWidget {
  const CivilianHome({super.key});

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Civilian Dashboard'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            _buildOption(context, "Register Complaint", Icons.report, () {
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => const RegisterComplaintScreen()),
            );
            }),

            _buildOption(context, "Corruption Complaint", Icons.money_off, () {
              // TODO: Navigate to corruption complaint page
            }),
            _buildOption(context, "Crime in Local Area", Icons.location_city, () {
              // TODO: Navigate to local crime page
            }),
            _buildOption(context, "Send SOS Signal", Icons.warning_amber, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SOSPage()),
              );
            }),
            _buildOption(context, "See Crime Reports", Icons.map, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CrimeReportsPage()),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.indigo.shade100,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
