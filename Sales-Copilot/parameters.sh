aws ssm put-parameter `
    --name "SC_PRC_COMPETATIVE_TABLE" `
    --value "competitive_data" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"

aws ssm put-parameter `
    --name "SC_MASTER_VIEW_NAME" `
    --value "master_hcp_kpi_view" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"


