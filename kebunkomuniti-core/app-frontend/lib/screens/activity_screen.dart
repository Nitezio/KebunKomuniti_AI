import 'package:flutter/material.dart';
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
  final String _userName = "Ahmad bin Razak"; // Mock current user

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      appBar: AppBar(
        title: const Text("Orders & Activity", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green.shade800,
          indicatorColor: Colors.green.shade800,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Active Orders"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : TabBarView(
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
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text("No $filterStatus orders yet", style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final order = filtered[index];
        final bool isBuying = order['buyer_name'] == _userName;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: isBuying ? Colors.blue.shade50 : Colors.green.shade50, shape: BoxShape.circle),
                child: Icon(isBuying ? Icons.shopping_cart : Icons.sell, color: isBuying ? Colors.blue : Colors.green),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order['surplus']['item_name'] ?? "Item", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(isBuying ? "Buying from Neighbor" : "Selling to Neighbor", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("RM ${order['surplus']['price'] ?? '0.00'}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: filterStatus == "Pending" ? Colors.orange.shade100 : Colors.green.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(filterStatus, style: TextStyle(fontSize: 10, color: filterStatus == "Pending" ? Colors.orange.shade900 : Colors.green.shade900, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
