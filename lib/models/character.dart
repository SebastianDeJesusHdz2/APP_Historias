class Character {
  String id;
  String name;
  String physicalTraits;
  String description;
  String personality;
  String? imagePath;
  String raceId;
  Map<String, dynamic> customFields; // Por si algunas razas requieren campos extra

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
