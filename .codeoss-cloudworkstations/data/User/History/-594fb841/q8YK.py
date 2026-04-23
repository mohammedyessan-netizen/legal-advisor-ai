import os

# --- Project Config ---
# It's recommended to set these as environment variables
# You can create a .env file and use a library like python-dotenv to load them
# To install the library: pip install python-dotenv
#
# Example .env file:
# PROJECT_ID="your-gcp-project-id"
# REGION="your-region"
# INSTANCE_NAME="your-cloud-sql-instance"
# DB_USER="postgres"
# DB_PASS="your-db-password"
# DB_NAME="legal_vault_db"
# API_KEY="your-google-ai-studio-api-key"

PROJECT_ID = os.environ.get("PROJECT_ID", "aurad-493816")
REGION = os.environ.get("REGION", "us-central1")

# --- Cloud SQL Config ---
INSTANCE_NAME = os.environ.get("INSTANCE_NAME", "legal-vault-db-instance")
DB_USER = os.environ.get("DB_USER", "postgres")
DB_PASS = os.environ.get("DB_PASS", "Mm1323145@@") # Fallback for convenience, but using env var is strongly recommended
DB_NAME = os.environ.get("DB_NAME", "legal_vault_db")

INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

# --- Generative AI Config ---
API_KEY = os.environ.get("API_KEY", "AIzaSyBc92hGcN-OAyUEMe9w8ZWA4uAntjMIofM") # Fallback for convenience, but using env var is strongly recommended
API_KEY = os.environ.get("API_KEY", "ضع_المفتاح_الجديد_هنا") # ضع المفتاح الجديد بين علامتي التنصيص

if DB_PASS == "Mm1323145@@" or (API_KEY and "AIzaSy" in API_KEY):
    print("⚠️ تحذير: يتم استخدام إعدادات افتراضية. يوصى بشدة بتعيين متغيرات البيئة (environment variables) للأمان والضبط الصحيح.")