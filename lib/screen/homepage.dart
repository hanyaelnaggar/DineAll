import 'package:flutter/material.dart';
import 'package:dineall/screen/food_screen.dart';
import 'package:dineall/screen/cart_screen.dart';
import 'package:dineall/screen/profile_screen.dart';
import 'package:dineall/screen/chatbot_screen.dart';
import 'package:dineall/screen/notification_screen.dart';
import 'package:dineall/service/location_service.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;
  String _selectedLocation = 'Locating...';
  List<String> _locations = ['Locating...'];
  // String _selectedSortOption = 'Popular';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (mounted) {
      setState(() {
        _selectedLocation = 'Locating...';
      });
    }

    try {
      final address = await LocationService().getCurrentAddress();
      
      if (mounted) {
        setState(() {
          if (address != null && address != "Unknown Location") {
            _locations = [address];
            _selectedLocation = address;
          } else {
            // Fallback to a formal address instead of coordinates
            _locations = ["9 Al Wady Road, Buildings Area (B3), Madinaty"];
            _selectedLocation = _locations[0];
          }
        });
      }
    } catch (e) {
       if (mounted) {
          setState(() {
            _selectedLocation = 'Error Locating';
             _locations = ['Error Locating'];
          });
       }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Categories Data
  final List<Map<String, dynamic>> _categories = [
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

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodScreen()),
      );
      return;
    }
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
    // Colors from Tailwind config
    const primary = Color(0xFF8B0000);
    const accent = Color(0xFFE32929);
    const darkBrown = Color(0xFF3E2723);
    const bgGray = Color(0xFFF5F5F5);
    // const textMain = Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: bgGray,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. Header
              SliverAppBar(
                backgroundColor: const Color(0xFFF5F5F5),
                expandedHeight: 220,
                collapsedHeight: 220,
                toolbarHeight: 220,
                floating: false,
                pinned: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32), // 2rem
                    bottomRight: Radius.circular(32), // 2rem
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24), // Removed fixed top padding
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min, // Use min size
                          children: [
                            // Top Row
                            Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '',
                                    style: TextStyle(
                                      color: primary,
                                      fontSize: 24, // text-2xl
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5, // tracking-tight
                                    ),
                                  ),
                                  const SizedBox(height: 4), // mt-1
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: primary, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: _selectedLocation,
                                            icon: const Icon(Icons.expand_more, color: primary, size: 14),
                                            dropdownColor: Colors.white,
                                            isDense: true,
                                            isExpanded: true,
                                            style: const TextStyle(
                                              color: primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            selectedItemBuilder: (BuildContext context) {
                                              return _locations.map<Widget>((String item) {
                                                return Text(
                                                  item,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                            onChanged: (String? newValue) {
                                              if (newValue != null) {
                                                setState(() {
                                                  _selectedLocation = newValue;
                                                });
                                              }
                                            },
                                            items: _locations.map<DropdownMenuItem<String>>((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(
                                                  value,
                                                  style: const TextStyle(
                                                    color: Color(0xFF8A0000),
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                     // Navigate to Notifications screen
                                     Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (context) => const NotificationScreen()),
                                     );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.notifications_none_outlined, color: primary, size: 22),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16), // Spacing for search bar

                        // Search Bar
                        TextField(
                          controller: _searchController,
                          style: const TextStyle(color: darkBrown),
                          cursorColor: primary,
                          decoration: InputDecoration(
                            hintText: 'Search brands, dishes, or cuisines...',
                            hintStyle: TextStyle(
                              color: darkBrown.withValues(alpha: 0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                            prefixIcon: const Icon(Icons.search, color: primary, size: 20),
                            filled: true,
                            fillColor: Colors.white,
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
                              borderSide: const BorderSide(color: primary, width: 1.5),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const FoodScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  elevation: 0,
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'View Restaurant',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24), // mt-6

                  // 2. Welcoming Hero Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'Exquisite Culinary Experiences',
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Title
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 36, // text-4xl/5xl equivalent
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                              color: darkBrown,
                              fontFamily:
                                  'Plus Jakarta Sans', // Assuming font is available or fallback
                            ),
                            children: [
                              TextSpan(text: 'The Ultimate\n'),
                              TextSpan(
                                text: 'Gourmet',
                                style: TextStyle(color: primary),
                              ),
                              TextSpan(text: ' Destination.'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          'Discover the finest multi-brand F&B marketplace. From local gems to global delicacies, we bring excellence to your table.',
                          style: TextStyle(
                            color: darkBrown.withValues(alpha: 0.7),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Hero Image with Overlay
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: NetworkImage(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuAQqzeagch3HIvL6QMPxaiSWQB9KQiifMmgnLtwYi7H0aFZZ3ZUdHUw_Hu4Cd4G_SKugTSRwRdlVvb1qwUkYPZMMP3hx1HwgRr2k2ralXyGZeGu37Bm-WAFatk6MjVhHuPKVScrpcyO_whWKiCv5Cqps1eAVoDMk41s06KqhSHx_dj4a0UcjHYDx8mIuuPhg0f_1Algvtbt2wdgHvgxFkoYdn7wVE0hpyTjYnM51_WrpaGRQelESHnfWujYNqXx5xTTiiSujI1IjkD2'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Top Rated Card Overlay
                            Positioned(
                              bottom: -20,
                              left: 20,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.stars,
                                          color: Colors.white, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Top Rated',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '100+ Brands',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: darkBrown,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            color: Color(0xFF3E2723),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
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
                      ],
                    ),
                  ),

                  const SizedBox(height: 32), // mt-8

                  // Promotions Title
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Special Offers',
                      style: TextStyle(
                        color: Color(0xFF3E2723),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Promotional Cards (Horizontal Scroll)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24), // px-6
                    child: Row(
                      children: [
                        _buildPromoCard(
                          bgImage:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBOAYCSfJMf5J-tpRJZbJO2V_mP4orzz-mM-scbuN6gcwnmitIuqk0Iy2STsgJkL8rxFq2GGMcpytt4pmI8qDmZvhjyH3x0BEPLHSukfgnX_Hw1p9MWfNgbpEVtfMUpvnqxMqlzCv2eG8KHXZLG-TYSN6oEu2DaoXi83rck35qK3pVWm02C-5cZtpkTzbPh92Yky4nJsOxJgSuRVNa4HlcnMyygUTe4CgMlyWptj_eel3Jpbu7U65wUAf_ziq1Wv1dZfd83GFBhu-8',
                          gradientColor: primary,
                          tag: 'EXCLUSIVE',
                          tagColor: accent,
                          tagTextColor: Colors.white,
                          title: 'Velvet Roast Coffee',
                          subtitle: 'Free pastry with every latte order',
                          btnText: 'ORDER NOW',
                          btnTextColor: primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FoodScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 16), // gap-4
                        _buildPromoCard(
                          bgImage:
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuBIFGbkah9Uw_jPsv8TjUeAcqswPpR_WY1-BulvKrAnYvWPw4x0LyKXKBtRSMa3_xaUKXkAbFe4uilK5YqA6ozImOh5fBxdLhcZ4-av5tqqJS9X5hOvefhSA8NyaZ-NUxBOjjBNXjWWLR4HEm9-rNEfIuxFWFfEFmhcQzJX4TFDdK48Qq2vuMVK4BL59XlnIU1V16ISUiD3tcg3nVA7SbZnZf2kVTrH2UjIAuN0O9aUM3a9x9cROsC3ofYFj7_xPoDrmcbG8Tyh67U',
                          gradientColor: accent,
                          tag: 'LIMITED TIME',
                          tagColor: primary,
                          tagTextColor: Colors.white,
                          title: 'Hearth & Grain',
                          subtitle: '20% off on all artisan sourdough',
                          btnText: 'CLAIM OFFER',
                          btnTextColor: accent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const FoodScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40), // mt-10

                  // 4. Trending Now
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24), // px-6
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Trending Now',
                              style: TextStyle(
                                color: darkBrown,
                                fontSize: 20, // text-xl
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Popular choices in your area',
                              style: TextStyle(
                                color: darkBrown.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text(
                            'MARKET PICKS',
                            style: TextStyle(
                              color: primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // mb-6

                  // Cards List (Horizontal Scroll)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: _buildTrendingCard(
                            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCFpVVFAaroSFRuTZPdgz1lPViSW5bl8HigqmTR4Cn8nw8iT9Sb7jKedUjINZDWjmWJWXcXiLPhdxv7v-h8XdNTIpHCBbr6zZgHkL7ku-OltAENSTAiwfUT7Ie1-a4xC-siR5kYFVP8bLFNt8zJUyTNJ8proFbkdddyGVIxfhqURDTd-OaWhP5VTxH1vuire_5-W3OYPrTvhmvMUImoC_imlSpsqfnrVLH-CdP3Q7SFC0SgBroQkfzszez1OHeSmpTo--SPT27uYX4',
                            rating: '4.9',
                            tag: 'Open Now',
                            tagColor: accent,
                            title: 'Flora & Fauna',
                            subtitle: 'Artisanal Salads • 15-25 min',
                          ),
                        ),
                        const SizedBox(width: 16), // gap-4
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          child: _buildTrendingCard(
                            image: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAr38oLyEyzG5-zOkjhHcPoqqhahHDkrYIXGYXyNeTc4Y-JrbqA5JiIAQuSxTpejt-59IDEdv1k6hCkM49ftPivSYrc5pN59JJPVPKwGBLErK9r8Qzc6b7zlqsPGKSgaizk-uiXR_7OyIpLwtyffhuF0NLXVSezWwitD-NhoNbC7ImKyHG1ubl65I64L_iqKG_mZeWd6F96MhOHdoQ60sTGtY3Yl9zGeLqfEZzzvrV9GEKOiKq8PJukHZAuAS9M-TEeoLMne_EEv4E',
                            rating: '4.7',
                            tag: 'New Opening',
                            tagColor: primary,
                            title: 'The Daily Brew',
                            subtitle: 'Espresso Bar • 10-15 min',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120), // pb-32 (padding for bottom nav)
                ]),
              ),
            ],
          ),

          // 5. Floating Bottom Navigation
          Positioned(
            bottom: 24, // bottom-6
            left: 24, // left-6
            right: 24, // right-6
            child: Container(
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
                  _buildNavItem(Icons.home, 'Home', 0),
                  _buildNavItem(Icons.restaurant, 'Restaurants', 1),
                  _buildNavItem(Icons.shopping_cart, 'Cart', 2),
                  _buildNavItem(Icons.account_circle, 'Profile', 3),
                ],
              ),
            ),
          ),
          _buildChatbotButton(),
        ],
      ),
    );
  }

  Widget _buildChatbotButton() {
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: const Color(0xFF8A0000),
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
    );
  }

  /*
  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
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
  */

  Widget _buildCategoryItem(String label, IconData icon, int index) {
    const primary = Color(0xFF8A0000);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodScreen(initialCategoryIndex: index),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFF3E5E5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCard({
    required String bgImage,
    required Color gradientColor,
    required String tag,
    required Color tagColor,
    required Color tagTextColor,
    required String title,
    required String subtitle,
    required String btnText,
    required Color btnTextColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        height: 220, // Fixed height to prevent overflow
        decoration: BoxDecoration(
          color: gradientColor,
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Opacity(
                opacity: 0.4,
                child: Image.network(
                  bgImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      gradientColor,
                      gradientColor.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        color: tagTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 1, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2, // Limit lines to prevent overflow
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(), // Use Spacer instead of SizedBox to push button to bottom
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      btnText,
                      style: TextStyle(
                        color: btnTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTrendingCard({
    required String image,
    required String rating,
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
  }) {
    const primary = Color(0xFF8B0000);
    const darkBrown = Color(0xFF3E2723);

    return GestureDetector(
      onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const FoodScreen()),
         );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32), // rounded-[2rem]
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Image Section
          Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25, // h-52
                width: double.infinity,
                child: Image.network(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
              // Rating Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFE32929), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: const TextStyle(
                          color: darkBrown,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Tag Badge
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
                  ),
                  child: Text(
                    tag.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Content Section
          Padding(
            padding: const EdgeInsets.all(24.0), // p-6
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkBrown,
                        fontSize: 18, // text-lg
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: darkBrown.withValues(alpha: 0.6),
                        fontSize: 14, // text-sm
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 48, // size-12
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), // rounded-2xl
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: primary, size: 24),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    const primary = Color(0xFF8B0000);
    const darkBrown = Color(0xFF3E2723);
    final isActive = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
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
    );
  }
}
