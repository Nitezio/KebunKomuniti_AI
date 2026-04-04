import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  Map<String, dynamic>? _diagnosisData;
  String _errorMessage = "";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
          _diagnosisData = null;
          _errorMessage = "";
        });
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _analyzeWithAI() async {
    if (_imageFile == null) return;
    setState(() {
      _isLoading = true;
      _diagnosisData = null;
      _errorMessage = "";
    });

    var result = await ApiService.analyzePlant(_imageFile!);

    setState(() {
      _isLoading = false;
      if (result != null && result['success'] == true) {
        _diagnosisData = result['diagnosis'];
      } else {
        _errorMessage = "AI Scan failed. Check connection.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(title: const Text('AI Plant Doctor'), centerTitle: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: kIsWeb 
                          ? Image.network(_imageFile!.path, fit: BoxFit.cover)
                          : Image.file(File(_imageFile!.path), fit: BoxFit.cover),
                      )
                    : const Icon(Icons.energy_savings_leaf_outlined, size: 60, color: Colors.green),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt), label: const Text("Camera"))),
                  const SizedBox(width: 16),
                  Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library), label: const Text("Gallery"))),
                ],
              ),
              const SizedBox(height: 24),
              if (_imageFile != null && _diagnosisData == null && !_isLoading)
                ElevatedButton(onPressed: _analyzeWithAI, child: const Text("DIAGNOSE NOW")),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              if (_diagnosisData != null) _buildDiagnosisCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    bool isHealthy = _diagnosisData!['is_healthy'];
    return Card(
      margin: const EdgeInsets.only(top: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(isHealthy ? "Healthy" : "Issues Found", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isHealthy ? Colors.green : Colors.orange)),
            const Divider(),
            _buildInfoRow("Species", _diagnosisData!['plant_name'] ?? "N/A"),
            _buildInfoRow("Confidence", _diagnosisData!['confidence'] ?? "0%"),
            if (!isHealthy) ...[
              const SizedBox(height: 10),
              Text("DIY: ${_diagnosisData!['diy_remedy']}", style: const TextStyle(fontSize: 12)),
              Text("Commercial: ${_diagnosisData!['commercial_remedy']}", style: const TextStyle(fontSize: 12)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]);
  }
}
