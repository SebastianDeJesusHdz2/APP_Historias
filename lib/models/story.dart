// lib/models/story.dart
import 'race.dart';

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

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'description': description,
    'imagePath': imagePath,
    'races': races.map((r) => r.toMap()).toList(),
  };

  factory Story.fromMap(Map<String, dynamic> m) => Story(
    id: m['id'] as String,
    title: m['title'] as String,
    description: m['description'] as String,
    imagePath: m['imagePath'] as String?,
    races: (m['races'] as List? ?? [])
        .map((x) => Race.fromMap((x as Map).cast<String, dynamic>()))
        .toList(),
  );
}
