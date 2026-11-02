import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';
import 'fertilizer_details_screen.dart';

class SoilResultScreen extends StatelessWidget {
  final SoilPredictionResult result;

  const SoilResultScreen({Key? key, required this.result}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHealthy = result.status.toLowerCase() == 'healthy';
    final statusColor = isHealthy ? AppTheme.accentLeaf : AppTheme.alertRed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Health Evaluation'),
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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Icon(
                      isHealthy ? Icons.eco_rounded : Icons.warning_rounded,
                      size: 54,
                      color: statusColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Soil Status: ${result.status}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Crop: ${result.crop}  •  Healthy Probability: ${(result.pHealthy * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.analytics_outlined, color: AppTheme.secondaryGreen),
                        SizedBox(width: 8),
                        Text('Local SHAP Feature Attributions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Impact of individual sensor readings on XGBoost soil health classification:',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    if (result.topShapFeatures.isEmpty)
                      const Text('No SHAP features generated.', style: TextStyle(fontStyle: FontStyle.italic))
                    else
                      ...result.topShapFeatures.map((sf) {
                        final isPositive = sf.shapValue >= 0;
                        final barColor = isPositive ? AppTheme.accentLeaf : AppTheme.alertRed;
                        final normVal = (sf.shapValue.abs() / 2.0).clamp(0.05, 1.0);

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${sf.feature} (Val: ${sf.measuredValue})',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                  ),
                                  Text(
                                    '${sf.shapValue > 0 ? "+" : ""}${sf.shapValue.toStringAsFixed(3)}',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: barColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: normVal,
                                        minHeight: 8,
                                        backgroundColor: Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    sf.direction,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: barColor),
                                  ),
                                ],
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
                  final item = FertilizerPrescriptionItem(
                    prescriptionType: 'Soil Amendment',
                    recommendedChemical: 'Agricultural Gypsum / Organic Bio-Compost',
                    dosage: '500 kg/ha broadcast incorporation',
                    advisory: 'Counterbalance soil ionic imbalances before planting.',
                    reason: 'Sensor indices indicate sub-optimal soil condition.',
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FertilizerDetailsScreen(
                        fertilizerItem: item,
                        crop: result.crop,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.healing_outlined),
                label: const Text('View Prescribed Soil Amendments'),
              ),
          ],
        ),
      ),
    );
  }
}
