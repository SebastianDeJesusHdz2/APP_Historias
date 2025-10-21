// lib/screens/home_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Imports por paquete
import 'package:apphistorias/models/story.dart';
import 'package:apphistorias/main.dart'; // StoryProvider
import 'package:apphistorias/screens/story_detail_screen.dart';
import 'package:apphistorias/screens/story_form.dart';

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeToggle;
  final bool isDark;

  const HomeScreen({super.key, required this.onThemeToggle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);
    final hasStories = storyProvider.stories.isNotEmpty;

    Widget buildHint({EdgeInsets padding = const EdgeInsets.fromLTRB(22, 12, 22, 6)}) {
      final color = Theme.of(context).colorScheme.secondary;
      return Padding(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.swipe_left_rounded, size: 18, color: color),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Consejo: desliza hacia la izquierda cualquier historia para eliminarla.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'CronIA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Configuración',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          Switch(
            value: isDark,
            onChanged: onThemeToggle,
            activeColor: Theme.of(context).colorScheme.secondary,
            inactiveThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: !hasStories
          ? Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            'Sin historias todavía.\n¡Crea tu primera historia y empieza a imaginar!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w400,
              letterSpacing: 1.2,
            ),
          ),
        ),
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Consejo solo cuando hay historias
          buildHint(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
              itemCount: storyProvider.stories.length,
              itemBuilder: (context, index) {
                final story = storyProvider.stories[index];

                // Imagen: base64, url http o archivo local
                Widget leadingWidget;
                final img = story.imagePath;

                if (img != null && img.isNotEmpty) {
                  final isBase64 = img.length > 100 &&
                      !img.startsWith('http') &&
                      !img.contains(Platform.pathSeparator);
                  if (isBase64) {
                    leadingWidget = ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        base64Decode(img),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) =>
                        const Icon(Icons.book_rounded, size: 38),
                      ),
                    );
                  } else if (img.startsWith('http')) {
                    leadingWidget = ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        img,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) =>
                        const Icon(Icons.book_rounded, size: 38),
                      ),
                    );
                  } else {
                    leadingWidget = ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(
                        File(img),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, e, s) =>
                        const Icon(Icons.book_rounded, size: 38),
                      ),
                    );
                  }
                } else {
                  leadingWidget = CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    radius: 32,
                    child: const Icon(Icons.book_rounded,
                        size: 38, color: Colors.white),
                  );
                }

                return Dismissible(
                  key: ValueKey(story.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (_) async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Eliminar historia'),
                        content: const Text(
                          'Esta acción no se puede deshacer, ¿deseas continuar?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                    return ok ?? false;
                  },
                  onDismissed: (_) {
                    // Quita del Provider; si queda vacío, desaparece el consejo al reconstruirse
                    storyProvider.removeStoryAt(index);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Historia eliminada')),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 22),
                    color: Theme.of(context).colorScheme.surface,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 18, horizontal: 20),
                      leading: leadingWidget,
                      title: Text(
                        story.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: Theme.of(context).colorScheme.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      subtitle: Text(
                        story.description,
                        style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_right_rounded,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 30,
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => StoryDetailScreen(story: story),
                          ),
                        );
                        if (result == 'deleted') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Historia eliminada')),
                          );
                        }
                        Provider.of<StoryProvider>(context, listen: false)
                            .refresh();
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nueva historia',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final newStory = await Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => StoryForm()),
          );
          if (newStory != null && newStory is Story) {
            storyProvider.addStory(newStory);
          }
        },
      ),
    );
  }
}
