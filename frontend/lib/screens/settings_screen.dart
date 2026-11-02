import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/connection_status_badge.dart';
import 'language_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _urlController;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _urlController = TextEditingController(text: provider.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _testConnection() async {
    setState(() => _isTesting = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.setBaseUrl(_urlController.text.trim());
    final isOnline = await provider.checkConnection();
    setState(() => _isTesting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isOnline
                ? 'Successfully connected to AgriAI backend server!'
                : 'Connection failed. Verify server is running at ${_urlController.text.trim()}',
          ),
          backgroundColor: isOnline ? AppTheme.primaryGreen : AppTheme.alertRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('System Settings'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: ConnectionStatusBadge(showLabel: false)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.dns, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Backend Server Configuration',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'API Base URL',
                      hintText: 'http://10.0.2.2:8000/api or http://localhost:8000/api',
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Quick Presets:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(
                        label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _urlController.text = 'http://10.0.2.2:8000/api';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Localhost (8000)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _urlController.text = 'http://localhost:8000/api';
                          });
                        },
                      ),
                      ActionChip(
                        label: const Text('Local LAN (192.168.1.x)', style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          setState(() {
                            _urlController.text = 'http://192.168.1.100:8000/api';
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isTesting ? null : _testConnection,
                      icon: _isTesting
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.wifi_tethering),
                      label: Text(_isTesting ? 'Testing Link...' : 'Save & Test Connection'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.translate, color: AppTheme.secondaryGreen),
                  title: const Text('Language / ભાષા / भाषा', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    provider.currentLocale.languageCode == 'gu'
                        ? 'ગુજરાતી'
                        : provider.currentLocale.languageCode == 'hi'
                            ? 'हिन्दी'
                            : 'English',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: AppTheme.secondaryGreen),
                  title: const Text('Dark Mode Theme', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Optimize contrast for direct field sunlight'),
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleTheme(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryDarkGreen),
              title: const Text('AgriAI App Version', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('v1.0.0 (EfficientNetB0 + XGBoost Multimodal)'),
            ),
          ),
        ],
      ),
    );
  }
}
