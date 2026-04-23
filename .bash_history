            
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
EOF

python search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel, TextGenerationModel

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

# استخدام نموذج PaLM 2 (text-bison) الأقدم والأكثر توفراً كبديل لتجنب أخطاء 404
llm = TextGenerationModel.from_pretrained("text-bison@002")

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
            response = llm.predict(prompt, max_output_tokens=512)
            print(f"\n{response.text}\n")
        else:
            print("\nلم يتم العثور على إجابة في الخزائن.")
            
except Exception as e:
    print("حدث خطأ أثناء البحث:", e)
EOF

python search.py
cat << 'EOF' > search.py
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

# استخدام نموذج المستشار القانوني الذكي Gemini 1.5 Pro
llm = GenerativeModel("gemini-1.5-pro")

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
EOF

python search.py
bash <(curl -sSL https://storage.googleapis.com/cloud-samples-data/adc/setup_adc.sh)
python search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import requests
from google.auth import default
from google.auth.transport.requests import Request

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء (Llama 3.1) ---
            print("\n⚖️ جاري صياغة الإجابة من قبل المستشار القانوني (Llama 3.1)...")
            prompt = f"""
            أنت مستشار قانوني ذكي وموثوق.
            أجب على السؤال التالي بناءً على النص القانوني المرفق فقط.
            إذا لم تكن الإجابة موجودة في النص، قل "عذراً، الإجابة غير متوفرة في المصادر الحالية".
            لا تؤلف أي معلومات من خارج النص.
            
            النص القانوني: {result[2]}
            المصدر: {result[0]} - {result[1]}
            
            السؤال: {question}
            """
            
            # استدعاء Llama 3.1 
            credentials, _ = default(scopes=["https://www.googleapis.com/auth/cloud-platform"])
            credentials.refresh(Request())
            
            url = f"https://{REGION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT_ID}/locations/{REGION}/endpoints/openapi/chat/completions"
            headers = {
                "Authorization": f"Bearer {credentials.token}",
                "Content-Type": "application/json",
            }
            payload = {
                "model": "meta/llama-3.1-8b-instruct-maas",
                "messages": [{"role": "user", "content": prompt}],
            }
            
            api_response = requests.post(url, headers=headers, json=payload)
            if api_response.status_code == 200:
                print(f"\n{api_response.json()['choices'][0]['message']['content']}\n")
            else:
                print("\n❌ حدث خطأ أثناء التواصل مع نموذج Llama:", api_response.text)
        else:
            print("\nلم يتم العثور على إجابة في الخزائن.")
            
except Exception as e:
    print("حدث خطأ أثناء البحث:", e)
EOF

python search.py
cat << 'EOF' > search.py
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

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# تهيئة نموذج المستشار القانوني الذكي (الذي حددته)
llm = GenerativeModel("gemini-3.1-pro-preview")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

python search.py
cat << 'EOF' > search.py
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

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج Gemini Flash المستقر والمتاح للجميع
llm = GenerativeModel("gemini-1.5-flash-001")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

python search.py
pip install google-generativeai
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "ضع_مفتاحك_هنا"
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج المستشار القانوني عبر المفتاح المجاني
llm = genai.GenerativeModel("gemini-1.5-flash")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

pip install google-generativeai
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "ضع_مفتاحك_هنا"
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج المستشار القانوني عبر المفتاح المجاني
llm = genai.GenerativeModel("gemini-1.5-flash")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

python search.py
nano search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "AIzaSyBc92hGcN-OAyUEMe9w8ZWA4uAntjMIofM".strip() # تقوم strip بتنظيف المفتاح من أي مسافات زائدة تلقائياً
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج المستشار القانوني عبر المفتاح المجاني
llm = genai.GenerativeModel("gemini-1.5-flash")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

python search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "AIzaSyBc92hGcN-OAyUEMe9w8ZWA4uAntjMIofM".strip()
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج المستشار القانوني عبر المفتاح المجاني
llm = genai.GenerativeModel("gemini-pro")

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
        # البحث الذكي باستخدام المتجهات
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
            
            # --- إضافة طبقة الذكاء ---
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
EOF

python search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "AIzaSyBc92hGcN-OAyUEMe9w8ZWA4uAntjMIofM".strip()
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# استخدام نموذج المستشار القانوني عبر المفتاح المجاني
llm = genai.GenerativeModel("gemini-1.5-flash")

print("جاري تهيئة محرك البحث القانوني...")

# السؤال القانوني الذي سنطرحه على العقل الرقمي
question = "ماذا تنص المادة 406 من قانون العقوبات؟"
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
        # البحث الذكي باستخدام المتجهات
        search_query = sqlalchemy.text("""
            SELECT source_title, reference, content 
            FROM statutory_vault 
            ORDER BY embedding <=> :q_embedding 
            LIMIT 1
        """)
        result = db_conn.execute(search_query, {"q_embedding": str(question_embedding)}).fetchone()
        
        # التأكد من أن النتيجة التي تم العثور عليها قريبة فعلاً من السؤال (منع الهلوسة)
        # سيقوم النموذج الذكي بتحليل النص المستخرج ليقرر ما إذا كان يجيب على السؤال فعلاً
        if result:
            print("\n✅ تم جلب أقرب نص من العقل الرقمي:")
            print(f"المصدر: {result[0]} - {result[1]}")
            print(f"النص القانوني: {result[2]}")
            
            # --- إضافة طبقة الذكاء ---
            print("\n⚖️ جاري صياغة الإجابة من قبل المستشار القانوني...")
            prompt = f"""
            أنت مستشار قانوني ذكي وموثوق.
            أجب على السؤال التالي بناءً على النص القانوني المرفق فقط.
            إذا لم تكن الإجابة موجودة بوضوح في النص المرفق، قل حرفياً: "عذراً، الإجابة غير متوفرة في المصادر الحالية".
            تحذير: لا تؤلف أي معلومات من خارج النص أبداً.
            
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
EOF

python search.py
cat << 'EOF' > search.py
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai

PROJECT_ID = "aurad-493816"
REGION = "us-central1"
INSTANCE_NAME = "legal-vault-db-instance"
INSTANCE_CONNECTION_NAME = f"{PROJECT_ID}:{REGION}:{INSTANCE_NAME}"

DB_USER = "postgres"
DB_PASS = "Mm1323145@@"
DB_NAME = "legal_vault_db"

# إعداد المفتاح المجاني (API Key)
API_KEY = "AIzaSyBc92hGcN-OAyUEMe9w8ZWA4uAntjMIofM".strip()
genai.configure(api_key=API_KEY)

# تهيئة الذكاء الاصطناعي لنموذج المتجهات
vertexai.init(project=PROJECT_ID, location=REGION)
embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

# --- البحث التلقائي عن أفضل نموذج متاح للمفتاح الخاص بك ---
print("جاري فحص النماذج المتاحة لمفتاحك...")
available_models = [m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods]
if not available_models:
    raise Exception("❌ المفتاح الخاص بك لا يحتوي على صلاحيات لنماذج Gemini. يرجى التأكد من إنشاء المفتاح من Google AI Studio.")

best_model = available_models[0]
for m in available_models:
    if "gemini-1.5-flash" in m:
        best_model = m
        break

print(f"✅ تم الاتصال بنجاح! سيتم استخدام النموذج: {best_model}")
llm = genai.GenerativeModel(best_model)

print("جاري تهيئة محرك البحث القانوني...")

# السؤال القانوني الذي سنطرحه على العقل الرقمي
question = "ماذا تنص المادة 406 من قانون العقوبات؟"
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
        # البحث الذكي باستخدام المتجهات
        search_query = sqlalchemy.text("""
            SELECT source_title, reference, content 
            FROM statutory_vault 
            ORDER BY embedding <=> :q_embedding 
            LIMIT 1
        """)
        result = db_conn.execute(search_query, {"q_embedding": str(question_embedding)}).fetchone()
        
        if result:
            print("\n✅ تم جلب أقرب نص من العقل الرقمي:")
            print(f"المصدر: {result[0]} - {result[1]}")
            print(f"النص القانوني: {result[2]}")
            
            # --- إضافة طبقة الذكاء ---
            print("\n⚖️ جاري صياغة الإجابة من قبل المستشار القانوني...")
            prompt = f"""
            أنت مستشار قانوني ذكي وموثوق.
            أجب على السؤال التالي بناءً على النص القانوني المرفق فقط.
            إذا لم تكن الإجابة موجودة بوضوح في النص المرفق، قل حرفياً: "عذراً، الإجابة غير متوفرة في المصادر الحالية".
            تحذير: لا تؤلف أي معلومات من خارج النص أبداً.
            
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
EOF

python search.py
pip install PyPDF2
python upload_pdf.py
source myenv/bin/activate
python upload_pdf.py
ls -l
# 1. تثبيت جميع المكتبات المطلوبة
pip install -r requirements.txt
# 2. تشغيل ملف تهيئة قاعدة البيانات (لإنشاء الخزائن الأربعة)
python database.py
# 3. تشغيل ملف رفع الـ PDF (تأكد من وجود ملف penal_code.pdf في نفس المجلد)
# هذا الأمر سيبدأ بابتلاع الكتاب وتحويله إلى متجهات
python upload_pdf.py
# 4. بعد الانتهاء من الرفع، اختبر العقل الرقمي
python search.py
# تهيئة مساحة العمل كـ Git
git init
# إضافة جميع الملفات (سيتم استثناء الملفات الموجودة في .gitignore مثل .env)
git add .
# حفظ التغييرات
git commit -m "النسخة الأولى من العقل الرقمي والمستشار القانوني"
# تغيير اسم الفرع الرئيسي إلى main
git branch -M main
# ربط المستودع المحلي بالمستودع على GitHub (استبدل الرابط برابط مستودعك)
git remote add origin https://github.com/YourUsername/YourRepoName.git
# رفع الكود إلى الإنترنت
git push -u origin main
git add
git commit -m "النسخة الأولى من المستشار القانوني"
git branch -M main
git remote remove origin
git remote add origin https://github.com/mohammedyessan-netizen/legal-advisor-ai.git
git push -u origin main
git remote set-url origin git@github.com:mohammedyessan-netizen/legal-advisor-ai.git
git push -u origin main
