import os
import uuid
import json
from pathlib import Path
from typing import List, Optional, Dict, Any

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query, Request, status
from fastapi.responses import FileResponse, JSONResponse
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database.repository import SqliteDiagnosisRepository
from app.api.deps import (
    get_db,
    get_cnn_service,
    get_soil_service,
    get_kb_service,
    get_fertilizer_ml_service,
    get_integration_service,
    get_report_service
)
from app.schemas.diagnostic import (
    HealthResponse,
    ModelStatusResponse,
    SoilPredictionRequest,
    SoilPredictionResponse,
    LeafDiseasePredictionResponse,
    TopPrediction,
    ShapFeatureImpact,
    IntegratedAnalysisResponse,
    FertilizerPrescription,
    PlantProtectionAdvisory,
    RecommendationRequest
)
from app.services.cnn_service import CNNLeafDiseaseService
from app.services.soil_service import SoilHealthService
from app.services.fertilizer_service import AgronomicKnowledgeBase, FertilizerMLModel
from app.services.integration_service import MultimodalIntegrationService
from app.services.report_service import ReportService

router = APIRouter()

SUPPORTED_CROPS = [
    {
        "name": "Guava",
        "scientific_name": "Psidium guajava",
        "description": "High-value fruit crop vulnerable to Canker, Dot, Mummification, and Rust.",
        "diseases": ["Guava_Canker", "Guava_Dot", "Guava_Healthy", "Guava_Mummification", "Guava_Rust"],
        "optimal_ph_range": "6.0 - 7.5",
        "optimal_ec_range": "< 1800 µS/cm"
    },
    {
        "name": "Papaya",
        "scientific_name": "Carica papaya",
        "description": "Rapidly growing tropical fruit susceptible to Anthracnose, Black Spot, Mosaic, and Ring Spot.",
        "diseases": ["Papaya_Anthracnose", "Papaya_Black_Spot", "Papaya_Healthy", "Papaya_Mosaic", "Papaya_Ring_Spot"],
        "optimal_ph_range": "6.0 - 7.0",
        "optimal_ec_range": "< 1500 µS/cm"
    },
    {
        "name": "Brinjal",
        "scientific_name": "Solanum melongena",
        "description": "Widely cultivated vegetable susceptible to Bacterial Wilt, Cercospora Leaf Spot, Little Leaf, and TMV.",
        "diseases": ["Brinjal_Bacterial_Wilt", "Brinjal_Cercospora_Leaf_Spot", "Brinjal_Healthy", "Brinjal_Little_Leaf", "Brinjal_Tobacco_Mosaic_Virus"],
        "optimal_ph_range": "5.5 - 6.8",
        "optimal_ec_range": "< 2000 µS/cm"
    },
    {
        "name": "Castor",
        "scientific_name": "Ricinus communis",
        "description": "Major commercial oilseed crop prone to Bacterial Blight, Cercospora, Rust, and Seedling Blight.",
        "diseases": ["Castor_Bacterial_Blight", "Castor_Cercospora", "Castor_Healthy", "Castor_Rust", "Castor_Seedling_Blight"],
        "optimal_ph_range": "5.5 - 7.0",
        "optimal_ec_range": "< 2000 µS/cm"
    },
    {
        "name": "Cumin",
        "scientific_name": "Cuminum cyminum",
        "description": "High-value cash spice crop vulnerable to devastating Alternaria Blight, Fusarium Wilt, and Powdery Mildew.",
        "diseases": ["Cumin_Alternaria_Blight", "Cumin_Fusarium_Wilt", "Cumin_Healthy", "Cumin_Powdery_Mildew"],
        "optimal_ph_range": "6.8 - 8.2",
        "optimal_ec_range": "< 1600 µS/cm"
    }
]


# ============================================================================
# 1. System Health & Metadata Endpoints
# ============================================================================

@router.get("/health", response_model=HealthResponse, tags=["System"])
def check_health():
    """Returns application health status, version, and project details."""
    return HealthResponse(
        status="healthy",
        version="1.0.0",
        project=settings.PROJECT_NAME
    )


