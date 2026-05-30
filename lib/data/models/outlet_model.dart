/// Dart model representation of the `outlets` collection in PocketBase.
class OutletModel {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final bool isOpen;
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
    required this.isOpen,
    required this.operationalHours,
    this.hasPickup = true,
    this.hasDelivery = true,
    this.hasDineIn = false,
  });

  /// Factory constructor to create an [OutletModel] from a JSON map (PocketBase Record fields).
  factory OutletModel.fromJson(Map<String, dynamic> json) {
    return OutletModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      isOpen: json['is_open'] as bool? ?? true,
      operationalHours: json['operational_hours'] as String? ?? '08:00 - 22:00',
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
      'is_open': isOpen,
      'operational_hours': operationalHours,
      'has_pickup': hasPickup,
      'has_delivery': hasDelivery,
      'has_dine_in': hasDineIn,
    };
  }
}
