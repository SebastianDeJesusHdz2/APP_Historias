import 'story_detail_screen.dart';
import 'package:flutter/material.dart';
import 'story_form.dart';
import 'package:provider/provider.dart';
import '../models/story.dart';
import '../main.dart'; // Para provider
import 'dart:io';
import 'dart:convert'; // <-- NUEVO para base64

class HomeScreen extends StatelessWidget {
  final void Function(bool) onThemeToggle;
  final bool isDark;

  HomeScreen({required this.onThemeToggle, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final storyProvider = Provider.of<StoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CronIA',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28, letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_rounded),
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
      body: storyProvider.stories.isEmpty
          ? Center(
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
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 22),
        itemCount: storyProvider.stories.length,
        itemBuilder: (context, index) {
          final story = storyProvider.stories[index];

          // Imagen: base64, url http o archivo local
          Widget leadingWidget;
          final img = story.imagePath;

          if (img != null && img.isNotEmpty) {
            final isBase64 = img.length > 100 && !img.startsWith('http') && !img.contains(Platform.pathSeparator);
            if (isBase64) {
              leadingWidget = ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.memory(
                  base64Decode(img),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, e, s) => Icon(Icons.book_rounded, size: 38),
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
                  errorBuilder: (ctx, e, s) => Icon(Icons.book_rounded, size: 38),
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
                  errorBuilder: (ctx, e, s) => Icon(Icons.book_rounded, size: 38),
                ),
              );
            }
          } else {
            leadingWidget = CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              radius: 32,
              child: Icon(Icons.book_rounded, size: 38, color: Colors.white),
            );
          }

          return Card(
            margin: EdgeInsets.only(bottom: 22),
            color: Theme.of(context).colorScheme.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => StoryDetailScreen(story: story),
                  ),
                );
                // Fuerza rebuild del Home tras volver del detalle
                Provider.of<StoryProvider>(context, listen: false).refresh();
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: Icon(Icons.add, color: Colors.white),
        label: Text('Nueva historia', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
