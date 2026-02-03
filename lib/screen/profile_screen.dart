import 'package:dineall/screen/cart_screen.dart';
import 'package:dineall/screen/favorites_screen.dart';
import 'package:dineall/screen/food_screen.dart';
import 'package:dineall/screen/login_screen.dart';
import 'package:dineall/screen/payment_methods_screen.dart';
import 'package:dineall/screen/settings_screen.dart';
import 'package:dineall/service/user_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors matching the rest of the application
    const primary = Color(0xFF8B0000); // Deep Red
    const backgroundLight = Color(0xFFF5F5F5);
    const textDarkBrown = Color(0xFF3E2723);
    
    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: textDarkBrown),
          onPressed: () {},
        ),
        title: Text(
          'DineAll',
          style: GoogleFonts.plusJakartaSans(
            color: textDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.settings, color: textDarkBrown, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
            child: Column(
              children: [
                // Profile Header
                AnimatedBuilder(
                  animation: UserService(),
                  builder: (context, child) {
                    final user = UserService().currentUser;
                    final name = user?.name ?? 'Guest User';
                    final date = user?.joinDate ?? 'Join DineAll today!';
                    final image = user?.imageUrl ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuBSL40aBfuZrv81ARnlpTHvSusd6_w09ior8DZBxT3656prXUgYZeaJ2so-b1y5KanDVnKiCQU3wOHoQyi5cq8Plo6fbg3CaZt-NjgM3ds-lOFWbueSB5YDN6dCuw0GuCfTdFmVzKUw6B3yJZMllVM-4q__OLOmNM7U3VOxzPXG0LJCeSUIubpUVJRwkKcKkbjYO1YogNP80WyIJAUIWrvjQKtaE2K9B81GKC7nolV_aBYxRZmI7GBpHY0jCDHggUlpolyhTjPbwsk';

                    return Column(
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textDarkBrown,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: primary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  }
                ),
                const SizedBox(height: 32),

                // Menu Options
                Column(
                  children: [
                    _buildProfileOption(
                      icon: Icons.receipt_long,
                      title: 'My Orders',
                      primary: primary,
                      textDarkBrown: textDarkBrown,
                    ),
                    _buildProfileOption(
                      icon: Icons.credit_card,
                      title: 'Payment Methods',
                      primary: primary,
                      textDarkBrown: textDarkBrown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PaymentMethodsScreen()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.location_on,
                      title: 'Manage Addresses',
                      primary: primary,
                      textDarkBrown: textDarkBrown,
                    ),
                    _buildProfileOption(
                      icon: Icons.favorite,
                      title: 'Favorites',
                      primary: primary,
                      textDarkBrown: textDarkBrown,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
                        );
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.support_agent,
                      title: 'Help & Support',
                      primary: primary,
                      textDarkBrown: textDarkBrown,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      UserService().logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFD32F2F), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Color(0xFFD32F2F)),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD32F2F),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
                border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, Icons.home, 'Home', 0, primary, textDarkBrown),
                  _buildNavItem(context, Icons.restaurant, 'Restaurants', 1, primary, textDarkBrown),
                  _buildNavItem(context, Icons.shopping_cart, 'Cart', 2, primary, textDarkBrown),
                  _buildNavItem(context, Icons.account_circle, 'Profile', 3, primary, textDarkBrown),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, Color primary, Color darkBrown) {
    final isActive = index == 3; // Profile is always active on ProfileScreen

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FoodScreen()),
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        }
      },
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
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color primary,
    required Color textDarkBrown,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDarkBrown,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primary,
                            letterSpacing: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
