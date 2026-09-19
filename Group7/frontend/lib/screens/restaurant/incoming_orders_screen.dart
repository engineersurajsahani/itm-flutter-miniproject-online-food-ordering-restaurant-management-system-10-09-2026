import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/status_badge.dart';

class IncomingOrdersScreen extends StatefulWidget {
  final String restaurantId;

  const IncomingOrdersScreen({super.key, required this.restaurantId});

  @override
  State<IncomingOrdersScreen> createState() => _IncomingOrdersScreenState();
}

class _IncomingOrdersScreenState extends State<IncomingOrdersScreen> {
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String _statusFilter = 'All';

  final List<String> _filters = ['All', 'Placed', 'Accepted', 'Preparing', 'Ready', 'Delivered', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('${ApiConstants.orders}/restaurant/${widget.restaurantId}');
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

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await ApiService.patch('${ApiConstants.orders}/$orderId/status', {
        'status': newStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status changed to $newStatus!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
        _fetchOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildActionButton(OrderModel order) {
    switch (order.orderStatus) {
      case 'Placed':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                label: const Text('Accept Order'),
                onPressed: () => _updateStatus(order.id, 'Accepted'),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Decline'),
              onPressed: () => _updateStatus(order.id, 'Cancelled'),
            ),
          ],
        );

      case 'Accepted':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.soup_kitchen_outlined, size: 18),
            label: const Text('Start Preparing / Cooking'),
            onPressed: () => _updateStatus(order.id, 'Preparing'),
          ),
        );

      case 'Preparing':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.takeout_dining_outlined, size: 18),
            label: const Text('Mark Ready for Delivery / Pickup'),
            onPressed: () => _updateStatus(order.id, 'Ready'),
          ),
        );

      case 'Ready':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('Mark Delivered'),
            onPressed: () => _updateStatus(order.id, 'Delivered'),
          ),
        );

      case 'Delivered':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '✅ Order Completed & Delivered',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ),
        );

      case 'Cancelled':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text(
              '❌ Order Cancelled',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _statusFilter == 'All'
        ? _orders
        : _orders.where((o) => o.orderStatus == _statusFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incoming Orders & Workflow'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 48,
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final filter = _filters[idx];
                final isSelected = filter == _statusFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _statusFilter = filter),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // Orders List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchOrders,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredOrders.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_outlined, size: 70, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                _statusFilter == 'All'
                                    ? 'No orders received yet'
                                    : 'No orders with status "$_statusFilter"',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredOrders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final order = filteredOrders[index];

                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Order ID & Status
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

                                    // Customer Info
                                    Row(
                                      children: [
                                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Customer: ${order.customerName}',
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                        if (order.customerPhone.isNotEmpty) ...[
                                          const SizedBox(width: 8),
                                          Text('(${order.customerPhone})', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Deliver to: ${order.deliveryAddress}',
                                            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18),

                                    // Items List
                                    const Text('Items Ordered:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const SizedBox(height: 6),
                                    ...order.items.map((item) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${item.quantity}x ${item.name}', style: const TextStyle(fontSize: 13)),
                                            Text('₹${(item.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                                          ],
                                        ),
                                      );
                                    }),
                                    const Divider(height: 18),

                                    // Total & Payment
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Total Bill:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        Text(
                                          '₹${order.totalAmount.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),

                                    // 1-Click Status Workflow Action Button
                                    _buildActionButton(order),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
