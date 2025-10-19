import 'package:hive/hive.dart';
import '../models/story.dart';
import '../models/race.dart';
import '../models/character.dart';

// Register adapters del modelo donde corresponda (normalmente en main.dart)

class LocalStorageService {
  // API Key
  static const _apiKeyBox = 'apiKeyBox';
  static const _key = 'apiKey';

  static Future<void> saveApiKey(String apiKey) async {
    var box = await Hive.openBox(_apiKeyBox);
    await box.put(_key, apiKey);
  }

  static Future<String?> getApiKey() async {
    var box = await Hive.openBox(_apiKeyBox);
    return box.get(_key);
  }

  // Historias
  static const _storyBox = 'storyBox';

  static Future<void> saveStories(List<Story> stories) async {
    var box = await Hive.openBox<Story>(_storyBox);
    await box.clear(); // Limpia para evitar duplicados (ajustable)
    await box.addAll(stories);
  }

  static Future<List<Story>> getStories() async {
    var box = await Hive.openBox<Story>(_storyBox);
    return box.values.toList();
  }

  // Razas
  static const _raceBox = 'raceBox';

  static Future<void> saveRaces(List<Race> races) async {
    var box = await Hive.openBox<Race>(_raceBox);
    await box.clear();
    await box.addAll(races);
  }

  static Future<List<Race>> getRaces() async {
    var box = await Hive.openBox<Race>(_raceBox);
    return box.values.toList();
  }

  // Personajes
  static const _characterBox = 'characterBox';

  static Future<void> saveCharacters(List<Character> characters) async {
    var box = await Hive.openBox<Character>(_characterBox);
    await box.clear();
    await box.addAll(characters);
  }

  static Future<List<Character>> getCharacters() async {
    var box = await Hive.openBox<Character>(_characterBox);
    return box.values.toList();
  }

// Puedes agregar métodos similares para imágenes u archivos, guardando el path o base64
}

