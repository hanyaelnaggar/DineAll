import 'package:flutter/material.dart';
import 'package:dineall/screen/cart_screen.dart';
import 'package:dineall/service/cart_service.dart';
import 'package:dineall/service/favorite_service.dart';
import '../services/menu_api.dart';
import '../services/auth_api.dart';
import '../services/token_store.dart';
import '../services/token_manager.dart';

class RestaurantMenuScreen extends StatefulWidget {
  final Map<String, dynamic> restaurant;

  const RestaurantMenuScreen({super.key, required this.restaurant});

  @override
  State<RestaurantMenuScreen> createState() => _RestaurantMenuScreenState();
}

class _RestaurantMenuScreenState extends State<RestaurantMenuScreen> {
  int _selectedCategoryIndex = 0;
  List<String> _categories = ['Popular', 'Mains', 'Sides', 'Drinks'];

  // ✅ API objects
  final MenuApi _menuApi = MenuApi();
  final AuthApi _authApi = AuthApi();
  final TokenStore _tokenStore = TokenStore();
  late final TokenManager _tokenManager;

  // ✅ fetched items mapped to same structure as your mock
  List<Map<String, dynamic>>? _apiMenuItems;

  // (Optional) keep for debug / error state
  bool _isLoadingMenu = false;
  String? _menuError;

