import 'package:flutter/material.dart';

import '../../pedagogy/trial.dart';
import '../trials/trial_selection_screen.dart';

/// Trial selection inside the Forum (noun declension, oratory duels).
class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key, this.highlightTrialId});
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context) => TrialSelectionScreen(activity: Activity.forum, highlightTrialId: highlightTrialId);
}
