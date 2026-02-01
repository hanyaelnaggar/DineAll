import 'package:flutter/material.dart';
import 'package:dineall/service/cart_service.dart';
import 'package:dineall/screen/profile_screen.dart';
import 'checkout_screen.dart';
import 'food_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int _selectedIndex = 2; // Cart tab active
  final TextEditingController _promoCtrl = TextEditingController();
  final TextEditingController _specialRequestCtrl = TextEditingController();

  @override
  void dispose() {
    _promoCtrl.dispose();
    _specialRequestCtrl.dispose();
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    if (index == 2) return; // Already on Cart

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FoodScreen(initialTabIndex: index),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF8A0000);
    const backgroundLight = Color(0xFFF8F5F5);
    const darkText = Color(0xFF1D0C0C);

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: 8),
            Text(
              'DineAll',
              style: GoogleFonts.plusJakartaSans(
                color: primary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep, color: primary),
              onPressed: () {
                CartService().clearAll();
              },
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: CartService(),
        builder: (context, child) {
          final cartService = CartService();
          final cartItemsMap = cartService.items;
          final restaurantKeys = cartItemsMap.keys.toList();
          final totalAmount = cartService.totalPrice;
          final totalItems = cartService.totalItemCount;

          if (cartItemsMap.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    child: const Text('Start Browsing'),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Cart',
                            style: TextStyle(
                              color: darkText,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Review your items across different brands',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final restaurantName = restaurantKeys[index];
                        final items = cartItemsMap[restaurantName]!;
                        // Use the first item to get restaurant details (logo/tag)
                        // In a real app, you might store restaurant metadata separately in the CartService
                        final firstItem = items.first; 
                        
                        return _buildBrandGroup(
                          restaurantName,
                          firstItem.restaurantImage,
                          firstItem.restaurantTag,
                          items,
                        );
                      },
                      childCount: restaurantKeys.length,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
                      child: Column(
                        children: [
                          // Promo Code Section
                          TextField(
                            controller: _promoCtrl,
                            decoration: InputDecoration(
                              hintText: 'Apply Promo Code',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                              prefixIcon: const Icon(Icons.sell_outlined, color: primary),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.chevron_right, color: primary),
                                onPressed: () {
                                  if (_promoCtrl.text.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Applied promo: ${_promoCtrl.text}'),
                                        backgroundColor: primary,
                                      ),
                                    );
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: primary.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                                borderSide: BorderSide(color: primary, width: 1.5),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                            cursorColor: primary,
                          ),
                          
                          const SizedBox(height: 16),

                          // Special Request Section
                          TextField(
                            controller: _specialRequestCtrl,
                            decoration: InputDecoration(
                              hintText: 'Special Request',
                              hintStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primary,
                              ),
                              prefixIcon: const Icon(Icons.note_alt_outlined, color: primary),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check_circle_outline, color: primary),
                                onPressed: () {
                                  if (_specialRequestCtrl.text.isNotEmpty) {
                                    final cartService = CartService();
                                    if (cartService.items.isNotEmpty) {
                                      // Heuristic: Update the last item of the last restaurant
                                      // This assumes the "item I added" is the last one.
                                      final lastRestaurant = cartService.items.keys.last;
                                      final items = cartService.items[lastRestaurant]!;
                                      // Safety check
                                      if (items.isNotEmpty) {
                                        final lastIndex = items.length - 1;
                                        cartService.updateSpecialRequest(
                                          lastRestaurant, 
                                          lastIndex, 
                                          _specialRequestCtrl.text
                                        );
                                        
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Note added to ${items.last.name}'),
                                            backgroundColor: primary,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                        _specialRequestCtrl.clear();
                                        FocusScope.of(context).unfocus();
                                      }
                                    }
                                  }
                                },
                              ),
                              filled: true,
                              fillColor: primary.withValues(alpha: 0.1),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(color: primary.withValues(alpha: 0.2)),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(100)),
                                borderSide: BorderSide(color: primary, width: 1.5),
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),
                            cursorColor: primary,
                          ),
                          
                          const SizedBox(height: 24),

                          // Order Summary
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'TOTAL AMOUNT',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '\$${totalAmount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: darkText,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '$totalItems items across ${restaurantKeys.length} brands',
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'View Breakdown',
                                        style: TextStyle(
                                          color: primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => const CheckoutScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 4,
                                    shadowColor: primary.withValues(alpha: 0.4),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'Proceed to Checkout',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, size: 20),
                                    ],
                                  ),
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
              
          // Floating Bottom Navigation (Replaces standard bottom nav)
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
                  _buildNavItem(Icons.explore, 'Discover', 1),
                  _buildNavItem(Icons.shopping_cart, 'Cart', 2, badge: totalItems > 0 ? '$totalItems' : null),
                  _buildNavItem(Icons.account_circle, 'Profile', 3),
                ],
              ),
            ),
          ),
        ],
      );
    },
  ),
);
}

  Widget _buildBrandGroup(String restaurantName, String logo, String tag, List<CartItem> items) {
    const darkText = Color(0xFF1D0C0C);
    const primary = Color(0xFF8A0000);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(logo),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) {}, // Handle error gracefully
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurantName,
                          style: const TextStyle(
                            color: darkText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (tag.isNotEmpty)
                          Text(
                            tag,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    CartService().clearRestaurantCart(restaurantName);
                  },
                  child: const Text(
                    'CLEAR ORDER',
                    style: TextStyle(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFFAFAFA)),
          // Items
          ...items.asMap().entries.map((entry) {
            int itemIndex = entry.key;
            CartItem item = entry.value;
            return _buildCartItem(restaurantName, itemIndex, item);
          }),
          
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FoodScreen()),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Continue Shopping',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primary,
                  side: const BorderSide(color: primary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(String restaurantName, int itemIndex, CartItem item) {
    const darkText = Color(0xFF1D0C0C);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {},
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.specialRequest.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Note: ${item.specialRequest}',
                      style: const TextStyle(
                        color: Color(0xFF8A0000),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Actions
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 24),
                onPressed: () {
                  CartService().removeFromCart(restaurantName, itemIndex);
                },
              ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  children: [
                    _buildQtyBtn('-', () {
                      CartService().updateQuantity(restaurantName, itemIndex, -1);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          color: darkText,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildQtyBtn('+', () {
                      CartService().updateQuantity(restaurantName, itemIndex, 1);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(String label, VoidCallback onTap) {
    const primary = Color(0xFF8A0000);
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: primary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {String? badge}) {
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
}
