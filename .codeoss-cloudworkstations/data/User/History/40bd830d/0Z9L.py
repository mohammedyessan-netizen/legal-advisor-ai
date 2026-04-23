import PyPDF2
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import re

from config import (
    PROJECT_ID,
    REGION,
    INSTANCE_CONNECTION_NAME,
    DB_USER,
    DB_PASS,
    DB_NAME,
)

# تهيئة الذكاء الاصطناعي
print("جاري تهيئة نماذج الذكاء الاصطناعي (Vertex AI)...")
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

        BATCH_SIZE = 100  # معالجة 100 فقرة في كل دفعة لزيادة الكفاءة

        with pool.connect() as db_conn:
            with db_conn.begin():  # بدء معاملة (transaction) واحدة لجميع الإضافات
                for i in range(0, len(valid_chunks), BATCH_SIZE):
                    batch_chunks = valid_chunks[i:i + BATCH_SIZE]
                    print(f"جاري معالجة الدفعة {i//BATCH_SIZE + 1} (الفقرات من {i+1} إلى {i+len(batch_chunks)})...")

                    # 1. الحصول على المتجهات (Embeddings) دفعة واحدة
                    embeddings = embedding_model.get_embeddings(batch_chunks)

                    # 2. تجهيز البيانات للإضافة دفعة واحدة
                    records_to_insert = []
                    for j, chunk in enumerate(batch_chunks):
                        # استخراج المرجع (رقم المادة) بشكل أفضل
                        reference_match = re.search(r'^(المادة\s+\d+)', chunk)
                        reference = f"جزء غير محدد {i + j + 1}"  # مرجع افتراضي
                        if reference_match:
                            reference = reference_match.group(1).strip()

                        records_to_insert.append({
                            "title": source_title,
                            "ref": reference,
                            "content": chunk,
                            "embedding": str(embeddings[j].values)
                        })

                    # 3. تنفيذ الإضافة لهذه الدفعة (Batch Insert)
                    insert_query = sqlalchemy.text("""
                        INSERT INTO statutory_vault (source_title, reference, content, embedding)
                        VALUES (:title, :ref, :content, :embedding)
                    """)
                    db_conn.execute(insert_query, records_to_insert)

        print("\n✅ تم رفع جميع المواد القانونية بنجاح إلى الخزانة!")
except FileNotFoundError:
    print(f"\n❌ خطأ: لم يتم العثور على الملف '{pdf_file_name}'. يرجى التأكد من رفعه إلى مساحة العمل.")
except Exception as e:
    print("حدث خطأ:", e)