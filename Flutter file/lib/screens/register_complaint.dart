import 'dart:io';
import 'package:geocoding/geocoding.dart'; // Add this import for reverse geocoding

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  State<RegisterComplaintScreen> createState() => _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final _formKey = GlobalKey<FormState>();

  String? location;
  String? selectedCrime;
  String? description;
  String? victimName;
  String? suspectName;
  String? reporterName;
  File? mediaFile;
  LatLng? pickedLocation;

  final List<String> crimeTypes = [
    'Theft', 'Assault', 'Murder', 'Kidnapping', 'Cyber Crime',
    'Domestic Violence', 'Drug Abuse', 'Vandalism', 'Bribery'
  ];

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery); // or ImageSource.camera
    if (picked != null) {
      setState(() {
        mediaFile = File(picked.path);
      });
    }
  }
Future<void> _getCurrentLocation(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);
  final status = await Permission.location.request();

  if (!mounted) return;

  if (status.isGranted) {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      // Reverse geocode to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = "${place.street}, ${place.locality}, ${place.administrativeArea}";

        setState(() {
          pickedLocation = LatLng(position.latitude, position.longitude);
          String? readableAddress;
          readableAddress = address; // <- create a new variable to store this
        });

        messenger.showSnackBar(
          SnackBar(content: Text("Location selected: $address")),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text("Error fetching location")),
      );
    }
  } else {
    messenger.showSnackBar(
      const SnackBar(content: Text("Permission denied to access location")),
    );
  }
}
Future<void> _submitForm(BuildContext context) async {
  if (!_formKey.currentState!.validate()) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all required fields")),
    );
    return;
  }

  _formKey.currentState!.save();

  final uri = Uri.parse("https://crimereportingsystem-production.up.railway.app/api/crime/report");
  final request = http.MultipartRequest('POST', uri);

  request.fields['type'] = selectedCrime!;
  request.fields['description'] = description!;
  request.fields['victim_name'] = victimName ?? '';
  request.fields['suspect_name'] = suspectName ?? '';
  request.fields['reportedBy'] = reporterName!;
  request.fields['location'] = location!;

  final now = DateTime.now().toUtc().add(const Duration(hours: 5, minutes: 30));
  final istTime = DateFormat("yyyy-MM-dd HH:mm:ss").format(now);
  request.fields['timestamp'] = istTime;

  if (mediaFile != null) {
    final mimeTypeData = lookupMimeType(mediaFile!.path)!.split('/');
    request.files.add(
      await http.MultipartFile.fromPath(
        'media',
        mediaFile!.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        filename: basename(mediaFile!.path),
      ),
    );
  }

  final response = await request.send();
  if (response.statusCode == 200 || response.statusCode == 201) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Complaint registered successfully 🎉")),
    );
    _formKey.currentState!.reset();
    setState(() {
      pickedLocation = null;
      mediaFile = null;
      selectedCrime = null;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Failed to register complaint ❌")),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Complaint")),
      body: Builder(
        builder: (scaffoldContext) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                DropdownSearch<String>(
                  items: crimeTypes,
                  popupProps: const PopupProps.menu(showSearchBox: true),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(labelText: "Type of Crime *"),
                  ),
                  onChanged: (value) => setState(() => selectedCrime = value),
                  selectedItem: selectedCrime,
                  validator: (value) => value == null ? "Please select a crime type" : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Description *"),
                  maxLines: 3,
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter description" : null,
                  onSaved: (value) => description = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Victim's Name (Optional)"),
                  onSaved: (value) => victimName = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Suspect's Name (Optional)"),
                  onSaved: (value) => suspectName = value,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Reported By (Your Name) *"),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Please enter your name" : null,
                  onSaved: (value) => reporterName = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Location is required' : null,
                onSaved: (value) => location = value!,
                ),

                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickMedia,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Media"),
                    ),
                    const SizedBox(width: 10),
                    if (mediaFile != null) const Text("File selected ✅"),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _submitForm(scaffoldContext),
                  child: const Text("Submit Complaint"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
