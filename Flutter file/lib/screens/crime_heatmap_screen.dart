import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CrimeHeatMapScreen extends StatefulWidget {
  const CrimeHeatMapScreen({super.key});

  @override
  State<CrimeHeatMapScreen> createState() => _CrimeHeatMapScreenState();
}

class _CrimeHeatMapScreenState extends State<CrimeHeatMapScreen> {
  List<LatLng> heatPoints = [];

  @override
  void initState() {
    super.initState();
    fetchCrimeData();
  }

  Future<void> fetchCrimeData() async {
    final url = Uri.parse("https://crimereportingsystem-production.up.railway.app/api/admin/reports");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final points = <LatLng>[];
        for (var report in data) {
          if (report['location'] != null) {
            final parts = report['location'].split(',');
            if (parts.length == 2) {
              final lat = double.tryParse(parts[0].trim());
              final lng = double.tryParse(parts[1].trim());
              if (lat != null && lng != null) {
                points.add(LatLng(lat, lng));
              }
            }
          }
        }

        setState(() => heatPoints = points);
      } else {
        debugPrint("Failed to load data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crime Heat Map")),
      body: FlutterMap(
        options: MapOptions(
          center: heatPoints.isNotEmpty ? heatPoints[0] : LatLng(12.9716, 77.5946),
          zoom: 12,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: heatPoints.map((point) {
              return Marker(
              point: point,
              width: 30,
              height: 30,
              child: const Icon(
                Icons.circle,
                color: Colors.redAccent,
                size: 16,
              ),
              )  ;
            }).toList(),
          ),
        ],
      ),
    );
  }
}
