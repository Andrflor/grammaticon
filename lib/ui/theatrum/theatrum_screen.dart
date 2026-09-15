import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../pedagogy/trial.dart';
import '../trials/trial_selection_screen.dart';

/// Le Theatrum : les cartes de lecture (latin → français) tirées des cadres.
class TheatrumScreen extends ConsumerWidget {
  const TheatrumScreen({super.key, this.highlightTrialId});
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => TrialSelectionScreen(activity: Activity.theatrum, highlightTrialId: highlightTrialId);
}
