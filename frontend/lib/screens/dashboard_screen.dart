import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/connection_status_badge.dart';
import 'leaf_disease_screen.dart';
import 'soil_form_screen.dart';
import 'integrated_advisory_screen.dart';
import 'history_screen.dart';
import 'history_details_screen.dart';
import 'crop_library_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'language_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final profile = provider.profile;
    final farmerName = profile['name'] ?? 'Farmer';
    final location = profile['location'] ?? 'Gujarat, India';

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriAI Farm Portal'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 14.0),
            child: Center(child: ConnectionStatusBadge()),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Farmer Welcome Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryDarkGreen, AppTheme.secondaryGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDarkGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Text(
                      farmerName.isNotEmpty ? farmerName[0] : 'F',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $farmerName!',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.amberAccent, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              location,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Diagnostic Tools Section
            const Text(
              'Diagnostic AI Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen),
            ),
            const SizedBox(height: 12),
            _toolActionCard(
              title: 'Leaf Disease Vision Detection',
              desc: 'Deep CNN vision classification across 40 pathological classes with Grad-CAM heatmaps.',
              icon: Icons.center_focus_strong_rounded,
              color: AppTheme.primaryGreen,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeafDiseaseScreen()));
              },
            ),
            const SizedBox(height: 10),
            _toolActionCard(
              title: 'Soil Health & SHAP Analytics',
              desc: 'Evaluate 23 physicochemical and spectral sensor features using XGBoost decision trees.',
              icon: Icons.terrain_rounded,
              color: AppTheme.secondaryGreen,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SoilFormScreen()));
              },
            ),
            const SizedBox(height: 10),
            _toolActionCard(
              title: 'Full Multimodal Decision Advisory',
              desc: 'Synthesize foliar disease images with soil nutrients for unified chemical remedies.',
              icon: Icons.hub_rounded,
              color: const Color(0xFF00796B),
              isFeatured: true,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IntegratedAdvisoryScreen()));
              },
            ),
            const SizedBox(height: 24),

            // Supported Cash & Fruit Crops
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Supported Crop Models',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CropLibraryScreen()));
                  },
                  child: const Text('View All', style: TextStyle(color: AppTheme.secondaryGreen)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _cropChip('Guava', 'Psidium guajava', Icons.eco),
                  _cropChip('Papaya', 'Carica papaya', Icons.spa),
                  _cropChip('Brinjal', 'Solanum melongena', Icons.grass),
                  _cropChip('Castor', 'Ricinus communis', Icons.energy_savings_leaf),
                  _cropChip('Cumin', 'Cuminum cyminum', Icons.grain),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recent Diagnoses List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Field Diagnoses',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
                  },
                  child: const Text('Archives', style: TextStyle(color: AppTheme.secondaryGreen)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.history.isEmpty)
              Card(
                color: AppTheme.accentLight,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(
                    child: Text(
                      'No diagnosis records yet. Try running Leaf Disease Vision or Multimodal Advisory!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.primaryDarkGreen),
                    ),
                  ),
                ),
              )
            else
              ...provider.history.take(3).map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppTheme.accentLight,
                      child: Icon(Icons.eco, color: AppTheme.primaryGreen),
                    ),
                    title: Text('${item.crop} (${item.sampleId})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('${item.leafDisease ?? item.soilStatus ?? "Integrated"} • Risk: ${item.overallRiskLevel ?? "Low"}'),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => HistoryDetailsScreen(record: item)));
                    },
                  ),
                );
              }),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        selectedItemColor: AppTheme.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          setState(() => _bottomNavIndex = idx);
          if (idx == 1) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeafDiseaseScreen()));
          } else if (idx == 2) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IntegratedAdvisoryScreen()));
          } else if (idx == 3) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.center_focus_strong), label: 'Leaf Vision'),
          BottomNavigationBarItem(icon: Icon(Icons.hub_rounded), label: 'Advisory'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Archives'),
        ],
      ),
    );
  }

  Widget _toolActionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isFeatured = false,
  }) {
    return Card(
      elevation: isFeatured ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isFeatured ? BorderSide(color: color, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withOpacity(0.12),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                    const SizedBox(height: 4),
                    Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87, height: 1.3)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cropChip(String name, String scientific, IconData icon) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(
            scientific,
            style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryDarkGreen, AppTheme.primaryGreen],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.eco_rounded, size: 48, color: Colors.white),
                SizedBox(height: 10),
                Text('AgriAI Precision Agriculture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                Text('Decision-Support Platform', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppTheme.primaryGreen),
            title: const Text('Dashboard'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.center_focus_strong, color: AppTheme.primaryGreen),
            title: const Text('Leaf Disease Vision'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeafDiseaseScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.terrain, color: AppTheme.primaryGreen),
            title: const Text('Soil Health Form'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SoilFormScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.hub, color: AppTheme.primaryGreen),
            title: const Text('Multimodal Advisory'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const IntegratedAdvisoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: AppTheme.primaryGreen),
            title: const Text('Diagnostic Archives'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books, color: AppTheme.primaryGreen),
            title: const Text('Crop Pathology Library'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CropLibraryScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.person, color: AppTheme.secondaryGreen),
            title: const Text('Farmer Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate, color: AppTheme.secondaryGreen),
            title: const Text('Language / ભાષા / भाषा'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguageScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppTheme.secondaryGreen),
            title: const Text('System Settings'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline, color: AppTheme.secondaryGreen),
            title: const Text('Help & Agronomy Rules'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HelpScreen()));
            },
          ),
        ],
      ),
    );
  }
}
