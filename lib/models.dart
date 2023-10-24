import 'dart:convert';

class UserInsight {
  final List<Insight> insights;

  UserInsight({required this.insights});

  factory UserInsight.fromJson(Map<String, dynamic> json) {
    return UserInsight(
      insights: (json['insights'] as List)
          .map((i) => Insight.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Insight {
  final List<String> steps;
  final String title;
  final String insight;
  final String nextSteps;
  final List<SourceFunction> sourceFunctions;
  final String lastGlucoseDataPointTimestampForInsight;
  int? rating; // can be null if not rated
  String? feedback; // can be null if no feedback given

  Insight({
    required this.steps,
    required this.title,
    required this.insight,
    required this.nextSteps,
    required this.sourceFunctions,
    required this.lastGlucoseDataPointTimestampForInsight,
    this.rating,
    this.feedback,
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      steps: List<String>.from(json['steps']),
      title: json['title'],
      insight: json['insight'],
      nextSteps: json['next_steps'],
      sourceFunctions: (json['source_functions'] as List)
          .map((sf) => SourceFunction.fromJson(sf as Map<String, dynamic>))
          .toList(),
      lastGlucoseDataPointTimestampForInsight:
          json['last_glucose_data_point_timestamp_for_insight'],
      rating: json['rating'],
      feedback: json['feedback'],
    );
  }
}

class SourceFunction {
  final String name;
  final Map<String, dynamic> sourceData;

  SourceFunction({required this.name, required this.sourceData});

  factory SourceFunction.fromJson(Map<String, dynamic> jsonData) {
    return SourceFunction(
        name: jsonData['name'],
        sourceData:
            json.decode(jsonData['source_data']) as Map<String, dynamic>);
  }
}

class AllUsersInsights {
  final Map<String, UserInsight> userInsights;

  AllUsersInsights({required this.userInsights});

  factory AllUsersInsights.fromJson(Map<String, dynamic> json) {
    Map<String, UserInsight> userInsights = {};

    json.forEach((key, value) {
      userInsights[key] = UserInsight.fromJson(value as Map<String, dynamic>);
    });

    return AllUsersInsights(userInsights: userInsights);
  }
}
