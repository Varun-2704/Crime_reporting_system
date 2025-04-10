import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

class CorruptionReportPage extends StatefulWidget {
  const CorruptionReportPage({super.key});

  @override
  State<CorruptionReportPage> createState() => _CorruptionReportPageState();
}

class _CorruptionReportPageState extends State<CorruptionReportPage> {
  final _formKey = GlobalKey<FormState>();
  String? authorityType, officerName, department, description, location, reportedBy;
  File? mediaFile;

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => mediaFile = File(picked.path));
  }

  Future<void> _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    _formKey.currentState!.save();

    final uri = Uri.parse("https://crimereportingsystem-production.up.railway.app/api/corruption/report");
    final request = http.MultipartRequest('POST', uri);

    request.fields['authorityType'] = authorityType!;
    request.fields['officerName'] = officerName!;
    request.fields['department'] = department!;
    request.fields['description'] = description!;
    request.fields['location'] = location!;
    request.fields['reportedBy'] = reportedBy!;

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
    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Corruption report submitted ✅")),
      );
      _formKey.currentState!.reset();
      setState(() => mediaFile = null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Corruption Complaint")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Authority Type"),
                onSaved: (value) => authorityType = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Officer Name"),
                onSaved: (value) => officerName = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Department"),
                onSaved: (value) => department = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Location"),
                onSaved: (value) => location = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Description"),
                onSaved: (value) => description = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
                maxLines: 3,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Reported By"),
                onSaved: (value) => reportedBy = value,
                validator: (value) => value!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file),
                label: const Text("Attach Media"),
              ),
              if (mediaFile != null) Text("Selected: ${basename(mediaFile!.path)}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: const Text("Submit Report"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
