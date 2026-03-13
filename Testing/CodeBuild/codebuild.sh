#!/bin/bash

UseCaseName="lab-process"
ConnectionARN="arn:aws:codeconnections:us-east-1:969385807621:connection/474c1d52-afe2-4ba1-a84c-b987a6ea416f"
REGION="us-east-1"
Github="https://github.com/project-apex-2025/lab-process-conductor.git"



cat > parms.json <<EOF
{
    "Parameters": {
      "UseCaseName": "${UseCaseName}",
      "ConnectionARN": "${ConnectionARN}",
      "Github": "${Github}"
    }
}
EOF

echo "Deploying Codebuild Service Role.."
STACK_NAME=${UseCaseName}-codebuild-servicerole-infra
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --parameter-overrides file://parms.json \
  --template-file service-role.yaml \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

ServiceRoleARN=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --region $REGION \
  --query 'Stacks[0].Outputs[?OutputKey==`CodeBuildServiceRoleOut`].OutputValue' \
  --output text)

TriggerHead="^refs/heads/dev"
TriggerFile="^UI/.*"
ECRImage="969385807621.dkr.ecr.us-east-1.amazonaws.com/codebuild-node-amd64:latest"   #Node js custom image
ServiceName="Web-Interface"
CodePath="UI/buildspec.yaml"

jq '.Parameters += {
  "ServiceRoleARN": "'"$ServiceRoleARN"'",
  "TriggerHead": "'"$TriggerHead"'",
  "TriggerFile": "'"$TriggerFile"'",
  "ServiceName": "'"$ServiceName"'",
  "CodePath": "'"$CodePath"'",
  "ECRImage": "'"$ECRImage"'"  
}' parms.json > parms.tmp && mv parms.tmp parms.json

echo "Deploying Codebuild Service Role.."
STACK_NAME=${UseCaseName}-codebuild-webui-infra
aws cloudformation deploy \
  --stack-name $STACK_NAME \
  --parameter-overrides file://parms.json \
  --template-file "Common/template/codebuild-UI.yaml" \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

TriggerHead="^refs/heads/dev"
TriggerFile="^agents/development_agent/.*"
ServiceName="development-agent"
CodePath="agents/development_agent/buildspec.yaml"

jq '.Parameters += {
  "TriggerHead": "'"$TriggerHead"'",
  "TriggerFile": "'"$TriggerFile"'",
  "ServiceName": "'"$ServiceName"'",
  "CodePath": "'"$CodePath"'"
}' parms.json > parms.tmp && mv parms.tmp parms.json

aws cloudformation deploy \
  --stack-name ${UseCaseName}-${ServiceName}-codebuild-infra \
  --parameter-overrides file://parms.json \
  --template-file "Common/template/codebuild-standard.yaml" \
  --region $REGION

TriggerHead="^refs/heads/dev"
TriggerFile="^agents/runtime_agent/.*"
ServiceName="runtime-agent"
CodePath="agents/runtime_agent/buildspec.yaml"

jq '.Parameters += {
  "TriggerHead": "'"$TriggerHead"'",
  "TriggerFile": "'"$TriggerFile"'",
  "ServiceName": "'"$ServiceName"'",
  "CodePath": "'"$CodePath"'"
}' parms.json > parms.tmp && mv parms.tmp parms.json

aws cloudformation deploy \
  --stack-name ${UseCaseName}-${ServiceName}-codebuild-infra \
  --parameter-overrides file://parms.json \
  --template-file "Common/template/codebuild-standard.yaml" \
  --region $REGION


