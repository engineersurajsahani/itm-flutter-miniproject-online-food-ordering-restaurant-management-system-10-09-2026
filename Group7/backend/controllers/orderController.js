const Order = require('../models/Order');
const FoodItem = require('../models/FoodItem');

// @desc    Place a new order
// @route   POST /api/orders
// @access  Private (Customer)
exports.createOrder = async (req, res) => {
  try {
    const { restaurantId, items, deliveryAddress, paymentType } = req.body;

    if (!items || items.length === 0) {
      return res.status(400).json({ success: false, message: 'Order must contain at least one item' });
    }

    if (!deliveryAddress) {
      return res.status(400).json({ success: false, message: 'Delivery address is required' });
    }

    // Verify items and calculate server-side total
    let totalAmount = 0;
    const validatedItems = [];

    for (const item of items) {
      const food = await FoodItem.findById(item.foodItemId);
      if (!food) {
        return res.status(404).json({ success: false, message: `Food item not found: ${item.foodItemId}` });
      }
      if (!food.isAvailable) {
        return res.status(400).json({ success: false, message: `Item is currently out of stock: ${food.name}` });
      }

      const itemQty = Number(item.quantity) || 1;
      const itemPrice = Number(food.price);
      totalAmount += itemPrice * itemQty;

      validatedItems.push({
        foodItemId: food._id,
        name: food.name,
        price: itemPrice,
        quantity: itemQty
      });
    }

    const order = await Order.create({
      customerId: req.user._id,
      restaurantId,
      items: validatedItems,
      totalAmount,
      deliveryAddress,
      paymentType: paymentType || 'Cash On Delivery',
      paymentStatus: 'Pending',
      orderStatus: 'Placed'
    });

    res.status(201).json({
      success: true,
      message: 'Order placed successfully',
      data: order
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get order history for logged-in customer
// @route   GET /api/orders/my-orders
// @access  Private (Customer)
exports.getMyOrders = async (req, res) => {
  try {
    const orders = await Order.find({ customerId: req.user._id })
      .populate('restaurantId', 'name address phone imageUrl')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      data: orders
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all orders for a specific restaurant
// @route   GET /api/orders/restaurant/:restaurantId
// @access  Private (Restaurant Owner / Admin)
exports.getRestaurantOrders = async (req, res) => {
  try {
    const orders = await Order.find({ restaurantId: req.params.restaurantId })
      .populate('customerId', 'name email phone address')
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: orders.length,
      data: orders
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Update order status workflow
// @route   PATCH /api/orders/:id/status
// @access  Private (Restaurant Owner / Admin)
exports.updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const allowedStatuses = ['Placed', 'Accepted', 'Preparing', 'Ready', 'Delivered', 'Cancelled'];

    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Allowed values are: ${allowedStatuses.join(', ')}`
      });
    }

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    order.orderStatus = status;

    // If order delivered, mark payment completed
    if (status === 'Delivered') {
      order.paymentStatus = 'Completed';
    }

    await order.save();

    res.json({
      success: true,
      message: `Order status updated to ${status}`,
      data: order
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get single order details
// @route   GET /api/orders/:id
// @access  Private
exports.getOrderById = async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('customerId', 'name email phone address')
      .populate('restaurantId', 'name address phone imageUrl');

    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    res.json({
      success: true,
      data: order
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
