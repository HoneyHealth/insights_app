import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

void main() {
  final insightCubit = InsightCubit(AllUsersInsights(userInsights: {}));

  runApp(
    BlocProvider(
      create: (context) => insightCubit,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insights Review Application',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const JsonInputPage(),
    );
  }
}

class JsonInputPage extends StatelessWidget {
  const JsonInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Load Insights JSON"),
      ),
      body: const Center(
        child: JsonInputWidget(),
      ),
    );
  }
}

class _JsonInputWidgetState extends State<JsonInputWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: getValueForScreenType(
            context: context,
            mobile: 600,
            tablet: 900,
            desktop: 1200,
          ),
        ),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: 'Paste your JSON here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _loadJson(context);
              },
              child: const Text("Load JSON"),
            ),
          ],
        ),
      ),
    );
  }

  void _loadJson(BuildContext context) {
    final jsonStr = _controller.text;
    final jsonData = json.decode(jsonStr) as Map<String, dynamic>;

    final newInsights = AllUsersInsights.fromJson(jsonData);

    // Emit the new insights data to the InsightCubit
    final cubit = context.read<InsightCubit>();
    cubit.updateInsights(newInsights);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: cubit,
          child: const UserSelectionPage(),
        ),
      ),
    );
  }
}

class JsonInputWidget extends StatefulWidget {
  const JsonInputWidget({
    super.key,
  });

  @override
  State<JsonInputWidget> createState() => _JsonInputWidgetState();
}

class InsightWidget extends StatelessWidget {
  final String userId;
  final Insight insight;

