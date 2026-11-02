import 'package:flutter/material.dart';
import '../constants/theme.dart';
import 'dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Precision Leaf Disease Vision',
      'desc': 'State-of-the-art CNN vision diagnosing 40 crop disease classes across Guava, Papaya, Brinjal, Castor, and Cumin with Grad-CAM heatmap explainability.',
      'icon': Icons.center_focus_strong_rounded,
      'color': AppTheme.primaryGreen,
    },
    {
      'title': 'Soil Health & SHAP Analytics',
      'desc': 'XGBoost soil health intelligence evaluating 23 physicochemical and spectral sensor parameters with local SHAP feature attributions.',
      'icon': Icons.terrain_rounded,
      'color': AppTheme.secondaryGreen,
    },
    {
      'title': 'Multimodal Cross-Synthesis',
      'desc': 'Synthesizes vision pathologies and soil deficits using 122 expert agronomic rules to prescribe targeted fertilizers and plant protections.',
      'icon': Icons.hub_rounded,
      'color': AppTheme.primaryDarkGreen,
    },
  ];

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Skip', style: TextStyle(color: AppTheme.secondaryGreen, fontSize: 16)),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentIndex = idx),
                itemBuilder: (context, idx) {
                  final page = _pages[idx];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 70,
                          backgroundColor: page['color'].withOpacity(0.12),
                          child: Icon(page['icon'], size: 70, color: page['color']),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          page['title'],
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.neutralDark),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['desc'],
                          style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == i ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == i ? AppTheme.primaryGreen : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(_currentIndex == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
