class AdminStats {
  final int users;
  final int queues;
  final int sectors;
  final String uptime;

  AdminStats({
    required this.users,
    required this.queues,
    required this.sectors,
    required this.uptime,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      users: json['users'] ?? 0,
      queues: json['queues'] ?? 0,
      sectors: json['sectors'] ?? 0,
      uptime: json['uptime'] ?? '0%',
    );
  }
}
