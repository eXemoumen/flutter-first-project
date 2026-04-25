import 'package:flutter/material.dart';

class TrainingModuleCard extends StatelessWidget {
  const TrainingModuleCard({
    super.key,
    required this.title,
    required this.description,
    required this.fileType,
    this.onOpen,
  });

  final String title;
  final String description;
  final String fileType;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book_rounded),
        title: Text(title),
        subtitle: Text(description),
        trailing: TextButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.open_in_new_rounded),
          label: Text(fileType.toUpperCase()),
        ),
      ),
    );
  }
}
