import '../persistence/save_data.dart';
import 'trials.dart';

enum TrialAccess {
  /// Free or purchased: playable.
  accessible('Aperta'),
  /// Prerequisites met, not yet bought.
  purchasable('Emenda'),
  /// Prerequisites missing.
  locked('Clausa');

  const TrialAccess(this.latin);
  final String latin;
}

class TrialStatus {
  const TrialStatus(this.trial, this.access, this.missing, this.affordable);
  final Trial trial;
  final TrialAccess access;

  /// Prerequisite trials not yet accessible.
  final List<Trial> missing;

  /// Gems suffice for the price (purchase still requires an explicit action).
  final bool affordable;
}

class Progression {
  const Progression._();

  static bool isAccessible(SaveData save, Trial t) => t.isFree || save.purchased.contains(t.id);

  static TrialStatus status(SaveData save, Trial t) {
    if (isAccessible(save, t)) return TrialStatus(t, TrialAccess.accessible, const [], true);
    final missing = [for (final p in t.prerequisites) if (!isAccessible(save, Trials.byId(p))) Trials.byId(p)];
    final affordable = save.gems >= t.price;
    return TrialStatus(t, missing.isEmpty ? TrialAccess.purchasable : TrialAccess.locked, missing, affordable);
  }

  static bool canPurchase(SaveData save, Trial t) {
    final s = status(save, t);
    return s.access == TrialAccess.purchasable && s.affordable;
  }

  /// Cheapest price among trials the player could buy now, or null.
  static int? cheapestPurchasable(SaveData save) {
    int? best;
    for (final t in Trials.all) {
      if (status(save, t).access == TrialAccess.purchasable) {
        if (best == null || t.price < best) best = t.price;
      }
    }
    return best;
  }

  /// Component ids in force for a Mixta trial (all when unconfigured).
  static List<String> componentsFor(SaveData save, Trial t) {
    if (!t.isMixta) return const [];
    final cfg = save.mixtaConfig[t.id];
    final valid = t.components.map((c) => c.id).toSet();
    final chosen = cfg == null ? <String>[] : cfg.where(valid.contains).toList();
    if (chosen.length < t.minComponents) return t.components.map((c) => c.id).toList();
    return chosen;
  }
}
