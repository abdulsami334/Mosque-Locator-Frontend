class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    return Coordinates(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
      };
}

class MosqueModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String area;
  final Coordinates coordinates;
  final Map<String, dynamic> prayerTimes;
  final Map<String, dynamic> amenities;
  final List<String> photos;
  final bool verified;

  MosqueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.area,
    required this.coordinates,
    required this.prayerTimes,
    required this.amenities,
    required this.photos,
    required this.verified,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    return MosqueModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      coordinates: json['coordinates'] != null
          ? Coordinates.fromJson(json['coordinates'])
          : Coordinates(lat: 0.0, lng: 0.0),
      prayerTimes: Map<String, dynamic>.from(json['prayerTimes'] ?? {}),
      amenities: Map<String, dynamic>.from(json['amenities'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      verified: json['verified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'address': address,
        'city': city,
        'area': area,
        'coordinates': coordinates.toJson(),
        'prayerTimes': prayerTimes,
        'amenities': amenities,
        'photos': photos,
        'verified': verified,
      };
}

