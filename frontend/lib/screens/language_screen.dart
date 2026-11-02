import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../constants/theme.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final currentLang = provider.currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Language / ભાષા / भाषा'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select Preferred Language',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryDarkGreen),
            ),
            const SizedBox(height: 6),
            const Text(
              'AgriAI provides native multilingual crop diagnostic reports, prescriptions, and voice-ready text.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            _buildLangCard(
              context: context,
              title: 'English',
              subtitle: 'Default international format',
              code: 'en',
              isSelected: currentLang == 'en',
              onTap: () => provider.setLocale('en'),
            ),
            const SizedBox(height: 12),
            _buildLangCard(
              context: context,
              title: 'हिन्दी (Hindi)',
              subtitle: 'भारतीय राष्ट्रीय भाषा - संपूर्ण कृषि सलाह',
              code: 'hi',
              isSelected: currentLang == 'hi',
              onTap: () => provider.setLocale('hi'),
            ),
            const SizedBox(height: 12),
            _buildLangCard(
              context: context,
              title: 'ગુજરાતી (Gujarati)',
              subtitle: 'પ્રાદેશિક ભાષા - ખેડૂત અનુકૂળ માર્ગદર્શન',
              code: 'gu',
              isSelected: currentLang == 'gu',
              onTap: () => provider.setLocale('gu'),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Confirm & Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String code,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
          width: 2,
        ),
      ),
      color: isSelected ? AppTheme.accentLight : Colors.white,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isSelected ? AppTheme.primaryGreen : Colors.grey[200],
          child: Text(
            code.toUpperCase(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: isSelected
            ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 26)
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
      ),
    );
  }
}
