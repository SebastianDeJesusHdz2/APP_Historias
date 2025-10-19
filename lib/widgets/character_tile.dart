import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;

  CharacterTile({required this.character, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: character.imagePath != null
          ? Image.asset(character.imagePath!)
          : Icon(Icons.person),
      title: Text(character.name),
      subtitle: Text(character.description),
      onTap: onTap,
    );
  }
}
