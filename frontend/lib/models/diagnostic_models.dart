class TopPrediction {
  final String cropClass;
  final double confidence;

  TopPrediction({required this.cropClass, required this.confidence});

  factory TopPrediction.fromJson(Map<String, dynamic> json) {
    return TopPrediction(
      cropClass: json['class'] ?? json['crop_class'] ?? 'Unknown',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'class': cropClass,
    'confidence': confidence,
  };
}

class ShapImpact {
  final String feature;
  final double shapValue;
  final double measuredValue;
  final String direction;

  ShapImpact({
    required this.feature,
    required this.shapValue,
    required this.measuredValue,
    required this.direction,
  });

  factory ShapImpact.fromJson(Map<String, dynamic> json) {
    return ShapImpact(
      feature: json['feature'] ?? '',
      shapValue: (json['shap_value'] as num?)?.toDouble() ?? 0.0,
      measuredValue: (json['measured_value'] as num?)?.toDouble() ?? 0.0,
      direction: json['direction'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'feature': feature,
    'shap_value': shapValue,
    'measured_value': measuredValue,
    'direction': direction,
  };
}

class LeafPredictionResult {
  final String crop;
  final String predictedClass;
  final double confidence;
  final List<TopPrediction> top3Predictions;
  final String? imageUrl;
  final String? gradcamUrl;
  final String? gradcamBase64;

  LeafPredictionResult({
    required this.crop,
    required this.predictedClass,
    required this.confidence,
    required this.top3Predictions,
    this.imageUrl,
    this.gradcamUrl,
    this.gradcamBase64,
  });

  factory LeafPredictionResult.fromJson(Map<String, dynamic> json) {
    final list = json['top_3_predictions'] as List<dynamic>? ?? [];
    return LeafPredictionResult(
      crop: json['crop'] ?? 'Unknown',
      predictedClass: json['predicted_class'] ?? 'Healthy',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      top3Predictions: list.map((e) => TopPrediction.fromJson(e as Map<String, dynamic>)).toList(),
      imageUrl: json['image_url'],
      gradcamUrl: json['gradcam_url'],
      gradcamBase64: json['gradcam_base64'],
    );
  }

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'predicted_class': predictedClass,
    'confidence': confidence,
    'top_3_predictions': top3Predictions.map((e) => e.toJson()).toList(),
    'image_url': imageUrl,
    'gradcam_url': gradcamUrl,
    'gradcam_base64': gradcamBase64,
  };
}

class SoilPredictionResult {
  final String crop;
  final String status;
  final double pHealthy;
  final double confidence;
  final List<ShapImpact> topShapFeatures;

  SoilPredictionResult({
    required this.crop,
    required this.status,
    required this.pHealthy,
    required this.confidence,
    required this.topShapFeatures,
  });

  factory SoilPredictionResult.fromJson(Map<String, dynamic> json) {
    final list = json['top_shap_features'] as List<dynamic>? ?? [];
    return SoilPredictionResult(
      crop: json['crop'] ?? '',
      status: json['status'] ?? 'Unknown',
      pHealthy: (json['p_healthy'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      topShapFeatures: list.map((e) => ShapImpact.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'crop': crop,
    'status': status,
    'p_healthy': pHealthy,
    'confidence': confidence,
    'top_shap_features': topShapFeatures.map((e) => e.toJson()).toList(),
  };
}

class FertilizerPrescriptionItem {
  final String prescriptionType;
  final String recommendedChemical;
  final String dosage;
  final String advisory;
  final String reason;

  FertilizerPrescriptionItem({
    required this.prescriptionType,
    required this.recommendedChemical,
    required this.dosage,
    required this.advisory,
    required this.reason,
  });

  factory FertilizerPrescriptionItem.fromJson(Map<String, dynamic> json) {
    return FertilizerPrescriptionItem(
      prescriptionType: json['prescription_type'] ?? '',
      recommendedChemical: json['recommended_chemical'] ?? '',
      dosage: json['dosage'] ?? '',
      advisory: json['advisory'] ?? '',
      reason: json['reason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'prescription_type': prescriptionType,
    'recommended_chemical': recommendedChemical,
    'dosage': dosage,
    'advisory': advisory,
    'reason': reason,
  };
}

class PlantProtectionItem {
  final String targetCondition;
  final String recommendedProtection;
  final String dosage;
  final String farmerAdvisory;
  final String urgency;

  PlantProtectionItem({
    required this.targetCondition,
    required this.recommendedProtection,
    required this.dosage,
    required this.farmerAdvisory,
    required this.urgency,
  });

  factory PlantProtectionItem.fromJson(Map<String, dynamic> json) {
    return PlantProtectionItem(
      targetCondition: json['target_condition'] ?? '',
      recommendedProtection: json['recommended_protection'] ?? '',
      dosage: json['dosage'] ?? '',
      farmerAdvisory: json['farmer_advisory'] ?? '',
      urgency: json['urgency'] ?? 'Standard',
    );
  }

  Map<String, dynamic> toJson() => {
    'target_condition': targetCondition,
    'recommended_protection': recommendedProtection,
    'dosage': dosage,
    'farmer_advisory': farmerAdvisory,
    'urgency': urgency,
  };
}

class IntegratedAnalysisResult {
  final String sampleId;
  final String crop;
  final bool isPairedSample;
  final String overallRiskLevel;
  final Map<String, dynamic>? leafDiagnosis;
  final Map<String, dynamic>? soilDiagnosis;
  final List<FertilizerPrescriptionItem> fertilizerPrescriptions;
  final List<PlantProtectionItem> plantProtectionAdvisory;
  final String agronomicSummary;
  final List<String> warnings;
  final String? reportUrl;

  IntegratedAnalysisResult({
    required this.sampleId,
    required this.crop,
    required this.isPairedSample,
    required this.overallRiskLevel,
    this.leafDiagnosis,
    this.soilDiagnosis,
    required this.fertilizerPrescriptions,
    required this.plantProtectionAdvisory,
    required this.agronomicSummary,
    required this.warnings,
    this.reportUrl,
  });

  factory IntegratedAnalysisResult.fromJson(Map<String, dynamic> json) {
    final fertList = json['fertilizer_prescriptions'] as List<dynamic>? ?? [];
    final protList = json['plant_protection_advisory'] as List<dynamic>? ?? [];
    final warnList = json['warnings'] as List<dynamic>? ?? [];

    return IntegratedAnalysisResult(
      sampleId: json['sample_id'] ?? '',
      crop: json['crop'] ?? '',
      isPairedSample: json['is_paired_sample'] ?? true,
      overallRiskLevel: json['overall_risk_level'] ?? 'Low',
      leafDiagnosis: json['leaf_diagnosis'] as Map<String, dynamic>?,
      soilDiagnosis: json['soil_diagnosis'] as Map<String, dynamic>?,
      fertilizerPrescriptions: fertList.map((e) => FertilizerPrescriptionItem.fromJson(e as Map<String, dynamic>)).toList(),
      plantProtectionAdvisory: protList.map((e) => PlantProtectionItem.fromJson(e as Map<String, dynamic>)).toList(),
      agronomicSummary: json['agronomic_summary'] ?? '',
      warnings: warnList.map((e) => e.toString()).toList(),
      reportUrl: json['report_url'],
    );
  }
}

class DiagnosisRecordModel {
  final int id;
  final String sampleId;
  final String timestamp;
  final String crop;
  final String diagnosisType;
  final bool isPairedSample;
  final String? leafDisease;
  final double? leafConfidence;
  final String? gradcamFilename;
  final String? soilStatus;
  final double? soilConfidence;
  final String? overallRiskLevel;
  final String? agronomicSummary;
  final String? reportPdfFilename;
  final List<dynamic> fertilizerPrescriptions;
  final List<dynamic> plantProtectionAdvisory;
  final List<dynamic> warnings;

  DiagnosisRecordModel({
    required this.id,
    required this.sampleId,
    required this.timestamp,
    required this.crop,
    required this.diagnosisType,
    required this.isPairedSample,
    this.leafDisease,
    this.leafConfidence,
    this.gradcamFilename,
    this.soilStatus,
    this.soilConfidence,
    this.overallRiskLevel,
    this.agronomicSummary,
    this.reportPdfFilename,
    this.fertilizerPrescriptions = const [],
    this.plantProtectionAdvisory = const [],
    this.warnings = const [],
  });

  factory DiagnosisRecordModel.fromJson(Map<String, dynamic> json) {
    return DiagnosisRecordModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      sampleId: json['sample_id'] ?? '',
      timestamp: json['timestamp'] ?? '',
      crop: json['crop'] ?? '',
      diagnosisType: json['diagnosis_type'] ?? 'integrated',
      isPairedSample: json['is_paired_sample'] ?? true,
      leafDisease: json['leaf_disease'],
      leafConfidence: (json['leaf_confidence'] as num?)?.toDouble(),
      gradcamFilename: json['gradcam_filename'],
      soilStatus: json['soil_status'],
      soilConfidence: (json['soil_confidence'] as num?)?.toDouble(),
      overallRiskLevel: json['overall_risk_level'],
      agronomicSummary: json['agronomic_summary'],
      reportPdfFilename: json['report_pdf_filename'],
      fertilizerPrescriptions: json['fertilizer_prescriptions'] as List<dynamic>? ?? [],
      plantProtectionAdvisory: json['plant_protection_advisory'] as List<dynamic>? ?? [],
      warnings: json['warnings'] as List<dynamic>? ?? [],
    );
  }
}

class CropModel {
  final String name;
  final String scientificName;
  final String description;
  final List<String> diseases;
  final String optimalPhRange;
  final String optimalEcRange;

  CropModel({
    required this.name,
    required this.scientificName,
    required this.description,
    required this.diseases,
    required this.optimalPhRange,
    required this.optimalEcRange,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    final dList = json['diseases'] as List<dynamic>? ?? [];
    return CropModel(
      name: json['name'] ?? '',
      scientificName: json['scientific_name'] ?? '',
      description: json['description'] ?? '',
      diseases: dList.map((e) => e.toString()).toList(),
      optimalPhRange: json['optimal_ph_range'] ?? '',
      optimalEcRange: json['optimal_ec_range'] ?? '',
    );
  }
}
