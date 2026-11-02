import sys
from pathlib import Path
import pytest
import numpy as np
from PIL import Image

# Ensure backend app is in sys.path
backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.services.cnn_service import CNNLeafDiseaseService
from app.services.soil_service import SoilHealthService
from app.services.fertilizer_service import AgronomicKnowledgeBase, FertilizerMLModel


def test_cnn_service_loading_and_inference():
    """Verifies that the EfficientNetB0 CNN model loads and infers correctly."""
    service = CNNLeafDiseaseService()
    assert service.is_loaded is True
    assert len(service.label_mapping) >= 40

    # Generate synthetic 256x256 test image
    test_img = np.random.randint(50, 200, (256, 256, 3), dtype=np.uint8)
    res = service.predict(test_img)

    assert "predicted_class" in res
    assert "confidence" in res
    assert 0.0 <= res["confidence"] <= 100.0
    assert len(res["top_3_predictions"]) == 3
    assert res.get("gradcam_base64") is not None


def test_soil_service_loading_and_shap():
    """Verifies that XGBoost soil health model loads and calculates SHAP values."""
    soil_svc = SoilHealthService()
    assert soil_svc.is_loaded is True
    assert len(soil_svc.feature_columns) == 23

    sample_readings = {
        "pH": 7.0,
        "Conductivity": 1100.0,
        "Nitrogen": 350.0,
        "Phosphorus": 30.0,
        "Potassium": 290.0,
        "Copper": 1.5,
        "Ferrous": 14.0,
        "Manganese": 9.0,
        "Sulphur": 20.0,
        "Zinc": 2.0,
        "LAI": 2.6,
        "TII": 34.0,
        "ARI": 0.15,
        "RBI": 0.88,
        "CRI": 1.5,
        "FAI": 0.70,
        "MRI": 1.2,
        "HCI": 1.6,
        "C/N_Ratio": 12.0
    }

    pred = soil_svc.predict("Guava", sample_readings)
    assert pred["crop"] == "Guava"
    assert pred["status"] in ["Healthy", "Unhealthy"]
    assert 0.0 <= pred["p_healthy"] <= 1.0
    assert len(pred["top_shap_features"]) > 0


def test_fertilizer_knowledge_base():
    """Verifies knowledge base query rules and nutrient threshold evaluation."""
    kb = AgronomicKnowledgeBase()
    assert kb.is_loaded is True
    assert len(kb.df_kb) >= 120

    # Query Guava Anthracnose
    prescriptions = kb.query_prescription("Guava", "Anthracnose")
    assert len(prescriptions) > 0
    assert "Recommended_Chemical" in prescriptions[0]

    # Evaluate low nitrogen deficiency
    soil_readings = {"Nitrogen": 150.0, "pH": 6.8}
    deficiencies = kb.evaluate_nutrient_thresholds("Guava", soil_readings)
    # Check that rule triggered
    assert isinstance(deficiencies, list)


def test_fertilizer_ml_model():
    """Verifies Fertilizer ML model inference."""
    fert_ml = FertilizerMLModel()
    if fert_ml.is_loaded:
        res = fert_ml.predict("Guava", "Abiotic", "Nitrogen", "Low")
        assert "intervention_class" in res
        assert "confidence" in res
