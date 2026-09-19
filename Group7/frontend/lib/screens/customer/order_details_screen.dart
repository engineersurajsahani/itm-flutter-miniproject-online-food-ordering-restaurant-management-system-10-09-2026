import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/status_badge.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel initialOrder;

  const OrderDetailsScreen({super.key, required this.initialOrder});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late OrderModel _order;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    setState(() => _isRefreshing = true);
    try {
      final res = await ApiService.get('${ApiConstants.orders}/${_order.id}');
      if (res['data'] != null && mounted) {
        setState(() {
          _order = OrderModel.fromJson(res['data']);
        });
      }
    } catch (e) {
      // Keep old state on error
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Widget _buildStatusStep(String stepName, int stepIndex, int currentStatusIndex, IconData icon) {
    final isPassed = currentStatusIndex >= stepIndex;
    final isCurrent = currentStatusIndex == stepIndex;

    Color color = Colors.grey.shade400;
    if (isCurrent) color = Theme.of(context).primaryColor;
    if (isPassed && !isCurrent) color = Colors.green;

    return Column(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isPassed ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            isPassed && !isCurrent ? Icons.check : icon,
            size: 20,
            color: isPassed ? Colors.white : color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepName,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isPassed ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stages = ['Placed', 'Accepted', 'Preparing', 'Ready', 'Delivered'];
    final currentIndex = stages.indexOf(_order.orderStatus);

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.id.substring(_order.id.length > 6 ? _order.id.length - 6 : 0).toUpperCase()}'),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _refreshOrder,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Workflow Tracker Card
            Card(
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
                        const Text(
                          'Order Status',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        StatusBadge(status: _order.orderStatus),
                      ],
                    ),
                    const Divider(height: 24),
                    if (_order.orderStatus == 'Cancelled')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cancel, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            const Text(
                              'This order was cancelled.',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusStep('Placed', 0, currentIndex, Icons.receipt_long),
                            Expanded(child: Container(height: 2, color: currentIndex >= 1 ? Colors.green : Colors.grey.shade300)),
                            _buildStatusStep('Accepted', 1, currentIndex, Icons.thumb_up_alt_outlined),
                            Expanded(child: Container(height: 2, color: currentIndex >= 2 ? Colors.green : Colors.grey.shade300)),
                            _buildStatusStep('Cooking', 2, currentIndex, Icons.soup_kitchen_outlined),
                            Expanded(child: Container(height: 2, color: currentIndex >= 3 ? Colors.green : Colors.grey.shade300)),
                            _buildStatusStep('Ready', 3, currentIndex, Icons.takeout_dining_outlined),
                            Expanded(child: Container(height: 2, color: currentIndex >= 4 ? Colors.green : Colors.grey.shade300)),
                            _buildStatusStep('Delivered', 4, currentIndex, Icons.check_circle_outline),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Restaurant & Order Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(
                          _order.restaurantName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Placed on: ${DateFormat('dd MMM yyyy, hh:mm a').format(_order.createdAt)}',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    const Divider(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Delivery To: ${_order.deliveryAddress}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items Ordered Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Items Ordered',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 20),
                    ..._order.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x  ${item.name}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${_order.totalAmount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Payment Mode: ${_order.paymentType}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                        Text(
                          'Status: ${_order.paymentStatus}',
                          style: TextStyle(
                            color: _order.paymentStatus == 'Completed' ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
