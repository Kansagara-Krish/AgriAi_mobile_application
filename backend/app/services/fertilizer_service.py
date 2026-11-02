import re
import json
from typing import Dict, Any, List, Optional
import numpy as np
import joblib
import pandas as pd
from app.core.config import settings

class AgronomicKnowledgeBase:
    """
    Interface to the validated agronomic knowledge base exported from
    'fertilizer_knowledge_base.csv' (122 expert rules across 5 crops).
    """

    def __init__(self):
        self.df_kb = None
        self.prescriptions_lookup = {}
        self.is_loaded = False
        self._load()

    def _load(self):
        if settings.KB_CSV_PATH.exists():
            self.df_kb = pd.read_csv(str(settings.KB_CSV_PATH))
            self.df_kb.columns = [c.strip() for c in self.df_kb.columns]
            self.is_loaded = True
            print(f"[OK] Knowledge Base loaded ({len(self.df_kb)} records) from {settings.KB_CSV_PATH}")
        else:
            raise FileNotFoundError(f"Knowledge Base CSV not found at: {settings.KB_CSV_PATH}")

        if settings.FERT_LOOKUP_PATH.exists():
            with open(settings.FERT_LOOKUP_PATH, "r", encoding="utf-8") as f:
                self.prescriptions_lookup = json.load(f)

    def get_crop_records(self, crop: str) -> pd.DataFrame:
        if self.df_kb is None:
            return pd.DataFrame()
        return self.df_kb[self.df_kb["Crop"].str.capitalize() == crop.strip().capitalize()]

    def query_prescription(self, crop: str, condition_or_param: str, level: Optional[str] = None) -> List[Dict[str, Any]]:
        crop_records = self.get_crop_records(crop)
        if crop_records.empty:
            return []

        cond_clean = condition_or_param.lower().strip()
        matches = []

        for _, row in crop_records.iterrows():
            leaf_cond = str(row.get("Leaf Disease / Condition", "")).lower()
            aff_param = str(row.get("Affected Parameter", "")).lower()
            param_lvl = str(row.get("Parameter Level (Low/High)", "")).strip().capitalize()

            is_match = (cond_clean in leaf_cond or cond_clean in aff_param or
                        leaf_cond in cond_clean or aff_param in cond_clean)

            if is_match:
                if level and param_lvl.lower() != level.lower():
                    continue
                matches.append({
                    "CNN_Label_ID": int(row.get("CNN_Label_ID", -1)) if pd.notnull(row.get("CNN_Label_ID")) else None,
                    "Crop": row.get("Crop"),
                    "Condition": row.get("Leaf Disease / Condition"),
                    "Type": row.get("Type"),
                    "Affected_Parameter": row.get("Affected Parameter"),
                    "Level": row.get("Parameter Level (Low/High)"),
                    "Threshold_Value": row.get("Value"),
                    "Recommended_Chemical": row.get("Recommended Fertilizer / Pesticide"),
                    "Dosage": row.get("Dosage (gm or ml per liter / plant)"),
                    "Advisory": row.get("Farmer Advisory / Recovery Suggestion")
                })
        return matches

    def evaluate_nutrient_thresholds(self, crop: str, soil_readings: Dict[str, float]) -> List[Dict[str, Any]]:
        crop_records = self.get_crop_records(crop)
        diagnosed_issues = []

        for _, row in crop_records.iterrows():
            if str(row.get("Type")).strip().capitalize() != "Abiotic":
                continue

            param = str(row.get("Affected Parameter", "")).strip()
            level_rule = str(row.get("Parameter Level (Low/High)", "")).strip().capitalize()
            val_str = str(row.get("Value", "")).strip()

            measured_val = None
            for key, val in soil_readings.items():
                if key.lower() == param.lower() or (key == "C/N_Ratio" and "c/n" in param.lower()):
                    measured_val = val
                    break

            if measured_val is None:
                continue

            threshold_match = re.search(r"[-+]?\d*\.\d+|\d+", val_str)
            if not threshold_match:
                continue
            threshold_num = float(threshold_match.group())

            is_triggered = False
            if level_rule == "Low" and ("<" in val_str or "<=" in val_str or level_rule.lower() in val_str.lower()):
                if measured_val < threshold_num:
                    is_triggered = True
            elif level_rule == "High" and (">" in val_str or ">=" in val_str or level_rule.lower() in val_str.lower()):
                if measured_val > threshold_num:
                    is_triggered = True
            elif "<" in val_str and measured_val < threshold_num:
                is_triggered = True
            elif ">" in val_str and measured_val > threshold_num:
                is_triggered = True

            if is_triggered:
                diagnosed_issues.append({
                    "parameter": param,
                    "level": level_rule,
                    "measured": measured_val,
                    "threshold": val_str,
                    "chemical": row.get("Recommended Fertilizer / Pesticide"),
                    "dosage": row.get("Dosage (gm or ml per liter / plant)"),
                    "advisory": row.get("Farmer Advisory / Recovery Suggestion")
                })
        return diagnosed_issues


class FertilizerMLModel:
    """
    XGBoost Model 2 for Intervention Classification (55 features, 9 classes).
    """

    def __init__(self):
        self.model = None
        self.feature_columns = []
        self.label_mapping = {}
        self.reverse_mapping = {}
        self.is_loaded = False
        self._load()

    def _load(self):
        if settings.FERT_MODEL_PATH.exists() and settings.FERT_FEATURES_PATH.exists():
            self.model = joblib.load(str(settings.FERT_MODEL_PATH))
            with open(settings.FERT_FEATURES_PATH, "r", encoding="utf-8") as f:
                self.feature_columns = json.load(f)
            if settings.FERT_LABELS_PATH.exists():
                with open(settings.FERT_LABELS_PATH, "r", encoding="utf-8") as f:
                    self.label_mapping = json.load(f)
                self.reverse_mapping = {int(k): v for k, v in self.label_mapping.items()}
            self.is_loaded = True
            print(f"[OK] Fertilizer XGBoost Model (55 features) loaded from {settings.FERT_MODEL_PATH}")
        else:
            print(f"Warning: Fertilizer model artifacts missing in {settings.TRAINED_MODELS_DIR / 'fertilizer'}")

    def predict(self, crop: str, etiology_type: str, parameter: str, level: str) -> Dict[str, Any]:
        if not self.is_loaded or self.model is None:
            return {"error": "Fertilizer ML model not loaded"}

        row = {f: 0 for f in self.feature_columns}
        crop_col = f"Crop_{crop.capitalize()}"
        if crop_col in row:
            row[crop_col] = 1

        type_col = f"Type_{etiology_type.capitalize()}"
        if type_col in row:
            row[type_col] = 1

        param_col = f"Param_Clean_{parameter}"
        if param_col in row:
            row[param_col] = 1

        level_col = f"Parameter Level (Low/High)_{level.capitalize()}"
        if level_col in row:
            row[level_col] = 1

        inter_col = f"Param_x_Level_{parameter}_{level.capitalize()}"
        if inter_col in row:
            row[inter_col] = 1

        df_input = pd.DataFrame([row], columns=self.feature_columns)
        probs = self.model.predict_proba(df_input)[0]
        pred_idx = int(np.argmax(probs))
        class_name = self.reverse_mapping.get(pred_idx, f"Class_{pred_idx}")
        conf = float(probs[pred_idx]) * 100.0

        return {
            "intervention_class": class_name,
            "confidence": round(conf, 2),
            "class_index": pred_idx
        }
