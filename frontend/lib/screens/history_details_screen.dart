import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';
import 'pdf_viewer_screen.dart';

class HistoryDetailsScreen extends StatelessWidget {
  final DiagnosisRecordModel record;

  const HistoryDetailsScreen({Key? key, required this.record}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color riskColor = AppTheme.accentLeaf;
    if (record.overallRiskLevel?.toLowerCase() == 'moderate') riskColor = Colors.orange;
    if (record.overallRiskLevel?.toLowerCase() == 'high') riskColor = AppTheme.alertRed;
    if (record.overallRiskLevel?.toLowerCase() == 'severe') riskColor = Colors.purple;

    return Scaffold(
      appBar: AppBar(
        title: Text('Record: ${record.sampleId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'View PDF Report',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfViewerScreen(
                    sampleId: record.sampleId,
                    reportUrl: '/api/reports/${record.id}',
                    crop: record.crop,
                    overallRisk: record.overallRiskLevel ?? 'N/A',
                    agronomicSummary: record.agronomicSummary,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Metadata Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          record.crop,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppTheme.primaryDarkGreen),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: riskColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: riskColor),
                          ),
                          child: Text(
                            '${record.overallRiskLevel ?? "Normal"} Risk',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: riskColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sample ID: ${record.sampleId}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        Text('Date: ${record.timestamp.split("T").first}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Leaf Condition
            if (record.leafDisease != null) ...[
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.accentLight,
                    child: Icon(Icons.center_focus_strong, color: AppTheme.primaryGreen),
                  ),
                  title: Text(
                    'Leaf Diagnosis: ${record.leafDisease!.replaceAll("_", " ")}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text('Confidence: ${record.leafConfidence?.toStringAsFixed(1) ?? "N/A"}%'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Soil Health
            if (record.soilStatus != null) ...[
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppTheme.accentLight,
                    child: Icon(Icons.terrain, color: AppTheme.secondaryGreen),
                  ),
                  title: Text(
                    'Soil Health: ${record.soilStatus}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  subtitle: Text('Confidence: ${record.soilConfidence?.toStringAsFixed(1) ?? "N/A"}%'),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Agronomic Summary
            if (record.agronomicSummary != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Agronomic Synthesis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(record.agronomicSummary!, style: const TextStyle(fontSize: 14, height: 1.4)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfViewerScreen(
                      sampleId: record.sampleId,
                      reportUrl: '/api/reports/${record.id}',
                      crop: record.crop,
                      overallRisk: record.overallRiskLevel ?? 'N/A',
                      agronomicSummary: record.agronomicSummary,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('View Official Diagnostic PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