  // Mock menu items for different restaurants (kept as fallback)
  final Map<String, List<Map<String, dynamic>>> _menuItems = {
    'The Burger House': [
      {
        'name': 'Classic Cheeseburger',
        'description': 'Double beef patty with cheddar, caramelized onions, and our secret sauce',
        'price': 12.99,
        'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800',
        'category': 'Burgers'
      },
      {
        'name': 'Spicy Crispy Chicken',
        'description': 'Crispy buttermilk chicken breast, spicy mayo, pickles, and shredded lettuce',
        'price': 11.50,
        'image': 'https://images.unsplash.com/photo-1615557960916-5f4791effe9d?q=80&w=800',
        'category': 'Burgers'
      },
      {
        'name': 'Bacon Deluxe',
        'description': 'Smoked bacon, BBQ sauce, crispy onion rings, cheddar cheese',
        'price': 14.50,
        'image': 'https://images.unsplash.com/photo-1594212699903-ec8a3eca50f5?q=80&w=800',
        'category': 'Burgers'
      },
      {
        'name': 'Onion Rings',
        'description': 'Crispy battered onion rings with dipping sauce',
        'price': 5.99,
        'image': 'https://images.unsplash.com/photo-1639024471283-03518883512d?q=80&w=800',
        'category': 'Sides'
      },
      {
        'name': 'Cola',
        'description': 'Refreshing cold cola',
        'price': 2.50,
        'image': 'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?q=80&w=800',
        'category': 'Drinks'
      },
      {
        'name': 'Vanilla Milkshake',
        'description': 'Creamy vanilla milkshake topped with whipped cream',
        'price': 4.99,
        'image': 'https://images.unsplash.com/photo-1579954115545-a95591f28bfc?q=80&w=800',
        'category': 'Drinks'
      },
    ],
    'Pizza Piazza': [
      {
        'name': 'Truffle Burrata',
        'description': 'Creamy burrata, truffle oil, wild mushrooms, 650 kcal',
        'price': 22.00,
        'image': 'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=800',
        'category': 'Signature Pizzas'
      },
      {
        'name': 'The Diavola',
        'description': 'Spicy salami, nduja, chili flakes, honey drizzle, 920 kcal',
        'price': 19.50,
        'image': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=800',
        'category': 'Signature Pizzas'
      },
      {
        'name': 'Margherita Classico',
        'description': 'San Marzano tomato sauce, fresh mozzarella, basil, EVOO',
        'price': 15.00,
        'image': 'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?q=80&w=800',
        'category': 'Classic'
      },
      {
        'name': 'Calzone Classico',
        'description': 'Folded pizza stuffed with ricotta, mozzarella, and ham',
        'price': 16.50,
        'image': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=800',
        'category': 'Calzones'
      },
      {
        'name': 'Garlic Knots',
        'description': 'Baked dough knots tossed in garlic butter and parsley',
        'price': 6.00,
        'image': 'https://images.unsplash.com/photo-1573140247632-f84660f67627?q=80&w=800',
        'category': 'Starters'
      },
    ],
    'Sushi Zen Master': [
      {
        'name': 'Dragon Roll',
        'description': 'Eel, cucumber, topped with avocado and tobiko',
        'price': 16.50,
        'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd43fb?q=80&w=800',
        'category': 'Rolls'
      },
      {
        'name': 'Salmon Sashimi',
        'description': '5 pieces of fresh Atlantic salmon',
        'price': 14.00,
        'image': 'https://images.unsplash.com/photo-1534482421-64566f976cfa?q=80&w=800',
        'category': 'Sashimi'
      },
      {
        'name': 'Spicy Tuna Roll',
        'description': 'Tuna mixed with spicy mayo and cucumber',
        'price': 12.00,
        'image': 'https://images.unsplash.com/photo-1617196034438-63563285611f?q=80&w=800',
        'category': 'Rolls'
      },
      {
        'name': 'Salmon Nigiri',
        'description': 'Fresh salmon over pressed vinegared rice',
        'price': 8.00,
        'image': 'https://images.unsplash.com/photo-1611143669185-af224c5e3252?q=80&w=800',
        'category': 'Nigiri'
      },
      {
        'name': 'Japanese Green Tea',
        'description': 'Hot authentic matcha green tea',
        'price': 3.50,
        'image': 'https://images.unsplash.com/photo-1627435601361-ec25f5b1d0e5?q=80&w=800',
        'category': 'Drinks'
      },
    ],
    'Flora & Fauna': [
      {
        'name': 'Quinoa Power Bowl',
        'description': 'Quinoa, avocado, chickpeas, roasted veggies, tahini dressing',
        'price': 13.50,
        'image': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800',
        'category': 'Bowls'
      },
      {
        'name': 'Caesar Salad',
        'description': 'Romaine lettuce, croutons, parmesan cheese, Caesar dressing',
        'price': 11.00,
        'image': 'https://images.unsplash.com/photo-1550304943-4f24f54ddde9?q=80&w=800',
        'category': 'Salads'
      },
      {
        'name': 'Green Detox Smoothie',
        'description': 'Spinach, kale, apple, lemon, ginger',
        'price': 8.50,
        'image': 'https://images.unsplash.com/photo-1610970881699-44a5587cabec?q=80&w=800',
        'category': 'Smoothies'
      },
    ],
    'The Daily Brew': [
      {
        'name': 'Croissant Sandwich',
        'description': 'Butter croissant with ham and swiss cheese',
        'price': 6.50,
        'image': 'https://images.unsplash.com/photo-1550507992-eb63eea0f568?q=80&w=800',
        'category': 'Sandwiches'
      },
      {
        'name': 'Chocolate Muffin',
        'description': 'Rich chocolate muffin with chocolate chips',
        'price': 4.00,
        'image': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?q=80&w=800',
        'category': 'Pastries'
      },
      {
        'name': 'Cappuccino',
        'description': 'Espresso with steamed milk and foam',
        'price': 4.50,
        'image': 'https://images.unsplash.com/photo-1572442388796-11668a67e53d?q=80&w=800',
        'category': 'Coffee'
      },
    ],
    'Velvet Roast Coffee': [
      {
        'name': 'Latte Macchiato',
        'description': 'Steamed milk stained with espresso',
        'price': 4.75,
        'image': 'https://images.unsplash.com/photo-1593443320739-9775819c0374?q=80&w=800',
        'category': 'Hot Coffee'
      },
      {
        'name': 'Nitro Cold Brew',
        'description': 'Cold brew coffee infused with nitrogen for a creamy texture',
        'price': 5.25,
        'image': 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?q=80&w=800',
        'category': 'Cold Brew'
      },
      {
        'name': 'Bagel with Cream Cheese',
        'description': 'Toasted bagel with plain or chive cream cheese',
        'price': 3.99,
        'image': 'https://images.unsplash.com/photo-1585478259539-e6215b190e02?q=80&w=800',
        'category': 'Snacks'
      },
    ],
    'Sweet Cravings': [
      {
        'name': 'Chocolate Lava Cake',
        'description': 'Warm chocolate cake with a molten center, served with vanilla ice cream',
        'price': 8.99,
        'image': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=800',
        'category': 'Cakes'
      },
      {
        'name': 'Strawberry Cheesecake',
        'description': 'New York style cheesecake topped with fresh strawberries',
        'price': 7.50,
        'image': 'https://images.unsplash.com/photo-1533134242443-d4fd215305ad?q=80&w=800',
        'category': 'Cakes'
      },
      {
        'name': 'Gelato Trio',
        'description': 'Three scoops of artisan gelato: Chocolate, Pistachio, and Vanilla',
        'price': 6.00,
        'image': 'https://images.unsplash.com/photo-1557142046-c704a3adf364?q=80&w=800',
        'category': 'Ice Cream'
      },
      {
        'name': 'Iced Caramel Macchiato',
        'description': 'Chilled espresso with milk, vanilla syrup, and caramel drizzle',
        'price': 5.50,
        'image': 'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?q=80&w=800',
        'category': 'Beverages'
      },
    ],
    'Golden Oven Bakery': [
      {
        'name': 'Sourdough Loaf',
        'description': 'Freshly baked artisanal sourdough bread',
        'price': 5.00,
        'image': 'https://images.unsplash.com/photo-1585478259539-e6215b190e02?q=80&w=800',
        'category': 'Bread'
      },
      {
        'name': 'Almond Croissant',
        'description': 'Flaky croissant filled with almond paste and topped with sliced almonds',
        'price': 4.50,
        'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=800',
        'category': 'Pastry'
      },
    ],
    'Taco Fiesta': [
      {
        'name': 'Street Tacos Trio',
        'description': 'Three corn tortillas with carne asada, onions, and cilantro',
        'price': 10.00,
        'image': 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?q=80&w=800',
        'category': 'Tacos'
      },
      {
        'name': 'Burrito Supreme',
        'description': 'Large flour tortilla filled with rice, beans, meat, cheese, and guacamole',
        'price': 12.00,
        'image': 'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?q=80&w=800',
        'category': 'Burritos'
      },
      {
        'name': 'Chips & Salsa',
        'description': 'Freshly fried tortilla chips with house-made salsa',
        'price': 4.00,
        'image': 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?q=80&w=800',
        'category': 'Sides'
      },
    ],
    'Prime Cut Steakhouse': [
      {
        'name': 'Filet Mignon',
        'description': '8oz tender filet mignon served with mashed potatoes',
        'price': 38.00,
        'image': 'https://images.unsplash.com/photo-1558030006-d502f9e31780?q=80&w=800',
        'category': 'Steaks'
      },
      {
        'name': 'Ribeye Steak',
        'description': '12oz ribeye steak grilled to perfection',
        'price': 42.00,
        'image': 'https://images.unsplash.com/photo-1600891964092-4316c288032e?q=80&w=800',
        'category': 'Steaks'
      },
      {
        'name': 'Loaded Baked Potato',
        'description': 'Large potato with butter, sour cream, chives, and bacon',
        'price': 7.00,
        'image': 'https://images.unsplash.com/photo-1518977676601-b53f02ac6d31?q=80&w=800',
        'category': 'Sides'
      },
      {
        'name': 'Red Wine Cabernet',
        'description': 'Glass of premium Cabernet Sauvignon',
        'price': 12.00,
        'image': 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?q=80&w=800',
        'category': 'Drinks'
      },
    ],
    'Pasta Mama': [
      {
        'name': 'Spaghetti Carbonara',
        'description': 'Spaghetti with pancetta, egg, pecorino cheese, and black pepper',
        'price': 16.00,
        'image': 'https://images.unsplash.com/photo-1612874742237-6526221588e3?q=80&w=800',
        'category': 'Pasta'
      },
      {
        'name': 'Fettuccine Alfredo',
        'description': 'Fettuccine pasta tossed in creamy parmesan sauce',
        'price': 15.00,
        'image': 'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?q=80&w=800',
        'category': 'Pasta'
      },
      {
        'name': 'Bruschetta',
        'description': 'Toasted bread topped with fresh tomatoes, basil, and garlic',
        'price': 8.00,
        'image': 'https://images.unsplash.com/photo-1572695157366-5e585ab2b69f?q=80&w=800',
        'category': 'Starters'
      },
      {
        'name': 'Tiramisu',
        'description': 'Classic Italian dessert with coffee-soaked ladyfingers and mascarpone',
        'price': 9.00,
        'image': 'https://images.unsplash.com/photo-1571877227200-a0d98ea607e9?q=80&w=800',
        'category': 'Dessert'
      },
    ],
    'Starbucks': [
      {
        'name': 'Caffe Latte',
        'description': 'Rich, full-bodied espresso in steamed milk, lightly topped with foam.',
        'price': 4.50,
        'image': 'https://images.unsplash.com/photo-1541167760496-1628856ab772?q=80&w=800',
        'category': 'Coffee'
      },
      {
        'name': 'Caramel Macchiato',
        'description': 'Freshly steamed milk with vanilla-flavored syrup marked with espresso and topped with a caramel drizzle.',
        'price': 5.25,
        'image': 'https://images.unsplash.com/photo-1485808191679-5f8c7c8f3120?q=80&w=800',
        'category': 'Coffee'
      },
      {
        'name': 'Croissant',
        'description': 'A buttery, flaky, viennoiserie pastry.',
        'price': 3.50,
        'image': 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?q=80&w=800',
        'category': 'Bakery'
      },
    ],
    'Pizza Hut': [
      {
        'name': 'Pepperoni Lover\'s',
        'description': 'Loaded with pepperoni and mozzarella cheese.',
        'price': 14.99,
        'image': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=800',
        'category': 'Pizzas'
      },
      {
        'name': 'Supreme',
        'description': 'Pepperoni, beef, sausage, mushrooms, peppers and onions.',
        'price': 16.99,
        'image': 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?q=80&w=800',
        'category': 'Pizzas'
      },
      {
        'name': 'Breadsticks',
        'description': 'Crispy on the outside, soft on the inside, seasoned with garlic and parmesan.',
        'price': 6.99,
        'image': 'https://images.unsplash.com/photo-1573140247632-f84660f67627?q=80&w=800',
        'category': 'Sides'
      },
    ],
    'Burger King': [
      {
        'name': 'Whopper',
        'description': 'Flame-grilled beef patty, topped with tomatoes, fresh cut lettuce, mayo, pickles, a swirl of ketchup, and white onions on a soft sesame seed bun.',
        'price': 7.99,
        'image': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=800',
        'category': 'Burgers'
      },
      {
        'name': 'Chicken Fries',
        'description': 'Breaded, crispy chicken perfect for dipping.',
        'price': 4.99,
        'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800',
        'category': 'Chicken'
      },
      {
        'name': 'French Fries',
        'description': 'Classic, crispy and golden brown.',
        'price': 3.29,
        'image': 'https://images.unsplash.com/photo-1630384060421-a431e4c2a14d?q=80&w=800',
        'category': 'Sides'
      },
    ],
    'KFC': [
      {
        'name': 'Original Recipe Chicken',
        'description': 'Hand-breaded chicken with the secret blend of 11 herbs and spices.',
        'price': 12.99,
        'image': 'https://images.unsplash.com/photo-1626082927389-6cd097cdc6ec?q=80&w=800',
        'category': 'Chicken'
      },
      {
        'name': 'Zinger Burger',
        'description': 'Spicy, crispy chicken breast with lettuce and mayo in a sesame bun.',
        'price': 6.99,
        'image': 'https://images.unsplash.com/photo-1615557960916-5f4791effe9d?q=80&w=800',
        'category': 'Burgers'
      },
      {
        'name': 'Mashed Potatoes',
        'description': 'Creamy mashed potatoes with signature gravy.',
        'price': 3.99,
        'image': 'https://images.unsplash.com/photo-1618449840665-9ed506d73a34?q=80&w=800',
        'category': 'Sides'
      },
    ],
    'Subway': [
      {
        'name': 'Italian B.M.T.',
        'description': 'Genoa salami, spicy pepperoni, and Black Forest Ham.',
        'price': 8.99,
        'image': 'https://images.unsplash.com/photo-1621800043295-a73fe2f76e2c?q=80&w=800',
        'category': 'Sandwiches'
      },
      {
        'name': 'Tuna Sub',
        'description': 'Classic tuna mixed with mayo and your choice of fresh veggies.',
        'price': 7.99,
        'image': 'https://images.unsplash.com/photo-1553909489-cd47e3321179?q=80&w=800',
        'category': 'Sandwiches'
      },
      {
        'name': 'Chocolate Chip Cookie',
        'description': 'Soft, chewy, and loaded with chocolate chips.',
        'price': 1.50,
        'image': 'https://images.unsplash.com/photo-1499636138143-bd630f5cf386?q=80&w=800',
        'category': 'Sides'
      },
    ],
  };

