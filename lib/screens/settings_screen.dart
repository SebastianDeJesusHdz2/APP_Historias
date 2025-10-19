import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final apiKeyController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      final key = await LocalStorageService.getApiKey().timeout(Duration(seconds: 5), onTimeout: () => null);
      setState(() {
        apiKeyController.text = key ?? '';
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    await LocalStorageService.saveApiKey(apiKeyController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('API Key guardada correctamente.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configuración')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('API Key de Perplexity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(height: 18),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                labelText: 'Introduce tu API Key',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                prefixIcon: Icon(Icons.vpn_key),
              ),
            ),
            SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.save_alt_rounded),
                label: Text('Guardar', style: TextStyle(fontSize: 18)),
                onPressed: _saveApiKey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