@router.get("/crops", tags=["Agronomy"])
def list_crops():
    """Returns the list of 5 supported crops and their pathology profiles."""
    return {
        "status": "success",
        "total_crops": len(SUPPORTED_CROPS),
        "crops": SUPPORTED_CROPS
    }


@router.get("/models/status", response_model=ModelStatusResponse, tags=["System"])
def check_models_status(
    cnn: CNNLeafDiseaseService = Depends(get_cnn_service),
    soil: SoilHealthService = Depends(get_soil_service),
    fert: FertilizerMLModel = Depends(get_fertilizer_ml_service),
    kb: AgronomicKnowledgeBase = Depends(get_kb_service),
    db: Session = Depends(get_db)
):
    """Returns deployment status of all machine learning models and knowledge bases."""
    db_ok = False
    try:
        db.execute(text("SELECT 1"))
        db_ok = True
    except Exception:
        db_ok = False

    return ModelStatusResponse(
        cnn_model_loaded=bool(cnn.is_loaded),
        cnn_model_type="EfficientNetB0 SavedModel",
        cnn_architecture="EfficientNetB0 (96.86% Accuracy, 40 Classes)",
        soil_model_loaded=bool(soil.is_loaded),
        soil_model_features_count=len(soil.feature_columns),
        fertilizer_model_loaded=bool(fert.is_loaded),
        knowledge_base_records_count=len(kb.df_kb) if kb.df_kb is not None else 0,
        database_connected=db_ok
    )


# ============================================================================
# 2. Leaf Disease Prediction Endpoint
# ============================================================================

@router.post("/disease/predict", response_model=LeafDiseasePredictionResponse, tags=["Leaf Vision"])
async def predict_leaf_disease(
    image: UploadFile = File(..., description="Leaf image file (JPEG/PNG)"),
    crop: Optional[str] = Form(None, description="Optional target crop hint"),
    cnn: CNNLeafDiseaseService = Depends(get_cnn_service)
):
    """
    Analyzes an uploaded leaf image using the EfficientNetB0 SavedModel.
    Generates diagnosis, confidence score, top-3 candidates, and Grad-CAM saliency overlay.
    """
    if not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid file type: {image.content_type}. Please upload an image file."
        )

    # Save incoming image to uploads directory
    file_ext = Path(image.filename).suffix or ".jpg"
    unique_filename = f"leaf_{uuid.uuid4().hex[:12]}{file_ext}"
    image_path = settings.UPLOADS_DIR / unique_filename

    try:
        contents = await image.read()
        with open(image_path, "wb") as f:
            f.write(contents)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to save uploaded image: {str(e)}"
        )

    # Run inference and generate Grad-CAM
    try:
        result = cnn.predict(image_path, save_gradcam_dir=settings.UPLOADS_DIR)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Inference error: {str(e)}"
        )

    pred_class = result["predicted_class"]
    detected_crop = pred_class.split("_")[0].capitalize() if "_" in pred_class else (crop or "Unknown")

    top3_list = [
        TopPrediction(crop_class=item["class"], confidence=item["confidence"])
        for item in result.get("top_3_predictions", [])
    ]

    gradcam_filename = result.get("gradcam_filename")
    image_url = f"/uploads/{unique_filename}"
    gradcam_url = f"/uploads/{gradcam_filename}" if gradcam_filename else None

    return LeafDiseasePredictionResponse(
        crop=crop.capitalize() if crop else detected_crop,
        predicted_class=pred_class,
        confidence=result["confidence"],
        top_3_predictions=top3_list,
        image_url=image_url,
        gradcam_url=gradcam_url,
        gradcam_base64=result.get("gradcam_base64")
    )


# ============================================================================
# 3. Soil Health Prediction Endpoint
# ============================================================================

