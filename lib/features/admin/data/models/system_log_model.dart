class SystemLog {
  final String id;
  final String action;
  final String details;
  final DateTime createdAt;
  final String? userName;
  final String? userRole;

  SystemLog({
    required this.id,
    required this.action,
    required this.details,
    required this.createdAt,
    this.userName,
    this.userRole,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      id: json['id'],
      action: json['action'],
      details: json['details'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      userName: json['user']?['name'],
      userRole: json['user']?['role'],
    );
  }
}
