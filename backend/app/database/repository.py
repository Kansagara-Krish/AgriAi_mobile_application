import json
from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any
from sqlalchemy.orm import Session
from app.models.db_models import DiagnosisRecord

class BaseDiagnosisRepository(ABC):
    """
    Abstract repository interface for persistence.
    Enables plug-and-play migration to MongoDB Atlas in the future
    without altering any service or API logic.
    """

    @abstractmethod
    def create(self, diagnosis_data: Dict[str, Any]) -> Dict[str, Any]:
        pass

    @abstractmethod
    def get_by_id(self, record_id: int) -> Optional[Dict[str, Any]]:
        pass

    @abstractmethod
    def get_by_sample_id(self, sample_id: str) -> Optional[Dict[str, Any]]:
        pass

    @abstractmethod
    def list_all(self, skip: int = 0, limit: int = 50, crop: Optional[str] = None) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    def delete(self, record_id: int) -> bool:
        pass


class SqliteDiagnosisRepository(BaseDiagnosisRepository):
    """
    SQLite implementation of the diagnosis repository.
    """

    def __init__(self, db: Session):
        self.db = db

    def create(self, data: Dict[str, Any]) -> Dict[str, Any]:
        record = DiagnosisRecord(
            sample_id=data.get("sample_id"),
            crop=data.get("crop"),
            diagnosis_type=data.get("diagnosis_type", "integrated"),
            is_paired_sample=data.get("is_paired_sample", True),
            image_filename=data.get("image_filename"),
            leaf_disease=data.get("leaf_disease"),
            leaf_confidence=data.get("leaf_confidence"),
            top_3_predictions_json=json.dumps(data.get("top_3_predictions", [])),
            gradcam_filename=data.get("gradcam_filename"),
            soil_status=data.get("soil_status"),
            soil_confidence=data.get("soil_confidence"),
            soil_p_healthy=data.get("soil_p_healthy"),
            soil_readings_json=json.dumps(data.get("soil_readings", {})),
            soil_shap_json=json.dumps(data.get("soil_shap_features", [])),
            overall_risk_level=data.get("overall_risk_level"),
            fertilizer_prescriptions_json=json.dumps(data.get("fertilizer_prescriptions", [])),
            plant_protection_advisory_json=json.dumps(data.get("plant_protection_advisory", [])),
            agronomic_summary=data.get("agronomic_summary"),
            warnings_json=json.dumps(data.get("warnings", [])),
            report_pdf_filename=data.get("report_pdf_filename")
        )
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record.to_dict()

    def get_by_id(self, record_id: int) -> Optional[Dict[str, Any]]:
        record = self.db.query(DiagnosisRecord).filter(DiagnosisRecord.id == record_id).first()
        return record.to_dict() if record else None

    def get_by_sample_id(self, sample_id: str) -> Optional[Dict[str, Any]]:
        record = self.db.query(DiagnosisRecord).filter(DiagnosisRecord.sample_id == sample_id).first()
        return record.to_dict() if record else None

    def list_all(self, skip: int = 0, limit: int = 50, crop: Optional[str] = None) -> List[Dict[str, Any]]:
        query = self.db.query(DiagnosisRecord)
        if crop:
            query = query.filter(DiagnosisRecord.crop.ilike(crop.strip()))
        records = query.order_by(DiagnosisRecord.timestamp.desc()).offset(skip).limit(limit).all()
        return [r.to_dict() for r in records]

    def delete(self, record_id: int) -> bool:
        record = self.db.query(DiagnosisRecord).filter(DiagnosisRecord.id == record_id).first()
        if not record:
            return False
        self.db.delete(record)
        self.db.commit()
        return True
