import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  void _showReceipt(Map<String, dynamic> order) {
    final bool isBuying = order['buyer_name'] == _userName;
    final String date = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(order['created_at']));

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text("Transaction Receipt", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const Text("KebunKomuniti Marketplace", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 32),
              
              _buildReceiptRow("Order ID", "#KB-${order['id']}"),
              _buildReceiptRow("Date", date),
              _buildReceiptRow("Type", isBuying ? "Purchased" : "Sold"),
              _buildReceiptRow("Item", order['surplus']['item_name']),
              _buildReceiptRow("Quantity", "${order['surplus']['quantity_kg']} kg"),
              _buildReceiptRow("Method", order['delivery_method']),
              
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("TOTAL PAID", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("RM ${order['surplus']['price'] ?? '0.00'}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade100, foregroundColor: Colors.black),
                  child: const Text("Close"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text("Transactions", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: "Active"), Tab(text: "Completed")],
          labelColor: Colors.green.shade800,
          indicatorColor: Colors.green.shade800,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList("Pending"),
          _buildOrderList("Completed"),
        ],
      ),
    );
  }

  Widget _buildOrderList(String filterStatus) {
    final filtered = _orders.where((o) => o['status'] == filterStatus).toList();
    if (filtered.isEmpty && !_isLoading) {
      return Center(child: Text("No $filterStatus transactions", style: const TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final bool isBuying = order['buyer_name'] == _userName;

        return GestureDetector(
          onTap: () => _showReceipt(order),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isBuying ? Colors.blue.shade50 : Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isBuying ? Icons.arrow_downward : Icons.arrow_upward, 
                    color: isBuying ? Colors.blue : Colors.green, size: 20
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(isBuying ? "BUY" : "SELL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isBuying ? Colors.blue : Colors.green, letterSpacing: 1)),
                          const SizedBox(width: 8),
                          Text(order['delivery_method'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Text(order['surplus']['item_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("RM ${order['surplus']['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(filterStatus, style: TextStyle(fontSize: 11, color: filterStatus == "Pending" ? Colors.orange : Colors.green)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
