import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/models/models.dart';

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
            buildChildTile("Referenced Insights", config.referencedInsights,
                'referencedInsights', 2),
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
