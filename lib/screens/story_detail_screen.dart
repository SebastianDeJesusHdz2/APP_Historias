import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import '../models/story.dart';
import '../screens/race_form.dart';
import '../screens/character_form.dart';
import '../widgets/race_tile.dart';
import '../widgets/image_selector.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  void _actualizaImagen(String img) {
    setState(() {
      widget.story.imagePath = img;
    });
  }

  void goToNewRaceForm() async {
    final newRace = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => RaceForm()),
    );
    if (newRace != null) {
      setState(() {
        widget.story.races.add(newRace);
      });
    }
  }

  void goToNewCharacterForm() async {
    final newCharacter = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => CharacterForm()),
    );
    if (newCharacter != null) {
      setState(() {
        // Lógica de asignación si corresponde.
      });
    }
  }

  Widget _buildStoryImage(String? img, {double w = 120, double h = 120}) {
    if (img == null || img.isEmpty) {
      return Icon(Icons.image, size: h, color: Colors.grey.shade300);
    }
    final isBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);

    if (isBase64) {
      return Image.memory(
        base64Decode(img),
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
      );
    }
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: w,
        height: h,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
      );
    }
    return Image.file(
      File(img),
      width: w,
      height: h,
      fit: BoxFit.cover,
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
    );
  }

  void _showImagePreview() {
    final img = widget.story.imagePath;
    if (img == null || img.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        final isBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);

        Widget largeImage;
        if (isBase64) {
          largeImage = InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.memory(
              base64Decode(img),
              fit: BoxFit.contain,
            ),
          );
        } else if (img.startsWith('http')) {
          largeImage = InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.network(img, fit: BoxFit.contain),
          );
        } else {
          largeImage = InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.file(File(img), fit: BoxFit.contain),
          );
        }

        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.2),
          insetPadding: const EdgeInsets.all(12),
          child: Stack(
            children: [
              Center(child: largeImage),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _buildStoryImage(widget.story.imagePath),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles de la Historia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna izquierda: imagen + selector
            Column(
              children: [
                // Toca la miniatura para ver en grande
                GestureDetector(
                  onTap: _showImagePreview,
                  child: thumb,
                ),
                const SizedBox(height: 16),
                ImageSelector(onImageSelected: _actualizaImagen),
              ],
            ),
            const SizedBox(width: 24),
            // Columna derecha: datos + acciones + listas
            Expanded(
              child: ListView(
                children: [
                  Text(
                    widget.story.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.story.description,
                    style: TextStyle(fontSize: 17, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.group),
                        label: const Text("Nueva Raza"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[700]),
                        onPressed: goToNewRaceForm,
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person),
                        label: const Text("Nuevo Personaje"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent[700]),
                        onPressed: goToNewCharacterForm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Razas:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ...widget.story.races.map((race) => RaceTile(race: race)),
                  // Agrega aquí una sección de personajes si lo deseas.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
