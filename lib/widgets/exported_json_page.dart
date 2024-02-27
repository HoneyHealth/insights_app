import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:responsive_builder/responsive_builder.dart';

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
