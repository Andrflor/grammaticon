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
  vulnus('vulnus.wav'),
  // Forum
  oratio('oratio.wav'),
  plausus('plausus.wav'),
  refutatio('refutatio.wav'),
  murmur('murmur.wav'),
  // Theatrum
  tibia('tibia.wav'),
  sibilus('sibilus.wav'),
  // Menus and navigation (tool/assets/generate_menu_sfx.sh)
  tuba('tuba.wav'),
  folium('folium.wav'),
  vetitum('vetitum.wav');

  const Sfx(this.file);
  final String file;
}

/// Small pool of players so short sounds can overlap. Failures are swallowed:
/// audio must never break the game (tests, headless machines).
class AudioService {
  AudioService({this.enabled = true, int poolSize = 4}) : _poolSize = poolSize; // ignore: prefer_initializing_formals

  /// The app-wide instance, for shared widgets (buttons, section titles)
  /// that have no provider access. Null in tests: they stay silent.
  static AudioService? current;

  final bool enabled;
  final int _poolSize;
  final List<AudioPlayer> _pool = [];
  AudioPlayer? _music;
  int _next = 0;
  /// Effects volume.
  double volume = 0.8;
  bool _soundOn = true;
  double _musicVolume = 0.5;
  bool _musicOn = true;
  bool _musicStarted = false;

  /// Master switch: off silences both effects and music.
  bool get soundOn => _soundOn;
  set soundOn(bool v) {
    _soundOn = v;
    _applyMusicVolume();
  }

  double get _effectiveMusicVolume => (_soundOn && _musicOn) ? _musicVolume : 0;

  /// Theme music file (assets/audio); user-provided track, looped.
  static const String themeFile = 'thema.mp3';

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

  // ----- music -----------------------------------------------------------------

  /// Starts the looping theme (idempotent).
  Future<void> startMusic() async {
    if (!enabled || _musicStarted) return;
    _musicStarted = true;
    try {
      final p = _music ??= AudioPlayer();
      await p.setReleaseMode(ReleaseMode.loop);
      await p.setVolume(_effectiveMusicVolume);
      await p.play(AssetSource('audio/$themeFile'), volume: _effectiveMusicVolume);
    } catch (e) {
      debugPrint('Mūsica nōn coepta: $e');
    }
  }

  /// Applies music settings; volume 0 or off mutes without stopping the loop.
  void setMusic({required bool on, required double volume}) {
    _musicOn = on;
    _musicVolume = volume;
    _applyMusicVolume();
  }

  void _applyMusicVolume() {
    _music?.setVolume(_effectiveMusicVolume).catchError((Object e) => debugPrint('Mūsica: $e'));
  }

  /// Pauses when the app goes to the background.
  void pauseMusic() => _music?.pause().catchError((Object e) => debugPrint('Mūsica: $e'));
  void resumeMusic() {
    if (_musicStarted) _music?.resume().catchError((Object e) => debugPrint('Mūsica: $e'));
  }

  void dispose() {
    for (final p in _pool) {
      p.dispose();
    }
    _pool.clear();
    _music?.dispose();
    _music = null;
  }
}
