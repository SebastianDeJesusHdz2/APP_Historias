import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/character.dart';

class CharacterTile extends StatelessWidget {
  final Character character;
  final VoidCallback? onTap;

  const CharacterTile({required this.character, this.onTap, super.key});

  Widget _buildImage(String? img) {
    if (img == null || img.isEmpty) {
      return const Icon(Icons.person, size: 38);
    }
    final isBase64 = img.length > 100 &&
        !img.startsWith('http') &&
        !img.contains(Platform.pathSeparator);

    if (isBase64) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.memory(
          base64Decode(img),
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (ctx, e, s) => const Icon(Icons.person, size: 38),
        ),
      );
    } else if (img.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          img,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (ctx, e, s) => const Icon(Icons.person, size: 38),
        ),
      );
    } else {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(img),
          width: 42,
          height: 42,
          fit: BoxFit.cover,
          errorBuilder: (ctx, e, s) => const Icon(Icons.person, size: 38),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _buildImage(character.imagePath),
      title: Text(character.name),
      subtitle: Text(character.description),
      onTap: onTap,
    );
  }
}

