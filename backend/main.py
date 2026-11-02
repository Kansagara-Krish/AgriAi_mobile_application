import os
import sys
from pathlib import Path
from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse

from app.core.config import settings
from app.database.session import init_db
from app.api.routes import router as api_router
from app.api.deps import (
    get_cnn_service,
    get_soil_service,
    get_kb_service,
    get_fertilizer_ml_service,
    get_integration_service,
    get_report_service
)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan context manager for startup and shutdown events.
    Initializes database schemas, model caches, and directories.
    """
    print("[STARTUP] Initializing AgriAI SQLite database...")
    init_db()

    print("[STARTUP] Pre-loading Agronomic & Machine Learning models...")
    try:
        cnn = get_cnn_service()
        soil = get_soil_service()
        kb = get_kb_service()
        fert = get_fertilizer_ml_service()
        get_integration_service()
        get_report_service()
        print("[STARTUP] All AI models and Agronomic Knowledge Base ready for real-time inference.")
    except Exception as e:
        print(f"[STARTUP WARNING] One or more models could not be preheated: {e}")

    yield

    print("[SHUTDOWN] AgriAI Backend server shutting down gracefully.")


app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Multimodal Precision Agriculture Decision-Support System integrating Leaf Disease Vision (EfficientNetB0), Soil Health Classification (XGBoost + SHAP), and Agronomic Knowledge Base.",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# CORS configuration for mobile and web clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static file mounts for images and generated PDF reports
app.mount("/uploads", StaticFiles(directory=settings.UPLOADS_DIR), name="uploads")
app.mount("/reports", StaticFiles(directory=settings.REPORTS_DIR), name="reports")

# Register API routes
app.include_router(api_router, prefix=settings.API_V1_PREFIX)


@app.get("/", include_in_schema=False)
def root():
    """Redirects root URL to interactive Swagger API documentation."""
    return RedirectResponse(url="/docs")


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=False
    )
