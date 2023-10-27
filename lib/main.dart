import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'color_schemes.g.dart';

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
      theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
      darkTheme: ThemeData(useMaterial3: true, colorScheme: darkColorScheme),
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
    [] + [];
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a User"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView(
            children: [
              ...state.userInsights.keys.map(
                (userId) {
                  return ListTile(
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text(
                      userId,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserInsightsPage(userId: userId),
                        ),
                      );
                    },
                  );
                },
              ).toList(),
              const SizedBox(
                height: 132,
              ),
            ],
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
                                const SizedBox(
                                  width: 108,
                                ),
                              getValueForScreenType(
                                context: context,
                                mobile: Column(
                                  children: [
                                    Text(
                                      getUserProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      getInsightProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                tablet: Row(children: [
                                  Text(getUserProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text(getInsightProgressText(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ]),
                              ),
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
        onPressed: () => _showExportConfigDialog(context),
        child: const Icon(Icons.download),
        tooltip: "Export to JSON",
      ),
    );
  }

  Future<void> _showExportConfigDialog(BuildContext context) async {
    final cubit = context.read<InsightCubit>();
    final config = await showDialog<ExportConfig>(
      context: context,
      builder: (BuildContext context) =>
          ExportConfigPage(config: cubit.exportConfig), // Updated this line
    );

    if (config != null) {
      // Update the cubit's exportConfig
      cubit.exportConfig = config;
      // Directly use the config in the toJson method
      final jsonString =
          jsonEncode(context.read<InsightCubit>().state.toJson(config));

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ExportedJsonPage(jsonString: jsonString),
        ),
      );
    }
  }
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
    return AlertDialog(
      title: Text('Export Configuration'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            SwitchListTile(
              title: Text("Export Launch Ready Insights Only"),
              value: config.exportLaunchReadyOnly,
              onChanged: (value) {
                setState(() {
                  config.exportLaunchReadyOnly = value;
                });
              },
            ),
            buildChildTile("Insights", config.insights, 'insights'),
            buildChildTile(
                "User Insight", config.userInsight, 'userInsight', 1),
            buildChildTile("Title", config.title, 'title', 2),
            buildChildTile("Insight", config.insightText, 'insightText', 2),
            buildChildTile("Next Steps", config.nextSteps, 'nextSteps', 2),
            buildChildTile("Source Functions", config.sourceFunctions,
                'sourceFunctions', 2),
            buildChildTile("Source Name", config.sourceName, 'sourceName', 3),
            buildChildTile("Source Data", config.sourceData, 'sourceData', 3),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Save the export config and close the dialog
            Navigator.of(context).pop(config);
          },
          child: Text('Export'),
        ),
      ],
    );
  }

  Widget buildChildTile(String title, CheckState checkState, String itemName,
      [int indentLevel = 0]) {
    bool? isChecked;
    if (checkState == CheckState.checked) {
      isChecked = true;
    } else if (checkState == CheckState.halfChecked) {
      isChecked = null;
    } else {
      isChecked = false;
    }

    return CheckboxListTile(
      contentPadding: EdgeInsets.only(left: 20.0 * indentLevel),
      value: isChecked,
      onChanged: (val) {
        setState(() {
          config.toggleItem(_toggleCheckState(checkState), itemName);
        });
      },
      title: Text(title),
      controlAffinity: ListTileControlAffinity.leading,
      tristate: true,
    );
  }

  CheckState _toggleCheckState(CheckState current) {
    if (current == CheckState.checked) {
      return CheckState.unchecked;
    } else {
      return CheckState.checked;
    }
  }
}

class ExportedJsonPage extends StatefulWidget {
  final String jsonString;

  const ExportedJsonPage({required this.jsonString, super.key});

  @override
  State<ExportedJsonPage> createState() => _ExportedJsonPageState();
}

class _ExportedJsonPageState extends State<ExportedJsonPage> {
  bool _copied = false;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exported JSON"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: getValueForScreenType(
                context: context,
                mobile: 600,
                tablet: 900,
                desktop: 1200,
              ),
            ),
            padding: const EdgeInsets.only(
              left: 16.0,
              right: 16.0,
              top: 8.0,
              bottom: 132,
            ),
            child: SelectableText(
              JsonEncoder.withIndent('  ').convert(
                json.decode(widget.jsonString),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Clipboard.setData(ClipboardData(text: widget.jsonString));
          setState(() {
            _copied = true;
          });
          _timer = Timer(Duration(seconds: 5), () {
            // Step 3: Assign the timer to the _timer instance
            if (mounted) {
              // Ensure the widget is still in the tree
              setState(() {
                _copied = false;
              });
            }
          });
        },
        label: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: _copied
              ? Row(
                  key: ValueKey<int>(
                      1), // To ensure the AnimatedSwitcher recognizes the change
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 5),
                    Text("Copied"),
                  ],
                )
              : Row(
                  key: ValueKey<int>(
                      2), // To ensure the AnimatedSwitcher recognizes the change
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 5),
                    Text("Copy"),
                  ],
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Step 2: Cancel the timer when disposing the widget
    super.dispose();
  }
}
