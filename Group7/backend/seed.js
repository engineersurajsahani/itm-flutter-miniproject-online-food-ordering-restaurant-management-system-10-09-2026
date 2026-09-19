const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const Restaurant = require('./models/Restaurant');
const FoodItem = require('./models/FoodItem');
const Order = require('./models/Order');

dotenv.config();

const seedData = async () => {
  try {
    const mongoUri = process.env.MONGO_URI || 'mongodb://127.0.0.1:27017/food_ordering_db';
    await mongoose.connect(mongoUri);
    console.log('🌱 Connected to MongoDB for seeding...');

    // Clear existing collections
    await User.deleteMany({});
    await Restaurant.deleteMany({});
    await FoodItem.deleteMany({});
    await Order.deleteMany({});
    console.log('🧹 Cleared existing database records.');

    // 1. Create Users
    console.log('👤 Creating users...');
    const admin = await User.create({
      name: 'System Admin',
      email: 'admin@foodhub.com',
      password: 'admin123',
      role: 'admin',
      phone: '+91 9876543210',
      address: 'Admin Headquarters, Tech Park'
    });

    const restaurantOwner1 = await User.create({
      name: 'Chef Sanjeev (Owner)',
      email: 'spicegarden@foodhub.com',
      password: 'owner123',
      role: 'restaurant',
      phone: '+91 9876543211',
      address: 'Shop 12, Food Street, City Centre'
    });

    const restaurantOwner2 = await User.create({
      name: 'Mario Rossi (Owner)',
      email: 'bistro@foodhub.com',
      password: 'owner123',
      role: 'restaurant',
      phone: '+91 9876543212',
      address: 'Plot 45, High Street, Downtown'
    });

    const customer1 = await User.create({
      name: 'Rahul Sharma',
      email: 'rahul@gmail.com',
      password: 'customer123',
      role: 'customer',
      phone: '+91 9876543213',
      address: 'Flat 302, Green Valley Apartments, City Centre'
    });

    const customer2 = await User.create({
      name: 'Priya Patel',
      email: 'priya@gmail.com',
      password: 'customer123',
      role: 'customer',
      phone: '+91 9876543214',
      address: 'House 14, Royal Palm Residency, Downtown'
    });

    // 2. Create Restaurants
    console.log('🏪 Creating restaurants...');
    const restaurant1 = await Restaurant.create({
      name: 'Spice Garden Indian Cuisine',
      description: 'Authentic North & South Indian dishes, curries, and tandoor delicacies.',
      cuisineType: 'North Indian, Mughlai',
      address: 'Shop 12, Food Street, City Centre',
      phone: '+91 9876543211',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=600&auto=format&fit=crop&q=60',
      isOpen: true,
      ownerId: restaurantOwner1._id
    });

    const restaurant2 = await Restaurant.create({
      name: 'The Bistro & Burger Joint',
      description: 'Artisanal burgers, wood-fired pizzas, cheesy appetizers, and beverages.',
      cuisineType: 'Fast Food, Italian, Cafe',
      address: 'Plot 45, High Street, Downtown',
      phone: '+91 9876543212',
      imageUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=600&auto=format&fit=crop&q=60',
      isOpen: true,
      ownerId: restaurantOwner2._id
    });

    // Link restaurantId to respective owners
    restaurantOwner1.restaurantId = restaurant1._id;
    await restaurantOwner1.save();

    restaurantOwner2.restaurantId = restaurant2._id;
    await restaurantOwner2.save();

    // 3. Create Food / Menu Items
    console.log('🍔 Creating food items...');
    const foodItemsData = [
      // Restaurant 1: Spice Garden
      {
        restaurantId: restaurant1._id,
        name: 'Paneer Butter Masala',
        description: 'Rich and creamy cottage cheese curry in tomato and butter gravy.',
        price: 260,
        category: 'Main Course',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant1._id,
        name: 'Butter Garlic Naan',
        description: 'Crisp Indian flatbread infused with fresh garlic and melted butter.',
        price: 45,
        category: 'Breads',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant1._id,
        name: 'Chicken Dum Biryani',
        description: 'Slow-cooked fragrant basmati rice with tender spiced chicken pieces.',
        price: 320,
        category: 'Main Course',
        isVeg: false,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant1._id,
        name: 'Crispy Veg Spring Rolls',
        description: 'Golden fried rolls filled with fresh shredded vegetables and herbs.',
        price: 180,
        category: 'Starters',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1544025162-d76694265947?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant1._id,
        name: 'Gulab Jamun (2 pcs)',
        description: 'Warm soft milk dumplings soaked in rose flavored sugar syrup.',
        price: 90,
        category: 'Desserts',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1541781774459-bb2af2f05b55?w=500&auto=format&fit=crop&q=60'
      },

      // Restaurant 2: The Bistro & Burger Joint
      {
        restaurantId: restaurant2._id,
        name: 'Classic Cheese Burger',
        description: 'Juicy grilled patty with cheddar cheese, lettuce, pickles, and chef secret sauce.',
        price: 210,
        category: 'Burgers',
        isVeg: false,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant2._id,
        name: 'Margherita Wood-Fired Pizza',
        description: 'Hand-stretched crust topped with fresh mozzarella, basil, and San Marzano tomato sauce.',
        price: 350,
        category: 'Pizzas',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1604382355076-af4b0eb60143?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant2._id,
        name: 'Peri Peri French Fries',
        description: 'Crispy golden potato fries tossed in tangy & spicy peri peri seasoning.',
        price: 130,
        category: 'Starters',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&auto=format&fit=crop&q=60'
      },
      {
        restaurantId: restaurant2._id,
        name: 'Cold Coffee with Ice Cream',
        description: 'Chilled blended brewed coffee topped with a rich scoop of vanilla ice cream.',
        price: 140,
        category: 'Beverages',
        isVeg: true,
        isAvailable: true,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?w=500&auto=format&fit=crop&q=60'
      }
    ];

    const insertedFoodItems = await FoodItem.insertMany(foodItemsData);

    // 4. Create Sample Orders
    console.log('📦 Creating sample orders...');
    const order1 = await Order.create({
      customerId: customer1._id,
      restaurantId: restaurant1._id,
      items: [
        {
          foodItemId: insertedFoodItems[0]._id,
          name: insertedFoodItems[0].name,
          price: insertedFoodItems[0].price,
          quantity: 2
        },
        {
          foodItemId: insertedFoodItems[1]._id,
          name: insertedFoodItems[1].name,
          price: insertedFoodItems[1].price,
          quantity: 4
        }
      ],
      totalAmount: 260 * 2 + 45 * 4, // 520 + 180 = 700
      deliveryAddress: customer1.address,
      paymentType: 'Cash On Delivery',
      paymentStatus: 'Pending',
      orderStatus: 'Preparing'
    });

    const order2 = await Order.create({
      customerId: customer2._id,
      restaurantId: restaurant2._id,
      items: [
        {
          foodItemId: insertedFoodItems[5]._id,
          name: insertedFoodItems[5].name,
          price: insertedFoodItems[5].price,
          quantity: 1
        },
        {
          foodItemId: insertedFoodItems[7]._id,
          name: insertedFoodItems[7].name,
          price: insertedFoodItems[7].price,
          quantity: 1
        }
      ],
      totalAmount: 210 + 130, // 340
      deliveryAddress: customer2.address,
      paymentType: 'Cash On Delivery',
      paymentStatus: 'Completed',
      orderStatus: 'Delivered'
    });

    const order3 = await Order.create({
      customerId: customer1._id,
      restaurantId: restaurant2._id,
      items: [
        {
          foodItemId: insertedFoodItems[6]._id,
          name: insertedFoodItems[6].name,
          price: insertedFoodItems[6].price,
          quantity: 1
        }
      ],
      totalAmount: 350,
      deliveryAddress: customer1.address,
      paymentType: 'Cash On Delivery',
      paymentStatus: 'Pending',
      orderStatus: 'Placed'
    });

    console.log('\n=============================================');
    console.log('🎉 SEEDING COMPLETED SUCCESSFULLY!');
    console.log('=============================================');
    console.log('Demo Credentials for Viva / Testing:');
    console.log('👑 Admin:      admin@foodhub.com / admin123');
    console.log('👨‍🍳 Restaurant: spicegarden@foodhub.com / owner123');
    console.log('👨‍🍳 Restaurant: bistro@foodhub.com / owner123');
    console.log('🙋 Customer:   rahul@gmail.com / customer123');
    console.log('🙋 Customer:   priya@gmail.com / customer123');
    console.log('=============================================\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
};

seedData();
