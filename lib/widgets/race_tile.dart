import 'dart:io';
import 'package:flutter/material.dart';
import 'package:apphistorias/models/race.dart';

class RaceTile extends StatelessWidget {
  final Race race;
  final VoidCallback? onTap;

  RaceTile({required this.race, this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget leadingWidget;
    if (race.imagePath != null && race.imagePath!.isNotEmpty) {
      leadingWidget = Image.file(
        File(race.imagePath!),
        width: 39,
        height: 39,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.group_work, size: 36),
      );
    } else {
      leadingWidget = Icon(Icons.group_work, size: 36);
    }

    return ListTile(
      leading: leadingWidget,
      title: Text(race.name),
      subtitle: Text(race.description),
      onTap: onTap,
    );
  }
}
