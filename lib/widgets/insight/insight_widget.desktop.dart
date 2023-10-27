import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:desktop_split_pane/desktop_split_pane.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

class InsightDesktopWidget extends StatelessWidget {
  final String userId;
  final Insight insight;

  const InsightDesktopWidget(this.userId, this.insight, {super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => HorizontalSplitPane(
        constraints: constraints,
        separatorColor: Theme.of(context).dividerColor,
        separatorThickness: 4.0,
        fractions: [0.5, 0.5],
        children: [
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: getValueForScreenType(
                        context: context,
                        mobile: 600,
                        tablet: 900,
                        desktop: 1200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          title: const Text('Launch Ready'),
                          value: insight.launchReady,
                          onChanged: insight.flag == null
                              ? (bool value) {
                                  context
                                      .read<InsightCubit>()
                                      .toggleLaunchReady(userId, insight);
                                }
                              : null, // Disable if flagged
                          subtitle: insight.flag != null
                              ? const Text(
                                  'This insight is flagged. Resolve the flag before launching.')
                              : const Text(''),
                        ),
                        Card(
                          child: ListTile(
                            title: SelectableText(insight.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SelectableText(insight.insight),
                                const SizedBox(height: 8.0),
                                const Text(
                                  "Next Steps:",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SelectableText(insight.nextSteps),
                              ],
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RatingBar.builder(
                              initialRating: insight.rating ?? 0,
                              minRating: 0.5,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                context
                                    .read<InsightCubit>()
                                    .setRating(userId, insight, rating);
                              },
                            ),
                            SizedBox(
                              height: 58,
                              child: Row(
                                children: [
                                  if (insight.flag != null)
                                    IntrinsicWidth(
                                      child: ListTile(
                                        title: Text(
                                            "Flagged for: ${insight.flag!.reason}"),
                                        subtitle: insight.flag!.comment != null
                                            ? Text(
                                                "Comment: ${insight.flag!.comment}")
                                            : null,
                                      ),
                                    ),
                                  MenuAnchor(
                                    alignmentOffset: const Offset(-70, 0),
                                    menuChildren: [
                                      MenuItemButton(
                                        child: const Text("Inaccurate"),
                                        onPressed: () {
                                          context
                                              .read<InsightCubit>()
                                              .flagInsight(userId, insight,
                                                  "Inaccurate");
                                        },
                                      ),
                                      MenuItemButton(
                                        child: const Text("Irrelevant"),
                                        onPressed: () {
                                          context
                                              .read<InsightCubit>()
                                              .flagInsight(userId, insight,
                                                  "Irrelevant");
                                        },
                                      ),
                                      MenuItemButton(
                                        child: const Text("Other"),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (context) {
                                              final commentController =
                                                  TextEditingController();
                                              return AlertDialog(
                                                title: const Text("Comment"),
                                                content: TextFormField(
                                                  controller: commentController,
                                                  maxLines: 5,
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        "Optionally enter more details on why this insight is flagged as other",
                                                    border:
                                                        OutlineInputBorder(),
                                                  ),
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      context
                                                          .read<InsightCubit>()
                                                          .flagInsight(
                                                              userId,
                                                              insight,
                                                              'Other',
                                                              commentController
                                                                  .text);
                                                      Navigator.pop(
                                                          context); // close comment dialog
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
                                    builder: (context, controller, child) =>
                                        AnimatedSwitcher(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      child: insight.flag == null
                                          ? IconButton(
                                              key: const ValueKey(
                                                  'flag_outlined'),
                                              icon: const Icon(
                                                  Icons.flag_outlined),
                                              tooltip: "Flag Insight",
                                              onPressed: () {
                                                if (controller.isOpen) {
                                                  controller.close();
                                                } else {
                                                  controller.open();
                                                }
                                              })
                                          : IconButton(
                                              key: const ValueKey(
                                                  'flag_circle_rounded'),
                                              onPressed: () {
                                                context
                                                    .read<InsightCubit>()
                                                    .removeFlag(
                                                        userId, insight);
                                              },
                                              tooltip: "Remove insight flag",
                                              icon: const Icon(
                                                Icons.flag_rounded,
                                                color: Colors.red,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        TextFormField(
                          onChanged: (value) {
                            context
                                .read<InsightCubit>()
                                .setComment(userId, insight, value);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Comments',
                            alignLabelWithHint: true,
                            hintText: 'Optional',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 132,
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: getValueForScreenType(
                        context: context,
                        mobile: 600,
                        tablet: 900,
                        desktop: 1200,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          "Source Functions:",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                  ),
                  for (var sourceFunction in insight.sourceFunctions) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: getValueForScreenType(
                          context: context,
                          mobile: 600,
                          tablet: 900,
                          desktop: 1200,
                        ),
                      ),
                      child: ListTile(
                        title: Text(sourceFunction.name),
                        // Add code here for Step 2
                      ),
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: _generateColumns(sourceFunction.sourceData),
                          rows: _generateRows(sourceFunction.sourceData),
                        ),
                      ),
                    )
                  ],
                  const SizedBox(
                    height: 132,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
