import 'character.dart';

enum RaceFieldType { text, number, boolean }

class RaceFieldDef {
  String key;      // identificador interno: ej. "tamano_orejas"
  String label;    // etiqueta visible: ej. "Tamaño de orejas"
  RaceFieldType type;

  RaceFieldDef({
    required this.key,
    required this.label,
    required this.type,
  });
}

class Race {
  String id;
  String name;
  String description;
  String? imagePath;             // path local, url o base64
  List<RaceFieldDef> fields;     // definición de características
  List<Character> characters;

  Race({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    List<RaceFieldDef>? fields,
    List<Character>? characters,
  })  : fields = fields ?? [],
        characters = characters ?? [];
}
