from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

print("جاري تهيئة نماذج الذكاء الاصطناعي (Vertex AI)...")
vertexai.init(project=PROJECT_ID, location=REGION)
# استخدام نموذج جوجل الأحدث لتحويل النصوص إلى متجهات بـ 768 بُعد
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

print("جاري تحويل النص التجريبي إلى متجهات...")
source_title = "القانون المدني"
reference = "المادة 1"
content = "تسري النصوص التشريعية على جميع المسائل التي تتناولها في لفظها أو في فحواها."

# استخراج المتجه الرقمي
embeddings = embedding_model.get_embeddings([content])
vector = embeddings[0].values

def getconn():
    connector = Connector()
    return connector.connect(
        INSTANCE_CONNECTION_NAME,
        "pg8000",
        user=DB_USER,
        password=DB_PASS,
        db=DB_NAME
    )

pool = sqlalchemy.create_engine("postgresql+pg8000://", creator=getconn)

print("جاري حفظ النص في (خزانة التشريعات)...")
try:
    with pool.connect() as db_conn:
        insert_query = sqlalchemy.text("""
            INSERT INTO statutory_vault (source_title, reference, content, embedding)
            VALUES (:title, :ref, :content, :embedding)
        """)
        db_conn.execute(insert_query, {"title": source_title, "ref": reference, "content": content, "embedding": str(vector)})
        db_conn.commit()
        print("✅ تم حفظ المادة القانونية بنجاح داخل العقل الرقمي! النظام الآن يحتوي على معلومات فعلية.")
except Exception as e:
    print("حدث خطأ:", e)