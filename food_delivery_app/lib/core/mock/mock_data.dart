import '../../features/customer/data/models/restaurant_model.dart';
import '../../features/customer/data/models/menu_item_model.dart';

// ─── Credentials ─────────────────────────────────────────────────────────────

// Customer
const String mockEmail = 'hssan@wamia.com';
const String mockPassword = 'tonna123';
const String mockUserName = 'Hssan';
const String mockToken = 'mock-jwt-token-wamia-2024';
const int mockUserId = 1;

// Restaurant
const String mockRestaurantEmail = 'pizza@wamia.com';
const String mockRestaurantPassword = 'pizza123';
const String mockRestaurantName = 'Pizza Palace';
const String mockRestaurantToken = 'mock-jwt-token-wamia-rest-2024';
const int mockRestaurantUserId = 2;

// Driver
const String mockDriverEmail = 'driver@wamia.com';
const String mockDriverPassword = 'driver123';
const String mockDriverName = 'Mehdi';
const String mockDriverToken = 'mock-jwt-token-wamia-driver-2024';
const int mockDriverUserId = 3;

// ─── Restaurants ─────────────────────────────────────────────────────────────

final List<RestaurantModel> mockRestaurants = [
  const RestaurantModel(id: 1, name: 'Burger Bliss', location: 'Downtown, 12 Main St'),
  const RestaurantModel(id: 2, name: 'Pizza Palace', location: 'Uptown, 45 Oak Ave'),
  const RestaurantModel(id: 3, name: 'Sushi World', location: 'Midtown, 8 Harbor Rd'),
  const RestaurantModel(id: 4, name: 'Taco Fiesta', location: 'Westside, 22 Sunset Blvd'),
];

// ─── Menu items per restaurant ────────────────────────────────────────────────

final Map<int, List<MenuItemModel>> mockMenus = {
  1: [
    const MenuItemModel(id: 101, name: 'Classic Cheeseburger', price: 8.99, options: [
      MenuOptionModel(id: 1001, name: 'Extra Cheese', price: 0.99),
      MenuOptionModel(id: 1002, name: 'Bacon', price: 1.49),
    ]),
    const MenuItemModel(id: 102, name: 'Double Smash Burger', price: 11.99, options: [
      MenuOptionModel(id: 1003, name: 'Jalapeños', price: 0.50),
    ]),
    const MenuItemModel(id: 103, name: 'Crispy Chicken Burger', price: 9.99, options: []),
    const MenuItemModel(id: 104, name: 'Loaded Fries', price: 4.99, options: [
      MenuOptionModel(id: 1004, name: 'Cheese Sauce', price: 0.75),
    ]),
    const MenuItemModel(id: 105, name: 'Chocolate Milkshake', price: 5.49, options: []),
    const MenuItemModel(id: 106, name: 'Onion Rings', price: 3.99, options: []),
  ],
  2: [
    const MenuItemModel(id: 201, name: 'Margherita Pizza', price: 12.99, options: [
      MenuOptionModel(id: 2001, name: 'Extra Mozzarella', price: 1.50),
      MenuOptionModel(id: 2002, name: 'Gluten-Free Crust', price: 2.00),
    ]),
    const MenuItemModel(id: 202, name: 'Pepperoni Feast', price: 14.99, options: [
      MenuOptionModel(id: 2003, name: 'Double Pepperoni', price: 1.99),
    ]),
    const MenuItemModel(id: 203, name: 'BBQ Chicken Pizza', price: 15.99, options: []),
    const MenuItemModel(id: 204, name: 'Veggie Supreme', price: 13.49, options: []),
    const MenuItemModel(id: 205, name: 'Garlic Bread', price: 3.99, options: []),
    const MenuItemModel(id: 206, name: 'Caesar Salad', price: 7.49, options: []),
  ],
  3: [
    const MenuItemModel(id: 301, name: 'Salmon Nigiri (8 pcs)', price: 16.99, options: []),
    const MenuItemModel(id: 302, name: 'Dragon Roll', price: 14.99, options: [
      MenuOptionModel(id: 3001, name: 'Spicy Mayo', price: 0.50),
    ]),
    const MenuItemModel(id: 303, name: 'Tuna Sashimi', price: 18.99, options: []),
    const MenuItemModel(id: 304, name: 'Edamame', price: 4.99, options: []),
    const MenuItemModel(id: 305, name: 'Miso Soup', price: 2.99, options: []),
    const MenuItemModel(id: 306, name: 'Tempura Udon', price: 12.49, options: []),
  ],
  4: [
    const MenuItemModel(id: 401, name: 'Street Tacos (3 pcs)', price: 9.99, options: [
      MenuOptionModel(id: 4001, name: 'Extra Salsa', price: 0.50),
      MenuOptionModel(id: 4002, name: 'Guacamole', price: 1.50),
    ]),
    const MenuItemModel(id: 402, name: 'Burrito Bowl', price: 11.99, options: [
      MenuOptionModel(id: 4003, name: 'Extra Rice', price: 0.75),
    ]),
    const MenuItemModel(id: 403, name: 'Loaded Nachos', price: 8.49, options: []),
    const MenuItemModel(id: 404, name: 'Quesadilla', price: 7.99, options: []),
    const MenuItemModel(id: 405, name: 'Churros', price: 4.49, options: []),
    const MenuItemModel(id: 406, name: 'Horchata', price: 3.49, options: []),
  ],
};

// ─── Extra display metadata (ratings, times — used only in UI layer) ──────────

const Map<int, String> mockDeliveryTimes = {
  1: '20–35 min',
  2: '25–40 min',
  3: '30–45 min',
  4: '15–30 min',
};

const Map<int, String> mockRatings = {
  1: '4.8',
  2: '4.6',
  3: '4.9',
  4: '4.7',
};

const Map<int, String> mockCategories = {
  1: 'Burgers',
  2: 'Pizza',
  3: 'Japanese',
  4: 'Mexican',
};

// Note: orders are now owned by MockOrderService (see mock_order_service.dart)
