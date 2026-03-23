import argparse
import sys
import os
import json
import psycopg2
from bs4 import BeautifulSoup
import requests
from dotenv import load_dotenv

# Load env variables from backend
load_dotenv(os.path.join(os.path.dirname(__file__), '../../backend/.env'))
DB_URL = os.getenv('DATABASE_URL')

def update_job_status(cursor, job_id, status):
    cursor.execute("UPDATE scraper_jobs SET status = %s, \"updatedAt\" = NOW() WHERE id = %s", (status, job_id))

def insert_lead(cursor, job_id, lead_type, source, ext_id, name, city, state, phone=None, email=None, raw_data=None):
    try:
        cursor.execute("""
            INSERT INTO scraped_leads ("jobId", "leadType", source, "externalId", name, city, state, phone, email, "rawData", status, "createdAt", "updatedAt")
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 'RAW', NOW(), NOW())
            ON CONFLICT ("source", "externalId") DO NOTHING;
        """, (job_id, lead_type, source, ext_id, name, city, state, phone, email, json.dumps(raw_data) if raw_data else None))
        return cursor.rowcount > 0
    except Exception as e:
        print(f"Error inserting lead: {e}")
        return False

def scrape_practo_mock(cursor, job_id, city, target_type):
    print(f"Mock scraping Practo for {target_type} in {city}...")
    # In a real scenario, we would use Playwright or requests + bs4 here to scrape actual data.
    # For this demonstration, we are generating mock data that simulates scraped results.
    
    mock_leads = [
        {"ext_id": f"prac_{city}_1", "name": f"Dr. Ramesh Sharma", "phone": "9876543210", "spec": "General Physician"},
        {"ext_id": f"prac_{city}_2", "name": f"Dr. Priya Patel", "phone": "9876543211", "spec": "Cardiologist"},
        {"ext_id": f"prac_{city}_3", "name": f"Dr. Amit Singh", "phone": "9876543212", "spec": "Pediatrician"},
        {"ext_id": f"prac_{city}_4", "name": f"City Care Hospital", "phone": "022-1234567", "spec": "Multi-specialty", "type": "HOSPITAL"},
    ]
    
    count = 0
    for lead in mock_leads:
        # Filter logic
        if target_type == 'DOCTOR' and lead.get('type') == 'HOSPITAL': continue
        if target_type == 'HOSPITAL' and lead.get('type') != 'HOSPITAL': continue
        
        l_type = 'HOSPITAL' if lead.get('type') == 'HOSPITAL' else 'DOCTOR'
        raw = {"specialization": lead.get("spec")}
        
        if insert_lead(cursor, job_id, l_type, 'PRACTO', lead['ext_id'], lead['name'], city, 'Maharashtra', lead['phone'], None, raw):
            count += 1
            
    print(f"Successfully scraped and inserted {count} new leads from Practo.")

def scrape_justdial_mock(cursor, job_id, city, target_type):
    print(f"Mock scraping Justdial for {target_type} in {city}...")
    
    if target_type not in ['STOCKIST', 'RETAILER']:
        print("Justdial mock only supports Stockists and Retailers in this demo.")
        return
        
    mock_leads = [
        {"ext_id": f"jd_{city}_1", "name": f"Metro Pharma Distributors", "phone": "9998887770", "type": "STOCKIST"},
        {"ext_id": f"jd_{city}_2", "name": f"Wellness Medico", "phone": "9998887771", "type": "RETAILER"},
        {"ext_id": f"jd_{city}_3", "name": f"Sai Health Care", "phone": "9998887772", "type": "RETAILER"},
    ]
    
    count = 0
    for lead in mock_leads:
        if target_type != lead.get('type'): continue
        
        if insert_lead(cursor, job_id, lead['type'], 'JUSTDIAL', lead['ext_id'], lead['name'], city, 'Maharashtra', lead['phone']):
            count += 1
            
    print(f"Successfully scraped and inserted {count} new leads from Justdial.")

def main():
    parser = argparse.ArgumentParser(description="VedantaTrade Web Scraper Worker")
    parser.add_argument("--job-id", type=int, required=True, help="Job ID from the database")
    args = parser.parse_args()
    
    if not DB_URL:
        print("Error: DATABASE_URL environment variable is not set. Ensure backend/.env exists.")
        sys.exit(1)
        
    try:
        conn = psycopg2.connect(DB_URL)
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Get Job Details
        cursor.execute("SELECT source, \"targetType\", city FROM scraper_jobs WHERE id = %s", (args.job_id,))
        job = cursor.fetchone()
        
        if not job:
            print(f"Error: Job ID {args.job_id} not found.")
            sys.exit(1)
            
        source, target_type, city = job
        print(f"Starting Job {args.job_id} - Source: {source}, Target: {target_type}, City: {city or 'ALL'}")
        
        update_job_status(cursor, args.job_id, 'RUNNING')
        
        # Branch based on source
        if source == 'PRACTO':
            scrape_practo_mock(cursor, args.job_id, city or 'Mumbai', target_type)
        elif source == 'JUSTDIAL':
            scrape_justdial_mock(cursor, args.job_id, city or 'Mumbai', target_type)
        else:
            print(f"Warning: Scraping logic for {source} is not yet implemented.")
            
        update_job_status(cursor, args.job_id, 'COMPLETED')
        print(f"Job {args.job_id} completed successfully.")
        
    except Exception as e:
        print(f"Job failed with error: {e}")
        try:
            update_job_status(cursor, args.job_id, 'FAILED')
        except:
            pass
        sys.exit(1)
    finally:
        if 'cursor' in locals(): cursor.close()
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    main()
