import streamlit as st
from google.cloud.sql.connector import Connector
import sqlalchemy
import vertexai
from vertexai.language_models import TextEmbeddingModel
import google.generativeai as genai
from config import (
    PROJECT_ID,
    REGION,
    INSTANCE_CONNECTION_NAME,
    DB_USER,
    DB_PASS,
    DB_NAME,
    API_KEY,
)

# --- إعدادات الصفحة ---
st.set_page_config(page_title="المستشار القانوني الذكي", page_icon="⚖️", layout="centered")

st.title("⚖️ المستشار القانوني الذكي")
st.write("اطرح سؤالك القانوني، وسيقوم العقل الرقمي بالبحث في القوانين وتقديم الإجابة الدقيقة.")

# --- التهيئة (يتم تنفيذها مرة واحدة فقط لتسريع التطبيق) ---
@st.cache_resource
def init_ai_and_db():
    # تهيئة نموذج الإجابة (Gemini)
    genai.configure(api_key=API_KEY)
    available_models = [m.name for m in genai.list_models() if 'generateContent' in m.supported_generation_methods]
    best_model = available_models[0]
    for m in available_models:
        if "gemini-1.5-flash" in m:
            best_model = m
            break
    llm = genai.GenerativeModel(best_model)

    # تهيئة نموذج البحث عن النصوص (Vertex AI)
    vertexai.init(project=PROJECT_ID, location=REGION)
    embedding_model = TextEmbeddingModel.from_pretrained("text-embedding-004")

    # تهيئة قاعدة البيانات
    connector = Connector()
    def getconn():
        return connector.connect(
            INSTANCE_CONNECTION_NAME, "pg8000", user=DB_USER, password=DB_PASS, db=DB_NAME
        )
    pool = sqlalchemy.create_engine("postgresql+pg8000://", creator=getconn)
    
    return llm, embedding_model, pool

llm, embedding_model, pool = init_ai_and_db()

# --- واجهة المستخدم ---
question = st.text_input("ما هو سؤالك القانوني؟", placeholder="مثال: ماذا تنص المادة 406 من قانون العقوبات؟")

if st.button("بحث 🔍"):
    if question:
        with st.spinner('جاري البحث في الخزانة القانونية والتفكير في الإجابة...'):
            try:
                # تحويل السؤال إلى متجه وبحث في قاعدة البيانات
                question_embedding = embedding_model.get_embeddings([question])[0].values
                with pool.connect() as db_conn:
                    search_query = sqlalchemy.text("""
                        SELECT source_title, reference, content 
                        FROM statutory_vault 
                        ORDER BY embedding <=> :q_embedding LIMIT 1
                    """)
                    result = db_conn.execute(search_query, {"q_embedding": str(question_embedding)}).fetchone()
                    
                    if result:
                        source, ref, content = result[0], result[1], result[2]
                        st.success(f"**المصدر المُستخرج:** {source} - {ref}\n\n**النص الأصلي:** {content}")
                        
                        prompt = f"أنت مستشار قانوني. أجب على السؤال التالي بناءً على النص المرفق فقط.\nالنص: {content}\nالسؤال: {question}"
                        response = llm.generate_content(prompt)
                        st.info(f"**⚖️ رأي المستشار:**\n\n{response.text}")
                    else:
                        st.warning("لم يتم العثور على إجابة مطابقة في الخزائن.")
            except Exception as e:
                st.error(f"حدث خطأ أثناء البحث: {e}")
    else:
        st.warning("يرجى إدخال سؤال للبحث!")