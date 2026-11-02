import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'AgriAI Diagnostic'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Crop Pathology & Soil Intelligence'**
  String get appTagline;

  /// No description provided for @commonSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Analysis'**
  String get commonSubmit;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get commonNext;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get commonRefresh;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get commonSearch;

  /// No description provided for @commonSelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get commonSelect;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Processing AI inference...'**
  String get commonLoading;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get commonError;

  /// No description provided for @commonViewReport.
  ///
  /// In en, this message translates to:
  /// **'View Diagnostic PDF Report'**
  String get commonViewReport;

  /// No description provided for @commonDownloadReport.
  ///
  /// In en, this message translates to:
  /// **'Download PDF Report'**
  String get commonDownloadReport;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navHome;

  /// No description provided for @navDisease.
  ///
  /// In en, this message translates to:
  /// **'Leaf Vision'**
  String get navDisease;

  /// No description provided for @navSoil.
  ///
  /// In en, this message translates to:
  /// **'Soil Health'**
  String get navSoil;

  /// No description provided for @navIntegrated.
  ///
  /// In en, this message translates to:
  /// **'Integrated Advisory'**
  String get navIntegrated;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Farmer Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navHelp.
  ///
  /// In en, this message translates to:
  /// **'Help & Agronomy'**
  String get navHelp;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Precision Leaf Disease Vision'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'State-of-the-art CNN vision diagnosing 40 crop disease classes across Guava, Papaya, Brinjal, Castor, and Cumin with Grad-CAM heatmap explainability.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Soil Health & SHAP Analytics'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'XGBoost soil health intelligence evaluating 23 physicochemical and spectral sensor parameters with local SHAP feature attributions.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Cross-Synthesis'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Synthesizes vision pathologies and soil deficits using 122 expert agronomic rules to prescribe targeted fertilizers and plant protections.'**
  String get onboardingDesc3;

  /// No description provided for @onboardingGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingGetStarted;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @langSelectTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Preferred Language'**
  String get langSelectTitle;

  /// No description provided for @langSelectDesc.
  ///
  /// In en, this message translates to:
  /// **'AgriAI provides complete multimodal diagnostics in English, Hindi, and Gujarati.'**
  String get langSelectDesc;

  /// No description provided for @langEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEnglish;

  /// No description provided for @langHindi.
  ///
  /// In en, this message translates to:
  /// **'हिन्दी (Hindi)'**
  String get langHindi;

  /// No description provided for @langGujarati.
  ///
  /// In en, this message translates to:
  /// **'ગુજરાતી (Gujarati)'**
  String get langGujarati;

  /// No description provided for @langContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue to App'**
  String get langContinue;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'AgriAI Farm Portal'**
  String get dashboardTitle;

  /// No description provided for @dashboardGreeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Farmer!'**
  String get dashboardGreeting;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Diagnostics & Decision Support'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Diagnostic Tools'**
  String get dashboardQuickActions;

  /// No description provided for @dashboardLeafDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Leaf Disease'**
  String get dashboardLeafDiagnosis;

  /// No description provided for @dashboardLeafDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload leaf photos for instant AI pathogen detection & Grad-CAM visual heatmaps.'**
  String get dashboardLeafDesc;

  /// No description provided for @dashboardSoilDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Analyze Soil Health'**
  String get dashboardSoilDiagnosis;

  /// No description provided for @dashboardSoilDesc.
  ///
  /// In en, this message translates to:
  /// **'Evaluate soil nutrients and spectral indices using XGBoost & SHAP attributions.'**
  String get dashboardSoilDesc;

  /// No description provided for @dashboardIntegratedAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Full Multimodal Advisory'**
  String get dashboardIntegratedAdvisory;

  /// No description provided for @dashboardIntegratedDesc.
  ///
  /// In en, this message translates to:
  /// **'Cross-synthesize leaf symptoms with soil parameters for unified chemical prescriptions.'**
  String get dashboardIntegratedDesc;

  /// No description provided for @dashboardRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Diagnoses'**
  String get dashboardRecentActivity;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardNoHistory.
  ///
  /// In en, this message translates to:
  /// **'No historical diagnostic records found.'**
  String get dashboardNoHistory;

  /// No description provided for @dashboardCropCoverage.
  ///
  /// In en, this message translates to:
  /// **'Supported Cash & Fruit Crops'**
  String get dashboardCropCoverage;

  /// No description provided for @cropGuava.
  ///
  /// In en, this message translates to:
  /// **'Guava (Psidium guajava)'**
  String get cropGuava;

  /// No description provided for @cropPapaya.
  ///
  /// In en, this message translates to:
  /// **'Papaya (Carica papaya)'**
  String get cropPapaya;

  /// No description provided for @cropBrinjal.
  ///
  /// In en, this message translates to:
  /// **'Brinjal (Solanum melongena)'**
  String get cropBrinjal;

  /// No description provided for @cropCastor.
  ///
  /// In en, this message translates to:
  /// **'Castor (Ricinus communis)'**
  String get cropCastor;

  /// No description provided for @cropCumin.
  ///
  /// In en, this message translates to:
  /// **'Cumin (Cuminum cyminum)'**
  String get cropCumin;

  /// No description provided for @diseaseScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Leaf Disease Classifier'**
  String get diseaseScreenTitle;

  /// No description provided for @diseaseUploadPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select or capture an infected crop leaf photo'**
  String get diseaseUploadPrompt;

  /// No description provided for @diseasePickCamera.
  ///
  /// In en, this message translates to:
  /// **'Take Photo with Camera'**
  String get diseasePickCamera;

  /// No description provided for @diseasePickGallery.
  ///
  /// In en, this message translates to:
  /// **'Select from Gallery'**
  String get diseasePickGallery;

  /// No description provided for @diseaseCropHint.
  ///
  /// In en, this message translates to:
  /// **'Select target crop (optional)'**
  String get diseaseCropHint;

  /// No description provided for @diseaseRunInference.
  ///
  /// In en, this message translates to:
  /// **'Diagnose Leaf Pathogen'**
  String get diseaseRunInference;

  /// No description provided for @diseaseResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Pathology Vision Result'**
  String get diseaseResultTitle;

  /// No description provided for @diseaseConfidence.
  ///
  /// In en, this message translates to:
  /// **'Confidence Score'**
  String get diseaseConfidence;

  /// No description provided for @diseaseTopPredictions.
  ///
  /// In en, this message translates to:
  /// **'Top Alternative Predictions'**
  String get diseaseTopPredictions;

  /// No description provided for @diseaseGradcamTitle.
  ///
  /// In en, this message translates to:
  /// **'Grad-CAM Lesion Explainability'**
  String get diseaseGradcamTitle;

  /// No description provided for @diseaseGradcamDesc.
  ///
  /// In en, this message translates to:
  /// **'Heatmap highlights symptomatic lesions and necrotic areas influencing the AI classification.'**
  String get diseaseGradcamDesc;

  /// No description provided for @soilScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil Health & Nutrient Analysis'**
  String get soilScreenTitle;

  /// No description provided for @soilSelectCrop.
  ///
  /// In en, this message translates to:
  /// **'Select Cultivated Crop'**
  String get soilSelectCrop;

  /// No description provided for @soilEnterParameters.
  ///
  /// In en, this message translates to:
  /// **'Physicochemical & Spectral Readings'**
  String get soilEnterParameters;

  /// No description provided for @soilSectionPhysico.
  ///
  /// In en, this message translates to:
  /// **'Physicochemical Parameters'**
  String get soilSectionPhysico;

  /// No description provided for @soilSectionMicro.
  ///
  /// In en, this message translates to:
  /// **'Micronutrients (ppm)'**
  String get soilSectionMicro;

  /// No description provided for @soilSectionSpectral.
  ///
  /// In en, this message translates to:
  /// **'Spectral Vegetation Indices'**
  String get soilSectionSpectral;

  /// No description provided for @soilPh.
  ///
  /// In en, this message translates to:
  /// **'Soil pH'**
  String get soilPh;

  /// No description provided for @soilConductivity.
  ///
  /// In en, this message translates to:
  /// **'Conductivity (µS/cm)'**
  String get soilConductivity;

  /// No description provided for @soilNitrogen.
  ///
  /// In en, this message translates to:
  /// **'Nitrogen (N) kg/ha'**
  String get soilNitrogen;

  /// No description provided for @soilPhosphorus.
  ///
  /// In en, this message translates to:
  /// **'Phosphorus (P) kg/ha'**
  String get soilPhosphorus;

  /// No description provided for @soilPotassium.
  ///
  /// In en, this message translates to:
  /// **'Potassium (K) kg/ha'**
  String get soilPotassium;

  /// No description provided for @soilCopper.
  ///
  /// In en, this message translates to:
  /// **'Copper (Cu) ppm'**
  String get soilCopper;

  /// No description provided for @soilFerrous.
  ///
  /// In en, this message translates to:
  /// **'Ferrous/Iron (Fe) ppm'**
  String get soilFerrous;

  /// No description provided for @soilManganese.
  ///
  /// In en, this message translates to:
  /// **'Manganese (Mn) ppm'**
  String get soilManganese;

  /// No description provided for @soilSulphur.
  ///
  /// In en, this message translates to:
  /// **'Sulphur (S) ppm'**
  String get soilSulphur;

  /// No description provided for @soilZinc.
  ///
  /// In en, this message translates to:
  /// **'Zinc (Zn) ppm'**
  String get soilZinc;

  /// No description provided for @soilLai.
  ///
  /// In en, this message translates to:
  /// **'Leaf Area Index (LAI)'**
  String get soilLai;

  /// No description provided for @soilTii.
  ///
  /// In en, this message translates to:
  /// **'Thermal Infrared Index (TII)'**
  String get soilTii;

  /// No description provided for @soilAri.
  ///
  /// In en, this message translates to:
  /// **'Anthocyanin Reflectance (ARI)'**
  String get soilAri;

  /// No description provided for @soilRbi.
  ///
  /// In en, this message translates to:
  /// **'Red-Blue Index (RBI)'**
  String get soilRbi;

  /// No description provided for @soilCri.
  ///
  /// In en, this message translates to:
  /// **'Carotenoid Reflectance (CRI)'**
  String get soilCri;

  /// No description provided for @soilFai.
  ///
  /// In en, this message translates to:
  /// **'Foliar Absorption Index (FAI)'**
  String get soilFai;

  /// No description provided for @soilMri.
  ///
  /// In en, this message translates to:
  /// **'Moisture Reflectance (MRI)'**
  String get soilMri;

  /// No description provided for @soilHci.
  ///
  /// In en, this message translates to:
  /// **'Humic Composition Index (HCI)'**
  String get soilHci;

  /// No description provided for @soilCnRatio.
  ///
  /// In en, this message translates to:
  /// **'C/N Ratio'**
  String get soilCnRatio;

  /// No description provided for @soilLoadDefaults.
  ///
  /// In en, this message translates to:
  /// **'Fill Typical Sample Values'**
  String get soilLoadDefaults;

  /// No description provided for @soilRunAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Evaluate Soil Health'**
  String get soilRunAnalysis;

  /// No description provided for @soilResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Soil Health Prediction'**
  String get soilResultTitle;

  /// No description provided for @soilStatusHealthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy Soil Condition'**
  String get soilStatusHealthy;

  /// No description provided for @soilStatusUnhealthy.
  ///
  /// In en, this message translates to:
  /// **'Unhealthy Soil Condition'**
  String get soilStatusUnhealthy;

  /// No description provided for @soilHealthyProb.
  ///
  /// In en, this message translates to:
  /// **'Healthy Probability'**
  String get soilHealthyProb;

  /// No description provided for @soilShapTitle.
  ///
  /// In en, this message translates to:
  /// **'Local SHAP Feature Attributions'**
  String get soilShapTitle;

  /// No description provided for @soilShapDesc.
  ///
  /// In en, this message translates to:
  /// **'Quantifies positive and negative contributions of each sensor reading toward the health score.'**
  String get soilShapDesc;

  /// No description provided for @integratedScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Multimodal Decision Advisory'**
  String get integratedScreenTitle;

  /// No description provided for @integratedDesc.
  ///
  /// In en, this message translates to:
  /// **'Couples leaf vision and soil sensor readings into unified agronomic prescriptions.'**
  String get integratedDesc;

  /// No description provided for @integratedSampleId.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Sample ID'**
  String get integratedSampleId;

  /// No description provided for @integratedPairedCheckbox.
  ///
  /// In en, this message translates to:
  /// **'Paired Sample (Leaf & Soil from same field plot)'**
  String get integratedPairedCheckbox;

  /// No description provided for @integratedSynthesize.
  ///
  /// In en, this message translates to:
  /// **'Generate Integrated Advisory'**
  String get integratedSynthesize;

  /// No description provided for @integratedRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Overall Agronomic Risk'**
  String get integratedRiskLevel;

  /// No description provided for @integratedRiskLow.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get integratedRiskLow;

  /// No description provided for @integratedRiskModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Risk'**
  String get integratedRiskModerate;

  /// No description provided for @integratedRiskHigh.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get integratedRiskHigh;

  /// No description provided for @integratedRiskSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe / Critical Risk'**
  String get integratedRiskSevere;

  /// No description provided for @integratedFertilizers.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Fertilizer & Soil Amendments'**
  String get integratedFertilizers;

  /// No description provided for @integratedPlantProtection.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Plant Protection & Bio-control'**
  String get integratedPlantProtection;

  /// No description provided for @integratedSummary.
  ///
  /// In en, this message translates to:
  /// **'Agronomic Synthesis Narrative'**
  String get integratedSummary;

  /// No description provided for @integratedWarnings.
  ///
  /// In en, this message translates to:
  /// **'Cross-Modal Alerts & Guardrails'**
  String get integratedWarnings;

  /// No description provided for @integratedChemical.
  ///
  /// In en, this message translates to:
  /// **'Recommended Chemical / Remedy'**
  String get integratedChemical;

  /// No description provided for @integratedDosage.
  ///
  /// In en, this message translates to:
  /// **'Prescribed Dosage'**
  String get integratedDosage;

  /// No description provided for @integratedAdvisory.
  ///
  /// In en, this message translates to:
  /// **'Farmer Field Advisory'**
  String get integratedAdvisory;

  /// No description provided for @historyScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Archives'**
  String get historyScreenTitle;

  /// No description provided for @historyFilterCrop.
  ///
  /// In en, this message translates to:
  /// **'Filter by Crop'**
  String get historyFilterCrop;

  /// No description provided for @historyAllCrops.
  ///
  /// In en, this message translates to:
  /// **'All Crops'**
  String get historyAllCrops;

  /// No description provided for @historyDate.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get historyDate;

  /// No description provided for @historyType.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis Type'**
  String get historyType;

  /// No description provided for @historyRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get historyRisk;

  /// No description provided for @historyDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this diagnosis record?'**
  String get historyDeleteConfirm;

  /// No description provided for @profileScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Farmer Profile & Plot Info'**
  String get profileScreenTitle;

  /// No description provided for @profileFarmerName.
  ///
  /// In en, this message translates to:
  /// **'Farmer Name'**
  String get profileFarmerName;

  /// No description provided for @profileFarmLocation.
  ///
  /// In en, this message translates to:
  /// **'Farm Location / Village'**
  String get profileFarmLocation;

  /// No description provided for @profileTotalArea.
  ///
  /// In en, this message translates to:
  /// **'Total Acreage (Acres)'**
  String get profileTotalArea;

  /// No description provided for @profilePrimaryCrop.
  ///
  /// In en, this message translates to:
  /// **'Primary Cultivated Crop'**
  String get profilePrimaryCrop;

  /// No description provided for @profileSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileSaveSuccess;

  /// No description provided for @settingsScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'System Settings & Connection'**
  String get settingsScreenTitle;

  /// No description provided for @settingsApiUrl.
  ///
  /// In en, this message translates to:
  /// **'Backend Server Base URL'**
  String get settingsApiUrl;

  /// No description provided for @settingsApiHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., http://10.0.2.2:8000 for Android Emulator or http://192.168.1.5:8000 for LAN'**
  String get settingsApiHint;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Application Language'**
  String get settingsLanguage;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode Theme'**
  String get settingsTheme;

  /// No description provided for @settingsCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Server Connection'**
  String get settingsCheckConnection;

  /// No description provided for @settingsConnOnline.
  ///
  /// In en, this message translates to:
  /// **'Connected to AgriAI Backend Server'**
  String get settingsConnOnline;

  /// No description provided for @settingsConnOffline.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach AgriAI Backend Server'**
  String get settingsConnOffline;

  /// No description provided for @settingsResetDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reset to Default URL'**
  String get settingsResetDefaults;

  /// No description provided for @helpScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Agronomic Knowledge & Guidelines'**
  String get helpScreenTitle;

  /// No description provided for @helpSystemArchitecture.
  ///
  /// In en, this message translates to:
  /// **'AgriAI System Architecture'**
  String get helpSystemArchitecture;

  /// No description provided for @helpVisionGuide.
  ///
  /// In en, this message translates to:
  /// **'Vision Diagnostic Guidelines'**
  String get helpVisionGuide;

  /// No description provided for @helpVisionTips.
  ///
  /// In en, this message translates to:
  /// **'Ensure natural lighting, capture upper and lower leaf surfaces, and avoid heavy shadows.'**
  String get helpVisionTips;

  /// No description provided for @helpSoilGuide.
  ///
  /// In en, this message translates to:
  /// **'Soil Sampling Protocols'**
  String get helpSoilGuide;

  /// No description provided for @helpSoilTips.
  ///
  /// In en, this message translates to:
  /// **'Collect 5-10 core samples at 15cm root depth, air-dry before lab reading, and cross-reference EC.'**
  String get helpSoilTips;

  /// No description provided for @helpSalinityAlert.
  ///
  /// In en, this message translates to:
  /// **'Salinity Hazard Warning'**
  String get helpSalinityAlert;

  /// No description provided for @helpSalinityDesc.
  ///
  /// In en, this message translates to:
  /// **'Electrical Conductivity exceeding 2200 µS/cm creates osmotic root burn. Withhold fertilizers and flush with clean water.'**
  String get helpSalinityDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'gu', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
