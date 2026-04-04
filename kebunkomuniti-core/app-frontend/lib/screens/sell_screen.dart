import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class SellScreen extends StatefulWidget {
  const SellScreen({super.key});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isAnalyzing = false;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isAnalyzing = true;
      });

      final aiResult = await ApiService.getListingAssistant(_imageFile!);
      if (aiResult != null) {
        setState(() {
          _nameController.text = aiResult['item_name'] ?? "";
          _weightController.text = aiResult['estimated_weight_kg']?.toString() ?? "";
          _priceController.text = aiResult['suggested_price_rm']?.toString() ?? "";
        });
      }
      setState(() => _isAnalyzing = false);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Take Photo'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Choose from Gallery'), onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          ],
        ),
      ),
    );
  }

  Future<void> _submitListing() async {
    if (_nameController.text.isEmpty) return;
    setState(() => _isUploading = true);
    
    bool success = await ApiService.listSurplus(
      _nameController.text, 
      double.tryParse(_weightController.text) ?? 0.0, 
      3.8126, 103.3256
    );

    setState(() => _isUploading = false);
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produce listed for sale!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Listing", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Produce Photo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                height: 220, width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, 
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300, width: 2, style: BorderStyle.solid)
                ),
                child: _imageFile == null 
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.green.shade700), const SizedBox(height: 8), const Text("Add photo for AI scan")])
                  : ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.file(_imageFile!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 24),
            if (_isAnalyzing) const Column(children: [LinearProgressIndicator(color: Colors.green), SizedBox(height: 8), Text("AI is estimating weight...", style: TextStyle(fontSize: 12, color: Colors.grey))]),
            
            const Text("Listing Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(controller: _nameController, decoration: InputDecoration(labelText: "Produce Name", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: TextField(controller: _weightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: "Total Price (RM)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))))),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _submitListing,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700, 
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                ),
                child: _isUploading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text("SELL", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
