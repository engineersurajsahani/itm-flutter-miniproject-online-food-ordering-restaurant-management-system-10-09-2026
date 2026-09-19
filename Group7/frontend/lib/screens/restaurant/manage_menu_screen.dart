import 'package:flutter/material.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import 'add_edit_food_screen.dart';

class ManageMenuScreen extends StatefulWidget {
  final String restaurantId;

  const ManageMenuScreen({super.key, required this.restaurantId});

  @override
  State<ManageMenuScreen> createState() => _ManageMenuScreenState();
}

class _ManageMenuScreenState extends State<ManageMenuScreen> {
  List<FoodItemModel> _foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('${ApiConstants.foodItems}/restaurant/${widget.restaurantId}');
      if (res['data'] != null && mounted) {
        final list = (res['data'] as List).map((i) => FoodItemModel.fromJson(i)).toList();
        setState(() {
          _foodItems = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load menu: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleAvailability(FoodItemModel item) async {
    try {
      await ApiService.patch('${ApiConstants.foodItems}/${item.id}/availability');
      _fetchMenu();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteFoodItem(FoodItemModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Food Item'),
        content: Text('Are you sure you want to remove "${item.name}" from your menu?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.delete('${ApiConstants.foodItems}/${item.id}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dish removed from menu'), backgroundColor: Colors.green),
          );
          _fetchMenu();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu & Pricing Management'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMenu,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _foodItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.restaurant_menu, size: 70, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text('No menu items yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Tap the + button below to add your first dish!', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _foodItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _foodItems[index];
                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Veg icon
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: item.isVeg ? Colors.green : Colors.red,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.circle,
                                      size: 10,
                                      color: item.isVeg ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 10),

                                  // Name & category
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.category} • ₹${item.price.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (item.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            item.description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 18),

                              // Controls: Available Switch, Edit, Delete
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Switch(
                                        value: item.isAvailable,
                                        activeColor: Colors.green,
                                        onChanged: (_) => _toggleAvailability(item),
                                      ),
                                      Text(
                                        item.isAvailable ? 'In Stock' : 'Out of Stock',
                                        style: TextStyle(
                                          color: item.isAvailable ? Colors.green : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        tooltip: 'Edit Price / Details',
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => AddEditFoodScreen(
                                                restaurantId: widget.restaurantId,
                                                existingItem: item,
                                              ),
                                            ),
                                          ).then((res) {
                                            if (res == true) _fetchMenu();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                                        tooltip: 'Delete Dish',
                                        onPressed: () => _deleteFoodItem(item),
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditFoodScreen(restaurantId: widget.restaurantId),
            ),
          ).then((res) {
            if (res == true) _fetchMenu();
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('Add New Dish'),
      ),
    );
  }
}
