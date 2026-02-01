import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF8A0000);
    const backgroundLight = Color(0xFFF8F5F5);

    final notifications = [
      {
        'title': 'Order Arriving Soon',
        'message': 'Your order from The Burger House is 5 mins away!',
        'time': '2 mins ago',
        'isUnread': true,
      },
      {
        'title': '50% Off Promo',
        'message': 'Use code DINE50 for 50% off your next pizza order.',
        'time': '1 hour ago',
        'isUnread': true,
      },
      {
        'title': 'Order Delivered',
        'message': 'Your order from Sushi Zen Master has been delivered. Enjoy!',
        'time': 'Yesterday',
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: backgroundLight,
      appBar: AppBar(
        backgroundColor: backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          final isUnread = notification['isUnread'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnread ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: isUnread ? Border.all(color: primary.withValues(alpha: 0.1)) : null,
              boxShadow: isUnread
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  decoration: BoxDecoration(
                    color: isUnread ? primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                              color: isUnread ? Colors.black87 : Colors.grey[700],
                            ),
                          ),
                          Text(
                            notification['time'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        notification['message'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
