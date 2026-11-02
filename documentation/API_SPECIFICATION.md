# AgriAI REST API Specification

This document details all 10 API endpoints exposed by the AgriAI FastAPI Gateway.

Base URL prefix: `/api`

---

## 1. System & Health Endpoints

### `GET /api/health`
Checks application readiness and health.
- **Response:** `200 OK`
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "project": "AgriAI Diagnostic and Recommendation Backend"
}
```

### `GET /api/crops`
Lists all 5 supported crops and their pathology profiles.
- **Response:** `200 OK`
```json
{
  "status": "success",
  "total_crops": 5,
  "crops": [
    {
      "name": "Guava",
      "scientific_name": "Psidium guajava",
      "description": "High-value fruit crop vulnerable to Canker, Dot, Mummification, and Rust.",
      "diseases": ["Guava_Canker", "Guava_Dot", "Guava_Healthy", "Guava_Mummification", "Guava_Rust"],
      "optimal_ph_range": "6.0 - 7.5",
      "optimal_ec_range": "< 1800 µS/cm"
    }
  ]
}
```

### `GET /api/models/status`
Returns deployment status of all models and databases.
- **Response:** `200 OK`
```json
{
  "cnn_model_loaded": true,
  "cnn_model_type": "EfficientNetB0 SavedModel",
  "cnn_architecture": "EfficientNetB0 (96.86% Accuracy, 40 Classes)",
  "soil_model_loaded": true,
  "soil_model_features_count": 23,
  "fertilizer_model_loaded": true,
  "knowledge_base_records_count": 122,
  "database_connected": true
}
```

---

## 2. Model Inference Endpoints

### `POST /api/disease/predict`
Runs leaf image pathology classification via EfficientNetB0.
- **Content-Type:** `multipart/form-data`
- **Parameters:**
  - `image`: Binary image file (JPEG/PNG)
  - `crop`: Optional crop hint (e.g., "Guava")
- **Response:** `200 OK`
```json
{
  "crop": "Guava",
  "predicted_class": "Guava_Canker",
  "confidence": 96.8,
  "top_3_predictions": [
    {"class": "Guava_Canker", "confidence": 96.8},
    {"class": "Guava_Dot", "confidence": 2.1},
    {"class": "Guava_Healthy", "confidence": 1.1}
  ],
  "image_url": "/uploads/leaf_abc123.jpg",
  "gradcam_url": "/uploads/gradcam_def456.png",
  "gradcam_base64": "..."
}
```

### `POST /api/soil/predict`
Evaluates soil sensor parameters using XGBoost and calculates SHAP values.
- **Content-Type:** `application/json`
- **Request Body:**
```json
{
  "crop": "Guava",
  "soil_readings": {
    "pH": 7.2,
    "Conductivity": 1200.0,
    "Nitrogen": 320.0,
    "Phosphorus": 28.0,
    "Potassium": 280.0
  }
}
```
- **Response:** `200 OK`
```json
{
  "crop": "Guava",
  "status": "Healthy",
  "p_healthy": 0.88,
  "confidence": 88.0,
  "top_shap_features": [
    {
      "feature": "Nitrogen",
      "shap_value": 0.42,
      "measured_value": 320.0,
      "direction": "Pushes Healthy"
    }
  ]
}
```

---

## 3. Multimodal Decision Engine

### `POST /api/integration/analyze`
Performs cross-modal synthesis, enforces guardrails, archives to database, and creates PDF report.
- **Content-Type:** `multipart/form-data` OR `application/json`
- **Parameters / Fields:**
  - `crop`: Crop name (e.g. "Guava")
  - `is_paired_sample`: Boolean
  - `image`: UploadFile (optional)
  - `soil_readings`: JSON string / object (optional)
- **Response:** `200 OK`
```json
{
  "sample_id": "SMP-A1B2C3D4",
  "crop": "Guava",
  "is_paired_sample": true,
  "overall_risk_level": "Moderate",
  "leaf_diagnosis": {...},
  "soil_diagnosis": {...},
  "fertilizer_prescriptions": [
    {
      "prescription_type": "Nitrogen_Supplement",
      "recommended_chemical": "Urea / Neem-Coated Urea",
      "dosage": "150 kg/ha split application",
      "advisory": "Apply in two splits during vegetative growth.",
      "reason": "Soil Nitrogen below critical threshold."
    }
  ],
  "plant_protection_advisory": [
    {
      "target_condition": "Guava_Canker",
      "recommended_protection": "Copper Oxychloride 50 WP",
      "dosage": "2.5 gm/L water",
      "farmer_advisory": "Foliar spray on affected foliage in early morning.",
      "urgency": "Immediate Application"
    }
  ],
  "agronomic_summary": "Foliar pathogen diagnosed. Soil nutrient reserves stable...",
  "warnings": [],
  "report_url": "/api/reports/1"
}
```

### `POST /api/recommendations/generate`
Queries 122-rule Knowledge Base and evaluates ML intervention model.
- **Request Body:**
```json
{
  "crop": "Guava",
  "condition_or_parameter": "canker",
  "parameter_level": "Low"
}
```

---

## 4. History & Reports Endpoints

### `GET /api/history`
- **Query Params:** `skip=0`, `limit=50`, `crop=Guava`
- **Response:** List of archived diagnoses.

### `GET /api/history/{id}`
- **Path Param:** `id` (integer ID or string `sample_id`)
- **Response:** Diagnosis record dictionary.

### `DELETE /api/history/{id}`
- **Path Param:** `id`
- **Response:** `{"message": "Record deleted successfully", "id": 1}`

### `GET /api/reports/{id}`
- **Path Param:** `id`
- **Response:** Streams official generated PDF report (`application/pdf`).
