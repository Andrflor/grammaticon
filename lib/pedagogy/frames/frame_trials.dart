/// Cartes du Theatrum et du Templum comme épreuves : une carte = un ensemble
/// de cadres et de nœuds visés. Identifiants : `th-<section>-<carte>` et
/// `tp-<section>-<carte>` (les adresses de référence sont conservées dans le
/// filtre pour retrouver les cadres).
library;

import '../trial.dart';
import 'frame_cards.dart';
import 'frame_catalogue.dart';

class FrameFilter extends ContentFilter {
  const FrameFilter(this.card);

  /// Adresse de carte `place/section/card`.
  final String card;
}

class FrameTrials {
  FrameTrials._();

  static String trialId(String cardAddress) {
    final p = cardAddress.split('/');
    return '${p[0] == 'templum' ? 'tp' : 'th'}-${p[1]}-${p[2]}';
  }

  static const _actors = ['comoedus', 'tragoedus', 'mimus', 'pantomimus', 'chorus', 'dominus'];
  static const _priests = ['augur', 'flamen'];

  static List<Trial> build() => [
    ..._place(Activity.theatrum, kTheatrumSections, kTheatrumCards, _actors),
    ..._place(Activity.templum, kTemplumSections, kTemplumCards, _priests),
  ];

  static List<Trial> _place(Activity activity, List<FrameSectionMeta> sections, List<FrameCardMeta> cards, List<String> opponents) {
    final byId = {for (final c in cards) c.id: c};
    final out = <Trial>[];
    var i = 0;
    for (final s in sections) {
      for (final cardId in s.cards) {
        final c = byId['${activity.key}/${s.id}/$cardId'];
        if (c == null) continue;
        final nodes = frameCardNodes(c.id);
        final production = activity == Activity.templum;
        out.add(Trial(
          id: trialId(c.id),
          name: c.name,
          subtitle: c.subtitle,
          skillIds: [production ? 'p' : 'l'],
          price: c.price,
          prerequisites: [for (final r in c.requires) trialId(r)],
          filter: FrameFilter(c.id),
          dimensions: [cardId == 'vocabula' ? Dimension.vocabulum : (production ? Dimension.productio : Dimension.sensus)],
          intro: production
              ? '${c.name}. Sententiam Gallicam Latīnē redde: ēlige fōrmam aut sententiam quae sēnsum servat.'
              : '${c.name}. Sententiās Latīnās lege et interpretātiōnem Gallicam fidēlem ēlige.',
          examples: [for (final n in nodes.take(3)) n],
          opponentId: opponents[i++ % opponents.length],
          activity: activity,
          questionsToWin: c.target,
          hearts: c.lives,
          group: s.name,
        ));
      }
    }
    return out;
  }
}
