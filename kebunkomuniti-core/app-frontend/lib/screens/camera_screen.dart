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
        _errorMessage = "Connection failed. Check your network link.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        elevation: 0,
        title: const Text('AI Plant Doctor', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: _imageFile != null
                    ? ClipRRect(borderRadius: BorderRadius.circular(24), child: Image.file(_imageFile!, fit: BoxFit.cover))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.energy_savings_leaf_outlined, size: 60, color: Colors.green.shade200),
                    const SizedBox(height: 16),
                    Text("No plant scanned yet", style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text("Camera"),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), foregroundColor: Colors.green.shade700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text("Gallery"),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), foregroundColor: Colors.green.shade700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_imageFile != null && _diagnosisData == null && !_isLoading)
                FilledButton.icon(
                  onPressed: _analyzeWithAI,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text("Diagnose Plant", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              if (_isLoading) const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: Colors.green))),
              if (_diagnosisData != null) _buildDiagnosisCard(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiagnosisCard() {
    if (_diagnosisData!['is_plant'] == false) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.red.shade200)),
        child: Row(children: [Icon(Icons.warning_rounded, color: Colors.red.shade700), const SizedBox(width: 16), Expanded(child: Text("Not a plant detected! Please scan a clear leaf.", style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600)))]),
      );
    }

    bool isHealthy = _diagnosisData!['is_healthy'];

    return Container(
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 24, offset: const Offset(0, 4))]),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: isHealthy ? Colors.green.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
                  child: Icon(isHealthy ? Icons.eco_rounded : Icons.coronavirus_rounded, color: isHealthy ? Colors.green.shade600 : Colors.orange.shade600, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHealthy ? "Healthy Plant" : "Action Required", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isHealthy ? Colors.green.shade800 : Colors.orange.shade800)
                      ),
                      Text(
                        "Confidence: ${_diagnosisData!['confidence'].toString().contains('%') ? _diagnosisData!['confidence'] : _diagnosisData!['confidence'].toString() + '%'}", 
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13)
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),
            _buildInfoRow("Species", _diagnosisData!['plant_name'] ?? "Unknown", Icons.local_florist_outlined),
            if (!isHealthy) _buildInfoRow("Issue", _diagnosisData!['disease_name'] ?? "Unknown Issue", Icons.bug_report_outlined, color: Colors.orange.shade800),

            if (!isHealthy) ...[
              const SizedBox(height: 20),
              // --- DIY REMEDY BOX ---
              _buildRemedyBox("DIY Home Solution", _diagnosisData!['diy_remedy'] ?? "N/A", Icons.home_repair_service_outlined),
              const SizedBox(height: 12),
              // --- COMMERCIAL REMEDY BOX ---
              _buildRemedyBox("Commercial Product", _diagnosisData!['commercial_remedy'] ?? "N/A", Icons.shopping_cart_outlined),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildRemedyBox(String title, String advice, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade800))),
            ],
          ),
          const SizedBox(height: 8),
          Text(advice, style: TextStyle(color: Colors.orange.shade900, height: 1.5), softWrap: true),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color ?? Colors.black87), softWrap: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
