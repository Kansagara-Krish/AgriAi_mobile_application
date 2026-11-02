# AgriAI Multimodal Agronomic Decision Engine

This document outlines the theoretical framework, biological guardrails, and decision trees implemented in `AgriAI_Application/backend/app/services/integration_service.py`.

---

## 1. Multimodal Architecture Principles

In real-world precision agriculture, diagnosing crop disease from foliar imagery alone can lead to critical misdiagnoses (e.g., mistaking abiotic nitrogen chlorosis for viral mosaic, or applying high-nitrogen fertilizer to a crop suffering from severe salinity).

AgriAI integrates:
1. **Foliar Vision:** EfficientNetB0 (40 classes, 256x256 resolution)
2. **Soil Health Classification:** XGBoost Model 1 (23 physicochemical & spectral features)
3. **Local Explainability:** Grad-CAM (lesion heatmaps) + SHAP TreeExplainer (nutrient attributions)
4. **Domain Agronomy:** 122 expert-validated rules and XGBoost Model 2 (intervention classifier)

---

## 2. Critical Cross-Modal Guardrails

### Guardrail A: Salinity & Alkalinity Osmotic Lockout
- **Condition:** Soil Electrical Conductivity (EC) > 2200 µS/cm OR soil pH > 8.0.
- **Biological Hazard:** Soluble salt concentration in soil pore water creates negative osmotic potential exceeding plant root water potential. Roots cannot uptake water or mineral ions. Applying chemical salts (e.g., urea, muriate of potash) induces lethal root burn.
- **Engine Action:**
  1. Blocks all mineral fertilizer applications.
  2. Issues critical alert `🚨 SALINITY / ALKALINITY LOCKOUT`.
  3. Prescribes soil amendments: Agricultural Gypsum (500-1000 kg/ha) and heavy clean irrigation flushing to leach soluble sodium and chlorides below the active root zone.
  4. Sets overall risk level to `High`.

### Guardrail B: Crop Mismatch Verification
- **Condition:** User selects crop $C_1$ (e.g., Guava), but vision model classifies foliage pathology belonging to crop $C_2$ (e.g., Papaya Mosaic).
- **Engine Action:**
  1. Issues warning `⚠️ CROP MISMATCH DETECTED`.
  2. Raises risk level to `High`.
  3. Prevents invalid fertilizer or chemical dosages calibrated specifically for crop $C_1$.

### Guardrail C: Low Vision Confidence Safety Net
- **Condition:** Vision confidence $< 60\%$.
- **Engine Action:**
  1. Warns the farmer that image diagnosis is uncertain.
  2. Suggests capturing a clearer photograph in natural morning light.
  3. Escalates minimum risk level to `Moderate`.

### Guardrail D: Sample Pairing Audit
- **Condition:** `is_paired_sample == False`.
- **Engine Action:**
  1. Notes that foliar image and soil test may originate from different plots.
  2. Decouples systemic cross-modal deductions.

---

## 3. Explainable AI (XAI) Integration

### Grad-CAM (Gradient-weighted Class Activation Mapping)
- Highlights spatial regions in the leaf photo that most heavily contributed to the predicted disease category.
- Enables agronomists and farmers to confirm that the CNN is responding to true leaf lesions and margins rather than soil debris or background noise.

### SHAP (SHapley Additive exPlanations)
- Evaluates the marginal contribution of each of the 23 soil features.
- Categorizes features into `Pushes Healthy` (positive contribution toward healthy classification) vs. `Pushes Unhealthy` (depleting soil fertility).