  @override
  void initState() {
    super.initState();

    // Update categories based on restaurant type
    final title = widget.restaurant['title'].toString();

    if (title.contains('Pizza') || title.contains('Hut')) {
      _categories = ['Popular', 'Signature Pizzas', 'Classic', 'Calzones', 'Starters', 'Pizzas', 'Sides'];
    } else if (title.contains('Burger') || title.contains('King')) {
      _categories = ['Popular', 'Burgers', 'Sides', 'Drinks', 'Chicken'];
    } else if (title.contains('Sushi')) {
      _categories = ['Popular', 'Rolls', 'Sashimi', 'Nigiri', 'Drinks'];
    } else if (title.contains('Flora') || title.contains('Salad')) {
      _categories = ['Popular', 'Bowls', 'Salads', 'Smoothies'];
    } else if (title.contains('Brew') || title.contains('Starbucks')) {
      _categories = ['Popular', 'Sandwiches', 'Pastries', 'Coffee', 'Bakery'];
    } else if (title.contains('Golden Oven') || title.contains('Bakery')) {
      _categories = ['Popular', 'Bread', 'Pastry'];
    } else if (title.contains('Roast') || title.contains('Coffee')) {
      _categories = ['Popular', 'Hot Coffee', 'Cold Brew', 'Snacks'];
    } else if (title.contains('Sweet') || title.contains('Cravings')) {
      _categories = ['Popular', 'Cakes', 'Ice Cream', 'Beverages'];
    } else if (title.contains('Taco') || title.contains('Fiesta')) {
      _categories = ['Popular', 'Tacos', 'Burritos', 'Sides'];
    } else if (title.contains('Prime') || title.contains('Steak')) {
      _categories = ['Popular', 'Steaks', 'Sides', 'Wines'];
    } else if (title.contains('Pasta')) {
      _categories = ['Popular', 'Pasta', 'Antipasti', 'Desserts'];
    } else if (title.contains('KFC')) {
      _categories = ['Popular', 'Chicken', 'Burgers', 'Sides'];
    } else if (title.contains('Subway')) {
      _categories = ['Popular', 'Sandwiches', 'Sides'];
    }

    // ✅ TokenManager + fetch menu from API
    _tokenManager = TokenManager(
      authApi: _authApi,
      tokenStore: _tokenStore,
      renewBefore: const Duration(minutes: 5),
      persistCredentials: true,
    );

    _fetchMenu();
  }

