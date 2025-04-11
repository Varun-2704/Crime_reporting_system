import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;

  const MapPickerDialog({super.key, this.initialLocation});

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  late LatLng selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialLocation ?? LatLng(21.2514, 81.6296); // Default: Raipur
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: SizedBox(
        width: 400,
        height: 400,
        child: FlutterMap(
          options: MapOptions(
            center: selected,
            zoom: 13.0,
            onTap: (tapPosition, point) {
              setState(() => selected = point);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: selected,
                  width: 50,
                  height: 50,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, selected),
          child: const Text("Select"),
        ),
      ],
    );
  }
}
