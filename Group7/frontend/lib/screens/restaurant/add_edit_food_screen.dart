import 'package:flutter/material.dart';
import '../../models/food_item_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class AddEditFoodScreen extends StatefulWidget {
  final String restaurantId;
  final FoodItemModel? existingItem;

  const AddEditFoodScreen({
    super.key,
    required this.restaurantId,
    this.existingItem,
  });

  @override
  State<AddEditFoodScreen> createState() => _AddEditFoodScreenState();
}

class _AddEditFoodScreenState extends State<AddEditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _category = 'Main Course';
  bool _isVeg = true;
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _categories = [
    'Main Course',
    'Starters',
    'Breads',
    'Pizzas',
    'Burgers',
    'Desserts',
    'Beverages',
    'Fast Food',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingItem != null) {
      final item = widget.existingItem!;
      _nameController.text = item.name;
      _descController.text = item.description;
      _priceController.text = item.price.toStringAsFixed(0);
      _imageUrlController.text = item.imageUrl;
      _category = _categories.contains(item.category) ? item.category : 'Main Course';
      _isVeg = item.isVeg;
      _isAvailable = item.isAvailable;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveFoodItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final payload = {
      'restaurantId': widget.restaurantId,
      'name': _nameController.text.trim(),
      'description': _descController.text.trim(),
      'price': double.tryParse(_priceController.text) ?? 0.0,
      'category': _category,
      'isVeg': _isVeg,
      'isAvailable': _isAvailable,
      'imageUrl': _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500',
    };

    try {
      if (widget.existingItem == null) {
        // Create new item
        await ApiService.post(ApiConstants.foodItems, payload);
      } else {
        // Update existing item
        await ApiService.put('${ApiConstants.foodItems}/${widget.existingItem!.id}', payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingItem == null ? 'Dish added successfully!' : 'Dish updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Food Item' : 'Add Food Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Dish Name',
                hint: 'e.g. Paneer Butter Masala',
                prefixIcon: Icons.fastfood_outlined,
                validator: (v) => (v == null || v.isEmpty) ? 'Please enter dish name' : null,
              ),
              CustomTextField(
                controller: _priceController,
                label: 'Price (₹)',
                hint: 'e.g. 250',
                prefixIcon: Icons.currency_rupee,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter price';
                  if (double.tryParse(v) == null) return 'Enter valid number';
                  return null;
                },
              ),

              // Category Selector
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: 'Menu Category',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(value: c, child: Text(c));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _category = val);
                  },
                ),
              ),

              CustomTextField(
                controller: _descController,
                label: 'Description',
                hint: 'Brief description of ingredients or taste...',
                prefixIcon: Icons.description_outlined,
                maxLines: 2,
              ),

              CustomTextField(
                controller: _imageUrlController,
                label: 'Image URL (Optional)',
                hint: 'https://...',
                prefixIcon: Icons.image_outlined,
              ),

              const SizedBox(height: 12),

              // Veg / Non-Veg Switch
              SwitchListTile(
                title: const Text('Vegetarian Dish'),
                subtitle: Text(_isVeg ? 'Marked as Pure Veg 🟢' : 'Marked as Non-Veg 🔴'),
                value: _isVeg,
                activeColor: Colors.green,
                onChanged: (val) => setState(() => _isVeg = val),
              ),

              // In Stock / Available Switch
              SwitchListTile(
                title: const Text('Item Available / In Stock'),
                subtitle: Text(_isAvailable ? 'Customers can order this dish' : 'Currently hidden / marked sold out'),
                value: _isAvailable,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (val) => setState(() => _isAvailable = val),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: isEditing ? 'Update Dish Details' : 'Add Dish to Menu',
                isLoading: _isLoading,
                onPressed: _saveFoodItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
