import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/crop_selector_dropdown.dart';
import 'soil_result_screen.dart';

class SoilFormScreen extends StatefulWidget {
  const SoilFormScreen({Key? key}) : super(key: key);

  @override
  State<SoilFormScreen> createState() => _SoilFormScreenState();
}

class _SoilFormScreenState extends State<SoilFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCrop = 'Guava';
  bool _isAnalyzing = false;

  final Map<String, TextEditingController> _controllers = {};

  final List<String> _paramKeys = [
    'pH', 'Conductivity', 'Nitrogen', 'Phosphorus', 'Potassium',
    'Copper', 'Ferrous', 'Manganese', 'Sulphur', 'Zinc',
    'LAI', 'TII', 'ARI', 'RBI', 'CRI', 'FAI', 'MRI', 'HCI', 'C/N_Ratio'
  ];

  @override
  void initState() {
    super.initState();
    for (var k in _paramKeys) {
      _controllers[k] = TextEditingController();
    }
    _loadTypicalDefaults();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _loadTypicalDefaults() {
    final defaults = {
      'pH': '7.2',
      'Conductivity': '1200.0',
      'Nitrogen': '320.0',
      'Phosphorus': '28.0',
      'Potassium': '280.0',
      'Copper': '1.2',
      'Ferrous': '12.0',
      'Manganese': '8.5',
      'Sulphur': '18.0',
      'Zinc': '1.8',
      'LAI': '2.4',
      'TII': '35.0',
      'ARI': '0.12',
      'RBI': '0.85',
      'CRI': '1.4',
      'FAI': '0.65',
      'MRI': '1.1',
      'HCI': '1.5',
      'C/N_Ratio': '12.5',
    };
    defaults.forEach((k, v) {
      _controllers[k]?.text = v;
    });
  }

  void _loadSalinityLockoutPreset() {
    _controllers['Conductivity']?.text = '2650.0';
    _controllers['pH']?.text = '8.6';
    _controllers['Nitrogen']?.text = '180.0';
    _controllers['Phosphorus']?.text = '12.0';
    _controllers['Potassium']?.text = '150.0';
  }

  void _submitAnalysis() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isAnalyzing = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final Map<String, dynamic> readings = {};
    _controllers.forEach((k, c) {
      readings[k] = double.tryParse(c.text.trim()) ?? 0.0;
    });

    try {
      final result = await provider.apiService.predictSoilHealth(
        crop: _selectedCrop,
        soilReadings: readings,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SoilResultScreen(result: result)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soil Analysis Error: $e'), backgroundColor: AppTheme.alertRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Health Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Defaults',
            onPressed: _loadTypicalDefaults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
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
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _loadTypicalDefaults,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Typical Healthy Sample', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: _loadSalinityLockoutPreset,
                    icon: const Icon(Icons.warning_amber, size: 16, color: AppTheme.accentSalinity),
                    label: const Text('Salinity Case', style: TextStyle(fontSize: 12, color: AppTheme.accentSalinity)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _sectionHeader('Physicochemical & Macro Nutrients', Icons.science),
              _buildFieldGrid(['pH', 'Conductivity', 'Nitrogen', 'Phosphorus', 'Potassium', 'C/N_Ratio']),
              const SizedBox(height: 16),
              _sectionHeader('Micronutrients (ppm)', Icons.grain),
              _buildFieldGrid(['Copper', 'Ferrous', 'Manganese', 'Sulphur', 'Zinc']),
              const SizedBox(height: 16),
              _sectionHeader('Spectral Vegetation Indices', Icons.satellite_alt),
              _buildFieldGrid(['LAI', 'TII', 'ARI', 'RBI', 'CRI', 'FAI', 'MRI', 'HCI']),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _submitAnalysis,
                icon: _isAnalyzing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.analytics_rounded),
                label: Text(_isAnalyzing ? 'Evaluating Soil XGBoost...' : 'Analyze Soil Health & SHAP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGreen),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryDarkGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldGrid(List<String> keys) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          children: keys.map((k) {
            return SizedBox(
              width: 150,
              child: TextFormField(
                controller: _controllers[k],
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: k,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) return 'Invalid';
                  return null;
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