  Future<void> _fetchMenu() async {
    setState(() {
      _isLoadingMenu = true;
      _menuError = null;
    });

    try {
      // ✅ same values as Postman example
      final items = await _menuApi.getMenu(
        tokenManager: _tokenManager,
        orgShortName: 'act',
        locRef: 'inve',
        rvcRef: '1',
      );

      final mapped = items.map((it) {
        final price = (it.price ?? 0).toDouble();

        return <String, dynamic>{
          'name': it.name,
          'description': ' ', // API doesn't provide description (keep UI same)
          'price': price,
          'image': widget.restaurant['image'], // fallback image
          'category': 'Popular', // so items show under Popular (and Popular shows all anyway)
        };
      }).toList();

      setState(() {
        _apiMenuItems = mapped;
        _isLoadingMenu = false;
      });
    } catch (e) {
      // ignore: avoid_print
      print('❌ GET MENU ERROR: $e');
      setState(() {
        _menuError = e.toString();
        _isLoadingMenu = false;
        _apiMenuItems = null; // fallback to mock
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF8A0000);
    const darkBrown = Color(0xFF3E2723);

    // ✅ Use API items if available, otherwise fallback to mock
    final allItems = (_apiMenuItems != null && _apiMenuItems!.isNotEmpty)
        ? _apiMenuItems!
        : (_menuItems[widget.restaurant['title']] ?? _menuItems['The Burger House']!);

    final selectedCategory = _categories[_selectedCategoryIndex];

    final currentItems = selectedCategory == 'Popular'
        ? allItems
        : allItems.where((item) => item['category'] == selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F5),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Header
              SliverAppBar(
                expandedHeight: 250,
                pinned: true,
                backgroundColor: Colors.transparent,
                leading: Container(
                  margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedBuilder(
                      animation: FavoriteService(),
                      builder: (context, child) {
                        final isFav = FavoriteService().isFavorite(widget.restaurant['title']);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : Colors.white,
                          ),
                          onPressed: () {
                            FavoriteService().toggleFavorite(widget.restaurant['title']);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFav ? 'Removed from favorites' : 'Added to favorites'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: const Color(0xFF8A0000),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        widget.restaurant['image'],
                        fit: BoxFit.cover,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.3),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                      // Restaurant Info Overlay
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (widget.restaurant['title'].toString().contains('Pizza'))
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AUTHENTIC NEAPOLITAN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),
                            Text(
                              widget.restaurant['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.restaurant['rating']} (500+)',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                const Icon(Icons.access_time, color: Colors.white70, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  widget.restaurant['time'],
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'More Info',
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.greenAccent, size: 16),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Categories Header
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverCategoryDelegate(
                  categories: _categories,
                  selectedIndex: _selectedCategoryIndex,
                  onCategorySelected: (index) {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                ),
              ),

              // Menu Items List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _categories[_selectedCategoryIndex],
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: darkBrown,
                                ),
                              ),
                              // ✅ optional tiny indicator (doesn't change design structure)
                              if (_isLoadingMenu)
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                        );
                      }

                      // If API failed and user wants to know, we keep it silent in UI (design unchanged)
                      // ignore: unused_local_variable
                      final err = _menuError;

                      final item = currentItems[index - 1];
                      return _buildMenuItem(item);
                    },
                    childCount: currentItems.length + 1,
                  ),
                ),
              ),
            ],
          ),

          // Bottom Cart Bar
          AnimatedBuilder(
            animation: CartService(),
            builder: (context, child) {
              final cart = CartService();

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutBack,
                bottom: cart.totalItemCount > 0 ? 24 : -100,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${cart.totalItemCount} items',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: const [
                            Text(
                              'VIEW CART',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    const primary = Color(0xFF8A0000);
    const darkBrown = Color(0xFF3E2723);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['description'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${(item['price'] as num).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                      ),
                    ),
                    const Spacer(),
                    AnimatedBuilder(
                      animation: CartService(),
                      builder: (context, child) {
                        final quantity = CartService().getItemQuantity(
                          widget.restaurant['title'],
                          item['name'],
                        );

                        if (quantity > 0) {
                          return Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: primary.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    CartService().decrementItemQuantity(
                                      widget.restaurant['title'],
                                      item['name'],
                                    );
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(18),
                                    bottomLeft: Radius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.remove, color: primary, size: 20),
                                  ),
                                ),
                                Text(
                                  '$quantity',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: darkBrown,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    String tag = '';
                                    if (widget.restaurant['tags'] != null &&
                                        (widget.restaurant['tags'] as List).isNotEmpty) {
                                      tag = (widget.restaurant['tags'] as List)[0];
                                    } else {
                                      tag = 'General';
                                    }

                                    CartService().addToCart(
                                      restaurantName: widget.restaurant['title'],
                                      restaurantImage: widget.restaurant['image'],
                                      restaurantTag: tag,
                                      itemName: item['name'],
                                      itemImage: item['image'],
                                      itemPrice: (item['price'] as num).toDouble(),
                                    );
                                  },
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(18),
                                    bottomRight: Radius.circular(18),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: Icon(Icons.add, color: primary, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return InkWell(
                          onTap: () {
                            String tag = '';
                            if (widget.restaurant['tags'] != null &&
                                (widget.restaurant['tags'] as List).isNotEmpty) {
                              tag = (widget.restaurant['tags'] as List)[0];
                            } else {
                              tag = 'General';
                            }

                            CartService().addToCart(
                              restaurantName: widget.restaurant['title'],
                              restaurantImage: widget.restaurant['image'],
                              restaurantTag: tag,
                              itemName: item['name'],
                              itemImage: item['image'],
                              itemPrice: (item['price'] as num).toDouble(),
                            );
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item['image'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 100,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverCategoryDelegate extends SliverPersistentHeaderDelegate {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  _SliverCategoryDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    const primary = Color(0xFF8A0000);

    return Container(
      color: const Color(0xFFF8F5F5),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onCategorySelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(_SliverCategoryDelegate oldDelegate) {
    return selectedIndex != oldDelegate.selectedIndex || categories != oldDelegate.categories;
  }
}
