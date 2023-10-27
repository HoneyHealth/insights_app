import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'insight_widget.mobile.dart';
import 'insight_widget.desktop.dart';

class InsightWidget extends StatelessWidget {
  final String userId;
  final Insight insight;

  const InsightWidget(this.userId, this.insight, {super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenTypeLayout.builder(
      mobile: (_) => InsightMobileWidget(userId, insight),
      desktop: (_) => InsightDesktopWidget(userId, insight),
    );
  }

  void _showFlagOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Flag Reason"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text("Inaccurate"),
              onTap: () {
                context
                    .read<InsightCubit>()
                    .flagInsight(userId, insight, "Inaccurate");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Irrelevant"),
              onTap: () {
                context
                    .read<InsightCubit>()
                    .flagInsight(userId, insight, "Irrelevant");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text("Other"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final commentController = TextEditingController();
                    return AlertDialog(
                      title: const Text("Comment"),
                      content: TextFormField(
                        controller: commentController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "Enter your comment here",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<InsightCubit>().flagInsight(userId,
                                insight, 'Other', commentController.text);
                            Navigator.pop(context); // close comment dialog
                            Navigator.pop(context); // close flag options dialog
                          },
                          child: const Text("Submit"),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DataColumn> _generateColumns(Map<String, dynamic> sourceData) {
    var columns = [const DataColumn(label: Text(''))];
    columns.addAll(sourceData.keys.map((key) => DataColumn(label: Text(key))));
    return columns;
  }

  List<DataRow> _generateRows(Map<String, dynamic> sourceData) {
    if (sourceData.isEmpty) return [];

    var firstEntry = sourceData.entries.first.value as Map<String, dynamic>;
    return firstEntry.keys.map((originalColumn) {
      var cells = [
        DataCell(
          Text(
            originalColumn,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ]; // Bolded the text
      cells.addAll(sourceData.entries.map((entry) {
        var value = (entry.value as Map<String, dynamic>)[originalColumn];
        return DataCell(Text(value.toString()));
      }).toList());

      return DataRow(cells: cells);
    }).toList();
  }
}
