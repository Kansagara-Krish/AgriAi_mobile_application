import datetime
from sqlalchemy import Column, Integer, String, Float, DateTime, Text, Boolean
from sqlalchemy.orm import declarative_base

Base = declarative_base()

class DiagnosisRecord(Base):
    """
    Persistent diagnosis entity recording leaf disease analysis,
    soil health predictions, agronomic recommendations, and generated reports.
    Designed with future MongoDB / NoSQL migration readiness.
    """
    __tablename__ = "diagnosis_records"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    sample_id = Column(String(64), unique=True, index=True, nullable=False)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow, nullable=False)
    crop = Column(String(50), nullable=False)
    diagnosis_type = Column(String(30), nullable=False)  # leaf_only, soil_only, integrated
    is_paired_sample = Column(Boolean, default=True)
    
    # Leaf Vision Model outputs
    image_filename = Column(String(255), nullable=True)
    leaf_disease = Column(String(100), nullable=True)
    leaf_confidence = Column(Float, nullable=True)
    top_3_predictions_json = Column(Text, nullable=True)
    gradcam_filename = Column(String(255), nullable=True)
    
    # Soil Health Model outputs
    soil_status = Column(String(50), nullable=True)  # Healthy / Unhealthy
    soil_confidence = Column(Float, nullable=True)
    soil_p_healthy = Column(Float, nullable=True)
    soil_readings_json = Column(Text, nullable=True)
    soil_shap_json = Column(Text, nullable=True)
    
    # Multimodal Decision Engine outputs
    overall_risk_level = Column(String(30), nullable=True)  # Low, Moderate, High, Severe
    fertilizer_prescriptions_json = Column(Text, nullable=True)
    plant_protection_advisory_json = Column(Text, nullable=True)
    agronomic_summary = Column(Text, nullable=True)
    warnings_json = Column(Text, nullable=True)
    
    # Report Reference
    report_pdf_filename = Column(String(255), nullable=True)

    def to_dict(self):
        import json
        return {
            "id": self.id,
            "sample_id": self.sample_id,
            "timestamp": self.timestamp.isoformat() if self.timestamp else None,
            "crop": self.crop,
            "diagnosis_type": self.diagnosis_type,
            "is_paired_sample": self.is_paired_sample,
            "image_filename": self.image_filename,
            "leaf_disease": self.leaf_disease,
            "leaf_confidence": self.leaf_confidence,
            "top_3_predictions": json.loads(self.top_3_predictions_json) if self.top_3_predictions_json else [],
            "gradcam_filename": self.gradcam_filename,
            "soil_status": self.soil_status,
            "soil_confidence": self.soil_confidence,
            "soil_p_healthy": self.soil_p_healthy,
            "soil_readings": json.loads(self.soil_readings_json) if self.soil_readings_json else {},
            "soil_shap_features": json.loads(self.soil_shap_json) if self.soil_shap_json else [],
            "overall_risk_level": self.overall_risk_level,
            "fertilizer_prescriptions": json.loads(self.fertilizer_prescriptions_json) if self.fertilizer_prescriptions_json else [],
            "plant_protection_advisory": json.loads(self.plant_protection_advisory_json) if self.plant_protection_advisory_json else [],
            "agronomic_summary": self.agronomic_summary,
            "warnings": json.loads(self.warnings_json) if self.warnings_json else [],
            "report_pdf_filename": self.report_pdf_filename
        }
