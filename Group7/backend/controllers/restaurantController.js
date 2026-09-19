const Restaurant = require('../models/Restaurant');
const FoodItem = require('../models/FoodItem');

// @desc    Get all restaurants
// @route   GET /api/restaurants
// @access  Public
exports.getRestaurants = async (req, res) => {
  try {
    const restaurants = await Restaurant.find().sort({ createdAt: -1 });
    res.json({
      success: true,
      count: restaurants.length,
      data: restaurants
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single restaurant with its menu items
// @route   GET /api/restaurants/:id
// @access  Public
exports.getRestaurantById = async (req, res) => {
  try {
    const restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found' });
    }

    // Fetch all food items of this restaurant
    const foodItems = await FoodItem.find({ restaurantId: req.params.id });

    res.json({
      success: true,
      data: {
        ...restaurant.toObject(),
        foodItems
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Create a new restaurant
// @route   POST /api/restaurants
// @access  Private (Admin / Restaurant Owner)
exports.createRestaurant = async (req, res) => {
  try {
    const { name, description, cuisineType, address, phone, imageUrl } = req.body;

    const restaurant = await Restaurant.create({
      name,
      description,
      cuisineType,
      address,
      phone,
      imageUrl,
      ownerId: req.user._id
    });

    res.status(201).json({
      success: true,
      data: restaurant
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update restaurant details
// @route   PUT /api/restaurants/:id
// @access  Private (Restaurant Owner / Admin)
exports.updateRestaurant = async (req, res) => {
  try {
    let restaurant = await Restaurant.findById(req.params.id);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found' });
    }

    // Check ownership if not admin
    if (req.user.role !== 'admin' && restaurant.ownerId && restaurant.ownerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized to update this restaurant' });
    }

    restaurant = await Restaurant.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.json({
      success: true,
      data: restaurant
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
