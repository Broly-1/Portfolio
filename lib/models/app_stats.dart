class AppStats {
  final String id;
  final int iosDownloads;
  final int androidDownloads;
  final DateTime lastUpdated;

  AppStats({
    required this.id,
    required this.iosDownloads,
    required this.androidDownloads,
    required this.lastUpdated,
  });

  factory AppStats.fromFirestore(Map<String, dynamic> data, String id) {
    return AppStats(
      id: id,
      iosDownloads: data['iosDownloads'] ?? 0,
      androidDownloads: data['androidDownloads'] ?? 0,
      lastUpdated: data['lastUpdated']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'iosDownloads': iosDownloads,
      'androidDownloads': androidDownloads,
      'lastUpdated': lastUpdated,
    };
  }
}
