import json
from typing import Dict, Any, List, Optional
import joblib
import pandas as pd
import shap
from app.core.config import settings

class SoilHealthService:
    """
    XGBoost Soil Health Classifier (Model 1) with local SHAP feature attribution.
    Target: Soil_Status_Binary (1 = Healthy, 0 = Unhealthy).
    Schema: 23 features (19 physicochemical/spectral + 4 crop indicators).
    """

    def __init__(self):
        self.model = None
        self.feature_columns = []
        self.explainer = None
        self.is_loaded = False
        self._load()

    def _load(self):
        if settings.SOIL_MODEL_PATH.exists() and settings.SOIL_FEATURES_PATH.exists():
            self.model = joblib.load(str(settings.SOIL_MODEL_PATH))
            with open(settings.SOIL_FEATURES_PATH, "r", encoding="utf-8") as f:
                self.feature_columns = json.load(f)
            self.explainer = shap.TreeExplainer(self.model)
            self.is_loaded = True
            print(f"[OK] Soil Health XGBoost model (23 features) loaded from {settings.SOIL_MODEL_PATH}")
        else:
            raise FileNotFoundError(f"Soil model artifacts missing in {settings.TRAINED_MODELS_DIR / 'soil'}")

    def preprocess_soil_input(self, crop: str, soil_dict: Dict[str, Any]) -> pd.DataFrame:
        """
        Aligns raw dictionary readings to the exact 23-feature schema.
        Handles default values and crop one-hot encoding.
        """
        default_sensor_medians = {
            'pH': 7.2,
            'Conductivity': 1200.0,
            'Nitrogen': 320.0,
            'Phosphorus': 28.0,
            'Potassium': 280.0,
            'Copper': 1.2,
            'Ferrous': 12.0,
            'Manganese': 8.5,
            'Sulphur': 18.0,
            'Zinc': 1.8,
            'LAI': 2.4,
            'TII': 35.0,
            'ARI': 0.12,
            'RBI': 0.85,
            'CRI': 1.4,
            'FAI': 0.65,
            'MRI': 1.1,
            'HCI': 1.5,
            'C/N_Ratio': 12.5
        }

        row = {}
        for feat in self.feature_columns:
            if feat.startswith("Crop_Name_"):
                crop_indicated = feat.replace("Crop_Name_", "").lower()
                row[feat] = 1 if crop.lower() == crop_indicated else 0
            else:
                val = soil_dict.get(feat, default_sensor_medians.get(feat, 0.0))
                try:
                    row[feat] = float(val) if val is not None and not pd.isna(val) else default_sensor_medians.get(feat, 0.0)
                except (ValueError, TypeError):
                    row[feat] = default_sensor_medians.get(feat, 0.0)

        return pd.DataFrame([row], columns=self.feature_columns)

    def predict(self, crop: str, soil_dict: Dict[str, Any]) -> Dict[str, Any]:
        """
        Runs XGBoost inference and extracts SHAP feature impact.
        """
        if not self.is_loaded:
            raise RuntimeError("Soil health model is not loaded")

        aligned_df = self.preprocess_soil_input(crop, soil_dict)
        prob_healthy = float(self.model.predict_proba(aligned_df)[0, 1])
        pred_class = int(prob_healthy >= 0.5)
        status = "Healthy" if pred_class == 1 else "Unhealthy"
        confidence = prob_healthy if pred_class == 1 else (1.0 - prob_healthy)

        top_shap_features = []
        try:
            if self.explainer:
                shap_res = self.explainer(aligned_df)
                shap_vals = shap_res.values[0]
                feature_impacts = []
                for feat_name, impact, measured_val in zip(self.feature_columns, shap_vals, aligned_df.iloc[0]):
                    feature_impacts.append({
                        "feature": feat_name,
                        "shap_value": round(float(impact), 4),
                        "measured_value": round(float(measured_val), 2),
                        "direction": "Pushes Healthy" if impact > 0 else "Pushes Unhealthy"
                    })
                top_shap_features = sorted(feature_impacts, key=lambda x: abs(x["shap_value"]), reverse=True)[:6]
        except Exception as e:
            print(f"SHAP explanation note: {e}")

        return {
            "crop": crop.capitalize(),
            "status": status,
            "class": pred_class,
            "p_healthy": round(prob_healthy, 4),
            "confidence": round(confidence * 100.0, 2),
            "top_shap_features": top_shap_features
        }
