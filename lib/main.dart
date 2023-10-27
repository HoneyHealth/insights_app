import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';
import 'package:insights_app/user_insights_page.dart';
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
