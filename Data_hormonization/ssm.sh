Can you please add this parameter to parameter store
ETL_CODE_GEN_AGENT_RUNTIME_ARN = arn:aws:bedrock-agentcore:us-east-1:969385807621:runtime/data_harmonization_code_agentv2-DLc54Z7jkh



aws ssm put-parameter `
  --name "ETL_CODE_GEN_AGENT_RUNTIME_ARN" `
  --value "arn:aws:bedrock-agentcore:us-east-1:969385807621:runtime/data_harmonization_code_agentv2-DLc54Z7jkh" `
  --type String `
  --tags Key=Name,Value=data-harmonization

 

  aws ssm put-parameter `
  --name "DATA_HARMONIZATION_DEPLOY_STEP_FUNCTION_ARN" `
  --value "arn:aws:states:us-east-1:969385807621:stateMachine:data-harmonization-deployment-WorkflowStateMachine" `
  --type String `
  --tags Key=Name,Value=data-harmonization



DATA_HARMONIZATION_CODE_GEN_OUTPUT_TRACKING_TABLE = data-harmonization-code-gen-output-tracking

  aws ssm put-parameter `
  --name "DATA_HARMONIZATION_CODE_GEN_OUTPUT_TRACKING_TABLE" `
  --value "data-harmonization-code-gen-output-tracking" `
  --type String `
  --tags Key=Name,Value=data-harmonization