const mongoose = require('mongoose');

const foodItemSchema = new mongoose.Schema({
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: [true, 'Food item must belong to a restaurant']
  },
  name: {
    type: String,
    required: [true, 'Please provide food item name'],
    trim: true
  },
  description: {
    type: String,
    default: ''
  },
  price: {
    type: Number,
    required: [true, 'Please provide price for the food item'],
    min: 0
  },
  category: {
    type: String,
    default: 'Main Course',
    trim: true
  },
  isVeg: {
    type: Boolean,
    default: true
  },
  isAvailable: {
    type: Boolean,
    default: true
  },
  imageUrl: {
    type: String,
    default: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=500&auto=format&fit=crop&q=60'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('FoodItem', foodItemSchema);
