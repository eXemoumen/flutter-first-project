import 'package:flutter/material.dart';

class InternListTile extends StatelessWidget {
  const InternListTile({
    super.key,
    required this.name,
    required this.matricule,
    required this.department,
    this.onTap,
  });

  final String name;
  final String matricule;
  final String department;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(name),
        subtitle: Text('$matricule • $department'),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
