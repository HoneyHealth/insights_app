import 'package:flutter/material.dart';
import 'package:insights_app/models/models.dart';
import 'package:intl/intl.dart';


class PreviousInsightWidget extends StatelessWidget {
  final PreviousInsight previousInsight;

  const PreviousInsightWidget({
    super.key,
    required this.previousInsight,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              previousInsight.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8.0),
            Text(
              DateFormat('yyyy-MM-dd – kk:mm').format(previousInsight.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8.0),
            Text(previousInsight.insightBody),
          ],
        ),
      ),
    );
  }
}
