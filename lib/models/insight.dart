import 'models.dart';

class Insight {
  final List<String> steps;
  final String title;
  final String insight;
  final String nextSteps;
  final List<SourceFunction> sourceFunctions;
  final String lastGlucoseDataPointTimestampForInsight;
  double? rating;

  String? comment; // can be null if no feedback given
  bool launchReady; // New property
  Flag? flag; // This will be non-null if the insight is flagged

  final Map<String, dynamic> otherData;

  Insight({
    required this.steps,
    required this.title,
    required this.insight,
    required this.nextSteps,
    required this.sourceFunctions,
    required this.lastGlucoseDataPointTimestampForInsight,
    this.rating,
    this.comment,
    this.launchReady = false, // Default value
    this.flag,
    required this.otherData,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    // Extract other keys and values from the JSON
    Map<String, dynamic> otherData = {};
    json.forEach((key, value) {
      if (key != 'steps' &&
          key != 'title' &&
          key != 'insight' &&
          key != 'next_steps' &&
          key != 'source_functions' &&
          key != 'last_glucose_data_point_timestamp_for_insight' &&
          key != 'rating' &&
          key != 'critique' &&
          key != 'launch_ready' &&
          key != 'flag') {
        otherData[key] = value;
      }
    });

    return Insight(
      steps: json.containsKey('steps') ? List<String>.from(json['steps']) : [],
      title: json['title'],
      insight: json['insight'],
      nextSteps: json['next_steps'],
      sourceFunctions: (json['source_functions'] as List?)
              ?.map((sf) => SourceFunction.fromJson(sf as Map<String, dynamic>))
              .toList() ??
          [],
      lastGlucoseDataPointTimestampForInsight:
          json['last_glucose_data_point_timestamp_for_insight'],
      rating: json['rating'] != null ? (json['rating'] + 0.0) as double : null,
      comment: json['critique'],
      launchReady: json['launch_ready'] ?? false,
      flag: json['flag'] != null
          ? Flag(
              reason: json['flag']['reason'], comment: json['flag']['comment'])
          : null,
      otherData: otherData,
    );
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    if (config == null || config.title == CheckState.checked) {
      result['title'] = title;
    }
    if (config == null || config.insightText == CheckState.checked) {
      result['insight'] = insight;
    }
    if (config == null || config.nextSteps == CheckState.checked) {
      result['next_steps'] = nextSteps;
    }

    if (config == null ||
        config.sourceFunctions == CheckState.checked ||
        config.sourceFunctions == CheckState.halfChecked) {
      result['source_functions'] =
          sourceFunctions.map((e) => e.toJson(config)).toList();
    }

    if (config == null ||
        config.reviewMetadata == CheckState.checked ||
        config.reviewMetadata == CheckState.halfChecked) {
      if (config == null ||
          config.rating == CheckState.checked && rating != null) {
        result['rating'] = rating;
      }
      if (config == null ||
          config.comment == CheckState.checked && comment != null) {
        result['critique'] = comment;
      }
      if (config == null || config.flag == CheckState.checked && flag != null) {
        result['flag'] = flag!.toJson();
      }
    }

    result.addAll(otherData);

    return result;
  }
}