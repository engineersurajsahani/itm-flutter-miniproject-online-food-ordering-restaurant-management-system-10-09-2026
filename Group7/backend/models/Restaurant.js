const mongoose = require('mongoose');

const restaurantSchema = new mongoose.Schema({
  name: {
    type: String,
    required: [true, 'Please provide restaurant name'],
    trim: true
  },
  description: {
    type: String,
    default: 'Delicious food served fresh every day.'
  },
  cuisineType: {
    type: String,
    default: 'Multi-Cuisine'
  },
  address: {
    type: String,
    required: [true, 'Please provide restaurant address']
  },
  phone: {
    type: String,
    required: [true, 'Please provide restaurant contact number']
  },
  imageUrl: {
    type: String,
    default: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=60'
  },
  isOpen: {
    type: Boolean,
    default: true
  },
  ownerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Restaurant', restaurantSchema);
