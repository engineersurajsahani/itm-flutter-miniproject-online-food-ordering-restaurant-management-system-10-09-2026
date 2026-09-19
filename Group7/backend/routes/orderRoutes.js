const express = require('express');
const router = express.Router();
const {
  createOrder,
  getMyOrders,
  getRestaurantOrders,
  updateOrderStatus,
  getOrderById
} = require('../controllers/orderController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.post('/', protect, authorize('customer', 'admin'), createOrder);
router.get('/my-orders', protect, authorize('customer', 'admin'), getMyOrders);
router.get('/restaurant/:restaurantId', protect, authorize('restaurant', 'admin'), getRestaurantOrders);
router.patch('/:id/status', protect, authorize('restaurant', 'admin'), updateOrderStatus);
router.get('/:id', protect, getOrderById);

module.exports = router;
