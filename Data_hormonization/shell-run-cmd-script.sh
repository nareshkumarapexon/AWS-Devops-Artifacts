 
# Below is the run command for the data-harmonisation-run-all-glue-jobs-lambda.yaml

 aws cloudformation deploy `
  --template-file data-harmonisation-run-all-glue-jobs-lambda.yaml `
  --stack-name data-harmonisation-run-all-glue-jobs-infra `
  --capabilities CAPABILITY_NAMED_IAM `
  --region us-east-1

# Below is the run command for the data-harmonization-omop-lambda.yaml
aws cloudformation deploy `
  --template-file data-harmonization-omop-lambda.yaml `
  --stack-name data-harmonization-omop-mapping-pipeline-infra `
  --capabilities CAPABILITY_NAMED_IAM

# Below is the run command for the data-harmonization-stepfunction.yaml
aws cloudformation deploy `
  --template-file data-harmonization-stepfunction.yaml `
  --stack-name data-harmonization-stepfunction-infra `
  --capabilities CAPABILITY_NAMED_IAM


# Below is the run command for the data-harmonization-omop-mapping-pipeline-neptune.yaml
  aws cloudformation deploy `
 --template-file data-harmonization-omop-mapping-pipeline-neptune.yaml `
 --stack-name data-harmonization-omop-mapping-pipeline-neptune-infra `
 --capabilities CAPABILITY_NAMED_IAM

# Below is the run command for the data-hormonization-DynamoDB-workflow-configs.yaml
 aws cloudformation deploy `
  --template-file data-hormonization-DynamoDB-workflow-configs.yaml `
  --stack-name data-harmonization-workflow-configs-infra `
  --capabilities CAPABILITY_NAMED_IAM `

