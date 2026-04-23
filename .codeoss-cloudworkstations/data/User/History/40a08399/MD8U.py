from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
from vertexai.generative_models import GenerativeModel

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

# تهيئة نموذج المستشار القانوني بالاسم العام لتجنب خطأ التوفر
llm = GenerativeModel("gemini-1.5-flash")

print("جاري تهيئة محرك البحث القانوني...")

# السؤال القانوني الذي سنطرحه على العقل الرقمي
question = "على ماذا تسري النصوص التشريعية؟"
print(f"\nالسؤال المطروح: {question}")

# تحويل السؤال إلى متجه للبحث
question_embedding = embedding_model.get_embeddings([question])[0].values

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

try:
    with pool.connect() as db_conn:
        # البحث الذكي باستخدام المتجهات (Vector Similarity Search)
        search_query = sqlalchemy.text("""
            SELECT source_title, reference, content 
            FROM statutory_vault 
            ORDER BY embedding <=> :q_embedding 
            LIMIT 1
        """)
        result = db_conn.execute(search_query, {"q_embedding": str(question_embedding)}).fetchone()
        
        if result:
            print("\n✅ تم العثور على الإجابة في العقل الرقمي:")
            print(f"المصدر: {result[0]} - {result[1]}")
            print(f"النص القانوني: {result[2]}")
            
            # --- إضافة طبقة الذكاء (Generation) ---
            print("\n⚖️ جاري صياغة الإجابة من قبل المستشار القانوني...")
            prompt = f"""
            أنت مستشار قانوني ذكي وموثوق.
            أجب على السؤال التالي بناءً على النص القانوني المرفق فقط.
            إذا لم تكن الإجابة موجودة في النص، قل "عذراً، الإجابة غير متوفرة في المصادر الحالية".
            لا تؤلف أي معلومات من خارج النص.
            
            النص القانوني: {result[2]}
            المصدر: {result[0]} - {result[1]}
            
            السؤال: {question}
            """
            response = llm.generate_content(prompt)
            print(f"\n{response.text}\n")
        else:
            print("\nلم يتم العثور على إجابة في الخزائن.")
            
except Exception as e:
    print("حدث خطأ أثناء البحث:", e)
