import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/crop_selector_dropdown.dart';
import 'history_details_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedCrop = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).fetchHistory(
        crop: _selectedCrop == 'All' ? null : _selectedCrop,
      );
    });
  }

  void _onCropFilterChanged(String? crop) {
    if (crop != null) {
      setState(() => _selectedCrop = crop);
      Provider.of<AppProvider>(context, listen: false).fetchHistory(
        crop: crop == 'All' ? null : crop,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final history = provider.history;
    final isLoading = provider.isLoadingHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Archives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Records',
            onPressed: () => provider.fetchHistory(crop: _selectedCrop == 'All' ? null : _selectedCrop),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('Filter Crop: ', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: CropSelectorDropdown(
                    selectedCrop: _selectedCrop,
                    includeAllOption: true,
                    onChanged: _onCropFilterChanged,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text(
                              'No diagnosis records found.',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Perform a leaf or soil diagnosis to archive results.',
                              style: TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => provider.fetchHistory(crop: _selectedCrop == 'All' ? null : _selectedCrop),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          itemCount: history.length,
                          itemBuilder: (context, idx) {
                            final item = history[idx];
                            Color riskColor = AppTheme.accentLeaf;
                            if (item.overallRiskLevel?.toLowerCase() == 'moderate') riskColor = Colors.orange;
                            if (item.overallRiskLevel?.toLowerCase() == 'high') riskColor = AppTheme.alertRed;
                            if (item.overallRiskLevel?.toLowerCase() == 'severe') riskColor = Colors.purple;

                            final dateStr = item.timestamp.contains('T')
                                ? item.timestamp.split('T').first
                                : item.timestamp;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: riskColor.withOpacity(0.15),
                                  child: Icon(Icons.eco, color: riskColor),
                                ),
                                title: Text(
                                  '${item.crop} (${item.sampleId})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                subtitle: Text(
                                  '${item.leafDisease ?? item.soilStatus ?? "Integrated"}\nDate: $dateStr  •  Risk: ${item.overallRiskLevel ?? "Low"}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                isThreeLine: true,
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Delete Record'),
                                        content: Text('Delete diagnosis record ${item.sampleId}?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: AppTheme.alertRed))),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      provider.deleteRecord(item.id);
                                    }
                                  },
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => HistoryDetailsScreen(record: item)),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
