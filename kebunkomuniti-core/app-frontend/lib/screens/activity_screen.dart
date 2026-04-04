import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../services/api_service.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _orders = [];
  bool _isLoading = true;
  final String _userName = "Ahmad bin Razak";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await ApiService.getHistory(_userName);
    setState(() {
      _orders = history;
      _isLoading = false;
    });
  }

  void _approve(int id, bool isBuyer) async {
    await ApiService.approveTransaction(id, isBuyer);
    _loadHistory();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Handshake Verified!")));
  }

  void _showReceipt(Map<String, dynamic> order) {
    final bool isBuying = order['buyer_name'] == _userName;
    final String date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(order['created_at']));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Transaction Receipt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Divider(height: 32),
              
              if (order['surplus']['image_path'] != null)
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(order['surplus']['image_path']), height: 100, width: 100, fit: BoxFit.cover)),
              
              const SizedBox(height: 16),
              _buildReceiptRow("Status", order['status']),
              _buildReceiptRow("Date", date), // THE FIX: Now using the date variable
              _buildReceiptRow("Type", isBuying ? "Buying" : "Selling"),
              _buildReceiptRow("Item", order['surplus']['item_name']),
              _buildReceiptRow("Weight", "${order['surplus']['quantity_kg']} kg"),
              _buildReceiptRow("Rate", "RM ${(order['surplus']['price_per_kg'] ?? 0.0).toStringAsFixed(2)} /kg"),
              _buildReceiptRow("Method", order['delivery_method']),
              
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isBuying ? "TOTAL PAID" : "TOTAL SOLD", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("RM ${(order['surplus']['price'] ?? 0.0).toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 24),
              
              if (order['status'] == "Pending")
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: order['buyer_name'] == "Awaiting Buyer" ? null : () => _approve(order['id'], isBuying),
                    icon: Icon(order['buyer_name'] == "Awaiting Buyer" ? Icons.hourglass_empty : Icons.handshake),
                    label: Text(order['buyer_name'] == "Awaiting Buyer" ? "Awaiting Buyer..." : (isBuying ? "Confirm Pickup" : "Confirm Delivery")),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order['buyer_name'] == "Awaiting Buyer" ? Colors.grey : Colors.green.shade700, 
                      foregroundColor: Colors.white
                    ),
                  ),
                ),
              
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: Colors.grey)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(title: const Text("Transactions"), bottom: TabBar(controller: _tabController, tabs: const [Tab(text: "Active"), Tab(text: "Completed")])),
      body: TabBarView(controller: _tabController, children: [_buildOrderList("Pending"), _buildOrderList("Completed")]),
    );
  }

  Widget _buildOrderList(String filterStatus) {
    final filtered = _orders.where((o) => o['status'] == filterStatus).toList();
    if (filtered.isEmpty && !_isLoading) return Center(child: Text("No $filterStatus transactions"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final bool isBuying = order['buyer_name'] == _userName;

        return GestureDetector(
          onTap: () => _showReceipt(order),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: ListTile(
              leading: Icon(isBuying ? Icons.shopping_basket : Icons.store, color: isBuying ? Colors.blue : Colors.green),
              title: Text(order['surplus']['item_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${isBuying ? 'Buying' : 'Selling'} • ${order['delivery_method']}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("RM ${order['surplus']['price'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(filterStatus, style: TextStyle(fontSize: 10, color: filterStatus == "Pending" ? Colors.orange : Colors.green)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
