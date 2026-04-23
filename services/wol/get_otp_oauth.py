import os.path
import re
import sys
import time
import google.auth
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# Gmail API のスコープ (読み取り専用)
SCOPES = ['https://www.googleapis.com/auth/gmail.readonly']

def get_gmail_service():
    creds = None
    token_path = 'C:/Users/rdpuser/token.json'
    creds_path = 'C:/Users/rdpuser/credentials.json'

    if os.path.exists(token_path):
        creds = Credentials.from_authorized_user_file(token_path, SCOPES)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            if not os.path.exists(creds_path):
                print(f"Error: {creds_path} not found.", file=sys.stderr)
                sys.exit(1)
            flow = InstalledAppFlow.from_client_secrets_file(creds_path, SCOPES)
            creds = flow.run_local_server(port=0)
        
        with open(token_path, 'w') as token:
            token.write(creds.to_json())

    return build('gmail', 'v1', credentials=creds)

def get_latest_otp():
    service = get_gmail_service()
    now_ts = int(time.time() * 1000)
    threshold_ts = now_ts - (90 * 1000) # 90秒前以降のみを対象

    # クエリで絞り込み (newer_than:1m は目安、詳細は internalDate で判定)
    query = 'from:kabu.com subject:"ワンタイム認証コードのお知らせ" newer_than:1m'
    results = service.users().messages().list(userId='me', q=query, maxResults=3).execute()
    messages = results.get('messages', [])

    for m in messages:
        msg = service.users().messages().get(userId='me', id=m['id'], format='full').execute()
        msg_ts = int(msg['internalDate'])
        
        # 実行の直前（90秒以内）に届いたメールのみ採用
        if msg_ts > threshold_ts:
            snippet = msg.get('snippet', '')
            match = re.search(r'(\d{6})', snippet)
            if match:
                return match.group(1)
    
    return None

if __name__ == "__main__":
    try:
        otp = get_latest_otp()
        if otp:
            print(otp)
            sys.exit(0)
        else:
            # 見つからない場合は何も出力せずに終了（AHK側のリトライ待ちにする）
            sys.exit(1)
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
