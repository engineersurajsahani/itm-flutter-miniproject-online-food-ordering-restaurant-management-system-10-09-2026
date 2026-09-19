import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/status_badge.dart';

class AllOrdersScreen extends StatefulWidget {
  const AllOrdersScreen({super.key});

  @override
  State<AllOrdersScreen> createState() => _AllOrdersScreenState();
}

class _AllOrdersScreenState extends State<AllOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAllOrders();
  }

  Future<void> _fetchAllOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConstants.adminOrders);
      if (res['data'] != null && mounted) {
        final list = (res['data'] as List).map((i) => OrderModel.fromJson(i)).toList();
        setState(() {
          _orders = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: $e'), backgroundColor: Colors.red),
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
        title: const Text('All Platform Orders'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchAllOrders,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _orders.isEmpty
                ? const Center(child: Text('No orders found on the platform.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final itemsSummary = order.items.map((i) => '${i.quantity}x ${i.name}').join(', ');

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order #${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0).toUpperCase()}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  StatusBadge(status: order.orderStatus),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMM yyyy, hh:mm a').format(order.createdAt),
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              const Divider(height: 18),
                              Row(
                                children: [
                                  const Icon(Icons.storefront, size: 16, color: Colors.orange),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Restaurant: ${order.restaurantName}',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline, size: 16, color: Colors.blue),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Customer: ${order.customerName}',
                                    style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Items: $itemsSummary',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Bill: ₹${order.totalAmount.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  Text(
                                    'Payment: ${order.paymentType} (${order.paymentStatus})',
                                    style: TextStyle(
                                      color: order.paymentStatus == 'Completed' ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
