import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
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
    final materialLightTheme =
        ThemeData(useMaterial3: true, colorScheme: lightColorScheme);
    final materialDarkTheme =
        ThemeData(useMaterial3: true, colorScheme: darkColorScheme);

    final cupertinoLightTheme =
        MaterialBasedCupertinoThemeData(materialTheme: materialLightTheme);
    const darkDefaultCupertinoTheme =
        CupertinoThemeData(brightness: Brightness.dark);
    final cupertinoDarkTheme = MaterialBasedCupertinoThemeData(
      materialTheme: materialDarkTheme.copyWith(
        cupertinoOverrideTheme: CupertinoThemeData(
          brightness: Brightness.dark,
          barBackgroundColor: darkDefaultCupertinoTheme.barBackgroundColor,
          textTheme: CupertinoTextThemeData(
            navActionTextStyle:
                darkDefaultCupertinoTheme.textTheme.navActionTextStyle.copyWith(
              color: const Color(0xF0F9F9F9),
            ),
            navLargeTitleTextStyle: darkDefaultCupertinoTheme
                .textTheme.navLargeTitleTextStyle
                .copyWith(
              color: const Color(0xF0F9F9F9),
            ),
          ),
        ),
      ),
    );

    return PlatformProvider(
      builder: (context) => PlatformTheme(
        themeMode: ThemeMode.system,
        materialLightTheme: materialLightTheme,
        materialDarkTheme: materialDarkTheme,
        cupertinoLightTheme: cupertinoLightTheme,
        cupertinoDarkTheme: cupertinoDarkTheme,
        builder: (context) => const PlatformApp(
          title: 'Insights Review Application',
          home: JsonInputPage(),
        ),
      ),
    );
  }
}

