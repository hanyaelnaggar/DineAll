import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dineall/screen/cart_screen.dart';
import 'package:dineall/screen/live_tracking_screen.dart';
import 'package:dineall/screen/food_screen.dart';
import 'package:dineall/service/cart_service.dart';

enum ChatIntent {
  order,
  navigateCart,
  trackOrder,
  menuQuery,
  greeting,
  unknown,
}

class ChatbotScreen extends StatefulWidget {
  static const routeName = '/chatbot';

  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _botTyping = false;

  final Color primary = const Color(0xFF8A0000);
  final Color backgroundLight = const Color(0xFFF5F5F5);
  final Color chatIncoming = const Color(0xFFFFFFFF);
  final Color textDarkBrown = const Color(0xFF3E2723);

  final List<_Message> _messages = [
    _Message(
      fromBot: true,
      text: "Hello! I'm your DineAll Assistant. I can help you order food, track deliveries, or check your cart. What can I do for you?",
      timestamp: const TimeOfDay(hour: 10, minute: 30),
    ),
  ];

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_Message(
        fromBot: false,
        text: text.trim(),
        timestamp: _now(),
        delivered: true,
      ));
      _controller.clear();
      _botTyping = true;
    });
    _scrollToBottom();

    // Analyze intent
    final intent = _analyzeIntent(text);

    // Simulate bot reply
    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (!mounted) return;

      switch (intent) {
        case ChatIntent.order:
          await _handleOrderIntent(text);
          break;
        case ChatIntent.navigateCart:
          await _handleNavigateCartIntent();
          break;
        case ChatIntent.trackOrder:
          await _handleTrackOrderIntent();
          break;
        case ChatIntent.menuQuery:
          await _handleMenuQueryIntent();
          break;
        case ChatIntent.greeting:
          _sendBotReply("Hi there! Ready to order something delicious?");
          break;
        case ChatIntent.unknown:
          _sendBotReply("I'm not sure I understood that. You can ask me to 'order a burger', 'show my cart', or 'track my order'.");
          break;
      }
    });
  }

  ChatIntent _analyzeIntent(String text) {
    final lower = text.toLowerCase();
    
    // Navigation: Cart
    if (lower.contains('cart') || lower.contains('basket') || lower.contains('checkout') || lower.contains('view order')) {
      if (lower.contains('add') || lower.contains('put')) return ChatIntent.order; // "Add to cart" is an order
      return ChatIntent.navigateCart;
    }

    // Navigation: Tracking
    if (lower.contains('track') || lower.contains('where') || lower.contains('status') || lower.contains('arrival')) {
      return ChatIntent.trackOrder;
    }

    // Navigation: Menu
    if (lower.contains('menu') || lower.contains('list') || lower.contains('options') || lower.contains('what do you have')) {
      return ChatIntent.menuQuery;
    }

    // Action: Order
    // Keywords that strongly suggest wanting an item
    if (lower.contains('order') || lower.contains('buy') || lower.contains('get') || lower.contains('want') || lower.contains('add') || lower.contains('i need')) {
      return ChatIntent.order;
    }
    
    // Implicit Order (just naming a food item)
    if (lower.contains('burger') || lower.contains('pizza') || lower.contains('sushi') || lower.contains('salad') || lower.contains('coffee') || lower.contains('cake')) {
      return ChatIntent.order;
    }

    // Greeting
    if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey')) {
      return ChatIntent.greeting;
    }

    return ChatIntent.unknown;
  }

  Future<void> _handleOrderIntent(String text) async {
    // Extract item name
    String itemName = text.trim();
    final lowerText = itemName.toLowerCase();
    final prefixes = ['i want a ', 'i want ', 'order a ', 'order ', 'get me a ', 'get me ', 'buy a ', 'buy ', 'add a ', 'add ', 'make a ', 'make ', 'i need a ', 'i need '];
    
    for (final prefix in prefixes) {
      if (lowerText.startsWith(prefix)) {
        itemName = itemName.substring(prefix.length).trim();
        break;
      }
    }
    
    // Cleanup suffix like "please" or "to cart"
    itemName = itemName.replaceAll(RegExp(r'\s+please$', caseSensitive: false), '');
    itemName = itemName.replaceAll(RegExp(r'\s+to (my )?cart$', caseSensitive: false), '');

    // Capitalize
    if (itemName.isNotEmpty) {
      itemName = itemName.split(' ').map((str) => str.isNotEmpty ? '${str[0].toUpperCase()}${str.substring(1)}' : '').join(' ');
    } else {
      _sendBotReply("What would you like to order? For example, type 'Order a Cheese Burger'.");
      return;
    }
    
    // Logic to determine details
    String imageUrl = 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=500&q=60'; // Generic
    String restaurantName = 'Special Request';
    double price = 15.00;
    String lower = itemName.toLowerCase();

    if (lower.contains('burger')) {
      imageUrl = 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Burger House';
      price = 12.50;
    } else if (lower.contains('pizza')) {
      imageUrl = 'https://images.unsplash.com/photo-1604382354936-07c5d9983bd3?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Pizza Hut';
      price = 18.00;
    } else if (lower.contains('sushi') || lower.contains('roll')) {
      imageUrl = 'https://images.unsplash.com/photo-1579871494447-9811cf80d66c?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Sushi Zen';
      price = 22.00;
    } else if (lower.contains('coffee') || lower.contains('latte') || lower.contains('espresso')) {
      imageUrl = 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Daily Brew';
      price = 5.50;
    } else if (lower.contains('salad') || lower.contains('bowl')) {
      imageUrl = 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Flora & Fauna';
      price = 14.00;
    } else if (lower.contains('dessert') || lower.contains('cake') || lower.contains('ice cream')) {
      imageUrl = 'https://images.unsplash.com/photo-1578985545062-69928b1d9587?auto=format&fit=crop&w=500&q=60';
      restaurantName = 'Sweet Cravings';
      price = 9.00;
    }

    CartService().addToCart(
      restaurantName: restaurantName,
      restaurantImage: imageUrl,
      restaurantTag: 'Custom Order',
      itemName: itemName,
      itemImage: imageUrl,
      itemPrice: price,
    );

    _sendBotReply("I've added $itemName to your cart. Opening your cart now...");
    
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
    }
  }

  Future<void> _handleNavigateCartIntent() async {
    _sendBotReply("Taking you to your cart...");
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
    }
  }

  Future<void> _handleTrackOrderIntent() async {
    _sendBotReply("Let's check on your order status. Redirecting you to live tracking...");
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const LiveTrackingScreen()));
    }
  }

  Future<void> _handleMenuQueryIntent() async {
    _sendBotReply("We have a great selection today! Opening the menu for you...");
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const FoodScreen()));
    }
  }

  void _sendBotReply(String text) {
    setState(() {
      _messages.add(_Message(
        fromBot: true,
        text: text,
        timestamp: _now(),
      ));
      _botTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 120,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  TimeOfDay _now() {
    final now = DateTime.now();
    return TimeOfDay(hour: now.hour, minute: now.minute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF230F0F) : backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              decoration: BoxDecoration(color: backgroundLight, boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => Navigator.of(context).pop(),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(child: Icon(Icons.arrow_back_ios_new, color: primary)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Chat Support', style: TextStyle(color: textDarkBrown, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('AI Assistant', style: TextStyle(color: textDarkBrown.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    ]),
                  ]),
                  // Top-right button using Container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: Center(
                      child: Icon(Icons.smart_toy, color: primary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_botTyping ? 1 : 0) + 1,
                itemBuilder: (context, index) {
                  // Chips row after first message
                  if (index == 1) {
                    return _QuickActions(
                      primary: primary,
                      onTap: (text) => _send(text),
                    );
                  }

                  // Typing indicator
                  if (_botTyping && index == _messages.length + 1) {
                    return _TypingBubble(
                      bg: chatIncoming,
                      border: Colors.grey.shade200,
                    );
                  }

                  // Spacer at top
                  if (index == 0) return const SizedBox(height: 8);

                  final msgIndex = index - 1;
                  final msg = _messages[msgIndex];

                  return _MessageBubble(
                    message: msg,
                    primary: primary,
                    chatIncoming: chatIncoming,
                    textDarkBrown: textDarkBrown,
                  );
                },
              ),
            ),

            // Composer
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF230F0F) : Colors.white,
                border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.attach_file, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            splashRadius: 18,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration.collapsed(hintText: 'Type your message...'),
                              onSubmitted: _send,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.mood, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            splashRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Send button with Icon
                  InkWell(
                    onTap: () => _send(_controller.text),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: primary, shape: BoxShape.circle, boxShadow: [
                        BoxShadow(color: primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
                      ]),
                      child: const Center(
                        child: Icon(Icons.send, color: Colors.white, size: 22),
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
}

class _Message {
  final bool fromBot;
  final String text;
  final TimeOfDay timestamp;
  final bool delivered;

  _Message({
    required this.fromBot,
    required this.text,
    required this.timestamp,
    this.delivered = false,
  });
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  final Color primary;
  final Color chatIncoming;
  final Color textDarkBrown;

  const _MessageBubble({
    required this.message,
    required this.primary,
    required this.chatIncoming,
    required this.textDarkBrown,
  });


  @override
  Widget build(BuildContext context) {
    final isMe = !message.fromBot;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isMe) _AssistantAvatar(primary: primary),
        Flexible(
          child: Container(
            margin: EdgeInsets.fromLTRB(isMe ? 60 : 8, 6, isMe ? 8 : 60, 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? primary : chatIncoming,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              border: isMe ? null : Border.all(color: Colors.grey.shade200),
              boxShadow: isMe
                  ? [
                      BoxShadow(color: primary.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0, 4)),
                    ]
                  : [const BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'DINEALL ASSISTANT',
                      style: GoogleFonts.plusJakartaSans(
                        color: primary.withValues(alpha: 0.8),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? Colors.white : textDarkBrown,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.timestamp),
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.check,
                        size: 14,
                        color: primary.withValues(alpha: 0.8),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
        if (isMe) _UserAvatar(),
      ],
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

class _AssistantAvatar extends StatelessWidget {
  final Color primary;
  const _AssistantAvatar({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
      child: const Center(
        child: Icon(Icons.smart_toy, color: Colors.white, size: 20),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 6)],
      ),
      child: const Icon(Icons.person, color: Colors.brown),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final Color bg;
  final Color border;
  const _TypingBubble({required this.bg, required this.border});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.only(right: 8),
        decoration: const BoxDecoration(color: Color(0xFF8A0000), shape: BoxShape.circle),
        child: Center(
          child: Container(
            width: 14,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
        child: const Row(children: [
          _Dot(delay: 0),
          SizedBox(width: 4),
          _Dot(delay: 150),
          SizedBox(width: 4),
          _Dot(delay: 300),
        ]),
      ),
    ]);
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({super.key, required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat();
    _anim = Tween<double>(begin: 0, end: -6).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _anim.value),
        child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final Color primary;
  final void Function(String text) onTap;

  const _QuickActions({super.key, required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label) {
      return InkWell(
        onTap: () => onTap(label),
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          margin: const EdgeInsets.only(right: 8, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: const [BoxShadow(color: Color(0x11000000), blurRadius: 4)],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 18, color: primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Wrap(
        children: [
          chip(Icons.inventory_2, 'Track my order'),
          chip(Icons.report, 'Missing item'),
          chip(Icons.location_on, 'Change address'),
          chip(Icons.support_agent, 'Talk to agent'),
        ],
      ),
    );
  }
}
