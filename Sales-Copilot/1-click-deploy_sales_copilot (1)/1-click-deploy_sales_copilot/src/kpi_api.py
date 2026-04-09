import json
import time
import boto3
from ssm import get_parameter_value   

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

# ---------------------------
# Redshift Configuration
# ---------------------------

AWS_REGION = "us-east-1"
# Redshift workgroup name retrieved from Parameter Store
WORKGROUP = get_parameter_value("REDSHIFT_MARKETING_COPILOT_WORKGROUP")
# Redshift database name retrieved from Parameter Store
DATABASE = get_parameter_value("MC_RS_DATABASE")
# Redshift secret ARN for authentication retrieved from Parameter Store
SECRET_ARN = get_parameter_value("MC_REDSHIFT_SECRET_ARN")
DEA_SCHEMA_COLUMNS = get_parameter_value("MC_HCP_SCHEMA_COLUMNS")
DEA_TABLE_NAME = get_parameter_value("MC_RS_TABLE")

# Interval (in seconds) between polling for query execution status
SQL_POLL_INTERVAL_SECONDS = 0.5
# Maximum time (in seconds) to wait for query execution to complete
SQL_POLL_MAX_SECONDS = 40.0

redshift = boto3.client("redshift-data", region_name=AWS_REGION)

# -------- Helper: Execute SQL --------
def execute_sql(sql):
    resp = redshift.execute_statement(
        WorkgroupName=WORKGROUP,
        Database=DATABASE,
        SecretArn=SECRET_ARN,
        Sql=sql
    )
    stmt_id = resp["Id"]

    elapsed = 0
    while elapsed < SQL_POLL_MAX_SECONDS:
        desc = redshift.describe_statement(Id=stmt_id)
        if desc["Status"] in ("FINISHED", "FAILED", "ABORTED"):
            break
        time.sleep(SQL_POLL_INTERVAL_SECONDS)
        elapsed += SQL_POLL_INTERVAL_SECONDS

    if desc["Status"] != "FINISHED":
        raise Exception(desc.get("Error", "Query failed"))

    result = redshift.get_statement_result(Id=stmt_id)
    cols = [c["name"] for c in result["ColumnMetadata"]]

    rows = []
    for record in result["Records"]:
        row = {}
        for i, cell in enumerate(record):
            row[cols[i]] = list(cell.values())[0] if cell else None
        rows.append(row)

    return rows

# -------- Lambda Handler --------
def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}

    year = params.get("year")
    quarter = params.get("quarter")
    month = params.get("month")
    channel = params.get("channel")
    specialty = params.get("specialty")

    filters = []

    if year:
        filters.append(f"year_key = {int(year)}")
    if quarter:
        filters.append(f"quarter_key = '{quarter}'")
    if month:
        filters.append(f"month_key = {int(month)}")
    if channel:
        filters.append(f"channel = '{channel}'")
    if specialty:
        filters.append(f"hcp_specialty = '{specialty}'")

    where_clause = f"WHERE {' AND '.join(filters)}" if filters else ""

    # -------- KPI QUERY --------
    kpi_sql = f"""
    SELECT
        COUNT(DISTINCT hcp_id) AS total_hcp_count,
        ROUND(
            100.0 * SUM(CASE WHEN reached_flag = TRUE THEN 1 ELSE 0 END)
            / NULLIF(COUNT(*), 0),
            2
        ) AS campaign_reach_percentage,
        ROUND(AVG(engagement_rate), 4) AS engagement_rate,
        COUNT(DISTINCT CASE WHEN campaign_status = 'Active' THEN campaign_id END)
            AS active_campaign_count
    FROM {DEA_TABLE_NAME}
    {where_clause}
    """

    # -------- Trend QUERY --------
    trend_sql = f"""
    SELECT
        month_key,
        ROUND(AVG(engagement_rate), 4) AS engagement_rate,
        ROUND(AVG(conversion_rate), 4) AS conversion_rate
    FROM {DEA_TABLE_NAME}
    {where_clause}
    GROUP BY month_key
    ORDER BY month_key
    """

    # -------- Segment QUERY --------
    segment_sql = f"""
    SELECT
        hcp_specialty,
        COUNT(DISTINCT hcp_id) AS hcp_count,
        ROUND(AVG(engagement_rate), 4) AS avg_engagement_rate
    FROM {DEA_TABLE_NAME}
    {where_clause}
    GROUP BY hcp_specialty
    ORDER BY hcp_count DESC
    """

    response = {
        "kpis": execute_sql(kpi_sql)[0],
        "trends": execute_sql(trend_sql),
        "segment_distribution": execute_sql(segment_sql)
    }

    try:
        response_body = {
            "kpis": execute_sql(kpi_sql)[0],
            "trends": execute_sql(trend_sql),
            "segment_distribution": execute_sql(segment_sql)
        }

        return {
            "statusCode": 200,
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET,OPTIONS",
                "Access-Control-Allow-Headers": "Content-Type"
            },
            "body": json.dumps(response_body)
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "headers": {"Content-Type": "application/json"},
            "body": json.dumps({"error": str(e)})
        }

if __name__ == "__main__":
    

    app = FastAPI()

    app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


    @app.get("/dashboard")
    async def dashboard(request: Request):
        event = {
            "queryStringParameters": dict(request.query_params)
        }

        response = lambda_handler(event, None)

        return json.loads(response["body"])