@router.post("/soil/predict", response_model=SoilPredictionResponse, tags=["Soil Health"])
def predict_soil_health(
    request: SoilPredictionRequest,
    soil: SoilHealthService = Depends(get_soil_service)
):
    """
    Evaluates soil physicochemical and spectral sensor parameters using XGBoost.
    Returns Healthy/Unhealthy classification, healthy probability, and top SHAP feature impacts.
    """
    crop_name = request.crop.strip().capitalize()
    readings_dict = request.soil_readings.model_dump(by_alias=True)

    try:
        result = soil.predict(crop_name, readings_dict)
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Soil inference error: {str(e)}"
        )

    shap_features = [
        ShapFeatureImpact(
            feature=sf["feature"],
            shap_value=sf["shap_value"],
            measured_value=sf["measured_value"],
            direction=sf["direction"]
        )
        for sf in result.get("top_shap_features", [])
    ]

    return SoilPredictionResponse(
        crop=result["crop"],
        status=result["status"],
        p_healthy=result["p_healthy"],
        confidence=result["confidence"],
        top_shap_features=shap_features
    )


# ============================================================================
# 4. Multimodal Integration & Decision Engine Endpoint
# ============================================================================

@router.post("/integration/analyze", response_model=IntegratedAnalysisResponse, tags=["Multimodal Engine"])
async def analyze_multimodal(
    request: Request,
    crop: Optional[str] = Form(None),
    is_paired_sample: bool = Form(True),
    image: Optional[UploadFile] = File(None),
    soil_readings: Optional[str] = Form(None),
    cnn: CNNLeafDiseaseService = Depends(get_cnn_service),
    soil: SoilHealthService = Depends(get_soil_service),
    integration: MultimodalIntegrationService = Depends(get_integration_service),
    report_svc: ReportService = Depends(get_report_service),
    db: Session = Depends(get_db)
):
    """
    Comprehensive multimodal diagnostic endpoint. Accepts multipart/form-data
    (leaf image file + soil JSON) OR application/json payload.
    Synthesizes vision, soil, agronomic rules, and fertilizer models into an actionable advisory,
    generates a downloadable PDF report, and archives the record to the database.
    """
    content_type = request.headers.get("content-type", "")
    sample_id = f"SMP-{uuid.uuid4().hex[:8].upper()}"

    # Handle JSON request body fallback
    if "application/json" in content_type:
        try:
            body = await request.json()
        except Exception:
            raise HTTPException(status_code=400, detail="Invalid JSON body")

        crop_val = body.get("crop", "Guava")
        is_paired = body.get("is_paired_sample", True)
        soil_dict = body.get("soil_readings", {})
        leaf_res = body.get("leaf_diagnosis")
        image_fn = None
        gradcam_fn = None
    else:
        # Multipart form processing
        crop_val = crop if crop else "Guava"
        is_paired = is_paired_sample
        soil_dict = {}
        if soil_readings:
            try:
                soil_dict = json.loads(soil_readings)
            except Exception:
                soil_dict = {}

        # Leaf vision inference if image provided
        leaf_res = None
        image_fn = None
        gradcam_fn = None

        if image and image.filename:
            file_ext = Path(image.filename).suffix or ".jpg"
            image_fn = f"leaf_{uuid.uuid4().hex[:12]}{file_ext}"
            saved_img_path = settings.UPLOADS_DIR / image_fn
            contents = await image.read()
            with open(saved_img_path, "wb") as f:
                f.write(contents)

            # Predict leaf disease
            cnn_pred = cnn.predict(saved_img_path, save_gradcam_dir=settings.UPLOADS_DIR)
            gradcam_fn = cnn_pred.get("gradcam_filename")
            leaf_res = {
                "predicted_class": cnn_pred["predicted_class"],
                "confidence": cnn_pred["confidence"],
                "top_3_predictions": cnn_pred["top_3_predictions"],
                "gradcam_filename": gradcam_fn,
                "image_filename": image_fn
            }

    # Soil health prediction if soil readings provided
    soil_res = None
    if soil_dict:
        soil_res = soil.predict(crop_val, soil_dict)

    # Multimodal Synthesis
    synthesis = integration.synthesize(
        crop=crop_val,
        cnn_result=leaf_res,
        soil_health_result=soil_res,
        raw_soil_readings=soil_dict,
        is_paired_sample=is_paired
    )

    # Determine diagnosis type
    diag_type = "integrated"
    if leaf_res and not soil_res:
        diag_type = "leaf_only"
    elif soil_res and not leaf_res:
        diag_type = "soil_only"

    # Persist record in SQLite Database
    repo = SqliteDiagnosisRepository(db)
    record_data = {
        "sample_id": sample_id,
        "crop": crop_val.capitalize(),
        "diagnosis_type": diag_type,
        "is_paired_sample": is_paired,
        "image_filename": image_fn or (leaf_res.get("image_filename") if leaf_res else None),
        "leaf_disease": leaf_res.get("predicted_class") if leaf_res else None,
        "leaf_confidence": leaf_res.get("confidence") if leaf_res else None,
        "top_3_predictions": leaf_res.get("top_3_predictions", []) if leaf_res else [],
        "gradcam_filename": gradcam_fn or (leaf_res.get("gradcam_filename") if leaf_res else None),
        "soil_status": soil_res.get("status") if soil_res else None,
        "soil_confidence": soil_res.get("confidence") if soil_res else None,
        "soil_p_healthy": soil_res.get("p_healthy") if soil_res else None,
        "soil_readings": soil_dict,
        "soil_shap_features": soil_res.get("top_shap_features", []) if soil_res else [],
        "overall_risk_level": synthesis["overall_risk_level"],
        "fertilizer_prescriptions": synthesis["fertilizer_prescriptions"],
        "plant_protection_advisory": synthesis["plant_protection_advisory"],
        "agronomic_summary": synthesis["agronomic_summary"],
        "warnings": synthesis["warnings"],
        "report_pdf_filename": f"report_{sample_id}.pdf"
    }

    # Generate PDF Report
    pdf_filename = f"report_{sample_id}.pdf"
    try:
        report_svc.generate_pdf_report(record_data, output_filename=pdf_filename)
        record_data["report_pdf_filename"] = pdf_filename
    except Exception as e:
        print(f"PDF generation note: {e}")
        record_data["report_pdf_filename"] = None

    saved_record = repo.create(record_data)

    # Build Pydantic response
    fert_prescriptions = [
        FertilizerPrescription(
            prescription_type=fp["prescription_type"],
            recommended_chemical=fp["recommended_chemical"],
            dosage=fp["dosage"],
            advisory=fp["advisory"],
            reason=fp["reason"]
        )
        for fp in synthesis["fertilizer_prescriptions"]
    ]

    plant_advisories = [
        PlantProtectionAdvisory(
            target_condition=pa["target_condition"],
            recommended_protection=pa["recommended_protection"],
            dosage=pa["dosage"],
            farmer_advisory=pa["farmer_advisory"],
            urgency=pa["urgency"]
        )
        for pa in synthesis["plant_protection_advisory"]
    ]

    report_url = f"/api/reports/{saved_record['id']}" if record_data.get("report_pdf_filename") else None

    return IntegratedAnalysisResponse(
        sample_id=sample_id,
        crop=crop_val.capitalize(),
        is_paired_sample=is_paired,
        overall_risk_level=synthesis["overall_risk_level"],
        leaf_diagnosis=leaf_res,
        soil_diagnosis=soil_res,
        fertilizer_prescriptions=fert_prescriptions,
        plant_protection_advisory=plant_advisories,
        agronomic_summary=synthesis["agronomic_summary"],
        warnings=synthesis["warnings"],
        report_url=report_url
    )


