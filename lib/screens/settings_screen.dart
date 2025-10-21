// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final apiKeyController = TextEditingController();
  bool _loading = true;
  bool _hideKey = true;

  // Preferencias básicas (si ya las usas)
  bool _showDeleteHint = true;
  bool _confirmBeforeDelete = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Carga key si existe
    final key = await LocalStorageService.getApiKey();
    final showHint = await LocalStorageService.getPrefBool('showDeleteHint') ?? true;
    final confirmDel = await LocalStorageService.getPrefBool('confirmBeforeDelete') ?? true;

    if (mounted) {
      setState(() {
        apiKeyController.text = key ?? '';
        _showDeleteHint = showHint;
        _confirmBeforeDelete = confirmDel;
        _loading = false;
      });
    }
  }

  Future<void> _saveApiKey() async {
    await LocalStorageService.saveApiKey(apiKeyController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key guardada localmente.')),
      );
    }
  }

  Future<void> _clearLocalCaches() async {
    await LocalStorageService.clearAllData(); // Vacía todas las cajas (incluida apiKey)
    if (mounted) {
      setState(() {
        apiKeyController.clear(); // deja el campo en blanco inmediatamente
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cachés y API key borradas.')),
      );
    }
  }

  Future<void> _toggleShowDeleteHint(bool v) async {
    setState(() => _showDeleteHint = v);
    await LocalStorageService.setPrefBool('showDeleteHint', v);
  }

  Future<void> _toggleConfirmBeforeDelete(bool v) async {
    setState(() => _confirmBeforeDelete = v);
    await LocalStorageService.setPrefBool('confirmBeforeDelete', v);
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text('API externa', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: apiKeyController,
                      obscureText: _hideKey,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: InputDecoration(
                        labelText: 'API key',
                        helperText: 'Se almacena localmente con Hive; puedes borrarla desde esta pantalla.',
                        prefixIcon: const Icon(Icons.vpn_key),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hideKey = !_hideKey),
                          icon: Icon(_hideKey ? Icons.visibility_off : Icons.visibility),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveApiKey,
                            icon: const Icon(Icons.save_alt_rounded),
                            label: const Text('Guardar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => apiKeyController.clear()),
                            icon: const Icon(Icons.cleaning_services_outlined),
                            label: const Text('Limpiar campo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text('Preferencias', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    title: const Text('Mostrar consejo de borrado'),
                    value: _showDeleteHint,
                    onChanged: _toggleShowDeleteHint,
                    subtitle: const Text('“Desliza hacia la izquierda para eliminar”'),
                    secondary: const Icon(Icons.swipe_left_alt_rounded),
                  ),
                  const Divider(height: 0),
                  SwitchListTile.adaptive(
                    title: const Text('Confirmar antes de eliminar'),
                    value: _confirmBeforeDelete,
                    onChanged: _toggleConfirmBeforeDelete,
                    subtitle: const Text('Diálogo de confirmación antes de borrar'),
                    secondary: const Icon(Icons.warning_amber_rounded),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
            child: Text('Datos locales', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Borrar historias y cachés locales'),
                subtitle: const Text('Incluye la API key guardada'),
                trailing: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
                  onPressed: _clearLocalCaches,
                  child: const Text('Borrar todo'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


