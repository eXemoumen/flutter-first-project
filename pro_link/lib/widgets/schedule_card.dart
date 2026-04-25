import 'package:flutter/material.dart';

import '../utils/date_formatter.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    super.key,
    required this.title,
    required this.department,
    required this.validFrom,
    required this.validTo,
  });

  final String title;
  final String department;
  final DateTime validFrom;
  final DateTime validTo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text('Department: $department'),
            Text(
              'Valid: ${DateFormatter.short(validFrom)} - ${DateFormatter.short(validTo)}',
            ),
          ],
        ),
      ),
    );
  }
}
