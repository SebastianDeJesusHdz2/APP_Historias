import 'package:apphistorias/models/race.dart';

class Story {
  String id;
  String title;
  String description;
  String? imagePath;
  List<Race> races;

  Story({
    required this.id,
    required this.title,
    required this.description,
    this.imagePath,
    List<Race>? races,
  }) : races = races ?? [];

// Agrega métodos para serialización si usas Hive/SQFlite
}
