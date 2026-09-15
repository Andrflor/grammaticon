/// Cartes du Theatrum et du Templum comme épreuves : une carte = un ensemble
/// de cadres et de nœuds visés. Identifiants : `th-<section>-<carte>` et
/// `tp-<section>-<carte>` (les adresses de référence sont conservées dans le
/// filtre pour retrouver les cadres).
library;

import '../../arbor/lectio.dart';
import '../../arbor/nominal_elementa.dart';
import '../../arbor/syntaxis.dart';
import '../../arbor/verbal_elementa.dart';
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

  /// Métadonnées d'une carte par adresse `place/section/card`.
  static final Map<String, FrameCardMeta> cardsById = {for (final c in [...kTheatrumCards, ...kTemplumCards]) c.id: c};

  static String trialId(String cardAddress) {
    final p = cardAddress.split('/');
    return '${p[0] == 'templum' ? 'tp' : 'th'}-${p[1]}-${p[2]}';
  }

  /// Noms des nœuds authored, pour les exemples d'introduction.
  static final Map<String, String> _nomina = {
    for (final s in [...kVerbalElementa, ...kNominalElementa, ...kSyntaxis, ...kLectio]) s.id: s.nomen,
  };

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
        final base = frameCardBaseNodes(c.id);
        final production = activity == Activity.templum;
        out.add(Trial(
          id: trialId(c.id),
          name: c.name,
          subtitle: c.subtitle,
          skillIds: ['${production ? 'p' : 'l'}.${s.id}.$cardId'],
          price: c.price,
          prerequisites: [for (final r in c.requires) trialId(r)],
          filter: FrameFilter(c.id),
          dimensions: [cardId == 'vocabula' ? Dimension.vocabulum : (production ? Dimension.productio : Dimension.sensus)],
          intro: [
            ...c.lesson,
            production
                ? 'Sententiam Gallicam Latīnē redde: ēlige fōrmam aut sententiam quae sēnsum servat.'
                : 'Sententiās Latīnās lege et interpretātiōnem Gallicam fidēlem ēlige.',
          ].join(' '),
          examples: c.examples.isNotEmpty ? c.examples.take(8).toList() : [for (final n in base) if (_nomina[n] != null) _nomina[n]!],
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
