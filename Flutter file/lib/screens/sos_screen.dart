import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  final List<Map<String, dynamic>> departments = const [
    {'name': 'Ambulance', 'icon': Icons.local_hospital, 'number': '102'},
    {'name': 'Police', 'icon': Icons.local_police, 'number': '100'},
    {'name': 'Highway Police', 'icon': Icons.directions_car, 'number': '103'},
    {'name': 'Fire Brigade', 'icon': Icons.local_fire_department, 'number': '101'},
    {'name': 'Disaster Management', 'icon': Icons.warning, 'number': '108'},
    {'name': 'Women Helpline', 'icon': Icons.support_agent, 'number': '1091'},
  ];

  Future<void> sendSOS(String departmentName, String number) async {
    final Uri callUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      print("Could not launch dialer for $departmentName");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send SOS Signal')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: departments.length,
        itemBuilder: (context, index) {
          final dept = departments[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: Icon(dept['icon'], color: Colors.redAccent),
              title: Text(dept['name']),
              trailing: ElevatedButton(
                onPressed: () => sendSOS(dept['name'], dept['number']),
                child: const Text('Send SOS'),
              ),
            ),
          );
        },
      ),
    );
  }
}
