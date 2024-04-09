class PreviousInsight {
  final String insightId;
  final String title;
  final String insightBody;
  final DateTime createdAt;
  

  PreviousInsight({
    required this.insightId,
    required this.title,
    required this.createdAt,
    required this.insightBody,
  });

  factory PreviousInsight.fromJson(Map<String, dynamic> json) {
    return PreviousInsight(
      insightId: json['insightId'],
      title: json['title'],
      insightBody: json['insightBody'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'insightId': insightId,
      'title': title,
      'insightBody': insightBody,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
