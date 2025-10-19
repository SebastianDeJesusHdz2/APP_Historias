import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/character.dart';
import '../models/race.dart';
import '../widgets/image_selector.dart';

class CharacterForm extends StatefulWidget {
  final List<Race> races;      // Razas disponibles
  final Race? initialRace;     // Opcional: raza preseleccionada

  const CharacterForm({required this.races, this.initialRace, super.key});

  @override
  _CharacterFormState createState() => _CharacterFormState();
}

class _CharacterFormState extends State<CharacterForm> {
  final nameController = TextEditingController();
  final physicalTraitsController = TextEditingController();
  final descriptionController = TextEditingController();
  final personalityController = TextEditingController();

  Race? _selectedRace;
  String? _image; // base64, url, path

  // Para campos dinámicos
  final Map<String, TextEditingController> _textCtrls = {};
  final Map<String, TextEditingController> _numberCtrls = {};
  final Map<String, bool> _boolValues = {};

  @override
  void initState() {
    super.initState();
    _selectedRace = widget.initialRace ?? (widget.races.isNotEmpty ? widget.races.first : null);
    _buildRaceDynamicState();
  }

  @override
  void dispose() {
    nameController.dispose();
    physicalTraitsController.dispose();
    descriptionController.dispose();
    personalityController.dispose();
    _textCtrls.values.forEach((c) => c.dispose());
    _numberCtrls.values.forEach((c) => c.dispose());
    super.dispose();
  }

  void _onImageSelected(String v) {
    setState(() => _image = v);
  }

  void _onRaceChanged(Race? r) {
    setState(() {
      _selectedRace = r;
      _buildRaceDynamicState();
    });
  }

  void _buildRaceDynamicState() {
    // Limpia controladores antiguos
    _textCtrls.clear();
    _numberCtrls.clear();
    _boolValues.clear();

    if (_selectedRace == null) return;

    for (final f in _selectedRace!.fields) {
      switch (f.type) {
        case RaceFieldType.text:
          _textCtrls[f.key] = TextEditingController();
          break;
        case RaceFieldType.number:
          _numberCtrls[f.key] = TextEditingController();
          break;
        case RaceFieldType.boolean:
          _boolValues[f.key] = false;
          break;
      }
    }
  }

  Widget _buildRaceFields() {
    if (_selectedRace == null) {
      return const Text('No hay razas disponibles.');
    }
    if (_selectedRace!.fields.isEmpty) {
      return const Text('Esta raza no define características adicionales.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _selectedRace!.fields.map((f) {
        switch (f.type) {
          case RaceFieldType.text:
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _textCtrls[f.key],
                decoration: InputDecoration(
                  labelText: f.label,
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          case RaceFieldType.number:
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _numberCtrls[f.key],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: f.label,
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          case RaceFieldType.boolean:
            return SwitchListTile(
              title: Text(f.label),
              value: _boolValues[f.key] ?? false,
              onChanged: (v) => setState(() => _boolValues[f.key] = v),
            );
        }
      }).toList(),
    );
  }

  void _save() {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El nombre es obligatorio.')),
      );
      return;
    }
    if (_selectedRace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una raza.')),
      );
      return;
    }

    // Construye customFields combinando los tipos
    final Map<String, dynamic> customFields = {};
    _textCtrls.forEach((k, v) => customFields[k] = v.text.trim());
    _numberCtrls.forEach((k, v) {
      final raw = v.text.trim();
      if (raw.isEmpty) {
        customFields[k] = null;
      } else {
        // Intenta parsear a num
        final n = num.tryParse(raw);
        customFields[k] = n ?? raw; // si falla, guarda como texto
      }
    });
    _boolValues.forEach((k, v) => customFields[k] = v);

    final character = Character(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      physicalTraits: physicalTraitsController.text.trim(),
      description: descriptionController.text.trim(),
      personality: personalityController.text.trim(),
      imagePath: _image,
      raceId: _selectedRace!.id,
      customFields: customFields,
    );

    Navigator.pop(context, character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Personaje')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Imagen del personaje (IA/Subir)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _previewImage(_image),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ImageSelector(onImageSelected: _onImageSelected),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Datos base
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: physicalTraitsController,
              decoration: const InputDecoration(
                labelText: 'Características físicas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: personalityController,
              decoration: const InputDecoration(
                labelText: 'Personalidad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Selección de raza
            DropdownButtonFormField<Race>(
              value: _selectedRace,
              items: widget.races
                  .map((r) => DropdownMenuItem(value: r, child: Text(r.name)))
                  .toList(),
              onChanged: _onRaceChanged,
              decoration: const InputDecoration(
                labelText: 'Raza',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campos dinámicos por raza
            _buildRaceFields(),

            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewImage(String? img) {
    if (img == null || img.isEmpty) {
      return Container(
        width: 72,
        height: 72,
        color: Colors.black12,
        child: const Icon(Icons.image, size: 32),
      );
    }
    final isBase64 = img.length > 100 &&
        !img.startsWith('http') &&
        !img.contains(Platform.pathSeparator);

    if (isBase64) {
      return Image.memory(
        base64Decode(img),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    } else if (img.startsWith('http')) {
      return Image.network(
        img,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    } else {
      return Image.file(
        File(img),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      );
    }
  }
}
