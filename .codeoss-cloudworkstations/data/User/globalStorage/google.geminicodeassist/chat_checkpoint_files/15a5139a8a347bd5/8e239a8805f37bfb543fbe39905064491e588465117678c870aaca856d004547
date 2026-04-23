from google.cloud.sql.connector import Connector
import sqlalchemy

# تهيئة المتصل بـ Google Cloud
connector = Connector()

# إعداد بيانات الاتصال
PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
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
        
        # تفعيل إضافة pgvector لتخزين النصوص كمتجهات (Embeddings)
        db_conn.execute(sqlalchemy.text("CREATE EXTENSION IF NOT EXISTS vector;"))
        db_conn.commit()
        print("✅ تم تفعيل إضافة pgvector بنجاح! قاعدة البيانات جاهزة الآن لتقنية RAG.")
        
        # إنشاء جداول الخزائن الأربعة (Vaults)
        vaults = [
            "statutory_vault",     # خزانة التشريعات
            "procedural_vault",    # خزانة الإجراءات
            "jurisprudence_vault", # خزانة الاجتهادات
            "doctrine_vault"       # خزانة الشروح
        ]
        
        for vault in vaults:
            create_table_query = f"""
            CREATE TABLE IF NOT EXISTS {vault} (
                id SERIAL PRIMARY KEY,
                source_title VARCHAR(255),  -- اسم الكتاب أو القانون
                reference VARCHAR(255),     -- رقم المادة أو الصفحة
                content TEXT,               -- النص القانوني (الفقرة)
                embedding VECTOR(768)       -- المتجه الرقمي (للبحث الذكي)
            );
            """
            db_conn.execute(sqlalchemy.text(create_table_query))
            
        db_conn.commit()
        print("✅ تم بناء الخزائن الأربعة بنجاح! النظام مستعد لاستقبال الملفات.")
except Exception as e:
    print("حدث خطأ أثناء الاتصال بقاعدة البيانات:", e)
