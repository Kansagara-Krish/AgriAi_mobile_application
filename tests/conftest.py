import sys
from pathlib import Path

# Insert backend at top of sys.path so app refers to backend/app
backend_dir = str(Path(__file__).resolve().parent.parent / "backend")
if backend_dir in sys.path:
    sys.path.remove(backend_dir)
sys.path.insert(0, backend_dir)

# If root app.py was somehow imported, clear it
if "app" in sys.modules and not hasattr(sys.modules["app"], "__path__"):
    del sys.modules["app"]

from app.database.session import init_db
init_db()
