import 'package:flutter/foundation.dart';

class FavoriteService extends ChangeNotifier {
  static final FavoriteService _instance = FavoriteService._internal();

  factory FavoriteService() {
    return _instance;
  }

  FavoriteService._internal();

  // Set of favorited restaurant names
  final Set<String> _favoriteRestaurants = {};

  Set<String> get favorites => _favoriteRestaurants;

  bool isFavorite(String restaurantName) {
    return _favoriteRestaurants.contains(restaurantName);
  }

  void toggleFavorite(String restaurantName) {
    if (_favoriteRestaurants.contains(restaurantName)) {
      _favoriteRestaurants.remove(restaurantName);
    } else {
      _favoriteRestaurants.add(restaurantName);
    }
    notifyListeners();
  }
}
