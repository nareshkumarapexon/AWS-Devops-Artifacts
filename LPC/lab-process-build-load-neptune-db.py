import json
import urllib.request
import ssl
import logging
import os
import boto3
import time
from datetime import datetime
from urllib.parse import unquote_plus
from boto3.dynamodb.conditions import Key

logger = logging.getLogger()
logger.setLevel(logging.INFO)

dynamodb = boto3.resource("dynamodb")

NEPTUNE_LOADER_URL = os.environ["NEPTUNE_LOADER_URL"].rstrip("/")  # ...:8182/loader
IAM_ROLE_ARN = os.environ["IAM_ROLE_ARN"]
REGION = os.environ["REGION"]
DYNAMO_TABLE_NAME = os.environ["DYNAMO_TABLE_NAME"]

TTL_GSI_NAME = os.environ.get("TTL_GSI_NAME", "ttl_s3_key-index")

POLL_SECONDS = int(os.environ.get("POLL_SECONDS", "20"))
MAX_WAIT_SECONDS = int(os.environ.get("MAX_WAIT_SECONDS", "180"))

table = dynamodb.Table(DYNAMO_TABLE_NAME)
context_ssl = ssl._create_unverified_context()


def update_document_status(document_id, status, extra_attrs=None):
    expr_parts = ["#s = :s", "#u = :u"]
    names = {"#s": "status", "#u": "updated_at"}
    values = {":s": status, ":u": datetime.utcnow().isoformat()}

    if extra_attrs:
        for k, v in extra_attrs.items():
            names[f"#{k}"] = k
            values[f":{k}"] = v
            expr_parts.append(f"#{k} = :{k}")

    table.update_item(
        Key={"document_id": document_id},
        UpdateExpression="SET " + ", ".join(expr_parts),
        ExpressionAttributeNames=names,
        ExpressionAttributeValues=values
    )


def get_item_by_ttl_key(ttl_key: str) -> dict:
    resp = table.query(
        IndexName=TTL_GSI_NAME,
        KeyConditionExpression=Key("ttl_s3_key").eq(ttl_key),
        Limit=1
    )
    items = resp.get("Items", [])
    if not items:
        raise Exception(f"No Dynamo item found for ttl_s3_key={ttl_key}. Create GSI {TTL_GSI_NAME}.")
    return items[0]


def http_json(method: str, url: str, payload=None, timeout=30):
    data = None
    headers = {"Content-Type": "application/json"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=headers, method=method)
    with urllib.request.urlopen(req, context=context_ssl, timeout=timeout) as resp:
        body = resp.read().decode("utf-8")
        return resp.status, body


def submit_load(bucket: str, ttl_key: str) -> str:
    payload = {
        "source": f"s3://{bucket}/{ttl_key}",
        "format": "turtle",
        "iamRoleArn": IAM_ROLE_ARN,
        "region": REGION,
        "failOnError": "TRUE",
        "parallelism": "LOW"
    }
    code, body = http_json("POST", NEPTUNE_LOADER_URL, payload=payload, timeout=30)
    logger.info(f"Submit response {code}: {body[:1200]}")
    if code != 200:
        raise Exception(f"Neptune submit failed: {body[:500]}")
    j = json.loads(body)
    load_id = j.get("payload", {}).get("loadId")
    if not load_id:
        raise Exception(f"No loadId in response: {body[:500]}")
    return load_id


def get_status(load_id: str):
    # Common Neptune endpoint:
    url = f"{NEPTUNE_LOADER_URL}/{load_id}?details=true&errors=true"
    code, body = http_json("GET", url, payload=None, timeout=30)
    logger.info(f"Status response {code}: {body[:1200]}")
    if code != 200:
        raise Exception(f"Neptune status GET failed: {body[:500]}")
    j = json.loads(body)
    raw = (j.get("payload", {}).get("overallStatus", {}).get("status") or "").upper()
    if "COMPLETED" in raw:
        return "COMPLETED", raw, j
    if "FAILED" in raw or "ERROR" in raw:
        return "FAILED", raw, j
    return "IN_PROGRESS", raw, j


# def poll(document_id: str, load_id: str):
#     deadline = time.time() + MAX_WAIT_SECONDS
#     update_document_status(document_id, "NEPTUNE_LOAD_SUBMITTED", {"neptune_load_id": load_id})

#     while time.time() < deadline:
#         state, raw, j = get_status(load_id)
#         if state == "COMPLETED":
#             update_document_status(document_id, "NEPTUNE_LOADED", {"neptune_load_status": raw})
#             return
#         if state == "FAILED":
#             update_document_status(document_id, "NEPTUNE_FAILED", {"error_message": json.dumps(j)[:1500]})
#             return
#         time.sleep(POLL_SECONDS)

#     # still running
#     update_document_status(document_id, "NEPTUNE_LOAD_SUBMITTED", {"note": "Still running after poll window"})


#for testing without dynamo
def poll(load_id: str):
    deadline = time.time() + MAX_WAIT_SECONDS
    while time.time() < deadline:
        state, raw, j = get_status(load_id)
        if state in ("COMPLETED", "FAILED"):
            return {"state": state, "raw": raw, "details": j}
        time.sleep(POLL_SECONDS)
    return {"state": "TIMEOUT"}

# def lambda_handler(event, context):
#     record = event["Records"][0]
#     bucket = record["s3"]["bucket"]["name"]
#     key = unquote_plus(record["s3"]["object"]["key"])

#     if not key.endswith(".ttl"):
#         return {"statusCode": 200}

#     # ttl_s3_key -> document_id via GSI
#     item = get_item_by_ttl_key(key)
#     document_id = item["document_id"]

#     # Idempotency
#     if item.get("status") == "NEPTUNE_LOADED":
#         return {"statusCode": 200, "body": json.dumps({"message": "Already loaded", "document_id": document_id})}

#     # Submit or reuse existing load
#     existing = item.get("neptune_load_id")
#     if item.get("status") == "NEPTUNE_LOAD_SUBMITTED" and existing:
#         poll(document_id, existing)
#         return {"statusCode": 200}

#     update_document_status(document_id, "NEPTUNE_LOADING")

#     load_id = submit_load(bucket, key)
#     update_document_status(document_id, "NEPTUNE_LOAD_SUBMITTED", {"neptune_load_id": load_id})

#     poll(document_id, load_id)
#     return {"statusCode": 200, "body": json.dumps({"document_id": document_id, "load_id": load_id})}

# testing without dynamo
def lambda_handler(event, context):
    if event.get("test_mode"):
        bucket = event["bucket"]
        key = event["key"]
    else:
        record = event["Records"][0]
        bucket = record["s3"]["bucket"]["name"]
        key = unquote_plus(record["s3"]["object"]["key"])

    # submit load (no dynamo)
    load_id = submit_load(bucket, key)
    # optionally poll status for 2–3 mins
    result = poll(load_id)
    return {"statusCode": 200, "body": json.dumps({"load_id": load_id, **result})}.