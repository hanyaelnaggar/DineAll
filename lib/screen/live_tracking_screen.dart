import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dineall/service/location_service.dart';

class LiveTrackingScreen extends StatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  State<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends State<LiveTrackingScreen> {
  final Color primary = const Color(0xFF8A0000);
  final MapController _mapController = MapController();
  
  // Default to San Francisco
  LatLng _userLatLng = const LatLng(37.7749, -122.4194);
  // ignore: unused_field
  bool _loadingLocation = true;
  String _locationError = '';

  // Sample positions
  final LatLng _restaurantLatLng = const LatLng(37.7894, -122.4076);
  final LatLng _courierLatLng = const LatLng(37.7810, -122.4110);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final pos = await LocationService().getCurrentPosition();
      
      if (mounted) {
        if (pos != null) {
          setState(() {
            _userLatLng = LatLng(pos.latitude, pos.longitude);
            _loadingLocation = false;
          });
          _mapController.move(_userLatLng, 14);
        } else {
           setState(() {
            _locationError = 'Location permission denied or service disabled.';
            _loadingLocation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationError = 'Error: $e';
          _loadingLocation = false;
        });
      }
    }
  }

  void _recenter() {
    _mapController.move(_userLatLng, 14);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Map Layer (Full Screen)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _userLatLng,
              initialZoom: 13,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.dineall',
              ),
              MarkerLayer(
                markers: [
                  // Restaurant
                  Marker(
                    point: _restaurantLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.store, color: Color(0xFF8A0000), size: 40),
                  ),
                  // Courier
                  Marker(
                    point: _courierLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.directions_bike, color: Colors.black, size: 35),
                  ),
                  // User
                  Marker(
                    point: _userLatLng,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Center(
                        child: Icon(Icons.my_location, color: Colors.blue, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 2. Header Overlay (Fixed Top)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _circleButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'TRACK ORDER',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '#DA-99210',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 40), // Balance spacing
              ],
            ),
          ),

          // 3. Recenter Button (Above Sheet)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).size.height * 0.45, 
            child: FloatingActionButton(
              heroTag: 'recenter',
              backgroundColor: Colors.white,
              onPressed: _recenter,
              child: const Icon(Icons.my_location, color: Color(0xFF8A0000)),
            ),
          ),

          // 4. Draggable Scrollable Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // Drag Handle
                      Container(
                        height: 5,
                        width: 40,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      
                      // Estimated Time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ESTIMATED ARRIVAL',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                  letterSpacing: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '15–20 mins',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8A0000),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8A0000).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'On Time',
                              style: TextStyle(
                                color: Color(0xFF8A0000),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      const Divider(height: 1),
                      const SizedBox(height: 24),

                      // Steps
                      _step(
                        icon: Icons.check_circle,
                        title: 'Order Confirmed',
                        time: '12:30 PM',
                        isActive: true,
                        isLast: false,
                      ),
                      _step(
                        icon: Icons.soup_kitchen,
                        title: 'Preparing',
                        time: '12:45 PM',
                        isActive: true,
                        isLast: false,
                      ),
                      _step(
                        icon: Icons.delivery_dining,
                        title: 'On the way',
                        subtitle: 'Picking up speed',
                        isActive: true,
                        isLast: false,
                      ),
                      _step(
                        icon: Icons.home,
                        title: 'Delivered',
                        isActive: false,
                        isLast: true,
                      ),

                      const SizedBox(height: 24),
                      
                      // Courier Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                                image: const DecorationImage(
                                  image: NetworkImage('https://i.pravatar.cc/150?img=11'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Ricardo G.',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, size: 14, color: Colors.amber),
                                      SizedBox(width: 4),
                                      Text(
                                        '4.9 • Top Courier',
                                        style: TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            _circleIconButton(Icons.message, Colors.blue),
                            const SizedBox(width: 12),
                            _circleIconButton(Icons.call, Colors.green),
                          ],
                        ),
                      ),
                      
                      if (_locationError.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          _locationError,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      
                      // Extra padding for scroll
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.black),
        onPressed: onTap,
      ),
    );
  }

  Widget _circleIconButton(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _step({
    required IconData icon,
    required String title,
    String? subtitle,
    String? time,
    required bool isActive,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF8A0000) : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive ? const Color(0xFF8A0000).withValues(alpha: 0.3) : Colors.grey[200],
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  if (time != null)
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              const SizedBox(height: 30), // Spacing for next step
            ],
          ),
        ),
      ],
    );
  }
}