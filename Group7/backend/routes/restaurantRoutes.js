const express = require('express');
const router = express.Router();
const {
  getRestaurants,
  getRestaurantById,
  createRestaurant,
  updateRestaurant
} = require('../controllers/restaurantController');
const { protect, authorize } = require('../middleware/authMiddleware');

router.get('/', getRestaurants);
router.get('/:id', getRestaurantById);
router.post('/', protect, authorize('admin', 'restaurant'), createRestaurant);
router.put('/:id', protect, authorize('admin', 'restaurant'), updateRestaurant);

module.exports = router;
