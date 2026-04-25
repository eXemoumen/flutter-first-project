import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/skill_mark_model.dart';

class PdfService {
  Future<File> exportEvaluationReport({
    required String internName,
    required List<SkillMarkModel> marks,
  }) async {
    final pdf = pw.Document();

    final average = marks.isEmpty
        ? 0.0
        : marks.map((e) => e.mark).reduce((a, b) => a + b) / marks.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            'Pro-Link Evaluation Report',
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text('Intern: $internName'),
          pw.Text('Average Mark: ${average.toStringAsFixed(2)}/20'),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey100),
            headers: const ['Skill', 'Mark', 'Comment', 'Date'],
            data: marks
                .map(
                  (m) => [
                    m.skillName,
                    m.mark.toStringAsFixed(2),
                    m.comment ?? '-',
                    m.evaluatedAt.toIso8601String().split('T').first,
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/pro_link_evaluation_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
