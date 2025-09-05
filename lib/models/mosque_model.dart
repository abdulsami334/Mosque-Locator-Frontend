class Coordinates {
  final double lat;
  final double lng;

  Coordinates({
    required this.lat,
    required this.lng,
  });

  factory Coordinates.fromJson(Map<String, dynamic> json) {
    // Case 1: Direct lat/lng
    if (json.containsKey('lat') && json.containsKey('lng')) {
      return Coordinates(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
    }
    // Case 2: GeoJSON style { type: "Point", coordinates: [lng, lat] }
    else if (json.containsKey('coordinates') && json['coordinates'] is List) {
      final coords = json['coordinates'] as List;
      if (coords.length >= 2) {
        return Coordinates(
          lat: (coords[1] as num).toDouble(),
          lng: (coords[0] as num).toDouble(),
        );
      }
    }
    return Coordinates(lat: 0.0, lng: 0.0);
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
  final String status;

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
    required this.status,
  });

  factory MosqueModel.fromJson(Map<String, dynamic> json) {
    Coordinates coords;

    // Agar backend 'coordinates' deta hai
    if (json['coordinates'] != null) {
      coords = Coordinates.fromJson(json['coordinates']);
    }
    // Agar backend 'location' deta hai
    else if (json['location'] != null) {
      coords = Coordinates.fromJson(json['location']);
    } else {
      coords = Coordinates(lat: 0.0, lng: 0.0);
    }

    return MosqueModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      coordinates: coords,
      prayerTimes: Map<String, dynamic>.from(json['prayerTimes'] ?? {}),
      amenities: Map<String, dynamic>.from(json['amenities'] ?? {}),
      photos: List<String>.from(json['photos'] ?? []),
      status: json['status'] ?? false,
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
        'status': status,
      };
}
