import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';
import '../components/gradcam_viewer.dart';
import 'fertilizer_details_screen.dart';

class DiseaseResultScreen extends StatelessWidget {
  final LeafPredictionResult result;

  const DiseaseResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isHealthy = result.predictedClass.toLowerCase().contains('healthy');
    final statusColor = isHealthy ? AppTheme.accentLeaf : AppTheme.alertRed;

    final originalFullUrl = provider.apiService.getAbsoluteAssetUrl(result.imageUrl);
    final gradcamFullUrl = provider.apiService.getAbsoluteAssetUrl(result.gradcamUrl);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaf Vision Diagnosis'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: isHealthy ? AppTheme.accentLight : const Color(0xFFFFEBEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: statusColor, width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      isHealthy ? Icons.check_circle_outline : Icons.coronavirus_outlined,
                      size: 54,
                      color: statusColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      result.predictedClass.replaceAll('_', ' '),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crop: ${result.crop}  •  Confidence: ${result.confidence.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            GradCamViewer(
              gradcamBase64: result.gradcamBase64,
              gradcamUrl: gradcamFullUrl.isNotEmpty ? gradcamFullUrl : null,
              originalImageUrl: originalFullUrl.isNotEmpty ? originalFullUrl : null,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Top-3 Candidate Predictions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 12),
                    ...result.top3Predictions.map((pred) {
                      final pct = pred.confidence / 100.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pred.cropClass.replaceAll('_', ' '),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text('${pred.confidence.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct.clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  pred.cropClass.toLowerCase().contains('healthy') ? AppTheme.accentLeaf : AppTheme.secondaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!isHealthy)
              ElevatedButton.icon(
                onPressed: () {
                  final item = PlantProtectionItem(
                    targetCondition: result.predictedClass,
                    recommendedProtection: 'Validated Bio-Fungicide / Copper Oxychloride',
                    dosage: '2.5 gm/L water foliar spray',
                    farmerAdvisory: 'Spray immediately upon lesion observation in morning hours.',
                    urgency: 'High',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FertilizerDetailsScreen(
                        protectionItem: item,
                        crop: result.crop,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text('View Prescribed Protection Remedy'),
              ),
          ],
        ),
      ),
    );
  }
}
