import 'package:flutter/material.dart';

class UserModel {
  final String name;
  final String email;
  final String imageUrl;
  final String joinDate;

  UserModel({
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.joinDate,
  });
}

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _currentUser != null;

  void login(String email, {String? name}) {
    // Simulate a login by creating a user based on input
    // In a real app, this would come from an API/Auth provider
    String displayName = name ?? email.split('@')[0];
    // Capitalize first letter
    if (displayName.isNotEmpty) {
      displayName = displayName[0].toUpperCase() + displayName.substring(1);
    }

    _currentUser = UserModel(
      name: displayName,
      email: email,
      imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSL40aBfuZrv81ARnlpTHvSusd6_w09ior8DZBxT3656prXUgYZeaJ2so-b1y5KanDVnKiCQU3wOHoQyi5cq8Plo6fbg3CaZt-NjgM3ds-lOFWbueSB5YDN6dCuw0GuCfTdFmVzKUw6B3yJZMllVM-4q__OLOmNM7U3VOxzPXG0LJCeSUIubpUVJRwkKcKkbjYO1YogNP80WyIJAUIWrvjQKtaE2K9B81GKC7nolV_aBYxRZmI7GBpHY0jCDHggUlpolyhTjPbwsk',
      joinDate: 'DineAll Member since ${DateTime.now().year}',
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
