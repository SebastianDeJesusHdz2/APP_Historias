import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

// USA SIEMPRE imports tipo package: para evitar duplicados de tipos
import 'package:apphistorias/models/story.dart';
import 'package:apphistorias/models/race.dart';
import 'package:apphistorias/models/character.dart';

import 'package:apphistorias/screens/race_form.dart';
import 'package:apphistorias/screens/character_form.dart';

import 'package:apphistorias/widgets/race_tile.dart';
import 'package:apphistorias/widgets/character_tile.dart';
import 'package:apphistorias/widgets/image_selector.dart';

class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({Key? key, required this.story}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  // Imagen de historia
  void _actualizaImagen(String img) {
    setState(() {
      widget.story.imagePath = img;
    });
  }

  // Crear nueva raza (usa RaceForm con ImageSelector para IA/Subir)
  void goToNewRaceForm() async {
    final newRace = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const RaceForm()),
    );
    if (newRace != null && newRace is Race) {
      setState(() {
        widget.story.races.add(newRace);
      });
    }
  }

  // Crear nuevo personaje (general, sin fijar raza)
  void goToNewCharacterForm() async {
    if (widget.story.races.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Primero crea al menos una raza.')),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CharacterForm(
          races: widget.story.races,
          initialRace: widget.story.races.first,
        ),
      ),
    );

    if (result != null && result is Character) {
      setState(() {
        final race = widget.story.races.firstWhere(
              (r) => r.id == result.raceId,
          orElse: () => widget.story.races.first,
        );
        race.characters.add(result);
      });
    }
  }

  // Crear nuevo personaje para una raza específica
  void _newCharacterForRace(Race race) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => CharacterForm(
          races: widget.story.races,
          initialRace: race,
        ),
      ),
    );

    if (result != null && result is Character) {
      setState(() {
        race.characters.add(result);
      });
    }
  }

  // -------- Helpers Imagen (historia/raza/personaje) --------
  Widget _buildAnyImage(String? img, {double w = 120, double h = 120, BoxFit fit = BoxFit.cover}) {
    if (img == null || img.isEmpty) {
      return Icon(Icons.image, size: h, color: Colors.grey.shade300);
    }
    final isBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);

    if (isBase64) {
      return Image.memory(
        base64Decode(img),
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
      );
    }
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
      );
    }
    return Image.file(
      File(img),
      width: w,
      height: h,
      fit: fit,
      errorBuilder: (ctx, err, stack) => Icon(Icons.broken_image, color: Colors.red, size: h),
    );
  }

  void _showImagePreview(String? img) {
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
            child: Image.memory(base64Decode(img), fit: BoxFit.contain),
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

  // -------- Editor inline de raza (funcional) --------
  void _openRaceEditor(Race race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (ctx) {
        final nameCtrl = TextEditingController(text: race.name);
        final descCtrl = TextEditingController(text: race.description);
        String? tempImage = race.imagePath;

        // Copia editable de fields
        final fields = List<RaceFieldDef>.from(race.fields);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
            left: 16, right: 16, top: 12,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setModal) {
              void addField() {
                setModal(() {
                  fields.add(RaceFieldDef(key: '', label: '', type: RaceFieldType.text));
                });
              }

              void removeField(int i) {
                setModal(() {
                  fields.removeAt(i);
                });
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Editar Raza', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),

                    // Imagen + selector IA/Subir
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showImagePreview(tempImage),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildAnyImage(tempImage, w: 72, h: 72),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ImageSelector(
                            onImageSelected: (img) => setModal(() => tempImage = img),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Características', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: addField,
                          icon: const Icon(Icons.add),
                          label: const Text('Agregar'),
                        )
                      ],
                    ),

                    // Lista editable de características
                    ...fields.asMap().entries.map((e) {
                      final i = e.key;
                      final f = e.value;
                      final keyCtrl = TextEditingController(text: f.key);
                      final labelCtrl = TextEditingController(text: f.label);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: labelCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Etiqueta (ej: Tamaño de orejas)',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) => f.label = v,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: keyCtrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Clave (ej: tamano_orejas)',
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (v) => f.key = v,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Text('Tipo:'),
                                  const SizedBox(width: 10),
                                  DropdownButton<RaceFieldType>(
                                    value: f.type,
                                    onChanged: (v) {
                                      if (v != null) setModal(() => f.type = v);
                                    },
                                    items: const [
                                      DropdownMenuItem(
                                        value: RaceFieldType.text,
                                        child: Text('Texto'),
                                      ),
                                      DropdownMenuItem(
                                        value: RaceFieldType.number,
                                        child: Text('Número'),
                                      ),
                                      DropdownMenuItem(
                                        value: RaceFieldType.boolean,
                                        child: Text('Sí/No'),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    onPressed: () => removeField(i),
                                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                                    tooltip: 'Eliminar característica',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (nameCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('El nombre es obligatorio')),
                            );
                            return;
                          }
                          // Persistimos cambios en la raza original
                          setState(() {
                            race.name = nameCtrl.text.trim();
                            race.description = descCtrl.text.trim();
                            race.imagePath = tempImage;
                            race.fields = fields
                                .where((f) => f.key.trim().isNotEmpty && f.label.trim().isNotEmpty)
                                .toList();
                          });
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar cambios'),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumb = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: _buildAnyImage(widget.story.imagePath),
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
            // Columna izquierda: imagen + selector (historia) + LISTA DE RAZAS
            Expanded(
              flex: 12,
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () => _showImagePreview(widget.story.imagePath),
                    child: thumb,
                  ),
                  const SizedBox(height: 12),
                  ImageSelector(onImageSelected: _actualizaImagen),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text(
                        'Razas',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: goToNewRaceForm,
                        icon: const Icon(Icons.add),
                        label: const Text('Nueva Raza'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (widget.story.races.isEmpty)
                    const Text('Aún no hay razas. Agrega la primera.'),
                  ...widget.story.races.map((race) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        leading: GestureDetector(
                          onTap: () => _showImagePreview(race.imagePath),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildAnyImage(race.imagePath, w: 48, h: 48),
                          ),
                        ),
                        title: Text(race.name),
                        subtitle: Text(race.description),
                        trailing: TextButton.icon(
                          onPressed: () => _openRaceEditor(race),
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Columna derecha: info + BOTONES + PERSONAJES AGRUPADOS POR RAZA
            Expanded(
              flex: 18,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.person_add_alt_1),
                        label: const Text("Nuevo Personaje"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent[700]),
                        onPressed: goToNewCharacterForm,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Personajes por raza",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 8),

                  if (widget.story.races.isEmpty)
                    const Text('No hay razas; agrega una para comenzar con personajes.'),
                  ...widget.story.races.map((race) {
                    final count = race.characters.length;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildAnyImage(race.imagePath, w: 36, h: 36),
                        ),
                        title: Text(race.name),
                        subtitle: Text('$count personaje${count == 1 ? '' : 's'}'),
                        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () => _newCharacterForRace(race),
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar'),
                            ),
                          ],
                        ),
                        children: [
                          if (race.characters.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 12),
                              child: Text('Sin personajes en esta raza.'),
                            ),
                          ...race.characters.map((ch) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: CharacterTile(
                                character: ch,
                                onTap: () {
                                  // Aquí podrías abrir detalle/edición del personaje
                                },
                              ),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
