import 'package:flutter/material.dart';
import 'cart_screen.dart';
import 'chatbot_screen.dart';
import 'package:dineall/screen/profile_screen.dart';
import 'package:dineall/screen/restaurant_menu_screen.dart';
import 'package:dineall/service/cart_service.dart';

// Data Model for Restaurant
class Restaurant {
  final String image;
  final double rating;
  final String title;
  final String deliveryCost;
  final Color deliveryColor;
  final String time;
  final String distance;
  final List<String> tags;
  final double priceValue; // For sorting
  final int popularityScore; // For sorting

  Restaurant({
    required this.image,
    required this.rating,
    required this.title,
    required this.deliveryCost,
    required this.deliveryColor,
    required this.time,
    required this.distance,
    required this.tags,
    required this.priceValue,
    required this.popularityScore,
  });
}

class FoodScreen extends StatefulWidget {
  final int? initialCategoryIndex;
  final int initialTabIndex;

  const FoodScreen({
    super.key, 
    this.initialCategoryIndex,
    this.initialTabIndex = 0,
  });

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  late int _selectedCategoryIndex;
  late int _selectedIndex; // Bottom nav index
  String _selectedSortOption = 'Popular';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryIndex = widget.initialCategoryIndex ?? 0;
    _selectedIndex = widget.initialTabIndex;
  }




  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Categories Data
  final List<Map<String, dynamic>> _categories = [
    {'name': 'View All', 'icon': Icons.grid_view},
    {'name': 'Coffee', 'icon': Icons.local_cafe},
    {'name': 'Pizza', 'icon': Icons.local_pizza},
    {'name': 'Burgers', 'icon': Icons.lunch_dining},
    {'name': 'Sushi', 'icon': Icons.set_meal},
    {'name': 'Dessert', 'icon': Icons.icecream},
    {'name': 'Bakery', 'icon': Icons.bakery_dining},
    {'name': 'Tacos', 'icon': Icons.local_dining},
    {'name': 'Salad', 'icon': Icons.restaurant},
    {'name': 'Steak', 'icon': Icons.kebab_dining},
    {'name': 'Pasta', 'icon': Icons.dinner_dining},
  ];

  // Mock Data for Restaurants
  final List<Restaurant> _allRestaurants = [
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAc1TFc8X1K_NLlrsJ968F2oha3jz7J7xUvJ5Yukuc9UNeKI7gtas77waMzzKY2PkDsYNJbyf9pGWlTI1n0-fldKEBPaYqKN_2SqmXQNf5fRiWFNlKV_enZe4IY1H-hDYKZbMFZuUARlsroVxP0TmCIqXN3NviINEwlnbnDNtavSCld_zVLpS2lZRNwXL1IMjXAEw77kMQ3b0kOHNaL3bI71HdIxzgyeJCVG5qqEvRG6jSsJSMA1oa58GqobW3GvOZX59kg0gHsmvQ',
      rating: 4.8,
      title: 'The Burger House',
      deliveryCost: '\$2.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '20-30 min',
      distance: '1.2 km',
      tags: ['Burgers', 'BBQ', 'Premium'],
      priceValue: 2,
      popularityScore: 95,
    ),
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDxtNBwDrkGIdLkW7zMEp1RaTy9otDzPnXUQMTyD0_2Wo1aQz90eTRF5GfqaXBV18pRjR9AlWCGNHYAWM8z5PJo6y7fx_DJjnLprhs6aM6b7_KmnOwYiNC-1deG9VepPCaUwHuw9zqLKsYfBWwdret0GjY7pzSWgVxCE_2VRpMLx58-kRBo3dKZrxnGyqABvWg1vzjtX8_dU6KLQZzbkAi1zFjcAp8H-KWz-hktmswrdcu6KDXKAEbowd9RJ3upXVMVk_EF8zLIPMY',
      rating: 4.5,
      title: 'Sushi Zen Master',
      deliveryCost: 'Free delivery',
      deliveryColor: Colors.green,
      time: '15-25 min',
      distance: '0.8 km',
      tags: ['Sushi', 'Japanese', 'Healthy'],
      priceValue: 3,
      popularityScore: 88,
    ),
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDgathoaIRkdZjdRUa0OYMxCTbZfV0r22uI_Tf2pUCD7mDXnL78_wCXgoDzx4kzmRaJSe4HJ_B6aKVMaatOJajabZWWxx7pnLX1jKy5gNTTsU5MvHWGYRuXTlm9Peejg8giHYQtJ_H2aV6cng_HT5KWQuHbycDRFj7cE7qIjK9xf4DQYG1WHlIFVHA2Yon1uIb9eRkpw6R7gQxEYXF5N4MdhIAIwRrVvCnSVRUHJBAkdqeVjJbbATlC_HPjyocrFWmUm108xxXLV-A',
      rating: 4.2,
      title: 'Pizza Piazza',
      deliveryCost: '\$1.50 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '25-40 min',
      distance: '2.5 km',
      tags: ['Pizza', 'Italian', 'Fast Food'],
      priceValue: 1,
      popularityScore: 92,
    ),
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCFpVVFAaroSFRuTZPdgz1lPViSW5bl8HigqmTR4Cn8nw8iT9Sb7jKedUjINZDWjmWJWXcXiLPhdxv7v-h8XdNTIpHCBbr6zZgHkL7ku-OltAENSTAiwfUT7Ie1-a4xC-siR5kYFVP8bLFNt8zJUyTNJ8proFbkdddyGVIxfhqURDTd-OaWhP5VTxH1vuire_5-W3OYPrTvhmvMUImoC_imlSpsqfnrVLH-CdP3Q7SFC0SgBroQkfzszez1OHeSmpTo--SPT27uYX4',
      rating: 4.9,
      title: 'Flora & Fauna',
      deliveryCost: '\$3.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '15-25 min',
      distance: '0.5 km',
      tags: ['Salad', 'Healthy', 'Vegan'],
      priceValue: 2,
      popularityScore: 80,
    ),
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAr38oLyEyzG5-zOkjhHcPoqqhahHDkrYIXGYXyNeTc4Y-JrbqA5JiIAQuSxTpejt-59IDEdv1k6hCkM49ftPivSYrc5pN59JJPVPKwGBLErK9r8Qzc6b7zlqsPGKSgaizk-uiXR_7OyIpLwtyffhuF0NLXVSezWwitD-NhoNbC7ImKyHG1ubl65I64L_iqKG_mZeWd6F96MhOHdoQ60sTGtY3Yl9zGeLqfEZzzvrV9GEKOiKq8PJukHZAuAS9M-TEeoLMne_EEv4E',
      rating: 4.7,
      title: 'The Daily Brew',
      deliveryCost: '\$0.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '10-15 min',
      distance: '0.3 km',
      tags: ['Coffee', 'Bakery', 'Breakfast'],
      priceValue: 1,
      popularityScore: 85,
    ),
    Restaurant(
      image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBOAYCSfJMf5J-tpRJZbJO2V_mP4orzz-mM-scbuN6gcwnmitIuqk0Iy2STsgJkL8rxFq2GGMcpytt4pmI8qDmZvhjyH3x0BEPLHSukfgnX_Hw1p9MWfNgbpEVtfMUpvnqxMqlzCv2eG8KHXZLG-TYSN6oEu2DaoXi83rck35qK3pVWm02C-5cZtpkTzbPh92Yky4nJsOxJgSuRVNa4HlcnMyygUTe4CgMlyWptj_eel3Jpbu7U65wUAf_ziq1Wv1dZfd83GFBhu-8',
      rating: 4.6,
      title: 'Velvet Roast Coffee',
      deliveryCost: 'Free delivery',
      deliveryColor: Colors.green,
      time: '15-20 min',
      distance: '1.0 km',
      tags: ['Coffee', 'Beverages'],
      priceValue: 2,
      popularityScore: 90,
    ),
    Restaurant(
      image: 'https://images.unsplash.com/photo-1563729784474-d77dbb933a9e?q=80&w=800',
      rating: 4.8,
      title: 'Sweet Cravings',
      deliveryCost: '\$1.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '20-30 min',
      distance: '1.5 km',
      tags: ['Dessert', 'Ice Cream', 'Sweets'],
      priceValue: 2,
      popularityScore: 89,
    ),
    Restaurant(
      image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?q=80&w=800',
      rating: 4.7,
      title: 'Golden Oven Bakery',
      deliveryCost: '\$0.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '10-20 min',
      distance: '0.6 km',
      tags: ['Bakery', 'Pastry', 'Bread'],
      priceValue: 1,
      popularityScore: 82,
    ),
    Restaurant(
      image: 'https://images.unsplash.com/photo-1551504734-5ee1c4a1479b?q=80&w=800',
      rating: 4.5,
      title: 'Taco Fiesta',
      deliveryCost: '\$2.49 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '25-35 min',
      distance: '2.0 km',
      tags: ['Tacos', 'Mexican', 'Spicy'],
      priceValue: 2,
      popularityScore: 91,
    ),
    Restaurant(
      image: 'https://images.unsplash.com/photo-1600891964092-4316c288032e?q=80&w=800',
      rating: 4.9,
      title: 'Prime Cut Steakhouse',
      deliveryCost: '\$5.99 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '40-50 min',
      distance: '3.5 km',
      tags: ['Steak', 'Grill', 'Premium'],
      priceValue: 4,
      popularityScore: 94,
    ),
    Restaurant(
      image: 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?q=80&w=800',
      rating: 4.6,
      title: 'Pasta Mama',
      deliveryCost: '\$3.49 delivery',
      deliveryColor: const Color(0xFF8A0000),
      time: '30-40 min',
      distance: '2.8 km',
      tags: ['Pasta', 'Italian', 'Comfort Food'],
      priceValue: 2,
      popularityScore: 87,
    ),
  ];

  List<Restaurant> _getFilteredRestaurants() {
    List<Restaurant> filtered = List.from(_allRestaurants);

    // Filter by Search Text
    if (_searchController.text.isNotEmpty) {
      String searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((r) {
        return r.title.toLowerCase().contains(searchTerm) ||
               r.tags.any((tag) => tag.toLowerCase().contains(searchTerm));
      }).toList();
    }

    // Filter by Category
    if (_selectedCategoryIndex != -1 && _selectedCategoryIndex < _categories.length) {
      String selectedCategory = _categories[_selectedCategoryIndex]['name'];
      if (selectedCategory != 'View All') {
        filtered = filtered.where((r) => r.tags.contains(selectedCategory)).toList();
      }
    }

    // Sort
    switch (_selectedSortOption) {
      case 'Popular':
        filtered.sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
        break;
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'Price: Low to High':
        filtered.sort((a, b) => a.priceValue.compareTo(b.priceValue));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.priceValue.compareTo(a.priceValue));
        break;
    }

    return filtered;
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF8A0000);
    const darkBrown = Color(0xFF3E2723);
    const backgroundLight = Color(0xFFF8F5F5);

    Widget content;
    if (_selectedIndex == 0) {
      content = _buildHomeContent(primary, darkBrown, backgroundLight);
    } else if (_selectedIndex == 1) {
      content = _buildDiscoverContent(primary, darkBrown);
    } else if (_selectedIndex == 3) {
      content = _buildProfileContent(primary, darkBrown);
    } else {
      content = _buildHomeContent(primary, darkBrown, backgroundLight);
    }

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: _selectedIndex == 3 ? null : AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8A0000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'DineAll',
          style: TextStyle(
            color: Color(0xFF8A0000),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: Stack(
        children: [
          content,

          // Floating Filter Button (Only on Home and Discover)
          if (_selectedIndex == 0 || _selectedIndex == 1)
          Positioned(
            bottom: 100, // Above the bottom nav
            right: 24,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                onTap: _showFilterOptions,
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(Icons.tune, color: Color(0xFF6B0000), size: 24),
                ),
              ),
            ),
          ),

          // Floating Chatbot Button (Only on Home and Discover)
          if (_selectedIndex == 0 || _selectedIndex == 1)
          Positioned(
            bottom: 170, // Above the filter button
            right: 24,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 6,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                  );
                },
                customBorder: const CircleBorder(),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Icon(
                    Icons.smart_toy,
                    color: Color(0xFF6B0000),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),

          // Floating Bottom Navigation (Replaces standard bottom nav)
          Positioned(
            bottom: 24, // bottom-6
            left: 24, // left-6
            right: 24, // right-6
            child: AnimatedBuilder(
              animation: CartService(),
              builder: (context, child) {
                final cartCount = CartService().totalItemCount;
                return Container(
                  height: 64, // h-16
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9), // glass-nav
                    borderRadius: BorderRadius.circular(999), // rounded-full
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), // shadow-xl (approx)
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildBottomNavItem(Icons.home, 'Home', 0),
                      _buildBottomNavItem(Icons.restaurant, 'Restaurants', 1),
                      _buildBottomNavItem(Icons.shopping_cart, 'Cart', 2, badge: cartCount > 0 ? '$cartCount' : null),
                      _buildBottomNavItem(Icons.account_circle, 'Profile', 3),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(Color primary, Color darkBrown, Color backgroundLight) {
    return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: // Search Bar (Full Width, No Filter Button)
                  TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    style: TextStyle(color: darkBrown),
                    cursorColor: primary,
                    decoration: InputDecoration(
                      hintText: 'Search brands, dishes, or cuisines...',
                      hintStyle: TextStyle(
                        color: darkBrown.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      prefixIcon: Icon(Icons.search, color: primary, size: 20),
                      filled: true,
                      fillColor: backgroundLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: darkBrown.withValues(alpha: 0.05)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: darkBrown.withValues(alpha: 0.05)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  // Categories Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categories',
                          style: TextStyle(
                            color: darkBrown,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showAllCategories,
                          child: Row(
                            children: [
                              Text(
                                'View all',
                                style: TextStyle(
                                  color: primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward, color: primary, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Categories Horizontal Scroll
                  Container(
                    color: backgroundLight,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: List.generate(_categories.length, (index) {
                          final category = _categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: _buildCategoryItem(category['name'], category['icon'], index),
                          );
                        }),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.black12),

                  // Popular Brands Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Popular Brands',
                            style: TextStyle(
                              color: darkBrown,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              _buildBrandItem('Starbucks', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDI2OgONgIE2CjVZuVABlBpRa_mslG4FBK3q1Gmt8Fd8KEn-HLW1UBtC6Q-lAJnv3b5nsIQofADHyHOaAzMPjsRge3GyIJlB2GC_iRiTlVmQ5oc7Fy_yysw8mQ_gkiSqY7ZSuMIWexMP1in6tmzVb1YMTYBw8XCaYcX7tFdZ_JwpdOVo5bryVgJS03q7aijuEvx7OHLivLbSlKwbMPmvy1F-474Fa_asv6qKyC6cJPT_gqiJcFuXllX8YJzs8gblstImTkLkclvMKI'),
                              const SizedBox(width: 16),
                              _buildBrandItem('Pizza Hut', 'https://lh3.googleusercontent.com/aida-public/AB6AXuDnTbrJU5__-mgABQzoASm_eYepK2zDg_1hu7ODg-Hz4H2mrMkvCz_7JGmLhoduke1vPovLK-FOslDt52y-U8i1Mxmo3SkmsYjR9DHGC5bfFFXl2nhpGyP7d5qNpN28AGvm4w34ao5aYaj9ff3FvFqS08UfUAAOAt8lJ-ytsRBJDUe8aCD4r4vBfaxorLaB9gfASxY1itXHMp68JiVwGuP263vxttQAv5nJUSwf7FD254HhHW2gcs5m69jUosoxRACWMxnSilIHy4Q'),
                              const SizedBox(width: 16),
                              _buildBrandItem('Burger King', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBHEmFm8RPhUo7MXGuLQcrKJINnquxbEzqW3ZdO_xn9mqNN9dxQOa2fQmagij6F3N9AkAfSL8OVynsEJEqkbcykl2-1czmp3JlWiqvqaC0mU85JdnyoldLomWEVUC34EDmDdaNPoT6bHCDAx4YZ3Iie6UDc7fa0IlQ5iWnZSFxjRc5adDpSC3YQXPg8_GitOFkVF7vlyB9OMA7AHKBljjcxwxZ7dQsBtVfK7Tt0dD36phwkA9PLlpjdg4CjluZb7JnBtx_zF1Qwqm0'),
                              const SizedBox(width: 16),
                              _buildBrandItem('KFC', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNPx5TxzOBH7uNazdjBRQzyeZLlaON6LN-sE0arqp56dnHPsmKLZnf3wE6QGx4lZMFKRv1WEnYbPUnratfk-0SxrGd5e0JCKJjZdWbJsTO3fTJ-UkaP_dSR1rDXXYDj420Grce8d3vJLp5moaP9mC6sr5D6xEgWinPl90UKq4EaJogwvELXL8jaEXpOblAYSwbREWRa9zBMNNzk1xt8kE-FWI-wN4mtw53pMUzmsZ8L9QFh3goaJ3K3vJ5EtAC5q27FsHnKAVWEvo'),
                              const SizedBox(width: 16),
                              _buildBrandItem('Subway', 'https://lh3.googleusercontent.com/aida-public/AB6AXuBGq_bL1Gh4TTSWr7XNMFY3FiA3UEeqzS72WUlne6P7myNnokEW0lGITPwkcbdrmY3j1SX15NIz_bSGX_lZEil8p9UH8lSqJbsgIWx3RDT_s98IVUOa3rFi82ExOrplyR2644_C6zve4vubBq4WEI1T95mJM0uaFnpLiAZjMGYqq_TVvbyoWFRr4PJZQRjTW3_QHoHIBcThdYEeibVfsNkTk9E_UtRvf9lDjd3cwCk-Ip5ZlefAyrDhAO5vHqP877iM-2KzOSJN58M'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Featured Restaurants List (Filtered)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Featured Restaurants',
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'See all',
                              style: TextStyle(
                                color: primary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ..._getFilteredRestaurants().map((restaurant) => Column(
                          children: [
                            _buildRestaurantCard(restaurant),
                            const SizedBox(height: 16),
                          ],
                        )),
                        if (_getFilteredRestaurants().isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No restaurants found for this category.'),
                          ),
                        const SizedBox(height: 100), // Bottom padding for FAB and Nav Bar
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          );
  }

  Widget _buildDiscoverContent(Color primary, Color darkBrown) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Discover Restaurants',
              style: TextStyle(
                color: darkBrown,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final restaurant = _allRestaurants[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildRestaurantCard(restaurant),
                );
              },
              childCount: _allRestaurants.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildProfileContent(Color primary, Color darkBrown) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: primary.withValues(alpha: 0.1),
            child: Icon(Icons.person, size: 50, color: primary),
          ),
          const SizedBox(height: 16),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          const Text('john.doe@example.com'),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () {},
            child: const Text('Edit Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData icon, String label, int index, {String? badge}) {
    const primary = Color(0xFF8B0000);
    const darkBrown = Color(0xFF3E2723);
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onBottomNavTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24,
                color: isActive ? primary : darkBrown.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 2),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: isActive ? primary : darkBrown.withValues(alpha: 0.4),
                  fontSize: 9,
                  fontWeight: FontWeight.w900, // font-extrabold
                  letterSpacing: 1.5, // tracking-widest
                ),
              ),
            ],
          ),
          // Badge Logic
          if (badge != null)
            Positioned(
              top: -8,
              right: -8,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, IconData icon, int index, {bool closeOnTap = false}) {
    const primary = Color(0xFF8A0000);
    final isSelected = _selectedCategoryIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedCategoryIndex == index) {
             _selectedCategoryIndex = -1; // Deselect
          } else {
             _selectedCategoryIndex = index;
          }
        });
        if (closeOnTap) {
          Navigator.pop(context);
        }
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? primary : const Color(0xFFF3E5E5), // Light pink/rose
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C), // Dark gray/black
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandItem(String name, String imageUrl) {
    const primary = Color(0xFF8A0000);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantMenuScreen(
              restaurant: {
                'title': name,
                'image': imageUrl,
                'rating': 4.5, // Default rating
                'time': '15-25 min', // Default time
                'deliveryCost': '\$1.99 delivery', // Default cost
                'tags': ['Popular', 'Fast Food'], // Default tags
              },
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: primary.withValues(alpha: 0.2), width: 1),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
            ),
            child: ClipOval(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.22,
                width: double.infinity,
                child: Image.network(restaurant.image, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: () {
                    // Navigate to Restaurant Menu
                     Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantMenuScreen(
                          restaurant: {
                            'title': restaurant.title,
                            'image': restaurant.image,
                            'rating': restaurant.rating,
                            'time': restaurant.time,
                            'deliveryCost': restaurant.deliveryCost,
                            'tags': restaurant.tags, // Pass tags
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8A0000).withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward, color: Color(0xFF8A0000), size: 24),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      restaurant.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    Text(
                      restaurant.deliveryCost,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: restaurant.deliveryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(restaurant.time, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                    const SizedBox(width: 16),
                    const Icon(Icons.place, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(restaurant.distance, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: restaurant.tags.map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'All Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return _buildCategoryItem(category['name'], category['icon'], index, closeOnTap: true);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow the sheet to take required height
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView( // Fix overflow
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFilterOption(
                      'Popular',
                      Icons.local_fire_department,
                      _selectedSortOption == 'Popular',
                      (val) {
                        setModalState(() => _selectedSortOption = 'Popular');
                        setState(() {});
                      }
                    ),
                    _buildFilterOption(
                      'Rating',
                      Icons.star,
                      _selectedSortOption == 'Rating',
                      (val) {
                        setModalState(() => _selectedSortOption = 'Rating');
                        setState(() {});
                      }
                    ),
                    _buildFilterOption(
                      'Price: Low to High',
                      Icons.arrow_upward,
                      _selectedSortOption == 'Price: Low to High',
                      (val) {
                        setModalState(() => _selectedSortOption = 'Price: Low to High');
                        setState(() {});
                      }
                    ),
                    _buildFilterOption(
                      'Price: High to Low',
                      Icons.arrow_downward,
                      _selectedSortOption == 'Price: High to Low',
                      (val) {
                        setModalState(() => _selectedSortOption = 'Price: High to Low');
                        setState(() {});
                      }
                    ),
                    const SizedBox(height: 24),
                    // Clear Filtering Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _searchController.clear(); // Clear search text
                          setModalState(() {
                            _selectedSortOption = 'Popular';
                            _selectedCategoryIndex = 0; // Reset to View All
                          });
                          setState(() {
                            _selectedSortOption = 'Popular';
                            _selectedCategoryIndex = 0; // Reset to View All
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF8A0000), width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          foregroundColor: const Color(0xFF8A0000),
                        ),
                        child: const Text(
                          'Clear Filtering',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A0000),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon, bool isSelected, Function(bool) onTap) {
    return InkWell(
      onTap: () => onTap(!isSelected),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? const Color(0xFF8A0000) : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? const Color(0xFF8A0000) : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: Color(0xFF8A0000)),
          ],
        ),
      ),
    );
  }
}
