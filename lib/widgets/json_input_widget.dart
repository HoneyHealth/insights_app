import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/insights_cubit.dart';
import 'package:insights_app/models/models.dart';
import 'package:responsive_builder/responsive_builder.dart';

import 'widgets.dart';

class JsonInputWidget extends StatefulWidget {
  const JsonInputWidget({
    super.key,
  });

  @override
  State<JsonInputWidget> createState() => _JsonInputWidgetState();
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
