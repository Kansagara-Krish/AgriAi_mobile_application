import sys
import uuid
from pathlib import Path
import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

backend_path = Path(__file__).resolve().parent.parent / "backend"
if str(backend_path) not in sys.path:
    sys.path.insert(0, str(backend_path))

from app.models.db_models import Base
from app.database.repository import SqliteDiagnosisRepository


@pytest.fixture
def db_session():
    """In-memory SQLite session for isolated database tests."""
    engine = create_engine("sqlite:///:memory:", connect_args={"check_same_thread": False})
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()


def test_repository_crud(db_session):
    repo = SqliteDiagnosisRepository(db_session)
    sample_id = f"TEST-{uuid.uuid4().hex[:6]}"

    # 1. Create
    data = {
        "sample_id": sample_id,
        "crop": "Guava",
        "diagnosis_type": "integrated",
        "is_paired_sample": True,
        "leaf_disease": "Guava_Canker",
        "leaf_confidence": 94.5,
        "soil_status": "Healthy",
        "soil_confidence": 88.0,
        "overall_risk_level": "Moderate",
        "agronomic_summary": "Test summary narrative.",
        "warnings": ["Test warning alert"]
    }
    created = repo.create(data)
    assert created["id"] is not None
    assert created["sample_id"] == sample_id
    rec_id = created["id"]

    # 2. Get by ID
    fetched_by_id = repo.get_by_id(rec_id)
    assert fetched_by_id is not None
    assert fetched_by_id["leaf_disease"] == "Guava_Canker"

    # 3. Get by sample_id
    fetched_by_sample = repo.get_by_sample_id(sample_id)
    assert fetched_by_sample is not None
    assert fetched_by_sample["id"] == rec_id

    # 4. List all
    all_records = repo.list_all(skip=0, limit=10)
    assert len(all_records) >= 1

    guava_records = repo.list_all(crop="Guava")
    assert len(guava_records) >= 1

    papaya_records = repo.list_all(crop="Papaya")
    assert len(papaya_records) == 0

    # 5. Delete
    deleted = repo.delete(rec_id)
    assert deleted is True

    # Confirm deletion
    assert repo.get_by_id(rec_id) is None
