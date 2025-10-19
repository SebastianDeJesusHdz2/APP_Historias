import 'character.dart';

class Race {
  String id;
  String name;
  String description;
  String? imagePath;
  Map<String, dynamic> customFields; // Permite campos personalizados
  List<Character> characters;

  Race({
    required this.id,
    required this.name,
    required this.description,
    this.imagePath,
    Map<String, dynamic>? customFields,
    List<Character>? characters,
  })  : customFields = customFields ?? {},
        characters = characters ?? [];
}
