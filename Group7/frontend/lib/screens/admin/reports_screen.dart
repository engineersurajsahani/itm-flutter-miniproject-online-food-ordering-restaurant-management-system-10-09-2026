import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/status_badge.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<dynamic> _statusBreakdown = [];
  List<dynamic> _restaurantSales = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConstants.adminReports);
      if (res['data'] != null && mounted) {
        setState(() {
          _statusBreakdown = res['data']['statusBreakdown'] ?? [];
          _restaurantSales = res['data']['restaurantSales'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load reports: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance & Order Reports'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchReports,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Order Status Breakdown
                    const Text(
                      '1. Order Status Distribution',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _statusBreakdown.isEmpty
                            ? const Text('No orders recorded yet')
                            : Column(
                                children: _statusBreakdown.map((item) {
                                  final status = item['_id'] ?? 'Unknown';
                                  final count = item['count'] ?? 0;
                                  final revenue = item['revenue'] ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        StatusBadge(status: status),
                                        Text(
                                          '$count Orders',
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          '₹$revenue',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Restaurant Sales Summary
                    const Text(
                      '2. Restaurant Sales & Revenue',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _restaurantSales.isEmpty
                            ? const Text('No restaurant sales yet')
                            : Column(
                                children: [
                                  // Table Header
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            'Restaurant',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            'Orders',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            'Gross Sales',
                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(),
                                  ..._restaurantSales.map((item) {
                                    final name = item['restaurantName'] ?? 'Unknown';
                                    final totalOrders = item['totalOrders'] ?? 0;
                                    final totalSales = item['totalSales'] ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              '$totalOrders',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              '₹$totalSales',
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
