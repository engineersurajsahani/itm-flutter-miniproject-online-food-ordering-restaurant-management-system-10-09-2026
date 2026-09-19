import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/stat_card.dart';
import '../auth/login_screen.dart';
import 'view_users_screen.dart';
import 'all_orders_screen.dart';
import 'reports_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _totalUsers = 0;
  int _totalRestaurants = 0;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;
  List<dynamic> _recentOrders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConstants.adminStats);
      if (res['data'] != null && mounted) {
        final data = res['data'];
        setState(() {
          _totalUsers = data['totalUsers'] ?? 0;
          _totalRestaurants = data['totalRestaurants'] ?? 0;
          _totalOrders = data['totalOrders'] ?? 0;
          _totalRevenue = (data['totalRevenue'] as num?)?.toDouble() ?? 0.0;
          _recentOrders = data['recentOrders'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stats: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Admin Logout'),
        content: const Text('Are you sure you want to exit admin session?'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Control Panel'),
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
              onRefresh: _fetchStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Summary Metrics Grid
                    const Text('Platform Key Metrics', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Users',
                            value: '$_totalUsers',
                            icon: Icons.people_outline,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Restaurants',
                            value: '$_totalRestaurants',
                            icon: Icons.storefront,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Total Orders',
                            value: '$_totalOrders',
                            icon: Icons.receipt_long,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatCard(
                            title: 'Total Revenue',
                            value: '₹${_totalRevenue.toStringAsFixed(0)}',
                            icon: Icons.currency_rupee,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Management Navigation Cards
                    const Text('System Management', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // 1. Registered Customers
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.people, color: Colors.blue),
                        ),
                        title: const Text('Registered Customers', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('View customer profiles, contacts, and delivery addresses'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ViewUsersScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 2. All Orders
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.purple.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.receipt, color: Colors.purple),
                        ),
                        title: const Text('All Platform Orders', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Monitor transactions and order workflow statuses'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AllOrdersScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),

                    // 3. Reports & Analytics
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.green.shade50, shape: BoxShape.circle),
                          child: const Icon(Icons.analytics_outlined, color: Colors.green),
                        ),
                        title: const Text('Performance & Reports', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Order status distributions and restaurant sales breakdowns'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportsScreen()),
                          );
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