# ============================================================================
# 5. Recommendation Query Endpoint
# ============================================================================

@router.post("/recommendations/generate", tags=["Recommendations"])
def generate_recommendations(
    request: RecommendationRequest,
    kb: AgronomicKnowledgeBase = Depends(get_kb_service),
    fert_ml: FertilizerMLModel = Depends(get_fertilizer_ml_service)
):
    """
    Generates targeted prescriptions by querying the 122-rule Agronomic Knowledge Base
    and evaluating ML intervention classifier for given crop, condition, or soil parameters.
    """
    crop = request.crop.strip().capitalize()
    cond = request.condition_or_parameter.strip()
    level = request.parameter_level

    # Query Knowledge base rules
    kb_prescriptions = kb.query_prescription(crop, cond, level=level)

    # If soil readings provided, evaluate nutrient thresholds
    soil_nutrient_deficiencies = []
    if request.soil_readings:
        soil_nutrient_deficiencies = kb.evaluate_nutrient_thresholds(crop, request.soil_readings)

    # ML model prediction if applicable
    ml_prediction = None
    if fert_ml.is_loaded:
        ml_prediction = fert_ml.predict(
            crop=crop,
            etiology_type="Biotic" if any(w in cond.lower() for w in ["canker", "rust", "spot", "blight", "wilt"]) else "Abiotic",
            parameter=cond,
            level=level or "Low"
        )

    return {
        "crop": crop,
        "query_condition": cond,
        "parameter_level": level,
        "prescriptions": kb_prescriptions,
        "nutrient_threshold_evaluations": soil_nutrient_deficiencies,
        "ml_model_prediction": ml_prediction
    }


