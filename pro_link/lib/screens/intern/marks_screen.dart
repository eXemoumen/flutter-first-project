import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../providers/intern_provider.dart';
import '../../services/pdf_service.dart';
import '../../utils/app_feedback.dart';
import '../../widgets/responsive_page.dart';

class MarksScreen extends ConsumerWidget {
  const MarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(internProvider);
    final user = ref.watch(authProvider).currentUser;
    final marks = state.marks;
    final average = state.averageMark;

    Future<void> exportPdf() async {
      try {
        final file = await PdfService().exportEvaluationReport(
          internName: user?.fullName ?? 'Intern',
          marks: marks,
        );

        if (!context.mounted) return;
        await launchUrl(Uri.file(file.path));
      } catch (e) {
        if (!context.mounted) return;
        AppFeedback.error(context, 'Export failed: $e');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Evaluations'),
        actions: [
          IconButton(
            onPressed: exportPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 980,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Average Mark',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${average.toStringAsFixed(2)} / 20',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(value: (average / 20).clamp(0, 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (marks.isNotEmpty)
              SizedBox(
                height: 220,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: BarChart(
                      BarChartData(
                        maxY: 20,
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 26),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= marks.length) {
                                  return const SizedBox.shrink();
                                }
                                final skill = marks[index].skillName;
                                final end = skill.length > 6 ? 6 : skill.length;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(skill.substring(0, end)),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          marks.length,
                          (index) => BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: marks[index].mark,
                                width: 16,
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            for (final mark in marks)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(mark.skillName),
                  subtitle: Text(mark.comment ?? 'No comment'),
                  trailing: Text(
                    mark.mark.toStringAsFixed(2),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

