import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

class MenuApi {
  MenuApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  static const String _baseUrl = 'https://integracore.acthosts.com';

  Future<List<MenuItem>> getMenu({
    required TokenManager tokenManager,
    required String orgShortName, // act
    required String locRef,       // inve
    required String rvcRef,       // 1
  }) async {
    final token = await tokenManager.getValidAccessToken();

    final url = Uri.parse('$_baseUrl/menus/$orgShortName:$locRef:$rvcRef');

    final headers = <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Simphony-OrgShortName': orgShortName,
      'Simphony-LocRef': locRef,
      'Simphony-RvcRef': rvcRef,
    };

    // logs (hidden عن UI)
    // ignore: avoid_print
    print('[MenuApi] ➡️ GET $url');
    // ignore: avoid_print
    print('[MenuApi] Headers: $headers');

    final res = await _client.get(url, headers: headers);

    // ignore: avoid_print
    print('[MenuApi] ⬅️ status=${res.statusCode}');
    // ignore: avoid_print
    print('[MenuApi] body=${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('GET menu failed: ${res.statusCode}');
    }

    final jsonBody = (jsonDecode(res.body) as Map).cast<String, dynamic>();
    final items = (jsonBody['menuItems'] as List? ?? const [])
        .map((e) => MenuItem.fromJson((e as Map).cast<String, dynamic>()))
        .toList();

    return items;
  }
}

class MenuItem {
  final int id;
  final String name;
  final num? price;

  MenuItem({required this.id, required this.name, required this.price});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final id = (json['menuItemId'] as num?)?.toInt() ?? 0;

    // name: { "en-US": "Omelette" }
    final nameMap = (json['name'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = (nameMap['en-US'] ?? nameMap.values.firstOrNull ?? 'Unknown').toString();

    // price: definitions[0].prices[0].price
    num? price;
    final defs = (json['definitions'] as List?) ?? const [];
    if (defs.isNotEmpty) {
      final def0 = (defs.first as Map).cast<String, dynamic>();
      final prices = (def0['prices'] as List?) ?? const [];
      if (prices.isNotEmpty) {
        final p0 = (prices.first as Map).cast<String, dynamic>();
        price = p0['price'] as num?;
      }
    }

    return MenuItem(id: id, name: name, price: price);
  }
}

// helper extension عشان name fallback
extension _FirstOrNull on Iterable {
  dynamic get firstOrNull => isEmpty ? null : first;
}
