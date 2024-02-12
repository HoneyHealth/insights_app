import 'models.dart';

class AllUsersInsights {
  final Map<String, UserInsight> userInsights;

  AllUsersInsights({required this.userInsights});

  factory AllUsersInsights.fromJson(Map<String, dynamic> json) {
    Map<String, UserInsight> userInsights = {};

    json.forEach((key, value) {
      if (value is Map<String, dynamic> && value.containsKey('insights')) {
        userInsights[key] = UserInsight.fromJson(value);
      } else if (value is List) {
        userInsights[key] = UserInsight.fromJson({"insights": value});
      } else {
        // Handle other unexpected formats or log an error
      }
    });

    return AllUsersInsights(userInsights: userInsights);
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    // Check if launchReady export filter is on
    bool launchReadyFilter = config?.exportLaunchReadyOnly == true;

    Map<String, UserInsight> filteredUserInsights = {};

    userInsights.forEach((userId, userInsight) {
      // If launchReady export filter is on, remove users with no launch-ready insights
      if (launchReadyFilter) {
        if (userInsight.insights.any((insight) => insight.launchReady)) {
          filteredUserInsights[userId] = userInsight;
        }
      } else {
        filteredUserInsights[userId] = userInsight;
      }
    });

    if (config == null ||
        config.insights == CheckState.checked ||
        config.insights == CheckState.halfChecked) {
      result["insights"] =
          filteredUserInsights.map((k, v) => MapEntry(k, v.toJson(config)));
    }

    return result;
  }
}
