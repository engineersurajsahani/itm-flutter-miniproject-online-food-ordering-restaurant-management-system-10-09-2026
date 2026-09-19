import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../models/restaurant_model.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/stat_card.dart';
import '../auth/login_screen.dart';
import 'manage_menu_screen.dart';
import 'incoming_orders_screen.dart';

class RestaurantDashboardScreen extends StatefulWidget {
  final UserModel user;

  const RestaurantDashboardScreen({super.key, required this.user});

  @override
  State<RestaurantDashboardScreen> createState() => _RestaurantDashboardScreenState();
}

class _RestaurantDashboardScreenState extends State<RestaurantDashboardScreen> {
  RestaurantModel? _restaurant;
  int _totalMenuItems = 0;
  int _activeOrdersCount = 0;
  int _completedOrdersCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRestaurantData();
  }

  Future<void> _fetchRestaurantData() async {
    setState(() => _isLoading = true);
    try {
      final restId = widget.user.restaurantId;
      if (restId == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Fetch restaurant details & menu items
      final restRes = await ApiService.get('${ApiConstants.restaurants}/$restId');
      if (restRes['data'] != null) {
        _restaurant = RestaurantModel.fromJson(restRes['data']);
        final items = restRes['data']['foodItems'] as List?;
        _totalMenuItems = items?.length ?? 0;
      }

      // Fetch restaurant orders to count active vs completed
      final ordersRes = await ApiService.get('${ApiConstants.orders}/restaurant/$restId');
      if (ordersRes['data'] != null) {
        final orders = ordersRes['data'] as List;
        _activeOrdersCount = orders.where((o) => ['Placed', 'Accepted', 'Preparing', 'Ready'].contains(o['orderStatus'])).length;
        _completedOrdersCount = orders.where((o) => o['orderStatus'] == 'Delivered').length;
      }

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load dashboard: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOpenStatus() async {
    if (_restaurant == null) return;
    try {
      final newStatus = !_restaurant!.isOpen;
      await ApiService.put('${ApiConstants.restaurants}/${_restaurant!.id}', {
        'isOpen': newStatus,
      });
      _fetchRestaurantData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final restId = widget.user.restaurantId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Manager Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchRestaurantData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restaurant Overview Card
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _restaurant?.name ?? 'My Restaurant',
                                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Owner: ${widget.user.name}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (_restaurant?.isOpen ?? true) ? Colors.green.shade50 : Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: (_restaurant?.isOpen ?? true) ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  child: Text(
                                    (_restaurant?.isOpen ?? true) ? 'OPEN FOR ORDERS' : 'STORE CLOSED',
                                    style: TextStyle(
                                      color: (_restaurant?.isOpen ?? true) ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Accept Online Orders:',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade800),
                                ),
                                Switch(
                                  value: _restaurant?.isOpen ?? true,
                                  activeColor: Colors.green,
                                  onChanged: (_) => _toggleOpenStatus(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Metrics Grid
                    const Text('Live Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Menu Dishes',
                            value: '$_totalMenuItems',
                            icon: Icons.restaurant_menu,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Active Orders',
                            value: '$_activeOrdersCount',
                            icon: Icons.pending_actions,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    StatCard(
                      title: 'Delivered / Completed',
                      value: '$_completedOrdersCount Orders',
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 20),

                    // Navigation Action Cards
                    const Text('Management Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Manage Menu
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.orange.shade100, shape: BoxShape.circle),
                          child: const Icon(Icons.menu_book, color: Colors.orange),
                        ),
                        title: const Text('Manage Menu & Pricing', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Add, edit prices, toggle availability, and delete dishes'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ManageMenuScreen(restaurantId: restId),
                            ),
                          ).then((_) => _fetchRestaurantData());
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Incoming Orders
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                          child: const Icon(Icons.delivery_dining, color: Colors.blue),
                        ),
                        title: const Text('Incoming Orders & Workflow', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Accept, prepare, mark ready, and deliver orders'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => IncomingOrdersScreen(restaurantId: restId),
                            ),
                          ).then((_) => _fetchRestaurantData());
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
