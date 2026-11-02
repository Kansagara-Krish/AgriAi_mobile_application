from typing import Generator
from sqlalchemy.orm import Session
from app.database.session import SessionLocal
from app.services.cnn_service import CNNLeafDiseaseService
from app.services.soil_service import SoilHealthService
from app.services.fertilizer_service import AgronomicKnowledgeBase, FertilizerMLModel
from app.services.integration_service import MultimodalIntegrationService
from app.services.report_service import ReportService

# Lazy-loaded singletons
_cnn_service = None
_soil_service = None
_kb_service = None
_fertilizer_ml_service = None
_integration_service = None
_report_service = None

def get_db() -> Generator[Session, None, None]:
    """Dependency for acquiring SQLite database sessions."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_cnn_service() -> CNNLeafDiseaseService:
    global _cnn_service
    if _cnn_service is None:
        _cnn_service = CNNLeafDiseaseService()
    return _cnn_service

def get_soil_service() -> SoilHealthService:
    global _soil_service
    if _soil_service is None:
        _soil_service = SoilHealthService()
    return _soil_service

def get_kb_service() -> AgronomicKnowledgeBase:
    global _kb_service
    if _kb_service is None:
        _kb_service = AgronomicKnowledgeBase()
    return _kb_service

def get_fertilizer_ml_service() -> FertilizerMLModel:
    global _fertilizer_ml_service
    if _fertilizer_ml_service is None:
        _fertilizer_ml_service = FertilizerMLModel()
    return _fertilizer_ml_service

def get_integration_service() -> MultimodalIntegrationService:
    global _integration_service
    if _integration_service is None:
        cnn = get_cnn_service()
        soil = get_soil_service()
        kb = get_kb_service()
        fert = get_fertilizer_ml_service()
        _integration_service = MultimodalIntegrationService(cnn, soil, kb, fert)
    return _integration_service

def get_report_service() -> ReportService:
    global _report_service
    if _report_service is None:
        _report_service = ReportService()
    return _report_service
