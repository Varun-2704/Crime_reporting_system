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
  String statusFilter = 'All';
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
        final List<dynamic> allReports = decoded['data'];
        setState(() {
          reports = allReports;
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
    final filteredReports = reports.where((report) {
      if (statusFilter == 'All') return true;
      return (report['status'] ?? '').toLowerCase() == statusFilter.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("All Crime Reports")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.filter_alt),
                    ),
                    value: statusFilter,
                    onChanged: (value) {
                      setState(() {
                        statusFilter = value!;
                      });
                    },
                    items: ['All', 'Pending', 'Closed', 'Investigating']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(status),
                            ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: filteredReports.isEmpty
                      ? const Center(child: Text("No reports found."))
                      : ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            final location = report['location'] is String
                                ? report['location']
                                : (report['location']?['address'] ?? report['location'].toString());

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(report['crimeType'] ?? "Unknown Crime"),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(report['description'] ?? "No description"),
                                    SizedBox(height: 4),
                                    Text("Location: $location"),
                                  ],
                                ),
                                trailing: Text(
                                  report['status'] ?? "Pending",
                                  style: TextStyle(
                                    color: (report['status'] ?? '').toLowerCase() == 'resolved'
                                        ? Colors.green
                                        : (report['status'] ?? '').toLowerCase() == 'investigating'
                                            ? Colors.orange
                                            : Colors.red,
                                  ),
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
