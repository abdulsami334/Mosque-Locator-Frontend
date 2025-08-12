class UserModel {
  final String? id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String city;
  final String area;
  final String reason;
  final bool approved;
final bool? isContributor;
  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.city,
    required this.area,
    required this.reason,
    this.approved = false,
    this.isContributor
  });

  // ✅ Convert JSON → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone'] ?? '',
      city: json['city'] ?? '',
      area: json['area'] ?? '',
      reason: json['reason'] ?? '',
      approved: json['approved'] ?? false,
      isContributor: json['isContributor']?? false
    );
  }

  // ✅ Convert Model → JSON
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password,
      "phone": phone,
      "city": city,
      "area": area,
      "reason": reason,
      "approved": approved,
      "isContributor":isContributor
    };
  }
}
