from google.cloud.sql.connector import Connector
import sqlalchemy

# تهيئة المتصل بـ Google Cloud
connector = Connector()

# إعداد بيانات الاتصال
PROJECT_ID = "aurad-493816"
REGION = "us-central1" # استبدل هذه بالمنطقة التي أنشأت فيها القاعدة
INSTANCE_NAME = "your-instance-name" # استبدل هذا باسم نسخة Cloud SQL التي أنشأها Terraform
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

def getconn():
    conn = connector.connect(
        INSTANCE_CONNECTION_NAME,
        "pg8000",
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME
    )
    return conn

# إنشاء محرك الاتصال (Engine)
pool = sqlalchemy.create_engine(
    "postgresql+pg8000://",
    creator=getconn,
)

try:
    with pool.connect() as db_conn:
        print("تم الاتصال بنجاح بقاعدة بيانات Cloud SQL! العقل الرقمي جاهز لتلقي القوانين.")
except Exception as e:
    print("حدث خطأ أثناء الاتصال بقاعدة البيانات:", e)