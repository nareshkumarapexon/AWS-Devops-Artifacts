#!/bin/bash

UseCaseName="sales-copilot"
ServiceName="Strategy-Agent"
AgentPath="Agents/Pre-Call/Strategy_Agent"


cat > parms.json <<EOF
{
    "Parameters": {
      "UseCaseName": "${UseCaseName}",
      "ServiceName": "${ServiceName}",
      "AgentPath": "${AgentPath}"
    }
}
EOF

aws cloudformation deploy \
  --stack-name ${UseCaseName}-${ServiceName}-codebuild-infra \
  --parameter-overrides file://parms.json \
  --template-file "../../../Common/codebuild-standard.yaml" \
  --region us-east-1