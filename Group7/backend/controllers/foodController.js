const FoodItem = require('../models/FoodItem');
const Restaurant = require('../models/Restaurant');

// @desc    Get all food items for a specific restaurant
// @route   GET /api/food-items/restaurant/:restaurantId
// @access  Public
exports.getFoodItemsByRestaurant = async (req, res) => {
  try {
    const foodItems = await FoodItem.find({ restaurantId: req.params.restaurantId }).sort({ category: 1, name: 1 });
    res.json({
      success: true,
      count: foodItems.length,
      data: foodItems
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Add a new food item to restaurant menu
// @route   POST /api/food-items
// @access  Private (Restaurant Owner / Admin)
exports.createFoodItem = async (req, res) => {
  try {
    const { restaurantId, name, description, price, category, isVeg, imageUrl, isAvailable } = req.body;

    // Check if restaurant exists
    const restaurant = await Restaurant.findById(restaurantId);
    if (!restaurant) {
      return res.status(404).json({ success: false, message: 'Restaurant not found' });
    }

    const foodItem = await FoodItem.create({
      restaurantId,
      name,
      description: description || '',
      price: Number(price),
      category: category || 'Main Course',
      isVeg: isVeg !== undefined ? isVeg : true,
      imageUrl: imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60',
      isAvailable: isAvailable !== undefined ? isAvailable : true
    });

    res.status(201).json({
      success: true,
      message: 'Food item added to menu successfully',
      data: foodItem
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update a food item
// @route   PUT /api/food-items/:id
// @access  Private (Restaurant Owner / Admin)
exports.updateFoodItem = async (req, res) => {
  try {
    let foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    foodItem = await FoodItem.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });

    res.json({
      success: true,
      message: 'Food item updated successfully',
      data: foodItem
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Toggle food item availability (In Stock / Out of Stock)
// @route   PATCH /api/food-items/:id/availability
// @access  Private (Restaurant Owner / Admin)
exports.toggleAvailability = async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    foodItem.isAvailable = !foodItem.isAvailable;
    await foodItem.save();

    res.json({
      success: true,
      message: `Food item marked as ${foodItem.isAvailable ? 'Available' : 'Out of Stock'}`,
      data: foodItem
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Delete a food item
// @route   DELETE /api/food-items/:id
// @access  Private (Restaurant Owner / Admin)
exports.deleteFoodItem = async (req, res) => {
  try {
    const foodItem = await FoodItem.findById(req.params.id);
    if (!foodItem) {
      return res.status(404).json({ success: false, message: 'Food item not found' });
    }

    await FoodItem.findByIdAndDelete(req.params.id);

    res.json({
      success: true,
      message: 'Food item removed from menu successfully'
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
