import 'package:flutter/cupertino.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:insights_app/widgets/json_input_widget.dart';

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
