from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field

class SoilReadingsSchema(BaseModel):
    pH: Optional[float] = Field(default=7.2, description="Soil pH level (4.0 - 10.0)")
    Conductivity: Optional[float] = Field(default=1200.0, description="Electrical Conductivity in µS/cm")
    Nitrogen: Optional[float] = Field(default=320.0, description="Available Nitrogen in kg/ha")
    Phosphorus: Optional[float] = Field(default=28.0, description="Available Phosphorus in kg/ha")
    Potassium: Optional[float] = Field(default=280.0, description="Available Potassium in kg/ha")
    Copper: Optional[float] = Field(default=1.2, description="Copper in ppm")
    Ferrous: Optional[float] = Field(default=12.0, description="Ferrous/Iron in ppm")
    Manganese: Optional[float] = Field(default=8.5, description="Manganese in ppm")
    Sulphur: Optional[float] = Field(default=18.0, description="Sulphur in ppm")
    Zinc: Optional[float] = Field(default=1.8, description="Zinc in ppm")
    LAI: Optional[float] = Field(default=2.4, description="Leaf Area Index")
    TII: Optional[float] = Field(default=35.0, description="Thermal Infrared Index")
    ARI: Optional[float] = Field(default=0.12, description="Anthocyanin Reflectance Index")
    RBI: Optional[float] = Field(default=0.85, description="Red-Blue Index")
    CRI: Optional[float] = Field(default=1.4, description="Carotenoid Reflectance Index")
    FAI: Optional[float] = Field(default=0.65, description="Foliar Absorption Index")
    MRI: Optional[float] = Field(default=1.1, description="Moisture Reflectance Index")
    HCI: Optional[float] = Field(default=1.5, description="Humic Composition Index")
    C_N_Ratio: Optional[float] = Field(default=12.5, alias="C/N_Ratio", description="Carbon-to-Nitrogen ratio")

    class Config:
        populate_by_name = True


class TopPrediction(BaseModel):
    crop_class: str = Field(..., alias="class")
    confidence: float

    class Config:
        populate_by_name = True


class ShapFeatureImpact(BaseModel):
    feature: str
    shap_value: float
    measured_value: float
    direction: str


class LeafDiseasePredictionResponse(BaseModel):
    crop: str
    predicted_class: str
    confidence: float
    top_3_predictions: List[TopPrediction]
    image_url: Optional[str] = None
    gradcam_url: Optional[str] = None
    gradcam_base64: Optional[str] = None


class SoilPredictionRequest(BaseModel):
    crop: str = Field(..., description="Target crop: Guava, Papaya, Brinjal, Castor, or Cumin")
    soil_readings: SoilReadingsSchema


class SoilPredictionResponse(BaseModel):
    crop: str
    status: str
    p_healthy: float
    confidence: float
    top_shap_features: List[ShapFeatureImpact]


class FertilizerPrescription(BaseModel):
    prescription_type: str
    recommended_chemical: str
    dosage: str
    advisory: str
    reason: str


class PlantProtectionAdvisory(BaseModel):
    target_condition: str
    recommended_protection: str
    dosage: str
    farmer_advisory: str
    urgency: str


class IntegratedAnalysisResponse(BaseModel):
    sample_id: str
    crop: str
    is_paired_sample: bool
    overall_risk_level: str
    leaf_diagnosis: Optional[Dict[str, Any]] = None
    soil_diagnosis: Optional[Dict[str, Any]] = None
    fertilizer_prescriptions: List[FertilizerPrescription]
    plant_protection_advisory: List[PlantProtectionAdvisory]
    agronomic_summary: str
    warnings: List[str]
    report_url: Optional[str] = None


class RecommendationRequest(BaseModel):
    crop: str
    condition_or_parameter: str
    parameter_level: Optional[str] = None
    soil_readings: Optional[Dict[str, float]] = None


class HealthResponse(BaseModel):
    status: str
    version: str
    project: str


class ModelStatusResponse(BaseModel):
    cnn_model_loaded: bool
    cnn_model_type: str
    cnn_architecture: str
    soil_model_loaded: bool
    soil_model_features_count: int
    fertilizer_model_loaded: bool
    knowledge_base_records_count: int
    database_connected: bool
