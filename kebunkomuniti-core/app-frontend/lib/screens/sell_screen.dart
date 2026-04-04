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
  double _price = 0.0;
  double _basePricePerKg = 0.0;
  String _method = "Pickup";
  bool _isAnalyzing = false;

  void _onNameChanged(String value) {
    if (ApiService.regulatedPrices.containsKey(value)) {
      setState(() {
        _basePricePerKg = ApiService.regulatedPrices[value]!;
        _calculateTotal();
      });
    }
  }

  void _calculateTotal() {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    setState(() {
      _price = _basePricePerKg * weight;
    });
  }

  void _adjustPrice(double delta) {
    double weight = double.tryParse(_weightController.text) ?? 0.0;
    double originalTotal = _basePricePerKg * weight;
    double maxTotal = originalTotal * 1.20; 
    
    double newPrice = _price + delta;
    if (newPrice >= 0 && newPrice <= maxTotal) {
      setState(() => _price = newPrice);
    } else if (newPrice > maxTotal) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Price exceeds regulation limit!")));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        _isAnalyzing = true;
      });
      final aiResult = await ApiService.getListingAssistant(_imageFile!);
      if (aiResult != null) {
        _nameController.text = aiResult['item_name'] ?? "";
        _weightController.text = aiResult['estimated_weight_kg']?.toString() ?? "";
        _onNameChanged(_nameController.text);
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
    if (_nameController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in all details")));
      return;
    }
    
    // THE FIX: Provide all 7 required arguments to match ApiService
    bool success = await ApiService.listSurplus(
      _nameController.text, 
      double.tryParse(_weightController.text) ?? 0.0, 
      3.8126, 103.3256,
      _price, 
      _method, 
      _imageFile?.path
    );

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Produce listed for sale!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sell Surplus")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                height: 180, width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                child: _imageFile == null ? const Icon(Icons.add_photo_alternate_outlined, size: 40) : ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_imageFile!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 16),
            if (_isAnalyzing) const LinearProgressIndicator(color: Colors.green),
            const SizedBox(height: 24),
            
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return ApiService.regulatedPrices.keys.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: _onNameChanged,
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextField(controller: controller, focusNode: focusNode, decoration: const InputDecoration(labelText: "Produce Name", border: OutlineInputBorder()));
              },
            ),
            
            const SizedBox(height: 16),
            TextField(controller: _weightController, keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal(), decoration: const InputDecoration(labelText: "Weight (kg)", border: OutlineInputBorder())),
            
            const SizedBox(height: 24),
            const Text("Method of Selling", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                ChoiceChip(label: const Text("Pickup"), selected: _method == "Pickup", onSelected: (_) => setState(() => _method = "Pickup")),
                const SizedBox(width: 12),
                ChoiceChip(label: const Text("Delivery"), selected: _method == "Delivery", onSelected: (_) => setState(() => _method = "Delivery")),
              ],
            ),

            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  const Text("Calculated Total Price", style: TextStyle(fontSize: 12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _adjustPrice(-0.5)),
                      Text("RM ${_price.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green)),
                      IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _adjustPrice(0.5)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitListing,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, padding: const EdgeInsets.all(18)),
                child: const Text("SELL NOW", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
