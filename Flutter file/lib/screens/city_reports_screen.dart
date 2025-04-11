import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityReportsScreen extends StatefulWidget {
  final String location;

  const CityReportsScreen({super.key, required this.location, required String city});

  @override
  State<CityReportsScreen> createState() => _CityReportsScreenState();
}

class _CityReportsScreenState extends State<CityReportsScreen> {
  List<dynamic> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final url = Uri.parse("https://crimereportingsystem-production.up.railway.app/api/admin/reports");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> allReports = json.decode(response.body);
        final filtered = allReports.where((r) {
          return (r['location'] as String?)?.toLowerCase().contains(widget.location.toLowerCase()) ?? false;
        }).toList();

        setState(() {
          reports = filtered;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load reports");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching reports: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Reports in ${widget.location}")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reports.isEmpty
              ? const Center(child: Text("No reports found."))
              : ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(report['crimeType'] ?? "Unknown Crime"),
                        subtitle: Text(report['description'] ?? "No description"),
                        trailing: Text(report['status'] ?? "Pending"),
                      ),
                    );
                  },
                ),
    );
  }
}
