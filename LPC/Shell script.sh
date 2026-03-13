# For adding table name in parameter store:

aws ssm put-parameter \
    --name "/lpc/aws-ls/dynamo_db/tables/workflow_runs_table" \
    --value "lab-process-runs" \
    --type String \
    --tags "Key=Name,Value=lab-process"

# This below Command runned for : "Uploaded-Yaml-infrastructure-LPC.yaml"
 aws cloudformation deploy `
--template-file Uploaded-Yaml-infrastructure-LPC.yaml `
--stack-name lab-process-document-upload-infra `
--capabilities CAPABILITY_NAMED_IAM  `

# Below is the command to run the lab-process-kg-upload-api-infra.yaml
aws cloudformation deploy `
  --template-file lab-process-kg-upload-api-infra.yaml `
  --stack-name lab-process-kg-upload-api-infra `
  --capabilities CAPABILITY_NAMED_IAM `
  --region us-east-1
