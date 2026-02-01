import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await _handleLocationPermission();
      if (!hasPermission) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting position: $e');
      return null;
    }
  }

  Future<String?> getCurrentAddress() async {
    try {
      final position = await getCurrentPosition();
      if (position == null) {
        return null;
      }

      return await getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('Location services are disabled.');
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('Location permissions are denied');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    return true;
  }

  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return formatAddress(place);
      }
    } catch (e) {
      debugPrint('Error decoding coordinates: $e');
    }
    return "Unknown Location";
  }

  String formatAddress(Placemark place) {
    List<String> parts = [];

    // Prioritize street address
    if (place.street != null && place.street!.isNotEmpty) {
      parts.add(place.street!);
    } else {
       // Fallback to components if street is empty
       if (place.name != null && place.name!.isNotEmpty) parts.add(place.name!);
       if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) parts.add(place.thoroughfare!);
    }

    // Add neighborhood/sublocality
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
       if (!parts.contains(place.subLocality)) parts.add(place.subLocality!);
    }
    
    // Add city/locality
    if (place.locality != null && place.locality!.isNotEmpty) {
       if (!parts.contains(place.locality)) parts.add(place.locality!);
    }
    
    // Add state/province/admin area
    if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
       if (!parts.contains(place.administrativeArea)) parts.add(place.administrativeArea!);
    }

    // Add country
    if (place.country != null && place.country!.isNotEmpty) {
       if (!parts.contains(place.country)) parts.add(place.country!);
    }

    return parts.where((p) => p.trim().isNotEmpty).join(', ');
  }
}
