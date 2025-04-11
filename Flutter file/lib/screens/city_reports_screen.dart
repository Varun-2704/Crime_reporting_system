// lib/screens/city_reports_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityReportsScreen extends StatefulWidget {
  const CityReportsScreen({super.key});

  @override
  State<CityReportsScreen> createState() => _CityReportsScreenState();
}

class _CityReportsScreenState extends State<CityReportsScreen> {
  List<dynamic> reports = [];
  String cityFilter = '';
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
        final decoded = json.decode(response.body);
        setState(() {
          reports = decoded['data'];
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

  Future<void> updateStatus(String id, String newStatus) async {
    final url = Uri.parse("https://crimereportingsystem-production.up.railway.app/api/admin/report/$id");
    try {
      final response = await http.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': newStatus}),
      );
      if (response.statusCode == 200) {
        print("Status updated successfully");
      } else {
        print("Failed to update status");
      }
    } catch (e) {
      print("Error updating status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = reports.where((report) {
      final location = report['location'];
      final locationStr = location is String
          ? location
          : (location?['address'] ?? location.toString());
      return cityFilter.isEmpty ||
          locationStr.toLowerCase().contains(cityFilter.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("All City Reports")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by city',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        cityFilter = value;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: filteredReports.isEmpty
                      ? const Center(child: Text("No reports found."))
                      : ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            final status = report['status'] ?? "Pending";

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(report['crimeType'] ?? "Unknown Crime"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(report['description'] ?? "No description"),
                                    const SizedBox(height: 8),
                                    const Text("Update Status:"),
                                    DropdownButton<String>(
                                      value: status,
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            report['status'] = newValue;
                                          });
                                          updateStatus(report['_id'], newValue);
                                        }
                                      },
                                      items: <String>['Pending', 'Investigating', 'Closed']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
