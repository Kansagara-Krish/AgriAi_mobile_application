import 'package:flutter/material.dart';
import '../constants/theme.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agronomy & AI Guidelines'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard(
            title: 'Multimodal AI Decision Engine',
            icon: Icons.psychology,
            color: AppTheme.primaryGreen,
            child: const Text(
              'AgriAI integrates deep vision classification (EfficientNetB0 with 96.86% accuracy across 40 classes) with machine learning soil fertility analytics (XGBoost + SHAP). Cross-modal rules ensure biological plausibility before issuing fertilizer or pesticide prescriptions.',
              style: TextStyle(fontSize: 14, height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: 'Leaf Photography Protocols',
            icon: Icons.camera_alt,
            color: AppTheme.secondaryGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• Capture in bright, indirect sunlight to prevent glare and deep shadows.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('• Frame the primary leaf lesion in the center of the viewport.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('• Inspect Grad-CAM visual heatmaps to verify the AI focused on necrotic tissues rather than dirt or background foilage.', style: TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: 'Soil Sampling & Sensor Rules',
            icon: Icons.terrain,
            color: Colors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• Collect 5-10 core samples in a zigzag pattern across the root zone (15-20 cm depth).', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('• Air-dry and sieve samples prior to laboratory or electrochemical probe testing.', style: TextStyle(fontSize: 13, height: 1.4)),
                SizedBox(height: 4),
                Text('• Review the top-6 local SHAP feature attributions to pinpoint specific limiting nutrients.', style: TextStyle(fontSize: 13, height: 1.4)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: 'Salinity & Alkalinity Hazard Alert',
            icon: Icons.warning_amber_rounded,
            color: AppTheme.accentSalinity,
            child: const Text(
              'CRITICAL AG-RULE: If electrical conductivity (EC) exceeds 2200 µS/cm or pH > 8.0, roots experience osmotic lockout and cannot absorb fertilizers. The AgriAI engine automatically suppresses nitrogen/potash chemicals and prescribes agricultural gypsum and leaching flushing.',
              style: TextStyle(fontSize: 13, height: 1.4, color: AppTheme.neutralDark),
            ),
          ),
          const SizedBox(height: 12),
          _buildCard(
            title: 'Supported Crops & Pathogens',
            icon: Icons.agriculture,
            color: AppTheme.primaryDarkGreen,
            child: const Text(
              'Guava (Canker, Rust, Mummification), Papaya (Mosaic, Anthracnose, Ring Spot), Brinjal (Bacterial Wilt, Cercospora, Little Leaf), Castor (Blight, Rust), Cumin (Fusarium Wilt, Alternaria, Powdery Mildew).',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.12),
                  radius: 18,
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
