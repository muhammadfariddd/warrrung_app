/// Dart model representation of the `outlets` collection in PocketBase.
class OutletModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isActive;
  final String openTime;
  final String closeTime;
  final String operationalHours;
  final bool hasPickup;
  final bool hasDelivery;
  final bool hasDineIn;

  OutletModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.isActive,
    required this.openTime,
    required this.closeTime,
    required this.operationalHours,
    this.hasPickup = true,
    this.hasDelivery = true,
    this.hasDineIn = false,
  });

  /// Dynamically computes if the outlet is currently open based on active state and operational hours.
  bool get isOpen {
    if (!isActive) return false;

    try {
      final now = DateTime.now();
      
      // Parse openTime (e.g., "08:00")
      final openParts = openTime.split(':');
      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      
      // Parse closeTime (e.g., "22:00")
      final closeParts = closeTime.split(':');
      final closeHour = int.parse(closeParts[0]);
      final closeMinute = int.parse(closeParts[1]);
      
      final openDateTime = DateTime(now.year, now.month, now.day, openHour, openMinute);
      var closeDateTime = DateTime(now.year, now.month, now.day, closeHour, closeMinute);
      
      // Handle overnight closing hours (e.g., open 22:00, close 03:00 next day)
      if (closeDateTime.isBefore(openDateTime)) {
        if (now.isBefore(closeDateTime)) {
          final prevDayOpen = openDateTime.subtract(const Duration(days: 1));
          return now.isAfter(prevDayOpen);
        } else {
          closeDateTime = closeDateTime.add(const Duration(days: 1));
        }
      }
      
      return now.isAfter(openDateTime) && now.isBefore(closeDateTime);
    } catch (_) {
      // Fallback if parsing fails
      return true;
    }
  }

  /// Returns the text to be displayed in the Red Operational Hours Badge when the outlet is closed.
  String get closedStatusText {
    if (!isActive) return 'TUTUP';

    try {
      final now = DateTime.now();
      
      final openParts = openTime.split(':');
      final openHour = int.parse(openParts[0]);
      final openMinute = int.parse(openParts[1]);
      
      final openDateTime = DateTime(now.year, now.month, now.day, openHour, openMinute);
      
      if (now.isBefore(openDateTime)) {
        return 'BUKA JAM $openTime';
      } else {
        return 'BUKA BESOK JAM $openTime';
      }
    } catch (_) {
      return 'TUTUP';
    }
  }

  /// Factory constructor to create an [OutletModel] from a JSON map (PocketBase Record fields).
  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      openTime: json['open_time'] as String? ?? '08:00',
      closeTime: json['close_time'] as String? ?? '22:00',
      operationalHours: json['operational_hours'] as String? ?? 'BUKA - TUTUP JAM 22:00',
      hasPickup: json['has_pickup'] as bool? ?? true,
      hasDelivery: json['has_delivery'] as bool? ?? true,
      hasDineIn: json['has_dine_in'] as bool? ?? false,
    );
  }

  /// Converts the [OutletModel] instance back into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'open_time': openTime,
      'close_time': closeTime,
      'operational_hours': operationalHours,
      'has_pickup': hasPickup,
      'has_delivery': hasDelivery,
      'has_dine_in': hasDineIn,
    };
  }
}
