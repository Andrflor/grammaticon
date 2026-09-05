import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Sound effects. Files live in assets/audio and were synthesised locally.
enum Sfx {
  recte('recte.wav'),
  errat('errat.wav'),
  impetus('impetus.wav'),
  ictus('ictus.wav'),
  gemma('gemma.wav'),
  numerus('numerus.wav'),
  victoria('victoria.wav'),
  clades('clades.wav'),
  tactus('tactus.wav'),
  emptio('emptio.wav'),
  vulnus('vulnus.wav');

  const Sfx(this.file);
  final String file;
}

/// Small pool of players so short sounds can overlap. Failures are swallowed:
/// audio must never break the game (tests, headless machines).
class AudioService {
  AudioService({this.enabled = true, int poolSize = 4}) : _poolSize = poolSize; // ignore: prefer_initializing_formals

  final bool enabled;
  final int _poolSize;
  final List<AudioPlayer> _pool = [];
  int _next = 0;
  double volume = 0.8;
  bool soundOn = true;

  Future<void> preload() async {
    if (!enabled) return;
    try {
      for (var i = 0; i < _poolSize; i++) {
        final p = AudioPlayer();
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setPlayerMode(PlayerMode.lowLatency);
        _pool.add(p);
      }
      await AudioCache.instance.loadAll([for (final s in Sfx.values) 'audio/${s.file}']);
    } catch (e) {
      debugPrint('Sonus nōn parātus: $e');
    }
  }

  void play(Sfx sfx) {
    if (!enabled || !soundOn || _pool.isEmpty) return;
    final p = _pool[_next];
    _next = (_next + 1) % _pool.length;
    // Fire and forget.
    p.stop().then((_) => p.play(AssetSource('audio/${sfx.file}'), volume: volume)).catchError((Object e) {
      debugPrint('Sonus dēfēcit: $e');
    });
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
  }
}
