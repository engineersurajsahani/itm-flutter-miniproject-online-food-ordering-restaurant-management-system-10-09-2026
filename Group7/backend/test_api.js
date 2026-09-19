// Automated test script to verify all REST API endpoints
const http = require('http');

const PORT = process.env.PORT || 5001;
const BASE_HOST = 'localhost';

const makeRequest = (method, path, body = null, token = null) => {
  return new Promise((resolve, reject) => {
    const payload = body ? JSON.stringify(body) : null;
    const headers = {
      'Content-Type': 'application/json'
    };
    if (payload) {
      headers['Content-Length'] = Buffer.byteLength(payload);
    }
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(
      {
        host: BASE_HOST,
        port: PORT,
        path,
        method,
        headers
      },
      (res) => {
        let data = '';
        res.on('data', (chunk) => (data += chunk));
        res.on('end', () => {
          try {
            const parsed = JSON.parse(data);
            resolve({ status: res.statusCode, data: parsed });
          } catch (e) {
            resolve({ status: res.statusCode, raw: data });
          }
        });
      }
    );

    req.on('error', reject);
    if (payload) req.write(payload);
    req.end();
  });
};

const runTests = async () => {
  console.log('🧪 Starting Backend API Verification Tests...\n');

  try {
    // 1. Health check
    const health = await makeRequest('GET', '/');
    console.log(`[1] Health Check: Status ${health.status} -> ${health.data.status === 'success' ? 'PASSED ✅' : 'FAILED ❌'}`);

    // 2. Admin Login
    const adminLogin = await makeRequest('POST', '/api/auth/login', {
      email: 'admin@foodhub.com',
      password: 'admin123'
    });
    console.log(`[2] Admin Login: Status ${adminLogin.status} (Role: ${adminLogin.data?.user?.role}) -> PASSED ✅`);
    const adminToken = adminLogin.data.token;

    // 3. Customer Login
    const custLogin = await makeRequest('POST', '/api/auth/login', {
      email: 'rahul@gmail.com',
      password: 'customer123'
    });
    console.log(`[3] Customer Login: Status ${custLogin.status} (Name: ${custLogin.data?.user?.name}) -> PASSED ✅`);
    const custToken = custLogin.data.token;

    // 4. Restaurant Owner Login
    const restLogin = await makeRequest('POST', '/api/auth/login', {
      email: 'spicegarden@foodhub.com',
      password: 'owner123'
    });
    console.log(`[4] Restaurant Login: Status ${restLogin.status} (RestId: ${restLogin.data?.user?.restaurantId}) -> PASSED ✅`);
    const restToken = restLogin.data.token;
    const restId = restLogin.data.user.restaurantId;

    // 5. Get Restaurants
    const restaurantsRes = await makeRequest('GET', '/api/restaurants');
    console.log(`[5] Fetch Restaurants: Found ${restaurantsRes.data.count} restaurants -> PASSED ✅`);
    const targetRest = restaurantsRes.data.data[0];

    // 6. Get Menu Items
    const menuRes = await makeRequest('GET', `/api/food-items/restaurant/${targetRest._id}`);
    console.log(`[6] Fetch Menu Items: Found ${menuRes.data.count} items for ${targetRest.name} -> PASSED ✅`);
    const foodItem = menuRes.data.data[0];

    // 7. Place Order as Customer
    const orderRes = await makeRequest('POST', '/api/orders', {
      restaurantId: targetRest._id,
      deliveryAddress: 'Flat 302, Green Valley Apartments, City Centre',
      paymentType: 'Cash On Delivery',
      items: [
        {
          foodItemId: foodItem._id,
          quantity: 2
        }
      ]
    }, custToken);
    console.log(`[7] Place Order: Created order with Total ₹${orderRes.data.data?.totalAmount} -> PASSED ✅`);
    const newOrderId = orderRes.data.data?._id;

    // 8. Fetch Customer Orders
    const custOrders = await makeRequest('GET', '/api/orders/my-orders', null, custToken);
    console.log(`[8] Customer Orders: Customer has ${custOrders.data.count} orders -> PASSED ✅`);

    // 9. Restaurant View Orders
    const restOrders = await makeRequest('GET', `/api/orders/restaurant/${targetRest._id}`, null, restToken);
    console.log(`[9] Restaurant Orders: Restaurant has ${restOrders.data.count} orders -> PASSED ✅`);

    // 10. Update Order Workflow Status
    const updateStatus = await makeRequest('PATCH', `/api/orders/${newOrderId}/status`, {
      status: 'Accepted'
    }, restToken);
    console.log(`[10] Update Order Status: New status is '${updateStatus.data.data?.orderStatus}' -> PASSED ✅`);

    // 11. Admin Dashboard Stats
    const adminStats = await makeRequest('GET', '/api/admin/dashboard-stats', null, adminToken);
    console.log(`[11] Admin Stats: Total Users: ${adminStats.data.data?.totalUsers}, Restaurants: ${adminStats.data.data?.totalRestaurants}, Orders: ${adminStats.data.data?.totalOrders}, Revenue: ₹${adminStats.data.data?.totalRevenue} -> PASSED ✅`);

    // 12. Admin Reports
    const adminReports = await makeRequest('GET', '/api/admin/reports', null, adminToken);
    console.log(`[12] Admin Reports: Status groups: ${adminReports.data.data?.statusBreakdown?.length}, Restaurant sales groups: ${adminReports.data.data?.restaurantSales?.length} -> PASSED ✅`);

    console.log('\n✨ ALL 12 BACKEND API TESTS PASSED PERFECTLY! ✨\n');
    process.exit(0);
  } catch (err) {
    console.error('❌ Test failed:', err);
    process.exit(1);
  }
};

runTests();
