import json
import requests
from bs4 import BeautifulSoup
from datetime import datetime

headers = {}

from datetime import datetime

def handle(event = None, context=None):
  print(event)
  url = "https://www.google.com/finance/quote/BTC-USD"
  req = requests.get(url, headers)
  soup = BeautifulSoup(req.content, 'html.parser')
  bitcoin_price = soup.select('div[data-source="BTC"]')[0].get("data-last-price")
  body = {"date": datetime.now().isoformat(), "BTC": bitcoin_price}  
  return {
    "statusCode": 200, 
    "body": json.dumps(body),
    "headers": {
      "Content-Type": "application/json"
    }
  }
