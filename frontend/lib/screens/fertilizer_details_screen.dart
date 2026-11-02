import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';

class FertilizerDetailsScreen extends StatelessWidget {
  final FertilizerPrescriptionItem? fertilizerItem;
  final PlantProtectionItem? protectionItem;
  final String crop;

  const FertilizerDetailsScreen({
    Key? key,
    this.fertilizerItem,
    this.protectionItem,
    required this.crop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = fertilizerItem?.recommendedChemical ?? protectionItem?.recommendedProtection ?? 'Intervention Remedy';
    final dosage = fertilizerItem?.dosage ?? protectionItem?.dosage ?? 'Standard dose';
    final type = fertilizerItem?.prescriptionType ?? protectionItem?.urgency ?? 'Prescribed Action';
    final advisory = fertilizerItem?.advisory ?? protectionItem?.farmerAdvisory ?? 'Follow label recommendations.';
    final reason = fertilizerItem?.reason ?? 'Target condition: ${protectionItem?.targetCondition ?? ""}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescription Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppTheme.accentLight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: AppTheme.primaryGreen,
                          child: Icon(Icons.medication, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryDarkGreen),
                              ),
                              Text('Crop: $crop  •  Category: $type', style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoCard(
              title: 'Prescribed Dosage & Application Rate',
              icon: Icons.scale,
              color: Colors.teal,
              content: dosage,
            ),
            const SizedBox(height: 12),
            _infoCard(
              title: 'Agronomic Field Advisory',
              icon: Icons.agriculture,
              color: AppTheme.secondaryGreen,
              content: advisory,
            ),
            const SizedBox(height: 12),
            _infoCard(
              title: 'Etiological Rationale',
              icon: Icons.info_outline,
              color: Colors.blueGrey,
              content: reason,
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFFFCC80)),
              ),
              color: const Color(0xFFFFF8E1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.shield, color: AppTheme.accentSalinity),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Agronomist Precaution: Always wear protective masks during application. Spray during early morning (6:00 - 9:00 AM) or late afternoon to avoid leaf scorching.',
                        style: TextStyle(fontSize: 13, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required IconData icon,
    required Color color,
    required String content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
              ],
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4)),
          ],
        ),
      ),
    );
  }
}
