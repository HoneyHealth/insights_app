import 'dart:convert';
import 'models.dart';

class SourceFunction {
  final String name;
  final Map<String, dynamic>? sourceData;

  SourceFunction({required this.name, required this.sourceData});

  factory SourceFunction.fromJson(Map<String, dynamic> jsonData) {
    return SourceFunction(
        name: jsonData['name'] ?? "NOT PROVIDED",
        sourceData: jsonData['source_data'] == null
            ? null
            : json.decode(jsonData['source_data']) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    if ((config == null || config.sourceName == CheckState.checked) &&
        name != "NOT PROVIDED") {
      result["name"] = name;
    }
    if ((config == null || config.sourceData == CheckState.checked) &&
        sourceData != null) {
      result['source_data'] = sourceData;
    }

    return result;
  }
}
