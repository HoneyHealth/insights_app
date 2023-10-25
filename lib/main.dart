import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models.dart';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: JsonInputPage(),
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
      body: const JsonInputWidget(),
    );
  }
}

class _JsonInputWidgetState extends State<JsonInputWidget> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (insight.flag != null)
          ListTile(
            title: Text("Flagged for: ${insight.flag!.reason}"),
            subtitle: insight.flag!.comment != null
                ? Text("Comment: ${insight.flag!.comment}")
                : null,
            trailing: ElevatedButton(
              onPressed: () {
                context.read<InsightCubit>().removeFlag(userId, insight);
              },
              child: const Text("Unflag"),
            ),
          )
        else
          IconButton(
            icon: Icon(Icons.flag),
            onPressed: () => _showFlagOptions(context),
          ),
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
              ? Text(
                  'This insight is flagged. Resolve the flag before launching.')
              : null,
        ),
        ListTile(
          title: Text(insight.title),
          subtitle: Text(insight.insight),
        ),
        RatingBar.builder(
          initialRating: insight.rating ?? 0,
          minRating: 0.5,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: Colors.amber,
          ),
          onRatingUpdate: (rating) {
            context.read<InsightCubit>().setRating(userId, insight, rating);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Rating saved!")),
            );
          },
        ),
        TextField(
          onChanged: (value) {
            context.read<InsightCubit>().setFeedback(userId, insight, value);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Feedback saved!")),
            );
          },
          decoration: const InputDecoration(
            labelText: 'Feedback',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            // Handle saving the rating and feedback
          },
          child: const Text("Save"),
        ),
        const Text("Source Functions:"),
        for (var sourceFunction in insight.sourceFunctions) ...[
          ListTile(
            title: Text(sourceFunction.name),
            // Add code here for Step 2
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
      ],
    );
  }

  void _showFlagOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Flag Reason"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text("Inaccurate"),
              onTap: () {
                context
                    .read<InsightCubit>()
                    .flagInsight(userId, insight, "Inaccurate");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Irrelevant"),
              onTap: () {
                context
                    .read<InsightCubit>()
                    .flagInsight(userId, insight, "Irrelevant");
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Other"),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    final _commentController = TextEditingController();
                    return AlertDialog(
                      title: Text("Comment"),
                      content: TextField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: "Enter your comment here",
                        ),
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<InsightCubit>().flagInsight(userId,
                                insight, 'Other', _commentController.text);
                            Navigator.pop(context); // close comment dialog
                            Navigator.pop(context); // close flag options dialog
                          },
                          child: Text("Submit"),
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
    var columns = [DataColumn(label: Text(''))];
    columns.addAll(sourceData.keys.map((key) => DataColumn(label: Text(key))));
    return columns;
  }

  List<DataRow> _generateRows(Map<String, dynamic> sourceData) {
    if (sourceData.isEmpty) return [];

    var firstEntry = sourceData.entries.first.value as Map<String, dynamic>;
    return firstEntry.keys.map((originalColumn) {
      var cells = [
        DataCell(
            Text(originalColumn, style: TextStyle(fontWeight: FontWeight.bold)))
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
  _UserInsightsPageState createState() => _UserInsightsPageState();
}

class _UserInsightsPageState extends State<UserInsightsPage> {
  int currentInsightIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Insights for ${widget.userId}"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          var insights = state.userInsights[widget.userId]?.insights ?? [];

          if (insights.isEmpty) return Text("No insights available.");

          return Column(
            children: [
              InsightWidget(widget.userId, insights[currentInsightIndex]),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentInsightIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentInsightIndex--;
                        });
                      },
                      child: Text("Previous"),
                    ),
                  ElevatedButton(
                    onPressed: () {
                      if (currentInsightIndex < insights.length - 1) {
                        setState(() {
                          currentInsightIndex++;
                        });
                      } else {
                        // Otherwise, navigate to summary for the current user
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InsightSummaryPage(userId: widget.userId),
                          ),
                        );
                      }
                    },
                    child: Text(currentInsightIndex < insights.length - 1
                        ? "Next"
                        : "Summary"),
                  ),
                ],
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
        title: Text("Summary for ${userId}"),
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
        child: Icon(Icons.arrow_forward),
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
        title: Text("Overall Insights Summary"),
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
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
