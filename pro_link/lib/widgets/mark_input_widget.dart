import 'package:flutter/material.dart';

class MarkInputWidget extends StatelessWidget {
  const MarkInputWidget({
    super.key,
    required this.skill,
    required this.controller,
    required this.commentController,
  });

  final String skill;
  final TextEditingController controller;
  final TextEditingController commentController;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skill,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Mark / 20',
                hintText: 'e.g. 16.5',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: commentController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Comment',
                hintText: 'Add qualitative feedback',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
