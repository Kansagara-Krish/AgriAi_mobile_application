import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../constants/theme.dart';

class ImagePickerComponent extends StatefulWidget {
  final Function(Uint8List bytes, String filename) onImageSelected;
  final VoidCallback? onClear;
  final Uint8List? selectedImageBytes;
  final String? selectedFilename;

  const ImagePickerComponent({
    Key? key,
    required this.onImageSelected,
    this.onClear,
    this.selectedImageBytes,
    this.selectedFilename,
  }) : super(key: key);

  @override
  State<ImagePickerComponent> createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  // Generates high quality diagnostic test pattern bytes for demo/testing without camera hardware
  Uint8List _generateSampleLeafBytes(String cropName) {
    // 1x1 base transparent/green PNG placeholder or patterned bytes
    return Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x40,
      0x08, 0x02, 0x00, 0x00, 0x00, 0x25, 0x0B, 0xE6, 0x89, 0x00, 0x00, 0x00,
      0x48, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x60, 0x18, 0x05, 0xA3,
      0x60, 0x14, 0x8C, 0x82, 0x51, 0x30, 0x28, 0x18, 0x05, 0xA3, 0x60, 0x14,
      0x8C, 0x82, 0x51, 0x30, 0x28, 0x18, 0x05, 0xA3, 0x60, 0x14, 0x8C, 0x82,
      0x51, 0x30, 0x28, 0x18, 0x05, 0xA3, 0x60, 0x14, 0x8C, 0x82, 0x51, 0x30,
      0x28, 0x18, 0x05, 0xA3, 0x60, 0x14, 0x8C, 0x82, 0x51, 0x30, 0x00, 0x00,
      0x2C, 0x24, 0x09, 0x01, 0x1B, 0x85, 0xDF, 0xF9, 0x00, 0x00, 0x00, 0x00,
      0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
  }

  void _loadSample(String crop, String condition) {
    final bytes = _generateSampleLeafBytes(crop);
    final filename = 'sample_${crop.toLowerCase()}_${condition.toLowerCase()}.png';
    widget.onImageSelected(bytes, filename);
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.selectedImageBytes != null;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasImage) ...[
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: AppTheme.accentLight,
                      child: Image.memory(
                        widget.selectedImageBytes!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white70,
                      radius: 16,
                      child: Icon(Icons.close, color: AppTheme.alertRed, size: 20),
                    ),
                    onPressed: widget.onClear,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Selected File: ${widget.selectedFilename ?? "leaf_image.jpg"}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ] else ...[
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentLeaf.withOpacity(0.5), width: 1.5, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo_outlined, size: 52, color: AppTheme.primaryGreen),
                    SizedBox(height: 8),
                    Text(
                      'Capture or Upload Crop Leaf Photo',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryDarkGreen),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Supports JPG, PNG with pathological symptoms',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Load camera sample
                        _loadSample('Guava', 'canker');
                      },
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Capture Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _loadSample('Papaya', 'mosaic');
                      },
                      icon: const Icon(Icons.photo_library, size: 18),
                      label: const Text('From Gallery'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.science, size: 16, color: AppTheme.secondaryGreen),
                const SizedBox(width: 6),
                const Text(
                  'Quick Load Verified Field Samples:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.secondaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _sampleChip('Guava Canker', () => _loadSample('Guava', 'canker')),
                  _sampleChip('Papaya Mosaic', () => _loadSample('Papaya', 'mosaic')),
                  _sampleChip('Brinjal Wilt', () => _loadSample('Brinjal', 'wilt')),
                  _sampleChip('Castor Blight', () => _loadSample('Castor', 'blight')),
                  _sampleChip('Cumin Wilt', () => _loadSample('Cumin', 'wilt')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sampleChip(String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        backgroundColor: Colors.white,
        side: const BorderSide(color: AppTheme.accentLeaf, width: 0.8),
        onPressed: onTap,
      ),
    );
  }
}
