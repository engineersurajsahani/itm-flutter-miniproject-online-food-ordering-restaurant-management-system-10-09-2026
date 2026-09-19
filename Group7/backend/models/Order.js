const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  foodItemId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'FoodItem',
    required: true
  },
  name: {
    type: String,
    required: true
  },
  price: {
    type: Number,
    required: true
  },
  quantity: {
    type: Number,
    required: true,
    min: 1,
    default: 1
  }
}, { _id: false });

const orderSchema = new mongoose.Schema({
  customerId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: [true, 'Order must belong to a customer']
  },
  restaurantId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Restaurant',
    required: [true, 'Order must belong to a restaurant']
  },
  items: {
    type: [orderItemSchema],
    validate: [val => val.length > 0, 'Order must have at least one food item']
  },
  totalAmount: {
    type: Number,
    required: true,
    min: 0
  },
  deliveryAddress: {
    type: String,
    required: [true, 'Delivery address is required']
  },
  paymentType: {
    type: String,
    default: 'Cash On Delivery'
  },
  paymentStatus: {
    type: String,
    enum: ['Pending', 'Completed'],
    default: 'Pending'
  },
  orderStatus: {
    type: String,
    enum: ['Placed', 'Accepted', 'Preparing', 'Ready', 'Delivered', 'Cancelled'],
    default: 'Placed'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

module.exports = mongoose.model('Order', orderSchema);
