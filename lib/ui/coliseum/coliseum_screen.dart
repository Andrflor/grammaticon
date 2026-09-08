import 'package:flutter/material.dart';

import '../../pedagogy/trial.dart';
import '../trials/trial_selection_screen.dart';

export '../trials/trial_selection_screen.dart' show TrialCard, showTrialSheet;

/// Trial selection inside the Amphitheatrum (verb conjugation).
class ColiseumScreen extends StatelessWidget {
  const ColiseumScreen({super.key, this.highlightTrialId});
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context) => TrialSelectionScreen(activity: Activity.amphitheatrum, highlightTrialId: highlightTrialId);
}
