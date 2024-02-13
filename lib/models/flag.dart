class Flag {
  final String reason;
  final String? comment; // Optional comment for "Other" reason

  Flag({required this.reason, this.comment});

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'comment': comment,
      };
}
