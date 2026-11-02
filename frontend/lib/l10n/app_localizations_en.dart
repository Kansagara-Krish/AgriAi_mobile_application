// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AgriAI Diagnostic';

  @override
  String get appTagline => 'Multimodal Crop Pathology & Soil Intelligence';

  @override
  String get commonSubmit => 'Submit Analysis';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonBack => 'Back';

  @override
  String get commonNext => 'Next';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSearch => 'Search...';

  @override
  String get commonSelect => 'Select';

  @override
  String get commonLoading => 'Processing AI inference...';

  @override
  String get commonSuccess => 'Operation completed successfully';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonViewReport => 'View Diagnostic PDF Report';

  @override
  String get commonDownloadReport => 'Download PDF Report';

  @override
  String get navHome => 'Dashboard';

  @override
  String get navDisease => 'Leaf Vision';

  @override
  String get navSoil => 'Soil Health';

  @override
  String get navIntegrated => 'Integrated Advisory';

  @override
  String get navHistory => 'History';

  @override
  String get navProfile => 'Farmer Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHelp => 'Help & Agronomy';

  @override
  String get onboardingTitle1 => 'Precision Leaf Disease Vision';

  @override
  String get onboardingDesc1 =>
      'State-of-the-art CNN vision diagnosing 40 crop disease classes across Guava, Papaya, Brinjal, Castor, and Cumin with Grad-CAM heatmap explainability.';

  @override
  String get onboardingTitle2 => 'Soil Health & SHAP Analytics';

  @override
  String get onboardingDesc2 =>
      'XGBoost soil health intelligence evaluating 23 physicochemical and spectral sensor parameters with local SHAP feature attributions.';

  @override
  String get onboardingTitle3 => 'Multimodal Cross-Synthesis';

  @override
  String get onboardingDesc3 =>
      'Synthesizes vision pathologies and soil deficits using 122 expert agronomic rules to prescribe targeted fertilizers and plant protections.';

  @override
  String get onboardingGetStarted => 'Get Started';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get langSelectTitle => 'Choose Preferred Language';

  @override
  String get langSelectDesc =>
      'AgriAI provides complete multimodal diagnostics in English, Hindi, and Gujarati.';

  @override
  String get langEnglish => 'English';

  @override
  String get langHindi => 'हिन्दी (Hindi)';

  @override
  String get langGujarati => 'ગુજરાતી (Gujarati)';

  @override
  String get langContinue => 'Continue to App';

  @override
  String get dashboardTitle => 'AgriAI Farm Portal';

  @override
  String get dashboardGreeting => 'Welcome back, Farmer!';

  @override
  String get dashboardSubtitle => 'Multimodal Diagnostics & Decision Support';

  @override
  String get dashboardQuickActions => 'Quick Diagnostic Tools';

  @override
  String get dashboardLeafDiagnosis => 'Diagnose Leaf Disease';

  @override
  String get dashboardLeafDesc =>
      'Upload leaf photos for instant AI pathogen detection & Grad-CAM visual heatmaps.';

  @override
  String get dashboardSoilDiagnosis => 'Analyze Soil Health';

  @override
  String get dashboardSoilDesc =>
      'Evaluate soil nutrients and spectral indices using XGBoost & SHAP attributions.';

  @override
  String get dashboardIntegratedAdvisory => 'Full Multimodal Advisory';

  @override
  String get dashboardIntegratedDesc =>
      'Cross-synthesize leaf symptoms with soil parameters for unified chemical prescriptions.';

  @override
  String get dashboardRecentActivity => 'Recent Diagnoses';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get dashboardNoHistory => 'No historical diagnostic records found.';

  @override
  String get dashboardCropCoverage => 'Supported Cash & Fruit Crops';

  @override
  String get cropGuava => 'Guava (Psidium guajava)';

  @override
  String get cropPapaya => 'Papaya (Carica papaya)';

  @override
  String get cropBrinjal => 'Brinjal (Solanum melongena)';

  @override
  String get cropCastor => 'Castor (Ricinus communis)';

  @override
  String get cropCumin => 'Cumin (Cuminum cyminum)';

  @override
  String get diseaseScreenTitle => 'Leaf Disease Classifier';

  @override
  String get diseaseUploadPrompt =>
      'Select or capture an infected crop leaf photo';

  @override
  String get diseasePickCamera => 'Take Photo with Camera';

  @override
  String get diseasePickGallery => 'Select from Gallery';

  @override
  String get diseaseCropHint => 'Select target crop (optional)';

  @override
  String get diseaseRunInference => 'Diagnose Leaf Pathogen';

  @override
  String get diseaseResultTitle => 'Pathology Vision Result';

  @override
  String get diseaseConfidence => 'Confidence Score';

  @override
  String get diseaseTopPredictions => 'Top Alternative Predictions';

  @override
  String get diseaseGradcamTitle => 'Grad-CAM Lesion Explainability';

  @override
  String get diseaseGradcamDesc =>
      'Heatmap highlights symptomatic lesions and necrotic areas influencing the AI classification.';

  @override
  String get soilScreenTitle => 'Soil Health & Nutrient Analysis';

  @override
  String get soilSelectCrop => 'Select Cultivated Crop';

  @override
  String get soilEnterParameters => 'Physicochemical & Spectral Readings';

  @override
  String get soilSectionPhysico => 'Physicochemical Parameters';

  @override
  String get soilSectionMicro => 'Micronutrients (ppm)';

  @override
  String get soilSectionSpectral => 'Spectral Vegetation Indices';

  @override
  String get soilPh => 'Soil pH';

  @override
  String get soilConductivity => 'Conductivity (µS/cm)';

  @override
  String get soilNitrogen => 'Nitrogen (N) kg/ha';

  @override
  String get soilPhosphorus => 'Phosphorus (P) kg/ha';

  @override
  String get soilPotassium => 'Potassium (K) kg/ha';

  @override
  String get soilCopper => 'Copper (Cu) ppm';

  @override
  String get soilFerrous => 'Ferrous/Iron (Fe) ppm';

  @override
  String get soilManganese => 'Manganese (Mn) ppm';

  @override
  String get soilSulphur => 'Sulphur (S) ppm';

  @override
  String get soilZinc => 'Zinc (Zn) ppm';

  @override
  String get soilLai => 'Leaf Area Index (LAI)';

  @override
  String get soilTii => 'Thermal Infrared Index (TII)';

  @override
  String get soilAri => 'Anthocyanin Reflectance (ARI)';

  @override
  String get soilRbi => 'Red-Blue Index (RBI)';

  @override
  String get soilCri => 'Carotenoid Reflectance (CRI)';

  @override
  String get soilFai => 'Foliar Absorption Index (FAI)';

  @override
  String get soilMri => 'Moisture Reflectance (MRI)';

  @override
  String get soilHci => 'Humic Composition Index (HCI)';

  @override
  String get soilCnRatio => 'C/N Ratio';

  @override
  String get soilLoadDefaults => 'Fill Typical Sample Values';

  @override
  String get soilRunAnalysis => 'Evaluate Soil Health';

  @override
  String get soilResultTitle => 'Soil Health Prediction';

  @override
  String get soilStatusHealthy => 'Healthy Soil Condition';

  @override
  String get soilStatusUnhealthy => 'Unhealthy Soil Condition';

  @override
  String get soilHealthyProb => 'Healthy Probability';

  @override
  String get soilShapTitle => 'Local SHAP Feature Attributions';

  @override
  String get soilShapDesc =>
      'Quantifies positive and negative contributions of each sensor reading toward the health score.';

  @override
  String get integratedScreenTitle => 'Multimodal Decision Advisory';

  @override
  String get integratedDesc =>
      'Couples leaf vision and soil sensor readings into unified agronomic prescriptions.';

  @override
  String get integratedSampleId => 'Diagnostic Sample ID';

  @override
  String get integratedPairedCheckbox =>
      'Paired Sample (Leaf & Soil from same field plot)';

  @override
  String get integratedSynthesize => 'Generate Integrated Advisory';

  @override
  String get integratedRiskLevel => 'Overall Agronomic Risk';

  @override
  String get integratedRiskLow => 'Low Risk';

  @override
  String get integratedRiskModerate => 'Moderate Risk';

  @override
  String get integratedRiskHigh => 'High Risk';

  @override
  String get integratedRiskSevere => 'Severe / Critical Risk';

  @override
  String get integratedFertilizers => 'Prescribed Fertilizer & Soil Amendments';

  @override
  String get integratedPlantProtection =>
      'Prescribed Plant Protection & Bio-control';

  @override
  String get integratedSummary => 'Agronomic Synthesis Narrative';

  @override
  String get integratedWarnings => 'Cross-Modal Alerts & Guardrails';

  @override
  String get integratedChemical => 'Recommended Chemical / Remedy';

  @override
  String get integratedDosage => 'Prescribed Dosage';

  @override
  String get integratedAdvisory => 'Farmer Field Advisory';

  @override
  String get historyScreenTitle => 'Diagnostic Archives';

  @override
  String get historyFilterCrop => 'Filter by Crop';

  @override
  String get historyAllCrops => 'All Crops';

  @override
  String get historyDate => 'Date & Time';

  @override
  String get historyType => 'Diagnosis Type';

  @override
  String get historyRisk => 'Risk Level';

  @override
  String get historyDeleteConfirm =>
      'Are you sure you want to delete this diagnosis record?';

  @override
  String get profileScreenTitle => 'Farmer Profile & Plot Info';

  @override
  String get profileFarmerName => 'Farmer Name';

  @override
  String get profileFarmLocation => 'Farm Location / Village';

  @override
  String get profileTotalArea => 'Total Acreage (Acres)';

  @override
  String get profilePrimaryCrop => 'Primary Cultivated Crop';

  @override
  String get profileSaveSuccess => 'Profile updated successfully';

  @override
  String get settingsScreenTitle => 'System Settings & Connection';

  @override
  String get settingsApiUrl => 'Backend Server Base URL';

  @override
  String get settingsApiHint =>
      'e.g., http://10.0.2.2:8000 for Android Emulator or http://192.168.1.5:8000 for LAN';

  @override
  String get settingsLanguage => 'Application Language';

  @override
  String get settingsTheme => 'Dark Mode Theme';

  @override
  String get settingsCheckConnection => 'Test Server Connection';

  @override
  String get settingsConnOnline => 'Connected to AgriAI Backend Server';

  @override
  String get settingsConnOffline => 'Cannot reach AgriAI Backend Server';

  @override
  String get settingsResetDefaults => 'Reset to Default URL';

  @override
  String get helpScreenTitle => 'Agronomic Knowledge & Guidelines';

  @override
  String get helpSystemArchitecture => 'AgriAI System Architecture';

  @override
  String get helpVisionGuide => 'Vision Diagnostic Guidelines';

  @override
  String get helpVisionTips =>
      'Ensure natural lighting, capture upper and lower leaf surfaces, and avoid heavy shadows.';

  @override
  String get helpSoilGuide => 'Soil Sampling Protocols';

  @override
  String get helpSoilTips =>
      'Collect 5-10 core samples at 15cm root depth, air-dry before lab reading, and cross-reference EC.';

  @override
  String get helpSalinityAlert => 'Salinity Hazard Warning';

  @override
  String get helpSalinityDesc =>
      'Electrical Conductivity exceeding 2200 µS/cm creates osmotic root burn. Withhold fertilizers and flush with clean water.';
}
