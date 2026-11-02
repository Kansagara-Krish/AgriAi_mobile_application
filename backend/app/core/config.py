import os
from pathlib import Path
from pydantic_settings import BaseSettings

BASE_DIR = Path(__file__).resolve().parent.parent.parent  # Points to AgriAI_Application/backend

class Settings(BaseSettings):
    PROJECT_NAME: str = "AgriAI Diagnostic and Recommendation Backend"
    API_V1_PREFIX: str = "/api"
    
    # Paths
    BASE_DIR: Path = BASE_DIR
    TRAINED_MODELS_DIR: Path = BASE_DIR / "trained_models"
    UPLOADS_DIR: Path = BASE_DIR / "uploads"
    REPORTS_DIR: Path = BASE_DIR / "reports"
    LOCAL_DB_DIR: Path = BASE_DIR.parent / "local_database"
    
    # Database
    DATABASE_URL: str = f"sqlite:///{LOCAL_DB_DIR / 'agriai.db'}"
    
    # Model Artifact Paths
    CNN_SAVEDMODEL_DIR: Path = TRAINED_MODELS_DIR / "cnn" / "efficientnetb0_savedmodel"
    CNN_LABELS_PATH: Path = TRAINED_MODELS_DIR / "cnn" / "label_encoding.json"
    CNN_METADATA_PATH: Path = TRAINED_MODELS_DIR / "cnn" / "efficientnetb0_metadata.json"
    
    SOIL_MODEL_PATH: Path = TRAINED_MODELS_DIR / "soil" / "xgb_soil_health_best.joblib"
    SOIL_FEATURES_PATH: Path = TRAINED_MODELS_DIR / "soil" / "soil_model_features.json"
    
    FERT_MODEL_PATH: Path = TRAINED_MODELS_DIR / "fertilizer" / "xgb_fertilizer_recommendation_best.joblib"
    FERT_FEATURES_PATH: Path = TRAINED_MODELS_DIR / "fertilizer" / "fertilizer_model_features.json"
    FERT_LABELS_PATH: Path = TRAINED_MODELS_DIR / "fertilizer" / "fertilizer_label_mapping.json"
    FERT_LOOKUP_PATH: Path = TRAINED_MODELS_DIR / "fertilizer" / "fertilizer_prescriptions_lookup.json"
    
    KB_CSV_PATH: Path = TRAINED_MODELS_DIR / "knowledge_base" / "fertilizer_knowledge_base.csv"
    
    # CORS
    CORS_ORIGINS: list = ["*"]
    
    # Server host and port
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    class Config:
        env_file = ".env"
        extra = "allow"

settings = Settings()

# Ensure directories exist
settings.UPLOADS_DIR.mkdir(parents=True, exist_ok=True)
settings.REPORTS_DIR.mkdir(parents=True, exist_ok=True)
settings.LOCAL_DB_DIR.mkdir(parents=True, exist_ok=True)
