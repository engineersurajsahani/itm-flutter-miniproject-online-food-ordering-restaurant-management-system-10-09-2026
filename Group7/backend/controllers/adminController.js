const User = require('../models/User');
const Restaurant = require('../models/Restaurant');
const Order = require('../models/Order');

// @desc    Get high-level system dashboard statistics
// @route   GET /api/admin/dashboard-stats
// @access  Private (Admin)
exports.getDashboardStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments({ role: 'customer' });
    const totalRestaurants = await Restaurant.countDocuments();
    const totalOrders = await Order.countDocuments();

    // Calculate total revenue from delivered / completed orders
    const revenueData = await Order.aggregate([
      { $match: { orderStatus: { $ne: 'Cancelled' } } },
      { $group: { _id: null, totalRevenue: { $sum: '$totalAmount' } } }
    ]);
    const totalRevenue = revenueData.length > 0 ? revenueData[0].totalRevenue : 0;

    // Recent 5 orders
    const recentOrders = await Order.find()
      .populate('customerId', 'name')
      .populate('restaurantId', 'name')
      .sort({ createdAt: -1 })
      .limit(5);

    res.json({
      success: true,
      data: {
        totalUsers,
        totalRestaurants,
        totalOrders,
        totalRevenue,
        recentOrders
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all registered customers
// @route   GET /api/admin/users
// @access  Private (Admin)
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find({ role: 'customer' }).select('-password').sort({ createdAt: -1 });
    res.json({
      success: true,
      count: users.length,
      data: users
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// @desc    Get all orders platform-wide
// @route   GET /api/admin/orders
// @access  Private (Admin)
exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.find()
      .populate('customerId', 'name email phone')
      .populate('restaurantId', 'name address phone')
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

// @desc    Get platform reports (Order status breakdown & restaurant sales)
// @route   GET /api/admin/reports
// @access  Private (Admin)
exports.getReports = async (req, res) => {
  try {
    // 1. Status breakdown
    const statusBreakdown = await Order.aggregate([
      {
        $group: {
          _id: '$orderStatus',
          count: { $sum: 1 },
          revenue: { $sum: '$totalAmount' }
        }
      }
    ]);

    // 2. Sales per restaurant
    const restaurantSales = await Order.aggregate([
      {
        $group: {
          _id: '$restaurantId',
          totalOrders: { $sum: 1 },
          totalSales: { $sum: '$totalAmount' }
        }
      },
      {
        $lookup: {
          from: 'restaurants',
          localField: '_id',
          foreignField: '_id',
          as: 'restaurant'
        }
      },
      {
        $unwind: '$restaurant'
      },
      {
        $project: {
          restaurantId: '$_id',
          restaurantName: '$restaurant.name',
          totalOrders: 1,
          totalSales: 1
        }
      },
      {
        $sort: { totalSales: -1 }
      }
    ]);

    res.json({
      success: true,
      data: {
        statusBreakdown,
        restaurantSales
      }
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
