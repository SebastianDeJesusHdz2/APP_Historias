// lib/services/local_storage_service.dart
import 'package:hive/hive.dart';
import '../models/story.dart';
import '../models/race.dart';
import '../models/character.dart';

class LocalStorageService {
  // -------- API Key --------
  static const _apiKeyBox = 'apiKeyBox';
  static const _key = 'apiKey';

  static Future<void> saveApiKey(String apiKey) async {
    final box = await Hive.openBox(_apiKeyBox);
    await box.put(_key, apiKey);
    await box.close();
  }

  static Future<String?> getApiKey() async {
    final box = await Hive.openBox(_apiKeyBox);
    final v = box.get(_key) as String?;
    await box.close();
    return v;
  }

  static Future<void> clearApiKeyBox() async {
    final box = await Hive.openBox(_apiKeyBox);
    await box.clear(); // deja la caja sin datos
    await box.close();
  }

  // -------- Historias / Razas / Personajes --------
  static const _storyBox = 'storyBox';
  static const _raceBox = 'raceBox';
  static const _characterBox = 'characterBox';

  static Future<void> saveStories(List<Story> stories) async {
    final box = await Hive.openBox<Story>(_storyBox);
    await box.clear();
    await box.addAll(stories);
    await box.close();
  }

  static Future<List<Story>> getStories() async {
    final box = await Hive.openBox<Story>(_storyBox);
    final list = box.values.toList();
    await box.close();
    return list;
  }

  static Future<void> saveRaces(List<Race> races) async {
    final box = await Hive.openBox<Race>(_raceBox);
    await box.clear();
    await box.addAll(races);
    await box.close();
  }

  static Future<List<Race>> getRaces() async {
    final box = await Hive.openBox<Race>(_raceBox);
    final list = box.values.toList();
    await box.close();
    return list;
  }

  static Future<void> saveCharacters(List<Character> characters) async {
    final box = await Hive.openBox<Character>(_characterBox);
    await box.clear();
    await box.addAll(characters);
    await box.close();
  }

  static Future<List<Character>> getCharacters() async {
    final box = await Hive.openBox<Character>(_characterBox);
    final list = box.values.toList();
    await box.close();
    return list;
  }

  // -------- Preferencias simples (opcional) --------
  static const _prefsBox = 'prefsBox';


  static Future<void> setPrefBool(String key, bool value) async {
    final box = await Hive.openBox(_prefsBox);
    await box.put(key, value);
    await box.close();
  }

  static Future<bool?> getPrefBool(String key) async {
    final box = await Hive.openBox(_prefsBox);
    final v = box.get(key) as bool?;
    await box.close();
    return v;
  }

  // -------- Limpieza total --------
  static Future<void> clearAllData() async {
    // Vacía todas las cajas relevantes, incluida la de API
    try {
      final api = await Hive.openBox(_apiKeyBox);
      await api.clear();
      await api.close();

      final st = await Hive.openBox<Story>(_storyBox);
      await st.clear();
      await st.close();

      final rc = await Hive.openBox<Race>(_raceBox);
      await rc.clear();
      await rc.close();

      final ch = await Hive.openBox<Character>(_characterBox);
      await ch.clear();
      await ch.close();

      final pf = await Hive.openBox(_prefsBox);
      await pf.clear();
      await pf.close();
    } catch (_) {
      // Ignora si alguna caja no existe aún
    }
  }
}



