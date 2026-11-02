# AgriAI: Multimodal Crop Pathology & Soil Intelligence Platform

[![Python](https://img.shields.io/badge/Python-3.10%2B-blue.svg)](https://www.python.org/)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110%2B-009688.svg)](https://fastapi.tiangolo.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.50%2B-02569B.svg)](https://flutter.dev/)
[![TensorFlow](https://img.shields.io/badge/TensorFlow-2.15%2B-FF6F00.svg)](https://tensorflow.org/)
[![XGBoost](https://img.shields.io/badge/XGBoost-2.0%2B-red.svg)](https://xgboost.readthedocs.io/)
[![SQLite](https://img.shields.io/badge/SQLite-3.0%2B-003B57.svg)](https://sqlite.org/)

---

## 🌾 Overview

**AgriAI** is an agricultural decision-support platform designed to protect yields and diagnose crop health across five major fruit, vegetable, and cash crops:
- 🍈 **Guava** (*Psidium guajava*)
- 🍈 **Papaya** (*Carica papaya*)
- 🍆 **Brinjal / Eggplant** (*Solanum melongena*)
- 🌿 **Castor** (*Ricinus communis*)
- 🌾 **Cumin** (*Cuminum cyminum*)

AgriAI bridges computer vision, machine learning soil analytics, and agronomic domain expertise to produce biologically coherent, cross-modal diagnoses.

---

## 🏛️ System Architecture

```
                                      +---------------------------------------------+
                                      |            AgriAI Client Layer              |
                                      |     (Flutter Mobile, Tablet, and Web)       |
                                      +----------------------+----------------------+
                                                             |
                                           REST API (JSON / Multipart / PDF)
                                                             |
                                      +----------------------v----------------------+
                                      |          FastAPI Backend Gateway            |
                                      |   Lifespan Caching | CORS | OpenAPI / Docs   |
                                      +----------------------+----------------------+
                                                             |
                     +---------------------------------------+---------------------------------------+
                     |                                       |                                       |
    +----------------v---------------+      +----------------v---------------+      +----------------v---------------+
    |       Leaf Vision Engine       |      |       Soil Health Engine       |      |     Agronomic Knowledge Base   |
    |  - EfficientNetB0 SavedModel   |      |  - XGBoost Classifier (23 ft)  |      |  - 122 Validated Field Rules   |
    |  - 40 Pathological Classes     |      |  - TreeExplainer SHAP Impact   |      |  - 9-Class Fertilizer XGBoost  |
    |  - Grad-CAM Lesion Heatmaps    |      |  - Binary Status & P(Healthy)  |      |  - Threshold Diagnostic Logic  |
    +----------------+---------------+      +----------------+---------------+      +----------------+---------------+
                     |                                       |                                       |
                     +---------------------------------------+---------------------------------------+
                                                             |
                                      +----------------------v----------------------+
                                      |     Multimodal Decision Integration Engine  |
                                      |  - Crop Mismatch Guardrail                  |
                                      |  - Salinity / Alkalinity Lockout Rule       |
                                      |  - Low Vision Confidence Detection          |
                                      |  - Unified Fertilizer & Protection Advisory |
                                      +----------------------+----------------------+
                                                             |
                                      +----------------------v----------------------+
                                      |         Persistence & Reporting             |
                                      |  - SQLite Database (SQLAlchemy Repository)   |
                                      |  - ReportLab PDF Generation Engine          |
                                      +---------------------------------------------+
```

---

## 🚀 Key Modules & AI Models

### 1. Leaf Disease Vision (EfficientNetB0)
- **Architecture:** Pretrained EfficientNetB0 transfer-learned on 40 distinct pathological classes.
- **Accuracy:** 96.86% top-1 accuracy.
- **Resolution:** 256 x 256 RGB input.
- **Explainability:** Grad-CAM saliency heatmaps highlighting symptomatic lesion tissues.

### 2. Soil Health Classifier (XGBoost + SHAP)
- **Features:** 23 variables (pH, Electrical Conductivity, Nitrogen, Phosphorus, Potassium, Copper, Ferrous, Manganese, Sulphur, Zinc, LAI, TII, ARI, RBI, CRI, FAI, MRI, HCI, C/N Ratio, and Crop Indicators).
- **Target:** Binary Soil Status (Healthy vs. Unhealthy).
- **Explainability:** Local SHAP (SHapley Additive exPlanations) TreeExplainer ranking positive and negative nutrient drivers.

### 3. Agronomic Knowledge Base & Fertilizer Model
- **Knowledge Base:** 122 expert validated agronomic rules covering nutrient thresholds, biological etiology, chemical remedies, and application dosages.
- **Intervention Classifier:** 55-feature XGBoost model classifying specific agricultural remedies.

### 4. Multimodal Cross-Modal Decision Synthesis
- **Salinity Lockout Guardrail:** When soil EC > 2200 µS/cm or pH > 8.0, chemical fertilizers are withheld to prevent osmotic root burn. Agricultural gypsum and heavy leaching flushes are prescribed.
- **Crop Mismatch Guardrail:** Alerts agronomists if the selected crop does not match the leaf image pathology.
- **Pairing Verification:** Flags unverified sample pairings when leaf and soil samples originate from different field plots.

---

## 📂 Directory Layout

```
AgriAI_Application/
├── backend/
│   ├── app/
│   │   ├── api/
│   │   │   ├── deps.py            # Dependency injection & service singletons
│   │   │   └── routes.py          # Complete REST API routes (10 endpoints)
│   │   ├── core/
│   │   │   └── config.py          # Application settings & environment variables
│   │   ├── database/
│   │   │   ├── repository.py      # Abstract & SQLite repository implementation
│   │   │   └── session.py         # SQLAlchemy engine and session factory
│   │   ├── models/
│   │   │   └── db_models.py       # DiagnosisRecord SQLAlchemy persistence model
│   │   ├── schemas/
│   │   │   └── diagnostic.py      # Pydantic schemas for requests and responses
│   │   └── services/
│   │       ├── cnn_service.py     # EfficientNetB0 inference & Grad-CAM
│   │       ├── soil_service.py    # XGBoost Soil Health & SHAP attributions
│   │       ├── fertilizer_service.py # 122-Rule Knowledge Base & ML classifier
│   │       ├── integration_service.py # Multimodal cross-synthesis engine
│   │       └── report_service.py  # ReportLab PDF diagnostic report generator
│   ├── trained_models/            # Model checkpoints, weights, and JSON schemas
│   ├── reports/                   # Generated PDF diagnostic reports
│   ├── uploads/                   # Uploaded leaf images & Grad-CAM overlays
│   ├── main.py                    # FastAPI server entrypoint
│   ├── requirements.txt           # Python dependencies
│   └── .env.example               # Configuration template
├── frontend/
│   ├── lib/
│   │   ├── components/            # Reusable UI widgets (Grad-CAM, Badges, Pickers)
│   │   ├── constants/             # Agricultural green theme & typography
│   │   ├── l10n/                  # Localization ARBs (English, Hindi, Gujarati)
│   │   ├── models/                # Strongly-typed Dart diagnostic data models
│   │   ├── providers/             # AppProvider state management
│   │   ├── screens/               # All 20 application screens
│   │   │   ├── splash_screen.dart
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── language_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── leaf_disease_screen.dart
│   │   │   ├── disease_result_screen.dart
│   │   │   ├── soil_form_screen.dart
│   │   │   ├── soil_result_screen.dart
│   │   │   ├── integrated_advisory_screen.dart
│   │   │   ├── fertilizer_details_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   ├── history_details_screen.dart
│   │   │   ├── pdf_viewer_screen.dart
│   │   │   ├── profile_screen.dart
│   │   │   ├── settings_screen.dart
│   │   │   ├── help_screen.dart
│   │   │   └── crop_library_screen.dart
│   │   ├── services/              # ApiService & StorageService (SharedPreferences)
│   │   └── main.dart              # Flutter application entrypoint
│   ├── pubspec.yaml               # Flutter package dependencies
│   └── l10n.yaml                  # Flutter localization tool configuration
├── documentation/                 # Technical specifications & guides
└── tests/                         # Comprehensive test suite
    ├── test_models.py
    ├── test_integration_service.py
    ├── test_database.py
    └── test_api_endpoints.py
```

---

## 🛠️ Backend Setup & Execution

### 1. Prerequisites
- Python 3.10+
- Virtual environment (`venv` or `conda`)

### 2. Installation
```bash
cd AgriAI_Application/backend
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Running the Server
```bash
python main.py
```
Or via uvicorn directly:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

The interactive Swagger documentation is available at:
`http://localhost:8000/docs`

---

## 📱 Flutter Mobile & Web Setup

### 1. Prerequisites
- Flutter SDK (3.13+ / 3.50+)
- Android Studio / Xcode / Chrome for Web

### 2. Configuration & Execution
```bash
cd AgriAI_Application/frontend
flutter pub get
flutter gen-l10n
flutter run
```

### 3. Backend IP Configuration
- **Android Emulator:** Set Backend URL to `http://10.0.2.2:8000/api` in Settings.
- **Physical Device:** Connect to the same Wi-Fi and set Backend URL to your machine's LAN IP (e.g. `http://192.168.1.50:8000/api`).
- **Web / Desktop:** Set Backend URL to `http://localhost:8000/api`.

---

## 🌐 Multilingual Localization

AgriAI includes complete translations in:
1. **English (`en`)** - `lib/l10n/app_en.arb`
2. **हिन्दी / Hindi (`hi`)** - `lib/l10n/app_hi.arb`
3. **ગુજરાતી / Gujarati (`gu`)** - `lib/l10n/app_gu.arb`

Farmers can change the language anytime via the drawer or Settings screen.

---

## 🧪 Running the Test Suite

Execute the comprehensive test suite covering model loading, SHAP explainer, cross-modal integration, database operations, and API endpoints:

```bash
pytest AgriAI_Application/tests -v
```

---

## 📄 License & Credits

Developed for advanced multimodal precision agriculture research and farmer decision-support.
All models and agronomic rules are validated against experimental agricultural field datasets.
