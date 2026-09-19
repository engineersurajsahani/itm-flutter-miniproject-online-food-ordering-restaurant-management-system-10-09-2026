const express = require('express');
const router = express.Router();
const {
  getFoodItemsByRestaurant,
  createFoodItem,
  updateFoodItem,
  toggleAvailability,
  deleteFoodItem
} = require('../controllers/foodController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/restaurant/:restaurantId', getFoodItemsByRestaurant);
router.post('/', protect, authorize('admin', 'restaurant'), createFoodItem);
router.put('/:id', protect, authorize('admin', 'restaurant'), updateFoodItem);
router.patch('/:id/availability', protect, authorize('admin', 'restaurant'), toggleAvailability);
router.delete('/:id', protect, authorize('admin', 'restaurant'), deleteFoodItem);

module.exports = router;
