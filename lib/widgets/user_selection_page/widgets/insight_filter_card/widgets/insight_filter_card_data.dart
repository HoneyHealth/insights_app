import 'package:flutter/widgets.dart';

class InsightFilterCardData extends StatelessWidget {
  final String title;
  final int count;
  final int total;

  const InsightFilterCardData({
    super.key,
    required this.title,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 8),
          Text(
            "$count / $total",
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