  const InsightWidget(this.userId, this.insight, {super.key});

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
                      title: Text(insight.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(insight.insight),
                          const SizedBox(height: 8.0),
                          const Text(
                            "Next Steps:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(insight.nextSteps),
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
                                    context.read<InsightCubit>().flagInsight(
                                        userId, insight, "Inaccurate");
                                  },
                                ),
                                MenuItemButton(
                                  child: const Text("Irrelevant"),
                                  onPressed: () {
                                    context.read<InsightCubit>().flagInsight(
                                        userId, insight, "Irrelevant");
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
                                                        userId,
                                                        insight,
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
                                child: insight.flag == null
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
                                              .removeFlag(userId, insight);
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
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Comments',
                      alignLabelWithHint: true,
                      hintText: 'Optional',
                      border: OutlineInputBorder(),
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

class UserSelectionPage extends StatelessWidget {
  const UserSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a User"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView(
            children: state.userInsights.keys.map((userId) {
              return ListTile(
                title: Text(userId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserInsightsPage(userId: userId),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserInsightsPage extends StatefulWidget {
  final String userId;

  const UserInsightsPage({required this.userId, super.key});

  @override
  State<UserInsightsPage> createState() => _UserInsightsPageState();
}

class _UserInsightsPageState extends State<UserInsightsPage> {
  int currentInsightIndex = 0;

  String getUserProgressText() {
    final cubit = context.read<InsightCubit>();
    final allUsers = cubit.state.userInsights.keys.toList();
    final currentUserIndex = allUsers.indexOf(widget.userId);

    return "${currentUserIndex + 1}/${allUsers.length} users";
  }

  String getInsightProgressText() {
    final insights = context
            .read<InsightCubit>()
            .state
            .userInsights[widget.userId]
            ?.insights ??
        [];
    return "${currentInsightIndex + 1}/${insights.length} insights";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights for ${widget.userId}"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          var insights = state.userInsights[widget.userId]?.insights ?? [];

          if (insights.isEmpty) return const Text("No insights available.");

          return Column(
            children: [
              Expanded(
                child:
                    InsightWidget(widget.userId, insights[currentInsightIndex]),
              ),
              BottomAppBar(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: min(
                          MediaQuery.of(context).size.width - 32,
                          getValueForScreenType(
                            context: context,
                            mobile: 600 - 32,
                            tablet: 900 - 32,
                            desktop: 1200 - 32,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (currentInsightIndex > 0)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      currentInsightIndex--;
                                    });
                                  },
                                  child: const Text("Previous"),
                                )
                              else
                                const SizedBox.shrink(),
                              Text(getUserProgressText(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text(getInsightProgressText(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ElevatedButton(
                                onPressed: () {
                                  if (currentInsightIndex <
                                      insights.length - 1) {
                                    setState(() {
                                      currentInsightIndex++;
                                    });
                                  } else {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            InsightSummaryPage(
                                                userId: widget.userId),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                    currentInsightIndex < insights.length - 1
                                        ? "Next"
                                        : "Summary"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class InsightSummaryPage extends StatelessWidget {
  final String userId;

  const InsightSummaryPage({required this.userId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Summary for $userId"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          final insights = state.userInsights[userId]?.insights ?? [];

          return ListView.builder(
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return ListTile(
                title: Text(insight.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(insight.rating != null
                        ? insight.rating!.toStringAsFixed(
                            insight.rating!.truncateToDouble() ==
                                    insight.rating!
                                ? 0
                                : 1)
                        : 'Not Rated'),
                    const SizedBox(width: 10),
                    if (insight.launchReady)
                      const Icon(Icons.launch, color: Colors.green),
                    if (insight.flag != null)
                      const Icon(
                        Icons.flag_rounded,
                        color: Colors.red,
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the next user's insights or go back to user selection if it's the last user
          final cubit = context.read<InsightCubit>();
          final allUsers = cubit.state.userInsights.keys.toList();
          final currentUserIndex = allUsers.indexOf(userId);

          if (currentUserIndex < allUsers.length - 1) {
            final nextUser = allUsers[currentUserIndex + 1];
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => UserInsightsPage(userId: nextUser),
              ),
            );
          } else {
            // If it's the last user, navigate to overall summary
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const OverallInsightSummaryPage(),
              ),
            );
          }
        },
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

class OverallInsightSummaryPage extends StatelessWidget {
  const OverallInsightSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Overall Insights Summary"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.userInsights.keys.length,
            itemBuilder: (context, index) {
              final userId = state.userInsights.keys.elementAt(index);
              final insights = state.userInsights[userId]?.insights ?? [];
              return ExpansionTile(
                title: Text("User: $userId"),
                children: insights.map((insight) {
                  return ListTile(
                    title: Text(insight.title),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(insight.rating != null
                            ? insight.rating!.toStringAsFixed(
                                insight.rating!.truncateToDouble() ==
                                        insight.rating!
                                    ? 0
                                    : 1)
                            : 'Not Rated'),
                        const SizedBox(width: 10),
                        if (insight.launchReady)
                          const Icon(Icons.launch, color: Colors.green),
                        if (insight.flag != null)
                          const Icon(
                            Icons.flag_rounded,
                            color: Colors.red,
                          ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exportToJson(context);
        },
        child: const Icon(Icons.download),
        tooltip: "Export to JSON",
      ),
    );
  }

  void _exportToJson(BuildContext context) async {
    final config = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExportConfigPage(config: ExportConfig()),
      ),
    );

    if (config != null) {
      final modifiedState =
          _applyExportConfig(config, context.read<InsightCubit>().state);
      final jsonString = jsonEncode(modifiedState.toJson());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Exported JSON"),
          content: SingleChildScrollView(
            child: SelectableText(jsonString),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        ),
      );
    }
  }
}

AllUsersInsights _applyExportConfig(
    ExportConfig config, AllUsersInsights originalState) {
  // Check if insights is selected
  if (!config.insights) return AllUsersInsights(userInsights: {});

  // Clone the original state
  final clonedState = AllUsersInsights(
    userInsights: Map.fromEntries(
      originalState.userInsights.entries.map(
        (e) => MapEntry(
          e.key,
          UserInsight(
            insights: e.value.insights.map(
              (insight) {
                return Insight(
                  steps: insight.steps,
                  title: config.title ? insight.title : '',
                  insight: config.insightText ? insight.insight : '',
                  nextSteps: config.nextSteps ? insight.nextSteps : '',
                  sourceFunctions: config.sourceFunctions
                      ? insight.sourceFunctions.map(
                          (sf) {
                            return SourceFunction(
                              name: config.sourceName ? sf.name : '',
                              sourceData:
                                  config.sourceData ? sf.sourceData : {},
                            );
                          },
                        ).toList()
                      : [],
                  lastGlucoseDataPointTimestampForInsight:
                      insight.lastGlucoseDataPointTimestampForInsight,
                  rating: insight.rating,
                  comment: insight.comment,
                  launchReady: insight.launchReady,
                  flag: insight.flag,
                );
              },
            ).toList(),
          ),
        ),
      ),
    ),
  );

  return clonedState;
}

class ExportConfigPage extends StatefulWidget {
  final ExportConfig config;

  ExportConfigPage({required this.config, super.key});

  @override
  _ExportConfigPageState createState() => _ExportConfigPageState();
}

class _ExportConfigPageState extends State<ExportConfigPage> {
  late ExportConfig config;

  @override
  void initState() {
    super.initState();
    config = widget.config;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Configuration"),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text("Insights"),
            value: config.insights,
            onChanged: (value) {
              setState(() {
                config.toggleInsights(value);
              });
            },
          ),
          buildChildTile(
              "User Insight", config.userInsight, config.toggleUserInsight),
          buildChildTile("Title", config.title,
              (value) => setState(() => config.title = value), 2),
          buildChildTile("Insight", config.insightText,
              (value) => setState(() => config.insightText = value), 2),
          buildChildTile("Next Steps", config.nextSteps,
              (value) => setState(() => config.nextSteps = value), 2),
          buildChildTile("Source Functions", config.sourceFunctions,
              config.toggleSourceFunctions, 2),
          buildChildTile("Source Name", config.sourceName,
              (value) => setState(() => config.sourceName = value), 4),
          buildChildTile("Source Data", config.sourceData,
              (value) => setState(() => config.sourceData = value), 4),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () {
          Navigator.pop(context, config);
        },
      ),
    );
  }

  Widget buildChildTile(String title, bool value, Function(bool) onChanged,
      [int indentFactor = 1]) {
    return SwitchListTile(
      title: Padding(
        padding: EdgeInsets.only(left: 24.0 * indentFactor),
        child: Text(title),
      ),
      value: value,
      onChanged: (value) {
        setState(() {
          onChanged(value);
        });
      },
    );
  }
}
