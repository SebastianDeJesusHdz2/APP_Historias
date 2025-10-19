import 'package:flutter/material.dart';

class CharacterForm extends StatefulWidget {
  @override
  _CharacterFormState createState() => _CharacterFormState();
}

class _CharacterFormState extends State<CharacterForm> {
  final nameController = TextEditingController();
  final physicalTraitsController = TextEditingController();
  final descriptionController = TextEditingController();
  final personalityController = TextEditingController();

  // Añadir selector de raza, imagen, y campos extra si la raza lo requiere.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nuevo Personaje')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: physicalTraitsController,
              decoration: InputDecoration(labelText: 'Características físicas'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            TextField(
              controller: personalityController,
              decoration: InputDecoration(labelText: 'Personalidad'),
            ),
            // Selector de raza y campos adicionales dinámicos aquí
            ElevatedButton(
              onPressed: () {
                // Guardar personaje
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
