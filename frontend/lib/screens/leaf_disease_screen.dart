import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/image_picker_component.dart';
import '../components/crop_selector_dropdown.dart';
import 'disease_result_screen.dart';

class LeafDiseaseScreen extends StatefulWidget {
  const LeafDiseaseScreen({Key? key}) : super(key: key);

  @override
  State<LeafDiseaseScreen> createState() => _LeafDiseaseScreenState();
}

class _LeafDiseaseScreenState extends State<LeafDiseaseScreen> {
  String _selectedCrop = 'Guava';
  Uint8List? _imageBytes;
  String? _filename;
  bool _isDiagnosing = false;

  void _onImageSelected(Uint8List bytes, String filename) {
    setState(() {
      _imageBytes = bytes;
      _filename = filename;
    });
  }

  void _onClearImage() {
    setState(() {
      _imageBytes = null;
      _filename = null;
    });
  }

  void _runInference() async {
    if (_imageBytes == null || _filename == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture a leaf photo first.')),
      );
      return;
    }

    setState(() => _isDiagnosing = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    try {
      final result = await provider.apiService.predictLeafDisease(
        imageBytes: _imageBytes!,
        filename: _filename!,
        crop: _selectedCrop,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => DiseaseResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Inference Error: $e'),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDiagnosing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaf Disease Vision'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Target Cultivated Crop:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryDarkGreen),
            ),
            const SizedBox(height: 6),
            CropSelectorDropdown(
              selectedCrop: _selectedCrop,
              onChanged: (val) {
                if (val != null) setState(() => _selectedCrop = val);
              },
            ),
            const SizedBox(height: 16),
            ImagePickerComponent(
              onImageSelected: _onImageSelected,
              onClear: _onClearImage,
              selectedImageBytes: _imageBytes,
              selectedFilename: _filename,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: (_isDiagnosing || _imageBytes == null) ? null : _runInference,
              icon: _isDiagnosing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.search),
              label: Text(_isDiagnosing ? 'Running EfficientNetB0 Inference...' : 'Diagnose Leaf Pathogen'),
            ),
          ],
        ),
      ),
    );
  }
}
