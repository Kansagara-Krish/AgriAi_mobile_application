import sys
from pathlib import Path
import pytest

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.services.cnn_service import CNNLeafDiseaseService
from app.services.soil_service import SoilHealthService
from app.services.fertilizer_service import AgronomicKnowledgeBase, FertilizerMLModel
from app.services.integration_service import MultimodalIntegrationService


@pytest.fixture(scope="module")
def integration_service():
    cnn = CNNLeafDiseaseService()
    soil = SoilHealthService()
    kb = AgronomicKnowledgeBase()
    fert = FertilizerMLModel()
    return MultimodalIntegrationService(cnn, soil, kb, fert)


def test_salinity_lockout_rule(integration_service):
    """
    CRITICAL RULE TEST:
    When soil EC > 2200 µS/cm or pH > 8.0, all chemical fertilizers MUST be blocked,
    and Agricultural Gypsum / Leaching flushing MUST be prescribed.
    """
    soil_readings = {
        "Conductivity": 2500.0,
        "pH": 8.4,
        "Nitrogen": 150.0  # Deficient, but chemical N should NOT be applied!
    }

    res = integration_service.synthesize(
        crop="Guava",
        cnn_result={"predicted_class": "Guava_Healthy", "confidence": 95.0},
        soil_health_result={"status": "Unhealthy", "p_healthy": 0.2},
        raw_soil_readings=soil_readings,
        is_paired_sample=True
    )

    # 1. Warning must be triggered
    warnings_text = " ".join(res["warnings"])
    assert "SALINITY / ALKALINITY LOCKOUT" in warnings_text

    # 2. Risk level must be High
    assert res["overall_risk_level"] == "High"

    # 3. Prescribed remedy must be Gypsum / Soil Amendment
    chems = [fp["recommended_chemical"].lower() for fp in res["fertilizer_prescriptions"]]
    assert any("gypsum" in c for c in chems)


def test_crop_mismatch_guardrail(integration_service):
    """
    When selected crop is Guava but CNN identifies Papaya disease,
    crop mismatch alert must be triggered with High risk.
    """
    res = integration_service.synthesize(
        crop="Guava",
        cnn_result={"predicted_class": "Papaya_Mosaic", "confidence": 92.0},
        soil_health_result={"status": "Healthy", "p_healthy": 0.85},
        raw_soil_readings={"pH": 7.0, "Conductivity": 1200.0},
        is_paired_sample=True
    )

    warnings_text = " ".join(res["warnings"])
    assert "CROP MISMATCH DETECTED" in warnings_text
    assert res["overall_risk_level"] == "High"


def test_low_confidence_guardrail(integration_service):
    """
    When CNN confidence is below 60%, warning must be issued to re-take image in daylight.
    """
    res = integration_service.synthesize(
        crop="Guava",
        cnn_result={"predicted_class": "Guava_Canker", "confidence": 54.0},
        soil_health_result={"status": "Healthy", "p_healthy": 0.8},
        raw_soil_readings={"pH": 7.0, "Conductivity": 1100.0},
        is_paired_sample=True
    )

    warnings_text = " ".join(res["warnings"])
    assert "LOW VISION CONFIDENCE" in warnings_text
    assert res["overall_risk_level"] in ["Moderate", "High"]


def test_unverified_sample_pairing(integration_service):
    """
    When is_paired_sample=False, warning must inform farmer of decoupled modalities.
    """
    res = integration_service.synthesize(
        crop="Guava",
        cnn_result={"predicted_class": "Guava_Healthy", "confidence": 96.0},
        soil_health_result={"status": "Healthy", "p_healthy": 0.9},
        raw_soil_readings={"pH": 7.1, "Conductivity": 1050.0},
        is_paired_sample=False
    )

    warnings_text = " ".join(res["warnings"])
    assert "UNVERIFIED SAMPLE PAIRING" in warnings_text
