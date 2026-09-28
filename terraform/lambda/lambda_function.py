import json
import os
from datetime import datetime, timezone


def lambda_handler(event, context):
    project = os.environ.get("PROJECT_NAME", "secure-web-app")

    result = {
        "project": project,
        "status": "ok",
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "message": "Health check executed successfully."
    }

    print(json.dumps(result))

    return {
        "statusCode": 200,
        "body": json.dumps(result)
    }
