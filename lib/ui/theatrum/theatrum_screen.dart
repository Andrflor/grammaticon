import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/app.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../pedagogy/trial.dart';
import '../settings/settings_screen.dart';
import '../trials/trial_selection_screen.dart';
import '../widgets/roman_widgets.dart';

/// Trial selection inside the Theatrum (Latin → French comprehension). When
/// the selected translation language has no shipped content, the theatre
/// says so instead of silently showing another language.
class TheatrumScreen extends ConsumerWidget {
  const TheatrumScreen({super.key, this.highlightTrialId});
  final String? highlightTrialId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider.select((s) => s.translationLanguage));
    final library = ref.watch(readingLibraryProvider);
    if (library.supports(lang.code)) {
      return TrialSelectionScreen(activity: Activity.theatrum, highlightTrialId: highlightTrialId);
    }
    final save = ref.watch(profileProvider);
    return Scaffold(
      body: Container(
        decoration: kScreenGradient,
        child: Column(
          children: [
            TopBar(title: 'Theātrum · Interpretātiō', gems: save.gems),
            Expanded(
              child: Center(
                child: RomanPanel(
                  width: 520,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${lang.latin}: nōndum parāta', style: G.display(22, color: G.purple)),
                      const SizedBox(height: 8),
                      Text(
                        'Interpretātiōnēs ${lang.latin.toLowerCase()} in hāc versiōne nōn continentur. Nihil aliā linguā ostenditur: ēlige linguam parātam in Optiōnibus.',
                        style: G.body(15, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      RomanButton(
                        label: 'Optiōnēs',
                        icon: Icons.settings,
                        style: RomanButtonStyle.gold,
                        onPressed: () => pushScreen(context, const SettingsScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
