import os
from dotenv import load_dotenv
from supabase import create_client

# Load backend .env using absolute path
dotenv_path = r"c:\Users\sandr\Documents\site ariane\backend\.env"
load_dotenv(dotenv_path)

url = os.environ.get("SUPABASE_URL")
service_key = os.environ.get("SUPABASE_SERVICE_KEY")

print(f"Connecting to Supabase URL: {url}")
if not url or not service_key:
    print("Error: SUPABASE_URL or SUPABASE_SERVICE_KEY not found in backend/.env")
    exit(1)

client = create_client(url, service_key)

tables = ["profiles", "courses", "lessons", "subscriptions", "lesson_progress"]
for table in tables:
    try:
        res = client.table(table).select("*", count="exact").limit(5).execute()
        count = res.count if hasattr(res, 'count') else len(res.data)
        print(f"Table '{table}' row count: {count}")
        if count > 0:
            print(f"First few rows in '{table}': {res.data}")
    except Exception as e:
        print(f"Error querying table '{table}': {e}")
