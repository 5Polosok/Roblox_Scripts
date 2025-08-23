import requests
import json

discord_webhook_url = 'https://discord.com/api/webhooks/1246458839297953865/kBWXxFuXh_-v8kYwMcPxnr36ynXdgJ6S3rWQ4t-8GtN4zH_vBiOmGbfSu_CA5FhIiNCo' # Replace with your Discord webhook URL
message_payload = {
    "content": "LINGANGULI GULI GULI GULI WACHA (DONT SHARE YOUR WEBHOOK ON SERVERS))))))) @everyone",
    "allowed_mentions": {
        "parse": ["everyone"]
    }
}

try:
    response = requests.post(
        discord_webhook_url,
        data=json.dumps(message_payload),
        headers={'Content-Type': 'application/json'}
    )
    response.raise_for_status() # Raise an exception for bad status codes (4xx or 5xx)
    print("Message with @everyone ping sent to Discord successfully!")
except requests.exceptions.RequestException as e:
    print(f"Error sending message with @everyone ping to Discord: {e}")
