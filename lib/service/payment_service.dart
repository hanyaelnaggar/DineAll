import 'package:flutter/foundation.dart';

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();

  factory PaymentService() {
    return _instance;
  }

  PaymentService._internal();

  final List<Map<String, String>> _savedCards = [];

  List<Map<String, String>> get savedCards => _savedCards;

  void addCard(String number, String expiry, String type) {
    // Basic validation to avoid duplicates based on last 4 digits
    if (_savedCards.any((card) => card['number']!.endsWith(number.substring(number.length - 4)))) {
      return;
    }

    _savedCards.add({
      'type': type,
      'number': number, // storing masked or full? Let's store masked for display
      'expiry': expiry,
    });
    notifyListeners();
  }
}
