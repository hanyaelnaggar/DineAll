import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String name;
  final String image;
  final double price;
  int quantity;
  final String restaurantName;
  final String restaurantImage; // Logo/Image of the restaurant
  final String restaurantTag; // e.g. "Gourmet American"
  String specialRequest;

  CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
    required this.restaurantName,
    required this.restaurantImage,
    this.restaurantTag = '',
    this.specialRequest = '',
  });
}

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  // Map<RestaurantName, List<CartItem>>
  final Map<String, List<CartItem>> _cartItems = {};

  // Getters
  Map<String, List<CartItem>> get items => _cartItems;

  int get totalItemCount {
    int count = 0;
    _cartItems.forEach((key, list) {
      for (var item in list) {
        count += item.quantity;
      }
    });
    return count;
  }

  double get totalPrice {
    double total = 0.0;
    _cartItems.forEach((key, list) {
      for (var item in list) {
        total += item.price * item.quantity;
      }
    });
    return total;
  }

  // Helper to get item quantity by name
  int getItemQuantity(String restaurantName, String itemName) {
    if (!_cartItems.containsKey(restaurantName)) return 0;
    
    try {
      final item = _cartItems[restaurantName]!.firstWhere((item) => item.name == itemName);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Helper to decrease quantity by name
  void decrementItemQuantity(String restaurantName, String itemName) {
    if (!_cartItems.containsKey(restaurantName)) return;

    final list = _cartItems[restaurantName]!;
    final index = list.indexWhere((item) => item.name == itemName);

    if (index != -1) {
      updateQuantity(restaurantName, index, -1);
    }
  }

  // Actions
  void addToCart({
    required String restaurantName,
    required String restaurantImage,
    required String restaurantTag,
    required String itemName,
    required String itemImage,
    required double itemPrice,
    String specialRequest = '', // Optional parameter
  }) {
    if (!_cartItems.containsKey(restaurantName)) {
      _cartItems[restaurantName] = [];
    }

    final restaurantList = _cartItems[restaurantName]!;
    
    // Check if item already exists (and matches special request if needed, but for now just name)
    try {
      final existingItem = restaurantList.firstWhere((item) => item.name == itemName);
      existingItem.quantity++;
      // If adding same item, maybe update special request? Or keep old? 
      // For now, let's just update if new one is provided
      if (specialRequest.isNotEmpty) {
          existingItem.specialRequest = specialRequest;
      }
    } catch (e) {
      // Item not found, add new
      restaurantList.add(CartItem(
        id: DateTime.now().toString(), // Simple ID generation
        name: itemName,
        image: itemImage,
        price: itemPrice,
        restaurantName: restaurantName,
        restaurantImage: restaurantImage,
        restaurantTag: restaurantTag,
        specialRequest: specialRequest,
      ));
    }

    notifyListeners();
  }

  void updateSpecialRequest(String restaurantName, int itemIndex, String request) {
    if (_cartItems.containsKey(restaurantName)) {
        _cartItems[restaurantName]![itemIndex].specialRequest = request;
        notifyListeners();
    }
  }

  void removeFromCart(String restaurantName, int itemIndex) {
    if (_cartItems.containsKey(restaurantName)) {
      _cartItems[restaurantName]!.removeAt(itemIndex);
      if (_cartItems[restaurantName]!.isEmpty) {
        _cartItems.remove(restaurantName);
      }
      notifyListeners();
    }
  }

  void updateQuantity(String restaurantName, int itemIndex, int change) {
    if (_cartItems.containsKey(restaurantName)) {
      final item = _cartItems[restaurantName]![itemIndex];
      item.quantity += change;
      
      if (item.quantity <= 0) {
        removeFromCart(restaurantName, itemIndex);
      } else {
        notifyListeners();
      }
    }
  }

  void clearRestaurantCart(String restaurantName) {
    _cartItems.remove(restaurantName);
    notifyListeners();
  }

  void clearAll() {
    _cartItems.clear();
    notifyListeners();
  }
}
