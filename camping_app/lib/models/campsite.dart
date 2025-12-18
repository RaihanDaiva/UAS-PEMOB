// ===========================================
// CAMPSITE MODEL
// ===========================================
// File: lib/models/campsite.dart

class Campsite {
  final int id;
  final String name;
  final String description;
  final String locationName;
  final double latitude;
  final double longitude;
  final int capacity;
  final double pricePerNight;
  final String facilities;
  final String? imageUrl;
  final bool isActive;

  Campsite({
    required this.id,
    required this.name,
    required this.description,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.capacity,
    required this.pricePerNight,
    required this.facilities,
    this.imageUrl,
    required this.isActive,
  });

  factory Campsite.fromJson(Map<String, dynamic> json) {
    return Campsite(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      locationName: json['location_name'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      capacity: json['capacity'],
      pricePerNight: (json['price_per_night'] as num).toDouble(),
      facilities: json['facilities'] ?? '',
      imageUrl: json['image_url'],
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'price_per_night': pricePerNight,
      'facilities': facilities,
      'image_url': imageUrl,
      'is_active': isActive,
    };
  }

  String get formattedPrice {
    return 'Rp ${pricePerNight.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]}.'
    )}';
  }

  List<String> get facilitiesList {
    return facilities.split(',').map((e) => e.trim()).toList();
  }
}