# ============================================================================
# 6. Historical Records & Persistence Endpoints
# ============================================================================

@router.get("/history", tags=["History"])
def list_history(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
    crop: Optional[str] = Query(None),
    db: Session = Depends(get_db)
):
    """Retrieves chronological list of historical diagnosis records from SQLite."""
    repo = SqliteDiagnosisRepository(db)
    records = repo.list_all(skip=skip, limit=limit, crop=crop)
    return {
        "status": "success",
        "count": len(records),
        "skip": skip,
        "limit": limit,
        "records": records
    }


@router.get("/history/{record_id}", tags=["History"])
def get_history_detail(
    record_id: str,
    db: Session = Depends(get_db)
):
    """Retrieves comprehensive details of a single diagnosis record by id or sample_id."""
    repo = SqliteDiagnosisRepository(db)
    record = None
    if record_id.isdigit():
        record = repo.get_by_id(int(record_id))
    if not record:
        record = repo.get_by_sample_id(record_id)

    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Diagnosis record '{record_id}' not found."
        )

    return record


@router.delete("/history/{record_id}", tags=["History"])
def delete_history_record(
    record_id: int,
    db: Session = Depends(get_db)
):
    """Deletes a diagnosis record by ID."""
    repo = SqliteDiagnosisRepository(db)
    success = repo.delete(record_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Diagnosis record '{record_id}' not found."
        )
    return {"message": "Record deleted successfully", "id": record_id}


# ============================================================================
# 7. PDF Report Generation & Download Endpoint
# ============================================================================

@router.get("/reports/{record_id}", tags=["Reports"])
def download_pdf_report(
    record_id: str,
    db: Session = Depends(get_db),
    report_svc: ReportService = Depends(get_report_service)
):
    """
    Downloads or streams the generated PDF report for a given diagnosis ID or sample ID.
    If the PDF does not exist on disk, it is dynamically generated from the archived record.
    """
    repo = SqliteDiagnosisRepository(db)
    record = None
    if record_id.isdigit():
        record = repo.get_by_id(int(record_id))
    if not record:
        record = repo.get_by_sample_id(record_id)

    if not record:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Diagnosis record '{record_id}' not found."
        )

    pdf_filename = record.get("report_pdf_filename") or f"report_{record.get('sample_id')}.pdf"
    pdf_path = settings.REPORTS_DIR / pdf_filename

    # If file doesn't exist, generate it now
    if not pdf_path.exists():
        try:
            pdf_path = report_svc.generate_pdf_report(record, output_filename=pdf_filename)
        except Exception as e:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate PDF report: {str(e)}"
            )

    return FileResponse(
        path=str(pdf_path),
        media_type="application/pdf",
        filename=pdf_filename,
        content_disposition_type="inline"
    )
