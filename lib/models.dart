import 'dart:convert';

class UserInsight {
  final List<Insight> insights;

  UserInsight({required this.insights});

  factory UserInsight.fromJson(Map<String, dynamic> json) {
    List<Insight> insightsList;

    // Check if 'json' contains the 'insights' key
    if (json.containsKey('insights') && json['insights'] is List) {
      // If 'insights' key exists and is a list, process it
      insightsList = (json['insights'] as List)
          .map((i) => Insight.fromJson(i as Map<String, dynamic>))
          .toList();
    } else {
      // If 'insights' key does not exist, treat the entire json as insights data
      insightsList = [Insight.fromJson(json)];
    }

    return UserInsight(
      insights: insightsList,
    );
  }

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    List<Insight> filteredInsights;
    if (config?.exportLaunchReadyOnly == true) {
      filteredInsights = insights.where((i) => i.launchReady).toList();
    } else {
      filteredInsights = insights;
    }

    if (config == null ||
        config.userInsight == CheckState.checked ||
        config.userInsight == CheckState.halfChecked) {
      result['insights'] =
          filteredInsights.map((e) => e.toJson(config)).toList();
    }

    return result;
  }
}

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
  });

  factory Insight.fromJson(Map<String, dynamic> json) {
    return Insight(
      steps: List<String>.from(json['steps']),
      title: json['title'],
      insight: json['insight'],
      nextSteps: json['next_steps'],
      sourceFunctions: (json['source_functions'] as List?)
              ?.map((sf) => SourceFunction.fromJson(sf as Map<String, dynamic>))
              .toList() ??
          [],
      lastGlucoseDataPointTimestampForInsight:
          json['last_glucose_data_point_timestamp_for_insight'],
      rating: (json['rating'] + 0.0) as double,
      comment: json['critique'],
      launchReady: json['launch_ready'] ?? false,
      flag: json['flag'] != null
          ? Flag(
              reason: json['flag']['reason'], comment: json['flag']['comment'])
          : null,
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

    return result;
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

  Map<String, dynamic> toJson([ExportConfig? config]) {
    Map<String, dynamic> result = {};

    if (config == null || config.sourceName == CheckState.checked) {
      result["name"] = name;
    }
    if (config == null || config.sourceData == CheckState.checked) {
      result['source_data'] = sourceData;
    }

    return result;
  }
}

class AllUsersInsights {
  final Map<String, UserInsight> userInsights;

  AllUsersInsights({required this.userInsights});

  factory AllUsersInsights.fromJson(Map<String, dynamic> json) {
    Map<String, UserInsight> userInsights = {};

    json.forEach((key, value) {
      // Check if value is directly an array or nested under 'insights'
      var insightsData;
      if (value is Map<String, dynamic> && value.containsKey('insights')) {
        insightsData = value['insights'];
      } else if (value is List) {
        insightsData = value;
      } else {
        // Handle other unexpected formats or log an error
      }

      if (insightsData != null) {
        for (var insightData in insightsData) {
          // Assuming that 'UserInsight.fromJson' can handle the insight data format
          userInsights[key] =
              UserInsight.fromJson(insightData as Map<String, dynamic>);
        }
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

class Flag {
  final String reason;
  final String? comment; // Optional comment for "Other" reason

  Flag({required this.reason, this.comment});

  Map<String, dynamic> toJson() => {
        'reason': reason,
        'comment': comment,
      };
}

enum CheckState {
  unchecked,
  checked,
  halfChecked,
}

class ExportConfig {
  CheckState insights = CheckState.unchecked;
  CheckState userInsight = CheckState.unchecked;
  CheckState title = CheckState.unchecked;
  CheckState insightText = CheckState.unchecked;
  CheckState nextSteps = CheckState.unchecked;
  CheckState sourceFunctions = CheckState.unchecked;
  CheckState sourceName = CheckState.unchecked;
  CheckState sourceData = CheckState.unchecked;

  CheckState reviewMetadata = CheckState.unchecked;
  CheckState rating = CheckState.unchecked;
  CheckState comment = CheckState.unchecked;
  CheckState flag = CheckState.unchecked;

  bool exportLaunchReadyOnly = false;

  void toggleItem(CheckState value, String itemName) {
    switch (itemName) {
      case 'insights':
        insights = value;
        _updateChildStates(value, ['userInsight']);
        break;
      case 'userInsight':
        userInsight = value;
        _updateChildStates(value, [
          'title',
          'insightText',
          'nextSteps',
          'sourceFunctions',
          'reviewMetadata'
        ]);
        _updateParentState('insights', [userInsight]);
        break;
      case 'title':
        title = value;
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'insightText':
        insightText = value;
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'nextSteps':
        nextSteps = value;
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'sourceFunctions':
        sourceFunctions = value;
        _updateChildStates(value, ['sourceName', 'sourceData']);
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'sourceName':
        sourceName = value;
        _updateParentState('sourceFunctions', [sourceName, sourceData]);
        break;
      case 'sourceData':
        sourceData = value;
        _updateParentState('sourceFunctions', [sourceName, sourceData]);
        break;
      case 'reviewMetadata':
        reviewMetadata = value;
        _updateChildStates(value, ['rating', 'comment', 'flag']);
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'rating':
        rating = value;
        _updateParentState('reviewMetadata', [rating, comment, flag]);
        break;
      case 'comment':
        comment = value;
        _updateParentState('reviewMetadata', [rating, comment, flag]);
        break;
      case 'flag':
        flag = value;
        _updateParentState('reviewMetadata', [rating, comment, flag]);
        break;
    }
  }

  void _updateChildStates(CheckState parentValue, List<String> childNames) {
    for (var child in childNames) {
      toggleItem(parentValue, child);
    }
  }

  void _updateParentState(String parentName, List<CheckState> childStates) {
    int checkedCount = childStates
        .where((element) =>
            element == CheckState.checked || element == CheckState.halfChecked)
        .length;
    CheckState newParentState;
    if (checkedCount == childStates.length) {
      newParentState = CheckState.checked;
    } else if (checkedCount == 0) {
      newParentState = CheckState.unchecked;
    } else {
      newParentState = CheckState.halfChecked;
    }

    switch (parentName) {
      case 'userInsight':
        if (userInsight != newParentState) {
          userInsight = newParentState;
        }
        _updateParentState('insights', [userInsight]);
        break;
      case 'sourceFunctions':
        if (sourceFunctions != newParentState) {
          sourceFunctions = newParentState;
        }
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'reviewMetadata':
        if (reviewMetadata != newParentState) {
          reviewMetadata = newParentState;
        }
        _updateParentState('userInsight',
            [title, insightText, nextSteps, sourceFunctions, reviewMetadata]);
        break;
      case 'insights':
        if (insights != newParentState) {
          insights = newParentState;
        }
        break;
    }
  }
}
