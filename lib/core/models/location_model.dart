class CampusLocation {
  final String id;
  final String name;
  final String? description;
  final String? buildingCode;
  final double lat;
  final double lng;
  final String? category;
  final String? floorInfo;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CampusLocation({
    required this.id,
    required this.name,
    this.description,
    this.buildingCode,
    required this.lat,
    required this.lng,
    this.category,
    this.floorInfo,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory CampusLocation.fromJson(Map<String, dynamic> json) {
    return CampusLocation(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      buildingCode: json['building_code'] as String?,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      category: json['category'] as String?,
      floorInfo: json['floor_info'] as String?,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'building_code': buildingCode,
      'lat': lat,
      'lng': lng,
      'category': category,
      'floor_info': floorInfo,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get categoryIcon {
    switch (category?.toLowerCase()) {
      case 'academic':
        return '🏫';
      case 'library':
        return '📚';
      case 'cafeteria':
        return '🍽️';
      case 'hostel':
        return '🏠';
      case 'sports':
        return '⚽';
      case 'admin':
        return '🏢';
      default:
        return '📍';
    }
  }
}
