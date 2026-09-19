# 🍔 Online Food Ordering & Restaurant Management System

A beginner-friendly, full-stack college assignment project built with **Flutter** (Frontend), **Node.js + Express.js** (Backend REST API), and **MongoDB** (Database).

---

## 📌 Project Overview

This system provides a complete end-to-end multi-role food ordering platform with:
1. **Order Workflow Management**: `Placed` → `Accepted` → `Preparing` → `Ready` → `Delivered` (or `Cancelled`).
2. **Menu & Pricing Control**: Add dishes, change prices, toggle in-stock/out-of-stock, and delete items.
3. **Role-Based Dashboards**: Distinct interfaces and permissions for **Customer**, **Restaurant Owner**, and **System Admin**.
4. **Order History & Reports**: Live order tracking, order history, platform sales analytics, and restaurant revenue reports.

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart) — Material Design, responsive forms, status badges, cart state.
- **Backend**: Node.js, Express.js — RESTful API architecture with JWT authentication and role-based middleware.
- **Database**: MongoDB with Mongoose ODM.
- **Communication**: RESTful JSON APIs via HTTP.

---

## 📂 Project Structure

```
SemiProject/
├── backend/
│   ├── config/
│   │   └── db.js                 # MongoDB connection
│   ├── models/
│   │   ├── User.js               # Customer, Restaurant Owner, Admin schemas
│   │   ├── Restaurant.js         # Restaurant profile schema
│   │   ├── FoodItem.js           # Menu items & pricing schema
│   │   └── Order.js              # Order workflow schema
│   ├── controllers/
│   │   ├── authController.js     # User registration & login
│   │   ├── restaurantController.js # Restaurant CRUD
│   │   ├── foodController.js     # Menu management & stock toggling
│   │   ├── orderController.js    # Order placement & status workflow
│   │   └── adminController.js    # System stats & performance reports
│   ├── routes/
│   │   ├── authRoutes.js
│   │   ├── restaurantRoutes.js
│   │   ├── foodRoutes.js
│   │   ├── orderRoutes.js
│   │   └── adminRoutes.js
│   ├── middleware/
│   │   └── authMiddleware.js     # JWT token validation & role access guard
│   ├── seed.js                   # Starter demo data seeder
│   ├── test_api.js               # Automated API test suite
│   ├── server.js                 # Server entry point
│   ├── package.json
│   └── .env
│
└── frontend/
    ├── lib/
    │   ├── config/
    │   │   └── api_constants.dart # Backend URL endpoints
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── restaurant_model.dart
    │   │   ├── food_item_model.dart
    │   │   ├── cart_item_model.dart
    │   │   └── order_model.dart
    │   ├── services/
    │   │   ├── api_service.dart   # Generic HTTP REST client
    │   │   ├── auth_service.dart  # Session & local storage manager
    │   │   └── cart_service.dart  # Cart state manager
    │   ├── widgets/
    │   │   ├── custom_button.dart
    │   │   ├── custom_textfield.dart
    │   │   ├── status_badge.dart
    │   │   └── stat_card.dart
    │   ├── screens/
    │   │   ├── auth/
    │   │   │   ├── login_screen.dart
    │   │   │   └── register_screen.dart
    │   │   ├── customer/
    │   │   │   ├── customer_dashboard_screen.dart
    │   │   │   ├── restaurant_list_screen.dart
    │   │   │   ├── menu_screen.dart
    │   │   │   ├── cart_screen.dart
    │   │   │   ├── order_history_screen.dart
    │   │   │   └── order_details_screen.dart
    │   │   ├── restaurant/
    │   │   │   ├── restaurant_dashboard_screen.dart
    │   │   │   ├── manage_menu_screen.dart
    │   │   │   ├── add_edit_food_screen.dart
    │   │   │   └── incoming_orders_screen.dart
    │   │   └── admin/
    │   │       ├── admin_dashboard_screen.dart
    │   │       ├── view_users_screen.dart
    │   │       ├── all_orders_screen.dart
    │   │       └── reports_screen.dart
    │   └── main.dart              # Role-based route dispatcher
    └── pubspec.yaml
```

---

## 🚀 Step-by-Step Running Guide

### 1. Start MongoDB
Make sure MongoDB is running on your system:
```bash
# macOS (Homebrew)
brew services start mongodb-community
# OR Linux / Windows
mongod
```

### 2. Setup & Run Backend
Open a terminal and navigate to the `backend/` directory:
```bash
cd backend

# 1. Install packages
npm install

# 2. Seed demo starter data (Users, Restaurants, Dishes, Sample Orders)
npm run seed

# 3. Start the Express server
npm start
# (Server runs on http://localhost:5001)
```

To run the automated backend test suite:
```bash
node test_api.js
```

### 3. Setup & Run Frontend (Flutter)
Open a second terminal and navigate to the `frontend/` directory:
```bash
cd frontend

# 1. Install dependencies
flutter pub get

# 2. Run the application
# For Chrome / Web:
flutter run -d chrome

# For macOS Desktop:
flutter run -d macos

# For Android Emulator / iOS Simulator:
flutter run
```

> **Note for Android Emulator:** If testing on Android emulator, open `lib/config/api_constants.dart` and change `baseUrl` from `http://localhost:5001/api` to `http://10.0.2.2:5001/api`.

---

## 🔑 Demo Credentials for College Evaluation / Viva

The app includes **Quick-Fill buttons** on the Login screen for one-click testing:

| Role | Email | Password | What to Demo |
| :--- | :--- | :--- | :--- |
| **👑 Admin** | `admin@foodhub.com` | `admin123` | View total users, restaurants, platform orders, sales reports & status distribution. |
| **👨‍🍳 Restaurant** | `spicegarden@foodhub.com` | `owner123` | Add new dishes, change food prices, toggle in/out of stock, accept & transition orders. |
| **👨‍🍳 Restaurant 2** | `bistro@foodhub.com` | `owner123` | Another restaurant profile with burgers & pizzas. |
| **🙋 Customer** | `rahul@gmail.com` | `customer123` | Browse menus, add items to cart, checkout (COD), track order status in real time. |

---

## 🎓 Viva Questions & Answers Cheat Sheet

**Q1: What architecture does this application follow?**  
> *Answer:* It follows a 3-tier client-server architecture:
> 1. **Presentation Tier:** Flutter mobile/web client.
> 2. **Application Tier:** Node.js + Express.js REST API with modular controllers, routes, and middleware.
> 3. **Data Tier:** MongoDB NoSQL database with Mongoose schemas and relationships.

**Q2: How is role-based access control (RBAC) handled?**  
> *Answer:* On the backend, an `authMiddleware.js` verifies the JWT token and checks the user's role against allowed roles (`authorize('admin', 'restaurant')`). On the frontend, `main.dart` and `login_screen.dart` inspect `user.role` to render the appropriate dashboard.

**Q3: How does the Order Status Workflow operate?**  
> *Answer:* An order begins with the status `Placed` when the customer submits the cart. The restaurant receives the order and can update it sequentially through `Accepted` $\rightarrow$ `Preparing` $\rightarrow$ `Ready` $\rightarrow$ `Delivered`. When marked as `Delivered`, the payment status automatically becomes `Completed`.

**Q4: How is cart state managed without complex external packages?**  
> *Answer:* We use Flutter's built-in `ChangeNotifier` and `ListenableBuilder` pattern via `CartService.instance`. It acts as an in-memory singleton that provides reactive UI updates whenever items or quantities change.
