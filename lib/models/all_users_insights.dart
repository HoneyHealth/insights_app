import 'models.dart';

class AllUsersInsights {
  final Map<String, UserInsights> userInsights;

  AllUsersInsights({
    required this.userInsights,
  });

  int get userCount => userInsights.length;

  int get insightCount => userInsights.values
      .fold(0, (acc, userInsight) => acc + userInsight.insights.length);

  factory AllUsersInsights.fromJson(Map<String, dynamic> json) {
    Map<String, UserInsights> userInsights = {};

    json.forEach((key, value) {
      if (value is List) {
        userInsights[key] =
            UserInsights.fromJson(value.cast<Map<String, dynamic>>());
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

    Map<String, UserInsights> filteredUserInsights = {};

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
      result =
          filteredUserInsights.map((k, v) => MapEntry(k, v.toJson(config)));
    }

    return result;
  }
}
