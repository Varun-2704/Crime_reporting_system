import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityCrimeReportsPage extends StatefulWidget {
  @override
  _CityCrimeReportsPageState createState() => _CityCrimeReportsPageState();
}

class _CityCrimeReportsPageState extends State<CityCrimeReportsPage> {
  List reports = [];
  String cityFilter = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final uri = Uri.parse("http://crimereportingsystem-production.up.railway.app/api/admin/reports");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      setState(() {
        reports = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch reports")),
      );
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
      appBar: AppBar(
        title: Text("Crimes in Your City"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Enter city name',
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
                      ? Center(child: Text("No reports found for this city."))
                      : ListView.builder(
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            final location = report['location'] is String
                                ? report['location']
                                : (report['location']?['address'] ??
                                    report['location'].toString());

                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(report['type'] ?? 'Unknown Crime'),
                                subtitle: Text(location ?? 'Unknown Location'),
                                trailing: Text(
                                  report['status'] ?? 'Pending',
                                  style: TextStyle(
                                    color: report['status'] == 'Resolved' ? Colors.green : Colors.red,
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
