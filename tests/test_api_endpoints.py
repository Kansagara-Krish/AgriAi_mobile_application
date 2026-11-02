import io
import sys
from pathlib import Path
import pytest
from fastapi.testclient import TestClient
from PIL import Image

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from main import app

client = TestClient(app)


def test_api_health():
    res = client.get("/api/health")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "healthy"
    assert "version" in data


def test_api_crops():
    res = client.get("/api/crops")
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "success"
    assert data["total_crops"] == 5
    crop_names = [c["name"] for c in data["crops"]]
    assert "Guava" in crop_names
    assert "Papaya" in crop_names


def test_api_models_status():
    res = client.get("/api/models/status")
    assert res.status_code == 200
    data = res.json()
    assert "cnn_model_loaded" in data
    assert "soil_model_loaded" in data
    assert data["cnn_model_loaded"] is True
    assert data["soil_model_loaded"] is True


def test_api_soil_predict():
    payload = {
        "crop": "Guava",
        "soil_readings": {
            "pH": 7.2,
            "Conductivity": 1200.0,
            "Nitrogen": 320.0,
            "Phosphorus": 28.0,
            "Potassium": 280.0
        }
    }
    res = client.post("/api/soil/predict", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["crop"] == "Guava"
    assert data["status"] in ["Healthy", "Unhealthy"]
    assert "p_healthy" in data
    assert len(data["top_shap_features"]) > 0


def test_api_disease_predict():
    # Create in-memory test leaf image
    img = Image.new("RGB", (256, 256), color=(40, 160, 40))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    buf.seek(0)

    files = {"image": ("test_leaf.jpg", buf, "image/jpeg")}
    data = {"crop": "Guava"}

    res = client.post("/api/disease/predict", files=files, data=data)
    assert res.status_code == 200
    resp_data = res.json()
    assert "predicted_class" in resp_data
    assert "confidence" in resp_data
    assert len(resp_data["top_3_predictions"]) == 3


def test_api_integration_analyze():
    # Test multimodal analyze with JSON body
    payload = {
        "crop": "Guava",
        "is_paired_sample": True,
        "soil_readings": {
            "pH": 7.0,
            "Conductivity": 1150.0,
            "Nitrogen": 310.0
        },
        "leaf_diagnosis": {
            "predicted_class": "Guava_Healthy",
            "confidence": 95.0
        }
    }
    res = client.post("/api/integration/analyze", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert "sample_id" in data
    assert data["crop"] == "Guava"
    assert data["overall_risk_level"] in ["Low", "Moderate", "High", "Severe"]
    assert "agronomic_summary" in data


def test_api_recommendations_generate():
    payload = {
        "crop": "Guava",
        "condition_or_parameter": "canker",
        "parameter_level": "Low"
    }
    res = client.post("/api/recommendations/generate", json=payload)
    assert res.status_code == 200
    data = res.json()
    assert data["crop"] == "Guava"
    assert "prescriptions" in data


def test_api_history_and_report_endpoints():
    # 0. Ensure at least one record exists by posting an analysis
    sample_payload = {
        "crop": "Guava",
        "is_paired_sample": True,
        "soil_readings": {"pH": 6.8, "Conductivity": 1100.0, "Nitrogen": 300.0},
        "leaf_diagnosis": {"predicted_class": "Guava_Healthy", "confidence": 95.0}
    }
    create_res = client.post("/api/integration/analyze", json=sample_payload)
    assert create_res.status_code == 200

    # 1. Fetch history
    res = client.get("/api/history?limit=10")
    assert res.status_code == 200
    data = res.json()
    assert "records" in data
    assert len(data["records"]) > 0

    first_rec = data["records"][0]
    rec_id = first_rec["id"]

    # 2. Get history detail
    detail_res = client.get(f"/api/history/{rec_id}")
    assert detail_res.status_code == 200
    assert detail_res.json()["id"] == rec_id

    # 3. Download report
    rep_res = client.get(f"/api/reports/{rec_id}")
    assert rep_res.status_code == 200
    assert rep_res.headers["content-type"] == "application/pdf"
