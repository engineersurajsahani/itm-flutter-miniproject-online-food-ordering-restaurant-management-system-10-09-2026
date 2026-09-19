const express = require('express');
const router = express.Router();
const {
  getDashboardStats,
  getUsers,
  getAllOrders,
  getReports
} = require('../controllers/adminController');
const { protect, authorize } = require('../middleware/authMiddleware');

// All admin routes are protected and require 'admin' role
router.use(protect);
router.use(authorize('admin'));

router.get('/dashboard-stats', getDashboardStats);
router.get('/users', getUsers);
router.get('/orders', getAllOrders);
router.get('/reports', getReports);

module.exports = router;
