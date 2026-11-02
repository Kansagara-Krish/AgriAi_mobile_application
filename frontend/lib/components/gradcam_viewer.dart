import 'dart:convert';
import 'package:flutter/material.dart';
import '../constants/theme.dart';

class GradCamViewer extends StatefulWidget {
  final String? gradcamBase64;
  final String? gradcamUrl;
  final String? originalImageUrl;
  final String title;

  const GradCamViewer({
    super.key,
    this.gradcamBase64,
    this.gradcamUrl,
    this.originalImageUrl,
    this.title = 'Grad-CAM Lesion Heatmap',
  });

  @override
  State<GradCamViewer> createState() => _GradCamViewerState();
}

class _GradCamViewerState extends State<GradCamViewer> {
  double _opacity = 1.0;
  bool _showComparison = false;

  @override
  Widget build(BuildContext context) {
    final hasBase64 = widget.gradcamBase64 != null && widget.gradcamBase64!.isNotEmpty;
    final hasUrl = widget.gradcamUrl != null && widget.gradcamUrl!.isNotEmpty;

    if (!hasBase64 && !hasUrl) {
      return Card(
        color: AppTheme.accentLight,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Grad-CAM heatmap not available for this prediction.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    Widget heatmapImageWidget;
    if (hasBase64) {
      try {
        final bytes = base64Decode(widget.gradcamBase64!);
        heatmapImageWidget = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 240,
        );
      } catch (_) {
        heatmapImageWidget = const Center(child: Text('Failed to render base64 heatmap'));
      }
    } else {
      heatmapImageWidget = Image.network(
        widget.gradcamUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 240,
        errorBuilder: (_, _, _) => const Center(child: Text('Unable to load heatmap image')),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.primaryDarkGreen,
            child: Row(
              children: [
                const Icon(Icons.remove_red_eye_rounded, color: Colors.amberAccent, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showComparison = !_showComparison;
                    });
                  },
                  child: Text(
                    _showComparison ? 'Heatmap Only' : 'Compare',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                  ),
                )
              ],
            ),
          ),
          if (!_showComparison)
            Opacity(
              opacity: _opacity,
              child: heatmapImageWidget,
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: widget.originalImageUrl != null
                        ? Image.network(
                            widget.originalImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(child: Icon(Icons.image, size: 40)),
                          )
                        : const Center(child: Icon(Icons.photo, size: 40, color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: heatmapImageWidget,
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Heatmap Intensity: ', style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _opacity,
                        min: 0.2,
                        max: 1.0,
                        activeColor: AppTheme.secondaryGreen,
                        onChanged: (val) {
                          setState(() {
                            _opacity = val;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildLegendItem(Colors.red, 'High Pathological Influence (Lesion)'),
                    const SizedBox(width: 12),
                    _buildLegendItem(Colors.blue, 'Healthy / Leaf Background'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ],
    );
  }
}
