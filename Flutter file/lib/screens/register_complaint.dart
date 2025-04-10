import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterComplaintScreen extends StatefulWidget {
  const RegisterComplaintScreen({super.key});

  @override
  State<RegisterComplaintScreen> createState() => _RegisterComplaintScreenState();
}

class _RegisterComplaintScreenState extends State<RegisterComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  String victimName = '';
  String? selectedCrime;
  String? suspectName;
  File? mediaProof;

  final List<String> crimeTypes = [
    'Theft', 'Assault', 'Murder', 'Kidnapping', 'Cyber Crime',
    'Domestic Violence', 'Drug Abuse', 'Vandalism', 'Bribery'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        mediaProof = File(pickedImage.path);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // TODO: Send data to Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Complaint Registered")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Complaint")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Victim's Name"),
                onSaved: (value) => victimName = value!,
                validator: (value) =>
                    value!.isEmpty ? "Please enter victim's name" : null,
              ),
              const SizedBox(height: 12),
              DropdownSearch<String>(
                items: crimeTypes,
                popupProps: const PopupProps.menu(showSearchBox: true),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(labelText: "Type of Crime"),
                ),
                onChanged: (value) => selectedCrime = value,
                selectedItem: selectedCrime,
                validator: (value) =>
                    value == null ? "Please select a crime type" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Suspect's Name (optional)"),
                onSaved: (value) => suspectName = value,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Media"),
                  ),
                  const SizedBox(width: 10),
                  if (mediaProof != null) const Text("File selected ✅")
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Submit Complaint"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
