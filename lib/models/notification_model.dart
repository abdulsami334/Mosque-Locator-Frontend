class NotificationModel {
  final String id;
  final String message;
  final String status; // unread / read
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'],
      message: json['message'] ?? '',
      status: json['status'] ?? 'unread',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
