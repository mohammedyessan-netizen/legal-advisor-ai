import PyPDF2
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import re

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# تهيئة الذكاء الاصطناعي
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

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

# اسم ملف الـ PDF (يجب أن ترفعه إلى شاشة الأوامر بهذا الاسم)
pdf_file_name = "penal_code.pdf"
source_title = "قانون العقوبات"

print(f"جاري قراءة ملف {pdf_file_name}...")
try:
    with open(pdf_file_name, 'rb') as file:
        reader = PyPDF2.PdfReader(file)
        full_text = ""
        for page in reader.pages:
            text = page.extract_text()
            if text:
                full_text += text + "\n"
        
        # التقطيع الدلالي: تقسيم الكتاب كلما وجد كلمة "المادة"
        chunks = re.split(r'(?=\bالمادة\b)', full_text)
        valid_chunks = [chunk.strip() for chunk in chunks if len(chunk.strip()) > 20]
        
        print(f"تم تقسيم الكتاب بنجاح إلى {len(valid_chunks)} فقرة/مادة قانونية.")
        print("بدأ العقل الرقمي بابتلاع وحفظ القوانين (قد يستغرق هذا بعض الوقت)...\n")
        
        with pool.connect() as db_conn:
            for i, chunk in enumerate(valid_chunks):
                print(f"جاري حفظ الفقرة {i+1} من {len(valid_chunks)}...")
                vector = embedding_model.get_embeddings([chunk])[0].values
                insert_query = sqlalchemy.text("""
                    INSERT INTO statutory_vault (source_title, reference, content, embedding)
                    VALUES (:title, :ref, :content, :embedding)
                """)
                db_conn.execute(insert_query, {"title": source_title, "ref": f"الجزء {i+1}", "content": chunk, "embedding": str(vector)})
            db_conn.commit()
            print("\n✅ تم رفع جميع المواد القانونية بنجاح إلى الخزانة!")
except FileNotFoundError:
    print(f"\n❌ خطأ: لم يتم العثور على الملف '{pdf_file_name}'. يرجى التأكد من رفعه إلى مساحة العمل.")
except Exception as e:
    print("حدث خطأ:", e)