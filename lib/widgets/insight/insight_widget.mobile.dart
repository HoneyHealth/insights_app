import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

class InsightMobileWidget extends StatefulWidget {
  final String userId;
  final Insight insight;

  const InsightMobileWidget(this.userId, this.insight, {super.key});

  @override
  State<InsightMobileWidget> createState() => _InsightMobileWidgetState();
}

class _InsightMobileWidgetState extends State<InsightMobileWidget> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commentController.text = widget.insight.comment ?? "";
  }

  @override
  void didUpdateWidget(InsightMobileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.insight != widget.insight) {
      _commentController.text = widget.insight.comment ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    value: widget.insight.launchReady,
                    onChanged: widget.insight.flag == null
                        ? (bool value) {
                            context.read<InsightCubit>().toggleLaunchReady(
                                widget.userId, widget.insight);
                          }
                        : null, // Disable if flagged
                    subtitle: widget.insight.flag != null
                        ? const Text(
                            'This insight is flagged. Resolve the flag before launching.')
                        : const Text(''),
                  ),
                  Card(
                    child: ListTile(
                      title: SelectableText(widget.insight.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SelectableText(widget.insight.insight),
                          const SizedBox(height: 8.0),
                          const Text(
                            "Next Steps:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SelectableText(widget.insight.nextSteps),
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
                        initialRating: widget.insight.rating ?? 0,
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
                              .setRating(widget.userId, widget.insight, rating);
                        },
                      ),
                      SizedBox(
                        height: 58,
                        child: Row(
                          children: [
                            if (widget.insight.flag != null)
                              IntrinsicWidth(
                                child: ListTile(
                                  title: Text(
                                      "Flagged for: ${widget.insight.flag!.reason}"),
                                  subtitle: widget.insight.flag!.comment != null
                                      ? Text(
                                          "Comment: ${widget.insight.flag!.comment}")
                                      : null,
                                ),
                              ),
                            MenuAnchor(
                              alignmentOffset: const Offset(-70, 0),
                              menuChildren: [
                                MenuItemButton(
                                  child: const Text("Inaccurate"),
                                  onPressed: () {
                                    context.read<InsightCubit>().flagInsight(
                                        widget.userId,
                                        widget.insight,
                                        "Inaccurate");
                                  },
                                ),
                                MenuItemButton(
                                  child: const Text("Irrelevant"),
                                  onPressed: () {
                                    context.read<InsightCubit>().flagInsight(
                                        widget.userId,
                                        widget.insight,
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
                                            decoration: const InputDecoration(
                                              hintText:
                                                  "Optionally enter more details on why this insight is flagged as other",
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () {
                                                context
                                                    .read<InsightCubit>()
                                                    .flagInsight(
                                                        widget.userId,
                                                        widget.insight,
                                                        'Other',
                                                        commentController.text);
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
                                duration: const Duration(milliseconds: 300),
                                child: widget.insight.flag == null
                                    ? IconButton(
                                        key: const ValueKey('flag_outlined'),
                                        icon: const Icon(Icons.flag_outlined),
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
                                              .removeFlag(widget.userId,
                                                  widget.insight);
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
                    controller: _commentController,
                    onChanged: (value) {
                      context
                          .read<InsightCubit>()
                          .setComment(widget.userId, widget.insight, value);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      alignLabelWithHint: true,
                      hintText: 'Optional',
                    ),
                  ),
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
            for (var sourceFunction in widget.insight.sourceFunctions) ...[
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
