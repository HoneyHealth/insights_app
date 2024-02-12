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
