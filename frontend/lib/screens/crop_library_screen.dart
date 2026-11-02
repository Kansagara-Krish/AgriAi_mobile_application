import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../models/diagnostic_models.dart';

class CropLibraryScreen extends StatefulWidget {
  const CropLibraryScreen({Key? key}) : super(key: key);

  @override
  State<CropLibraryScreen> createState() => _CropLibraryScreenState();
}

class _CropLibraryScreenState extends State<CropLibraryScreen> {
  List<CropModel> _crops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCrops();
  }

  void _loadCrops() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final list = await provider.apiService.getCrops();
    if (mounted) {
      setState(() {
        _crops = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Pathology Library'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _crops.length,
              itemBuilder: (context, idx) {
                final crop = _crops[idx];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ExpansionTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.accentLight,
                      child: Icon(Icons.eco, color: AppTheme.primaryGreen),
                    ),
                    title: Text(
                      crop.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      crop.scientificName,
                      style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13, color: Colors.black54),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(crop.description, style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                _infoBadge('Optimal pH', crop.optimalPhRange, Colors.teal),
                                const SizedBox(width: 8),
                                _infoBadge('Optimal EC', crop.optimalEcRange, Colors.indigo),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Recognized Pathologies & Conditions:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.primaryDarkGreen),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: crop.diseases.map((d) {
                                final isHealthy = d.toLowerCase().contains('healthy');
                                return Chip(
                                  backgroundColor: isHealthy ? AppTheme.accentLight : const Color(0xFFFFEBEE),
                                  label: Text(
                                    d.replaceAll('_', ' '),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isHealthy ? AppTheme.primaryDarkGreen : AppTheme.alertRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _infoBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
