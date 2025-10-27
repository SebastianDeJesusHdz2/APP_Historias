// lib/screens/story_detail_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

// Imports por paquete para evitar duplicados
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
  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  // ================== Helpers ==================
  Race? _raceById(String? id) {
    try {
      return widget.story.races.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  // Imagen de historia (solo actualiza; persiste fuera con Provider.saveAll si lo usas)
  void _actualizaImagen(String img) {
    setState(() => widget.story.imagePath = img);
  }

  // Crear nueva raza
  Future<void> goToNewRaceForm() async {
    final newRace = await Navigator.push(
      context,
      MaterialPageRoute(builder: (ctx) => const RaceForm()),
    );
    if (newRace != null && newRace is Race) {
      setState(() => widget.story.races.add(newRace));
    }
  }

  // Crear nuevo personaje para una raza específica
  Future<void> _newCharacterForRace(Race race) async {
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
      setState(() => race.characters.add(result));
    }
  }

  // -------- Helpers Imagen (historia/raza/personaje) --------
  Widget _buildAnyImage(String? img, {double w = 120, double h = 120, BoxFit fit = BoxFit.cover}) {
    if (img == null || img.isEmpty) {
      return Container(
        width: w,
        height: h,
        color: Colors.black12,
        child: Icon(Icons.image, size: h * 0.45, color: Colors.grey.shade400),
      );
    }
    final looksBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);

    if (looksBase64) {
      try {
        final bytes = base64Decode(img);
        return Image.memory(
          bytes,
          width: w,
          height: h,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _broken(w, h),
        );
      } catch (_) {
        return _broken(w, h);
      }
    }
    if (img.startsWith('http')) {
      return Image.network(
        img,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (ctx, err, stack) => _broken(w, h),
      );
    }
    final file = File(img);
    if (!file.existsSync()) return _broken(w, h);
    return Image.file(
      file,
      width: w,
      height: h,
      fit: fit,
      errorBuilder: (ctx, err, stack) => _broken(w, h),
    );
  }

  Widget _broken(double w, double h) => Container(
    width: w,
    height: h,
    color: Colors.black12,
    child: Icon(Icons.broken_image, size: h * 0.45, color: Colors.redAccent),
  );

  void _showImagePreview(String? img) {
    if (img == null || img.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        final looksBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);

        Widget largeImage;
        if (looksBase64) {
          try {
            largeImage = InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.memory(base64Decode(img), fit: BoxFit.contain),
            );
          } catch (_) {
            largeImage = _broken(double.infinity, 220);
          }
        } else if (img.startsWith('http')) {
          largeImage = InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.network(img, fit: BoxFit.contain, errorBuilder: (_, __, ___) => _broken(double.infinity, 220)),
          );
        } else {
          final f = File(img);
          largeImage = InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: f.existsSync()
                ? Image.file(f, fit: BoxFit.contain)
                : _broken(double.infinity, 220),
          );
        }

        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.6),
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

  // ================== Editor / Vista de Raza ==================
  void _openRaceEditor(Race race) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (ctx) {
        final nameCtrl = TextEditingController(text: race.name);
        final descCtrl = TextEditingController(text: race.description);
        String? tempImage = race.imagePath;

        final fields = List<RaceFieldDef>.from(race.fields);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
            left: 16, right: 16, top: 12,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setModal) {
              void addField() => setModal(() => fields.add(RaceFieldDef(key: '', label: '', type: RaceFieldType.text)));
              void removeField(int i) => setModal(() => fields.removeAt(i));

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Editar Raza', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
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
                          child: ImageSelector(onImageSelected: (img) => setModal(() => tempImage = img)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Características', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        TextButton.icon(onPressed: addField, icon: const Icon(Icons.add), label: const Text('Agregar')),
                      ],
                    ),
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
                                      decoration: const InputDecoration(labelText: 'Etiqueta', border: OutlineInputBorder()),
                                      onChanged: (v) => f.label = v,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: keyCtrl,
                                      decoration: const InputDecoration(labelText: 'Clave', border: OutlineInputBorder()),
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
                                    onChanged: (v) => v != null ? setModal(() => f.type = v) : null,
                                    items: const [
                                      DropdownMenuItem(value: RaceFieldType.text, child: Text('Texto')),
                                      DropdownMenuItem(value: RaceFieldType.number, child: Text('Número')),
                                      DropdownMenuItem(value: RaceFieldType.boolean, child: Text('Sí/No')),
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
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
                            return;
                          }
                          setState(() {
                            race.name = nameCtrl.text.trim();
                            race.description = descCtrl.text.trim();
                            race.imagePath = tempImage;
                            race.fields = fields.where((f) => f.key.trim().isNotEmpty && f.label.trim().isNotEmpty).toList();
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

  Future<void> _confirmDeleteRace(Race race) async {
    final count = race.characters.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar raza'),
        content: Text(count == 0
            ? '¿Seguro que quieres eliminar la raza "${race.name}"?'
            : 'La raza "${race.name}" tiene $count personaje${count == 1 ? '' : 's'}. Se eliminarán también.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => widget.story.races.removeWhere((r) => r.id == race.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Raza "${race.name}" eliminada')));
    }
  }

  // ================== Vista / Edición de Personaje ==================
  void _showCharacterPreview(Race race, Character ch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16, right: 16, top: 12,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ch.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _showImagePreview(ch.imagePath),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _buildAnyImage(ch.imagePath, w: double.infinity, h: 180, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                Text((ch.description ?? '').isEmpty ? 'Sin descripción.' : (ch.description ?? ''), style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(onPressed: () { Navigator.pop(ctx); _openCharacterEditor(race, ch); }, icon: const Icon(Icons.edit), label: const Text('Editar')),
                    TextButton.icon(onPressed: () { Navigator.pop(ctx); _confirmDeleteCharacter(race, ch); },
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                    OutlinedButton.icon(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close), label: const Text('Cerrar')),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCharacterEditor(Race currentRace, Character ch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      builder: (ctx) {
        final nameCtrl = TextEditingController(text: ch.name);
        final descCtrl = TextEditingController(text: ch.description ?? '');
        String? tempImage = ch.imagePath;
        Race selectedRace = _raceById(ch.raceId) ?? currentRace;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            left: 16, right: 16, top: 12,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setModal) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Editar Personaje', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
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
                        Expanded(child: ImageSelector(onImageSelected: (img) => setModal(() => tempImage = img))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    InputDecorator(
                      decoration: const InputDecoration(labelText: 'Raza', border: OutlineInputBorder()),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Race>(
                          value: selectedRace,
                          items: widget.story.races.map((r) => DropdownMenuItem<Race>(value: r, child: Text(r.name))).toList(),
                          onChanged: (r) => r != null ? setModal(() => selectedRace = r) : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
                            return;
                          }
                          setState(() {
                            ch.name = name;
                            ch.description = descCtrl.text.trim();
                            ch.imagePath = tempImage;
                            if (ch.raceId != selectedRace.id) {
                              final oldRace = _raceById(ch.raceId) ?? currentRace;
                              oldRace.characters.removeWhere((c) => c.id == ch.id);
                              ch.raceId = selectedRace.id;
                              selectedRace.characters.add(ch);
                            }
                          });
                          Navigator.pop(ctx);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Personaje actualizado')));
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar cambios'),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteCharacter(Race race, Character ch) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar personaje'),
        content: Text('¿Seguro que quieres eliminar a "${ch.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => race.characters.removeWhere((c) => c.id == ch.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Personaje "${ch.name}" eliminado')));
    }
  }

  // ================== UI ==================
  @override
  Widget build(BuildContext context) {
    final leftColumn = [
      GestureDetector(
        onTap: () => _showImagePreview(widget.story.imagePath),
        child: ClipRRect(borderRadius: BorderRadius.circular(16), child: _buildAnyImage(widget.story.imagePath)),
      ),
      const SizedBox(height: 12),
      ImageSelector(onImageSelected: _actualizaImagen),
      const SizedBox(height: 20),
      Row(
        children: [
          const Text('Razas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const Spacer(),
          TextButton.icon(onPressed: goToNewRaceForm, icon: const Icon(Icons.add), label: const Text('Nueva Raza')),
        ],
      ),
      const SizedBox(height: 6),
      if (widget.story.races.isEmpty) const Text('Aún no hay razas. Agrega la primera.'),
      ...widget.story.races.map((race) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            leading: GestureDetector(
              onTap: () => _showImagePreview(race.imagePath),
              child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildAnyImage(race.imagePath, w: 48, h: 48)),
            ),
            title: Text(race.name, overflow: TextOverflow.ellipsis),
            subtitle: Text(race.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Wrap(
              spacing: 6,
              children: [
                IconButton(tooltip: 'Editar', onPressed: () => _openRaceEditor(race), icon: const Icon(Icons.edit)),
                IconButton(tooltip: 'Eliminar raza', onPressed: () => _confirmDeleteRace(race), icon: const Icon(Icons.delete_forever, color: Colors.red)),
              ],
            ),
          ),
        );
      }),
    ];

    final rightColumn = [
      Text(widget.story.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 26), overflow: TextOverflow.ellipsis),
      const SizedBox(height: 8),
      Text(widget.story.description, style: TextStyle(fontSize: 17, color: Colors.grey[700])),
      const SizedBox(height: 20),
      const Text('Personajes por raza', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      const SizedBox(height: 8),
      if (widget.story.races.isEmpty) const Text('No hay razas; agrega una para comenzar con personajes.'),
      ...widget.story.races.map((race) {
        final count = race.characters.length;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildAnyImage(race.imagePath, w: 36, h: 36)),
            title: Text(race.name, overflow: TextOverflow.ellipsis),
            subtitle: Text('$count personaje${count == 1 ? '' : 's'}'),
            childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            trailing: Wrap(
              spacing: 8,
              children: [
                TextButton.icon(onPressed: () => _newCharacterForRace(race), icon: const Icon(Icons.add), label: const Text('Agregar')),
                IconButton(tooltip: 'Eliminar raza', onPressed: () => _confirmDeleteRace(race), icon: const Icon(Icons.delete_forever, color: Colors.red)),
              ],
            ),
            children: [
              if (race.characters.isEmpty)
                const Padding(padding: EdgeInsets.only(bottom: 12), child: Text('Sin personajes en esta raza.')),
              ...race.characters.map((ch) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    leading: GestureDetector(
                      onTap: () => _showImagePreview(ch.imagePath),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildAnyImage(ch.imagePath, w: 44, h: 44)),
                    ),
                    title: Text(ch.name, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      (ch.description ?? '').isEmpty
                          ? 'Sin descripción'
                          : (ch.description!.length > 80 ? '${ch.description!.substring(0, 80)}...' : ch.description!),
                    ),
                    onTap: () => _showCharacterPreview(race, ch),
                    trailing: Wrap(
                      spacing: 6,
                      children: [
                        IconButton(tooltip: 'Ver', onPressed: () => _showCharacterPreview(race, ch), icon: const Icon(Icons.visibility)),
                        IconButton(tooltip: 'Editar', onPressed: () => _openCharacterEditor(race, ch), icon: const Icon(Icons.edit)),
                        IconButton(tooltip: 'Eliminar', onPressed: () => _confirmDeleteCharacter(race, ch), icon: const Icon(Icons.delete_forever, color: Colors.red)),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    ];

    // Responsive: móvil 1 columna; tablet/desktop 2 columnas
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;
        return Scaffold(
          appBar: AppBar(title: const Text('Detalles de la Historia')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: isMobile
                ? ListView(
              children: [
                ...leftColumn,
                const SizedBox(height: 24),
                ...rightColumn,
              ],
            )
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 12,
                  child: ListView(children: leftColumn),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 18,
                  child: ListView(children: rightColumn),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
