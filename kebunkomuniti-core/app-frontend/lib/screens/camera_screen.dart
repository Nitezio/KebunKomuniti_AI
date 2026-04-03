import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  Map<String, dynamic>? _diagnosisData;
  String _errorMessage = "";

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
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
        _errorMessage =
            "Failed to connect. Are you and the backend on the same Wi-Fi?";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Plant Doctor AI',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Container(
                height: 250,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Text(
                          "No Leaf Scanned",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Camera"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text("Gallery"),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (_imageFile != null && _diagnosisData == null && !_isLoading)
                ElevatedButton.icon(
                  onPressed: _analyzeWithAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Analyze with AI"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                ),

              if (_isLoading) const CircularProgressIndicator(),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              if (_diagnosisData != null) _buildDiagnosisCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    if (_diagnosisData!['is_plant'] == false) {
      return Container(
        margin: const EdgeInsets.only(top: 20), // FIXED TYPO HERE
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.red),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                "Not a plant detected! Please take a clear photo of a leaf.",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    bool isHealthy = _diagnosisData!['is_healthy'];

    return Card(
      margin: const EdgeInsets.only(top: 20), // FIXED TYPO HERE
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy ? Icons.check_circle : Icons.coronavirus,
                  color: isHealthy ? Colors.green : Colors.red,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  isHealthy ? "Healthy Plant" : "Disease Detected",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isHealthy ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(height: 30, thickness: 1),
            _buildInfoRow("Species:", _diagnosisData!['plant_name']),
            if (!isHealthy)
              _buildInfoRow(
                "Issue:",
                _diagnosisData!['disease_name'],
                color: Colors.red,
              ),
            _buildInfoRow("AI Confidence:", "${_diagnosisData!['confidence']}"),

            if (!isHealthy) ...[
              const SizedBox(height: 15),
              const Text(
                "Treatment Plan:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 5),
              Text(
                _diagnosisData!['remedy_advice'],
                style: TextStyle(color: Colors.grey[800], height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