class JsonInputPage extends StatelessWidget {
  const JsonInputPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
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
            PlatformTextField(
              controller: _controller,
              maxLines: 10,
              material: (_, __) => MaterialTextFieldData(
                decoration: const InputDecoration(
                  hintText: 'Paste your JSON here',
                  border: OutlineInputBorder(),
                ),
              ),
              cupertino: (_, __) => CupertinoTextFieldData(
                placeholder: 'Paste your JSON here',
                padding: const EdgeInsets.all(12.0),
                clearButtonMode: OverlayVisibilityMode.editing,
              ),
            ),
            const SizedBox(height: 16),
            PlatformElevatedButton(
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Select a User"),
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView(
            children: [
              ...state.userInsights.keys.map(
                (userId) {
                  return PlatformListTile(
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
              ),
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
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text("Summary for $userId"),
        trailingActions: <Widget>[
          PlatformWidget(
            cupertino: (_, __) => PlatformIconButton(
              icon: Icon(Icons.adaptive.arrow_forward_rounded),
              onPressed: () {
                // Navigate to the next user's insights or go back to user selection if it's the last user
                final cubit = context.read<InsightCubit>();
                final allUsers = cubit.state.userInsights.keys.toList();
                final currentUserIndex = allUsers.indexOf(userId);

                if (currentUserIndex < allUsers.length - 1) {
                  final nextUser = allUsers[currentUserIndex + 1];
                  Navigator.pushReplacement(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => UserInsightsPage(userId: nextUser),
                    ),
                  );
                } else {
                  // If it's the last user, navigate to overall summary
                  Navigator.pushReplacement(
                    context,
                    platformPageRoute(
                      context: context,
                      builder: (context) => const OverallInsightSummaryPage(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          final insights = state.userInsights[userId]?.insights ?? [];

          return ListView.builder(
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return PlatformListTile(
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
      material: (_, __) => MaterialScaffoldData(
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
                platformPageRoute(
                  context: context,
                  builder: (context) => UserInsightsPage(userId: nextUser),
                ),
              );
            } else {
              // If it's the last user, navigate to overall summary
              Navigator.pushReplacement(
                context,
                platformPageRoute(
                  context: context,
                  builder: (context) => const OverallInsightSummaryPage(),
                ),
              );
            }
          },
          child: Icon(Icons.adaptive.arrow_forward_rounded),
        ),
      ),
    );
  }
}

class OverallInsightSummaryPage extends StatelessWidget {
  const OverallInsightSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: const Text("Overall Insights Summary"),
        trailingActions: [
          PlatformWidget(
            cupertino: (_, __) => PlatformIconButton(
              onPressed: () => _showExportConfigDialog(context),
              icon: Icon(PlatformIcons(context).cloudDownloadSolid),
            ),
          )
        ],
      ),
      body: BlocBuilder<InsightCubit, AllUsersInsights>(
        builder: (context, state) {
          return ListView.builder(
            itemCount: state.userInsights.keys.length,
            itemBuilder: (context, index) {
              final userId = state.userInsights.keys.elementAt(index);
              final insights = state.userInsights[userId]?.insights ?? [];
              return CustomExpansionTile(
                title: Text("User: $userId"),
                children: insights.map((insight) {
                  return PlatformListTile(
                    title: Text(insight.title),
                    trailing: buildTrailingWidgets(insight, context),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showExportConfigDialog(context),
          tooltip: "Export to JSON",
          child: Icon(PlatformIcons(context).cloudDownload),
        ),
      ),
    );
  }

  Widget buildTrailingWidgets(Insight insight, BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(insight.rating != null
            ? insight.rating!.toStringAsFixed(
                insight.rating!.truncateToDouble() == insight.rating! ? 0 : 1)
            : 'Not Rated'),
        const SizedBox(width: 10),
        if (insight.launchReady)
          const Icon((Icons.launch), color: Colors.green),
        if (insight.flag != null)
          const Icon(Icons.flag_rounded, color: Colors.red),
      ],
    );
  }

  Future<void> _showExportConfigDialog(BuildContext context) async {
    final cubit = context.read<InsightCubit>();
    final config = await showPlatformDialog<ExportConfig>(
      context: context,
      builder: (BuildContext context) =>
          ExportConfigPage(config: cubit.exportConfig),
    );

    if (config != null) {
      // Update the cubit's exportConfig
      cubit.exportConfig = config;
      // Directly use the config in the toJson method
      final jsonString = jsonEncode(cubit.state.toJson(config));

      Navigator.push(
        context,
        platformPageRoute(
          context: context,
          builder: (context) => ExportedJsonPage(jsonString: jsonString),
        ),
      );
    }
  }
}

class ExportConfigPage extends StatefulWidget {
  final ExportConfig config;

  const ExportConfigPage({required this.config, super.key});

  @override
  State<ExportConfigPage> createState() => _ExportConfigPageState();
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
    return PlatformAlertDialog(
      title: const Text('Export Configuration'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            PlatformListTile(
              title: const Text("Launch Ready Insights Only"),
              trailing: PlatformSwitch(
                  value: config.exportLaunchReadyOnly,
                  onChanged: (bool value) {
                    setState(() {
                      config.exportLaunchReadyOnly = value;
                    });
                  }),
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
            const Divider(),
            buildChildTile(
                "Review Metadata", config.reviewMetadata, 'reviewMetadata', 2),
            buildChildTile("Rating", config.rating, 'rating', 3),
            buildChildTile("Comment", config.comment, 'comment', 3),
            buildChildTile("Flag", config.flag, 'flag', 3),
          ],
        ),
      ),
      actions: [
        PlatformTextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        PlatformTextButton(
          onPressed: () {
            // Save the export config and close the dialog
            Navigator.of(context).pop(config);
          },
          child: const Text('Export'),
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
    return PlatformListTile(
        title: Text(title),
        material: (_, __) => MaterialListTileData(
              contentPadding: EdgeInsets.only(left: 20.0 * indentLevel),
            ),
        cupertino: (_, __) => CupertinoListTileData(
              padding: EdgeInsets.only(left: 20.0 * indentLevel),
            ),
        trailing: PlatformWidget(
          material: (_, __) => Checkbox(
            value: isChecked,
            tristate: true,
            onChanged: (val) {
              setState(() {
                config.toggleItem(_toggleCheckState(checkState), itemName);
              });
            },
          ),
          cupertino: (_, __) => CupertinoCheckbox(
            tristate: true,
            value: isChecked,
            onChanged: (val) {
              setState(() {
                config.toggleItem(_toggleCheckState(checkState), itemName);
              });
            },
          ),
        ));
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
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: const Text("Exported JSON"),
        trailingActions: [
          PlatformWidget(
            cupertino: (_, __) => PlatformIconButton(
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: widget.jsonString),
                );
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                    title: const Text('Copied'),
                    content: const Text(
                      'The JSON has been copied to the clipboard.',
                    ),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(CupertinoIcons.doc_on_clipboard),
            ),
          )
        ],
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
              const JsonEncoder.withIndent('  ').convert(
                json.decode(widget.jsonString),
              ),
            ),
          ),
        ),
      ),
      material: (_, __) => MaterialScaffoldData(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.jsonString));
            setState(() {
              _copied = true;
            });
            _timer = Timer(const Duration(seconds: 5), () {
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
            duration: const Duration(milliseconds: 300),
            child: _copied
                ? const Row(
                    key: ValueKey<int>(
                        1), // To ensure the AnimatedSwitcher recognizes the change
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.green),
                      SizedBox(width: 5),
                      Text("Copied"),
                    ],
                  )
                : const Row(
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
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Step 2: Cancel the timer when disposing the widget
    super.dispose();
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final List<Widget> children;

  const CustomExpansionTile({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        PlatformListTile(
          title: widget.title,
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          trailing: Icon(
            _isExpanded ? Icons.expand_less : Icons.expand_more,
          ),
        ),
        AnimatedCrossFade(
          firstChild:
              Container(), // Empty container for collapsed state (firstChild)
          secondChild: Column(
              children: widget.children), // Expanded content (secondChild)
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
        ),
      ],
    );
  }
}
