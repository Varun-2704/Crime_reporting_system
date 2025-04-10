import 'package:flutter/material.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  final List<Map<String, dynamic>> departments = const [
    {'name': 'Ambulance', 'icon': Icons.local_hospital},
    {'name': 'Police', 'icon': Icons.local_police},
    {'name': 'Highway Police', 'icon': Icons.directions_car},
    {'name': 'Fire Brigade', 'icon': Icons.local_fire_department},
    {'name': 'Disaster Management', 'icon': Icons.warning},
    {'name': 'Women Helpline', 'icon': Icons.support_agent},
  ];

  void sendSOS(String departmentName) {
    // TODO: Connect this to your backend to send SOS
    print("SOS sent to $departmentName");
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
                onPressed: () => sendSOS(dept['name']),
                child: const Text('Send SOS'),
              ),
            ),
          );
        },
      ),
    );
  }
}
