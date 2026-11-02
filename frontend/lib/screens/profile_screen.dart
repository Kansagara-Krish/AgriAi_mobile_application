import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';
import '../components/crop_selector_dropdown.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _acreageController;
  String _selectedCrop = 'Guava';

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<AppProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile['name'] ?? 'Rameshbhai Patel');
    _locationController = TextEditingController(text: profile['location'] ?? 'Anand, Gujarat');
    _acreageController = TextEditingController(text: profile['acreage'] ?? '12.5');
    _selectedCrop = profile['primary_crop'] ?? 'Guava';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _acreageController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.updateProfile({
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'acreage': _acreageController.text.trim(),
        'primary_crop': _selectedCrop,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farmer profile updated successfully!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer & Plot Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.accentLight,
                  child: const Icon(Icons.person, size: 54, color: AppTheme.primaryGreen),
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Farmer / Grower Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGreen),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter farmer name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Farm Location / Village & District',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.primaryGreen),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter location' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _acreageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Cultivated Acreage (Acres)',
                  prefixIcon: Icon(Icons.landscape_outlined, color: AppTheme.primaryGreen),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Please enter acreage' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Primary Cultivated Crop:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryDarkGreen),
              ),
              const SizedBox(height: 6),
              CropSelectorDropdown(
                selectedCrop: _selectedCrop,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCrop = val);
                },
              ),
              const SizedBox(height: 36),
              ElevatedButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
