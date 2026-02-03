import 'package:dineall/screen/live_tracking_screen.dart';
import 'package:dineall/screen/confirmed_order_screen.dart';
import 'package:dineall/screen/chatbot_screen.dart';
import 'package:dineall/service/cart_service.dart';
import 'package:dineall/service/location_service.dart';
import 'package:dineall/service/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  double get subtotal => CartService().totalPrice;

  double get total {
    if (_selectedOrderType == 'Delivery') {
      return subtotal + 5.00; // Add $5 delivery fee
    }
    return subtotal;
  }

  String _selectedPaymentMethod = 'Credit Card';
  String _selectedOrderType = 'Delivery';
  final TextEditingController _addressController = TextEditingController();
  bool _isLoadingAddress = false;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchUserLocation();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserLocation() async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final address = await LocationService().getCurrentAddress();
      
      if (mounted) {
        setState(() {
          if (address != null && address != "Unknown Location") {
            _addressController.text = address;
          } else {
             _addressController.text = "9 Al Wady Road, Buildings Area (B3), Madinaty";
          }
        });
      }

      /* 
      // Original API call - commented out to ensure the specific format is displayed for demo
      const String baseUrl = 'http://10.0.2.2:3000'; 
      // ...
      */
    } catch (e) {
      debugPrint("Error fetching location: $e");
      // Fallback if location services fail
      if (mounted) {
         setState(() {
          _addressController.text = "Madinaty - B3 - Group 12 - Apt 5";
        });
      }
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      labelStyle: const TextStyle(color: Colors.grey),
      prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF9B0F0F)) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF9B0F0F), width: 1.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF9B0F0F); // Deep Red
    const bgGray = Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: bgGray,
      appBar: AppBar(
        backgroundColor: bgGray,
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
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  
                  // 2. Order Summary Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ORDER SUMMARY',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9B0F0F).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                              '2 Brands',
                              style: TextStyle(
                                color: Color(0xFF9B0F0F),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. Restaurant Sections
                  AnimatedBuilder(
                    animation: CartService(),
                    builder: (context, child) {
                      final cartItems = CartService().items;
                      if (cartItems.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('Your cart is empty.'),
                        );
                      }
                      return Column(
                        children: cartItems.entries.map((entry) {
                          return _buildRestaurantSection(entry.key, entry.value);
                        }).toList(),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),

                  // 4. Order Type Section
                  _buildOrderTypeSection(),

                  if (_selectedOrderType == 'Delivery') ...[
                    const SizedBox(height: 24),
                    _buildDeliveryAddressSection(),
                  ],

                  const SizedBox(height: 24),
                  
                  // 5. Payment Method Section
                  _buildPaymentMethodSection(),

                  const SizedBox(height: 40),

                  // 6. Scrollable Summary Sheet
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Subtotal
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFF333333),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Delivery Fee
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Delivery Fee',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _selectedOrderType == 'Delivery' ? '\$5.00' : 'FREE',
                              style: TextStyle(
                                color: _selectedOrderType == 'Delivery' ? const Color(0xFF333333) : Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFEEEEEE)),
                        const SizedBox(height: 16),
                        // Total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL AMOUNT',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFB02020),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Proceed Button
                        AnimatedPrimaryButton(
                          text: 'Confirm & Pay',
                          onTap: () {
                            if (CartService().items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Your cart is empty!')),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Processing Payment...')),
                            );
                            
                            // Save card details if payment is via Credit Card
                            if (_selectedPaymentMethod == 'Credit Card' && cardNumber.isNotEmpty) {
                              PaymentService().addCard(cardNumber, expiryDate, 'Credit Card');
                            }

                            // Simulate payment delay then navigate to tracking
                            Future.delayed(const Duration(seconds: 2), () {
                              CartService().clearAll(); // Clear cart after successful payment
                              
                              if (_selectedOrderType == 'Delivery') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const LiveTrackingScreen()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ConfirmedOrderScreen()),
                                );
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ],
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton(
              heroTag: 'checkout_chat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatbotScreen()),
                );
              },
              backgroundColor: const Color(0xFF9B0F0F),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillOption(String title, IconData icon, {bool isSelected = false, VoidCallback? onTap}) {
    const primary = Color(0xFF9B0F0F);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primary.withValues(alpha: 0.1) : Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: isSelected ? primary : Colors.grey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? primary : Colors.grey, size: 20),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? primary : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Plus Jakarta Sans',
                  package: 'google_fonts',
                ),
              ),
              const Spacer(),
              if (isSelected)
                const Icon(Icons.check_circle, color: primary, size: 20)
              else
                Icon(Icons.circle_outlined, color: Colors.grey.withValues(alpha: 0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'ORDER TYPE',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildPillOption(
            'Delivery',
            Icons.moped,
            isSelected: _selectedOrderType == 'Delivery',
            onTap: () => setState(() => _selectedOrderType = 'Delivery'),
          ),
          _buildPillOption(
            'Pickup',
            Icons.store,
            isSelected: _selectedOrderType == 'Pickup',
            onTap: () => setState(() => _selectedOrderType = 'Pickup'),
          ),
          _buildPillOption(
            'Dine In',
            Icons.restaurant,
            isSelected: _selectedOrderType == 'Dine In',
            onTap: () => setState(() => _selectedOrderType = 'Dine In'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DELIVERY ADDRESS',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                if (_isLoadingAddress)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  InkWell(
                    onTap: _fetchUserLocation,
                    child: const Row(
                      children: [
                        Icon(Icons.my_location, size: 16, color: Color(0xFF9B0F0F)),
                        SizedBox(width: 4),
                        Text(
                          'Detect',
                          style: TextStyle(
                            color: Color(0xFF9B0F0F),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter delivery address',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.location_on_outlined, color: Color(0xFF9B0F0F)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 2,
              minLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    final bool isDineIn = _selectedOrderType == 'Dine In';
    final String cardLabel = isDineIn ? 'Pay Online' : 'Credit Card';
    final String cashLabel = isDineIn ? 'Pay at Restaurant' : 'Cash';
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'PAYMENT METHOD',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildPillOption(
            cardLabel,
            Icons.credit_card,
            isSelected: _selectedPaymentMethod == 'Credit Card',
            onTap: () => setState(() => _selectedPaymentMethod = 'Credit Card'),
          ),
          if (_selectedPaymentMethod == 'Credit Card')
            Column(
              children: [
                CreditCardForm(
                  formKey: formKey,
                  obscureCvv: true,
                  obscureNumber: true,
                  cardNumber: cardNumber,
                  cvvCode: cvvCode,
                  isHolderNameVisible: true,
                  isCardNumberVisible: true,
                  isExpiryDateVisible: true,
                  cardHolderName: cardHolderName,
                  expiryDate: expiryDate,
                  inputConfiguration: InputConfiguration(
                    cardNumberDecoration: _buildInputDecoration(
                      label: 'Number',
                      hint: 'XXXX XXXX XXXX XXXX',
                    ),
                    expiryDateDecoration: _buildInputDecoration(
                      label: 'Expired Date',
                      hint: 'XX/XX',
                    ),
                    cvvCodeDecoration: _buildInputDecoration(
                      label: 'CVV',
                      hint: 'XXX',
                    ),
                    cardHolderDecoration: _buildInputDecoration(
                      label: 'Card Holder',
                      hint: 'Name on Card',
                    ),
                  ),
                  onCreditCardModelChange: onCreditCardModelChange,
                ),
              ],
            ),
          _buildPillOption(
            cashLabel,
            isDineIn ? Icons.store : Icons.account_balance_wallet,
            isSelected: _selectedPaymentMethod == 'Cash',
            onTap: () => setState(() => _selectedPaymentMethod = 'Cash'),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantSection(String restaurantName, List<CartItem> items) {
    final String badge = items.isNotEmpty ? items.first.restaurantTag : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    restaurantName == 'Sushi Zen' ? Icons.rice_bowl : Icons.lunch_dining,
                    color: const Color(0xFF9B0F0F),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    restaurantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              if (badge.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCE8E8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Color(0xFFA02727),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Items
          ...items.map((item) => _buildCartItem(item)),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade200),
              image: DecorationImage(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD84315), // Dark orange/red
                  ),
                ),
              ],
            ),
          ),
          // Quantity Display (No buttons)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              // border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'x${item.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

}

// Custom Painter for Dashed Border with Rounded Corners
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;

  DashedRectPainter({
    this.strokeWidth = 1.0,
    this.color = Colors.red,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double dashedPathLength = gap;
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    var path = Path();
    path.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(28))); // Match container radius

    Path dashedPath = Path();
    for (ui.PathMetric pathMetric in path.computeMetrics()) {
      while (dashedPathLength < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(dashedPathLength, dashedPathLength + gap),
          Offset.zero,
        );
        dashedPathLength += gap * 2;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class AnimatedPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final bool isLoading;

  const AnimatedPrimaryButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  State<AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<AnimatedPrimaryButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF9B0F0F);
    const pressedColor = Color(0xFF7A0000); // Darker red

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: double.infinity,
          height: 64,
          decoration: BoxDecoration(
            color: _isPressed ? pressedColor : primary,
            borderRadius: BorderRadius.circular(36),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.4),
                blurRadius: _isPressed ? 6 : 12,
                offset: _isPressed ? const Offset(0, 2) : const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.chevron_right, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
