import 'package:flutter/material.dart';

import '../models/user_model.dart';

class RoleBadge extends StatelessWidget {
  const RoleBadge({super.key, required this.role});

  final AppRole role;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (role) {
      AppRole.admin => ('Admin', const Color(0xFFB35300)),
      AppRole.mentor => ('Mentor', const Color(0xFF006D77)),
      AppRole.intern => ('Intern', const Color(0xFF1F7A1F)),
    };

    return Chip(
      label: Text(label),
      backgroundColor: color.withOpacity(0.12),
      labelStyle: TextStyle(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
