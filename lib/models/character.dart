class Character {
  String id;
  String name;
  String physicalTraits;
  String description;
  String personality;
  String? imagePath;                 // base64, url o path local
  String raceId;                     // raza seleccionada
  Map<String, dynamic> customFields; // valores por característica de la raza

  Character({
    required this.id,
    required this.name,
    required this.physicalTraits,
    required this.description,
    required this.personality,
    this.imagePath,
    required this.raceId,
    Map<String, dynamic>? customFields,
  }) : customFields = customFields ?? {};
}

