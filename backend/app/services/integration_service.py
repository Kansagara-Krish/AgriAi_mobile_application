import uuid
from typing import Dict, Any, List, Optional
from app.services.cnn_service import CNNLeafDiseaseService
from app.services.soil_service import SoilHealthService
from app.services.fertilizer_service import AgronomicKnowledgeBase, FertilizerMLModel

class MultimodalIntegrationService:
    """
    Multimodal Decision Integration Engine.
    Synthesizes:
      1. CNN Leaf Disease Classification
      2. XGBoost Soil Health Classification & SHAP
      3. Validated Agronomic Knowledge Base Rules
      4. XGBoost Fertilizer Recommendation
    """

    def __init__(
        self,
        cnn_service: CNNLeafDiseaseService,
        soil_service: SoilHealthService,
        kb: AgronomicKnowledgeBase,
        fert_ml: FertilizerMLModel
    ):
        self.cnn_service = cnn_service
        self.soil_service = soil_service
        self.kb = kb
        self.fert_ml = fert_ml

    def synthesize(
        self,
        crop: str,
        cnn_result: Optional[Dict[str, Any]] = None,
        soil_health_result: Optional[Dict[str, Any]] = None,
        raw_soil_readings: Optional[Dict[str, float]] = None,
        is_paired_sample: bool = True
    ) -> Dict[str, Any]:
        crop_clean = crop.strip().capitalize()
        warnings = []
        fertilizer_prescriptions = []
        plant_protection_advisory = []
        risk_level = "Low"

        # 1. Crop Mismatch Guardrail
        if cnn_result and "predicted_class" in cnn_result:
            pred_class = cnn_result["predicted_class"]
            pred_crop = pred_class.split("_")[0].capitalize()
            if pred_crop.lower() != crop_clean.lower():
                warnings.append(
                    f"⚠️ CROP MISMATCH DETECTED: Selected crop is '{crop_clean}', but leaf image is diagnosed as '{pred_crop}' ({pred_class}). Recommendations may be invalid."
                )
                risk_level = "High"

        # 2. Low Confidence Guardrail
        if cnn_result and "confidence" in cnn_result:
            if cnn_result["confidence"] < 60.0:
                warnings.append(
                    f"⚠️ LOW VISION CONFIDENCE ({cnn_result['confidence']}%): Leaf visual diagnosis is uncertain. Recommend capturing clearer leaf photo in natural sunlight."
                )
                if risk_level == "Low":
                    risk_level = "Moderate"

        # 3. Unverified Sample Pairing Guardrail
        if not is_paired_sample and cnn_result and raw_soil_readings:
            warnings.append(
                "ℹ️ UNVERIFIED SAMPLE PAIRING: Leaf image and soil test may originate from different plots. Cross-modal decisions are decoupled."
            )

        # 4. Analyze Soil Measurements (if present)
        salinity_lockout = False
        soil_issues = []
        if raw_soil_readings:
            ec = raw_soil_readings.get("Conductivity", 0.0)
            ph = raw_soil_readings.get("pH", 7.0)
            
            # Salinity lockout check (EC > 2200 µS/cm or pH > 8.0)
            if ec > 2200.0 or ph > 8.0:
                salinity_lockout = True
                warnings.append(
                    f"🚨 SALINITY / ALKALINITY LOCKOUT: Soil EC is {ec} µS/cm and pH is {ph}. Roots cannot uptake nutrients. Cease all chemical fertilizers immediately."
                )
                fertilizer_prescriptions.append({
                    "prescription_type": "Soil_Amendment",
                    "recommended_chemical": "Agricultural Gypsum / Acidifying Organic Compost",
                    "dosage": "500 - 1000 kg/ha broadcast with heavy irrigation flushing",
                    "advisory": "Leach excessive soluble salts before applying mineral fertilizers.",
                    "reason": "Salinity osmotic barrier prevents root absorption."
                })
                risk_level = "High"

            # Evaluate quantitative nutrient deficiencies
            soil_issues = self.kb.evaluate_nutrient_thresholds(crop_clean, raw_soil_readings)

        # 5. Analyze Leaf Condition (if present)
        leaf_disease = cnn_result.get("predicted_class", "") if cnn_result else ""
        is_healthy_leaf = "healthy" in leaf_disease.lower() if leaf_disease else True
        is_nutritional_foliar = any(n in leaf_disease.lower() for n in ["nitrogen", "pottasium", "potassium", "magnesium", "phosphorus"])
        is_biotic = not is_healthy_leaf and not is_nutritional_foliar if leaf_disease else False

        # Biotic Plant Protection
        if is_biotic:
            risk_level = "High"
            # Query knowledge base for plant protection
            cond_key = leaf_disease.replace(f"{crop_clean}_", "").replace("_", " ")
            records = self.kb.query_prescription(crop_clean, cond_key)
            if records:
                for r in records:
                    plant_protection_advisory.append({
                        "target_condition": r["Condition"],
                        "recommended_protection": r["Recommended_Chemical"],
                        "dosage": r["Dosage"],
                        "farmer_advisory": r["Advisory"],
                        "urgency": "Immediate Application"
                    })
            else:
                plant_protection_advisory.append({
                    "target_condition": leaf_disease,
                    "recommended_protection": "Validated Broad-Spectrum Bio-fungicide / Copper Oxychloride",
                    "dosage": "2.5 gm/L water",
                    "farmer_advisory": "Isolate infected foliage and spray in early morning or late evening.",
                    "urgency": "High"
                })

        # 6. Synthesize Fertilizer Prescriptions
        if not salinity_lockout and raw_soil_readings:
            for issue in soil_issues:
                param = issue["parameter"]
                lvl = issue["level"]
                # If nutrient is in toxic excess (High)
                if lvl.lower() == "high":
                    fertilizer_prescriptions.append({
                        "prescription_type": "No_Chemical_Fertilizer",
                        "recommended_chemical": "Cease Fertilizer Application & Irrigate",
                        "dosage": "No fertilizer",
                        "advisory": f"Excessive {param} detected ({issue['measured']}). Withhold fertilizers to avoid crop toxicity.",
                        "reason": f"Soil {param} exceeds safe threshold."
                    })
                    if risk_level != "High":
                        risk_level = "Moderate"
                else:
                    # Low nutrient deficiency
                    fertilizer_prescriptions.append({
                        "prescription_type": f"{param}_Supplement",
                        "recommended_chemical": issue["chemical"],
                        "dosage": str(issue["dosage"]),
                        "advisory": issue["advisory"],
                        "reason": f"Soil {param} ({issue['measured']}) is below required agronomic threshold ({issue['threshold']})."
                    })
                    if risk_level == "Low":
                        risk_level = "Moderate"

        # 7. Summary Narrative
        if is_healthy_leaf and (not soil_health_result or soil_health_result.get("status") == "Healthy") and len(fertilizer_prescriptions) == 0:
            summary = f"OPTIMAL & HEALTHY: {crop_clean} exhibits vigorous leaf canopy and balanced soil parameters. Continue routine cultural practices and standard irrigation schedules."
            risk_level = "Low"
        elif is_biotic and len(fertilizer_prescriptions) == 0:
            summary = f"BIOTIC INFECTION DETECTED: Foliar pathogen identified as '{leaf_disease}'. Soil nutrient reserves are stable. Apply targeted plant protection; do not apply extra fertilizers."
        elif len(fertilizer_prescriptions) > 0 and not is_biotic:
            summary = f"SOIL DEFICIENCIES IDENTIFIED: Crop {crop_clean} shows specific nutrient shortages. Apply soil-informed fertilizer amendments as prescribed."
        else:
            summary = f"MULTIMODAL DIAGNOSIS COMPLETED for {crop_clean}. Review both plant protection and soil health advisories for comprehensive field management."

        return {
            "overall_risk_level": risk_level,
            "fertilizer_prescriptions": fertilizer_prescriptions,
            "plant_protection_advisory": plant_protection_advisory,
            "agronomic_summary": summary,
            "warnings": warnings,
            "is_paired_sample": is_paired_sample
        }
