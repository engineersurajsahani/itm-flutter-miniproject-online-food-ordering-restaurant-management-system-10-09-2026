import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../services/api_service.dart';
import '../../config/api_constants.dart';
import 'menu_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<RestaurantModel> _restaurants = [];
  List<RestaurantModel> _filteredRestaurants = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRestaurants() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConstants.restaurants);
      if (res['data'] != null && mounted) {
        final list = (res['data'] as List).map((i) => RestaurantModel.fromJson(i)).toList();
        setState(() {
          _restaurants = list;
          _filteredRestaurants = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load restaurants: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterSearch(String query) {
    if (query.isEmpty) {
      setState(() => _filteredRestaurants = _restaurants);
    } else {
      final lower = query.toLowerCase();
      setState(() {
        _filteredRestaurants = _restaurants.where((r) {
          return r.name.toLowerCase().contains(lower) || r.cuisineType.toLowerCase().contains(lower);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _fetchRestaurants,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                onChanged: _filterSearch,
                decoration: InputDecoration(
                  hintText: 'Search restaurants or cuisines...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Restaurants List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredRestaurants.isEmpty
                      ? const Center(child: Text('No restaurants found.'))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant = _filteredRestaurants[index];
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MenuScreen(restaurant: restaurant),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Restaurant Image Banner
                                    Image.network(
                                      restaurant.imageUrl,
                                      height: 140,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 140,
                                        color: Colors.grey.shade300,
                                        child: const Center(child: Icon(Icons.restaurant, size: 48, color: Colors.grey)),
                                      ),
                                    ),

                                    // Content
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  restaurant.name,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: restaurant.isOpen ? Colors.green.shade50 : Colors.red.shade50,
                                                  borderRadius: BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: restaurant.isOpen ? Colors.green : Colors.red,
                                                  ),
                                                ),
                                                child: Text(
                                                  restaurant.isOpen ? 'OPEN' : 'CLOSED',
                                                  style: TextStyle(
                                                    color: restaurant.isOpen ? Colors.green : Colors.red,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            restaurant.cuisineType,
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  restaurant.address,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
