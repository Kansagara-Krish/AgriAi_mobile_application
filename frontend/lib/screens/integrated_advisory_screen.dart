import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';
import '../components/image_picker_component.dart';
import '../components/crop_selector_dropdown.dart';
import 'fertilizer_details_screen.dart';
import 'pdf_viewer_screen.dart';

class IntegratedAdvisoryScreen extends StatefulWidget {
  const IntegratedAdvisoryScreen({Key? key}) : super(key: key);

  @override
  State<IntegratedAdvisoryScreen> createState() => _IntegratedAdvisoryScreenState();
}

class _IntegratedAdvisoryScreenState extends State<IntegratedAdvisoryScreen> {
  String _selectedCrop = 'Guava';
  bool _isPairedSample = true;
  Uint8List? _imageBytes;
  String? _filename;
  bool _isSynthesizing = false;
  IntegratedAnalysisResult? _analysisResult;

  // Typical soil sensor values
  final Map<String, double> _soilReadings = {
    'pH': 7.2,
    'Conductivity': 1200.0,
    'Nitrogen': 320.0,
    'Phosphorus': 28.0,
    'Potassium': 280.0,
    'Copper': 1.2,
    'Ferrous': 12.0,
    'Manganese': 8.5,
    'Sulphur': 18.0,
    'Zinc': 1.8,
    'LAI': 2.4,
    'TII': 35.0,
    'ARI': 0.12,
    'RBI': 0.85,
    'CRI': 1.4,
    'FAI': 0.65,
    'MRI': 1.1,
    'HCI': 1.5,
    'C/N_Ratio': 12.5
  };

  void _runMultimodalSynthesis() async {
    setState(() => _isSynthesizing = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    try {
      final res = await provider.apiService.analyzeMultimodal(
        crop: _selectedCrop,
        isPairedSample: _isPairedSample,
        imageBytes: _imageBytes,
        filename: _filename,
        soilReadings: _soilReadings,
      );

      setState(() {
        _analysisResult = res;
      });

      // Refresh background history list
      provider.fetchHistory();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Multimodal Synthesis Error: $e'), backgroundColor: AppTheme.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isSynthesizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Integrated Multimodal Advisory'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target Cultivated Crop:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    CropSelectorDropdown(
                      selectedCrop: _selectedCrop,
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCrop = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Paired Sample Verification', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Leaf image and soil test originate from the same field plot', style: TextStyle(fontSize: 12)),
                      value: _isPairedSample,
                      activeThumbColor: AppTheme.primaryGreen,
                      onChanged: (val) => setState(() => _isPairedSample = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ImagePickerComponent(
              onImageSelected: (bytes, fn) => setState(() {
                _imageBytes = bytes;
                _filename = fn;
              }),
              onClear: () => setState(() {
                _imageBytes = null;
                _filename = null;
              }),
              selectedImageBytes: _imageBytes,
              selectedFilename: _filename,
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.terrain, color: AppTheme.primaryGreen),
                        SizedBox(width: 8),
                        Text('Soil Sensor Readings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Included: pH ${_soilReadings["pH"]}, EC ${_soilReadings["Conductivity"]} µS/cm, N ${_soilReadings["Nitrogen"]} kg/ha, P ${_soilReadings["Phosphorus"]} kg/ha, K ${_soilReadings["Potassium"]} kg/ha + 14 micronutrients/spectral indices.',
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isSynthesizing ? null : _runMultimodalSynthesis,
              icon: _isSynthesizing
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.hub_rounded),
              label: Text(_isSynthesizing ? 'Synthesizing Vision & Soil Models...' : 'Run Multimodal Decision Engine'),
            ),
            const SizedBox(height: 24),

            // Results Section
            if (_analysisResult != null) _buildResultSection(_analysisResult!),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(IntegratedAnalysisResult res) {
    Color riskColor = AppTheme.accentLeaf;
    if (res.overallRiskLevel.toLowerCase() == 'moderate') riskColor = Colors.orange;
    if (res.overallRiskLevel.toLowerCase() == 'high') riskColor = AppTheme.alertRed;
    if (res.overallRiskLevel.toLowerCase() == 'severe') riskColor = Colors.purple;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Overall Risk Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: riskColor, width: 1.5),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Sample: ${res.sampleId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${res.overallRiskLevel} Risk',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Crop: ${res.crop}  •  Paired: ${res.isPairedSample ? "Yes" : "No"}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Agronomic Summary
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notes, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Text('Agronomic Synthesis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(res.agronomicSummary, style: const TextStyle(fontSize: 14, height: 1.4)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Warnings / Guardrails
        if (res.warnings.isNotEmpty) ...[
          Card(
            color: const Color(0xFFFFF3E0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFFFB74D)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: AppTheme.accentSalinity),
                      SizedBox(width: 8),
                      Text('Agronomic Guardrail Alerts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.accentSalinity)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...res.warnings.map((w) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(w, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Fertilizer Prescriptions
        if (res.fertilizerPrescriptions.isNotEmpty) ...[
          const Text('Prescribed Fertilizers & Soil Amendments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkGreen)),
          const SizedBox(height: 8),
          ...res.fertilizerPrescriptions.map((fp) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.accentLight,
                  child: Icon(Icons.science, color: AppTheme.primaryGreen),
                ),
                title: Text(fp.recommendedChemical, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('Rate: ${fp.dosage}\nAdvisory: ${fp.advisory}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FertilizerDetailsScreen(
                        fertilizerItem: fp,
                        crop: res.crop,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 12),
        ],

        // Plant Protection Advisories
        if (res.plantProtectionAdvisory.isNotEmpty) ...[
          const Text('Plant Protection & Bio-Control Prescriptions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryDarkGreen)),
          const SizedBox(height: 8),
          ...res.plantProtectionAdvisory.map((pa) {
            return Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.shield, color: AppTheme.alertRed),
                ),
                title: Text(pa.recommendedProtection, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                subtitle: Text('Target: ${pa.targetCondition}\nDosage: ${pa.dosage}'),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FertilizerDetailsScreen(
                        protectionItem: pa,
                        crop: res.crop,
                      ),
                    ),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 16),
        ],

        // View Official PDF Report button
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfViewerScreen(
                  sampleId: res.sampleId,
                  reportUrl: res.reportUrl,
                  crop: res.crop,
                  overallRisk: res.overallRiskLevel,
                  agronomicSummary: res.agronomicSummary,
                ),
              ),
            );
          },
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('View & Download Official PDF Report'),
        ),
      ],
    );
  }
}
