import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'save_data.dart';

/// Storage backend abstraction (shared_preferences in the app, memory in tests).
abstract class SaveStore {
  Future<String?> read();
  Future<void> write(String raw);
  Future<void> clear();
}

class PrefsSaveStore implements SaveStore {
  PrefsSaveStore({this.key = 'grammaticon.save'});
  final String key;

  @override
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(key);

  @override
  Future<void> write(String raw) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(key, raw);
  }

  @override
  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(key);
  }
}

class MemorySaveStore implements SaveStore {
  String? raw;
  int writes = 0;

  @override
  Future<String?> read() async => raw;

  @override
  Future<void> write(String r) async {
    raw = r;
    writes++;
  }

  @override
  Future<void> clear() async => raw = null;
}

/// Loads and saves the game state. Writes are serialised so that a save issued
/// during an animation can never be reordered with a later one.
class SaveRepository {
  SaveRepository(this.store, {this.codec = const SaveCodec()});
  final SaveStore store;
  final SaveCodec codec;
  Future<void> _chain = Future.value();

  Future<SaveData> load() async {
    final raw = await store.read();
    if (raw == null || raw.isEmpty) return SaveData(createdAt: DateTime.now());
    try {
      return codec.decode(raw);
    } catch (e) {
      debugPrint('Cōnservātiō legī nōn potuit: $e');
      return SaveData(createdAt: DateTime.now());
    }
  }

  /// Persists [data]; returns when the write has completed.
  Future<void> save(SaveData data) {
    final raw = codec.encode(data.copyWith(updatedAt: DateTime.now()));
    _chain = _chain.then((_) => store.write(raw));
    return _chain;
  }

  Future<void> reset() => store.clear();

  String export(SaveData data) => codec.encode(data);
  SaveData import(String raw) => codec.decode(raw);
}
