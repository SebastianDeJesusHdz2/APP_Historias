import 'package:flutter/material.dart';

class RaceForm extends StatefulWidget {
  @override
  _RaceFormState createState() => _RaceFormState();
}

class _RaceFormState extends State<RaceForm> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  // Campos personalizados: podrías gestionarlos con List<Map> según lógica
  List<Map<String, TextEditingController>> customFields = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nueva Raza')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            // Aquí construiría campos personalizados de forma dinámica
            ElevatedButton(
              onPressed: () {
                // Guardar raza
              },
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
