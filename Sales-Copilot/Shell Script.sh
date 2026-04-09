aws ssm put-parameter `
    --name "SC_PRC_HCP_TABLE" `
    --value "healthcare_data" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"


aws ssm put-parameter `
    --name "SC_PRC_HCP_HISTORY_TABLE" `
    --value "history_mart" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"
 
 
aws ssm put-parameter `
    --name "SC_PRC_HCP_ACESS_FORMULARY_TABLE" `
    --value "formulary_mart" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"

aws ssm put-parameter `
  --name "SC_COMPETATIVE_SCHEMA_COLUMNS" `
  --type String `
  --value '{
    "table_name": "competitive_data",
    "description": "Stores competitive market share, momentum, and activity signals at the HCP and territory level. This table supports competitive analysis for pre-call preparation by identifying share shifts, competitor pressure drivers, and affected products within a therapy area. Used by the CompetitiveAgent to generate explainable competitive insights without performing ranking or territory prioritization.",
    "use_cases": [
      "Analyze competitor market share vs our brand for a given HCP",
      "Detect recent competitive share shifts and momentum",
      "Identify drivers of competitive pressure such as detailing, sampling, and events",
      "Provide product- and therapy-specific competitive context for pre-call intelligence",
      "Support territory-level aggregation of competitive trends",
      "Feed competitive insights into strategy and pre-call orchestration"
    ],
    "columns": [
      {
        "name": "hcp_id",
        "description": "Healthcare provider identifier. Foreign key to healthcare_data.hcp_id. Used to analyze competitive dynamics at the individual HCP level.",
        "foreign_key": "healthcare_data.hcp_id"
      },
      {
        "name": "territory_id",
        "description": "Sales territory identifier (e.g., US-MN-N). Used to aggregate and compare competitive pressure across territories."
      }
    ]
  }' `
  --tags Key=Name,Value=sales-copilot


aws ssm put-parameter `
    --name "SC_PRC_COMPETATIVE_TABLE" `
    --value "competitive_data" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"


aws ssm put-parameter `
  --name "SC_COMPETATIVE_SCHEMA_COLUMNS" `
  --type "String" `
  --value '{
    "table_name": "competitive_data",
    "description": "Stores competitive market share, momentum, and activity signals at the HCP and territory level. This table supports competitive analysis for pre-call preparation by identifying share shifts, competitor pressure drivers, and affected products within a therapy area. Used by the CompetitiveAgent to generate explainable competitive insights without performing ranking or territory prioritization.",
    "use_cases": [
      "Analyze competitor market share vs our brand for a given HCP",
      "Detect recent competitive share shifts and momentum",
      "Identify drivers of competitive pressure such as detailing, sampling, and events",
      "Provide product- and therapy-specific competitive context for pre-call intelligence",
      "Support territory-level aggregation of competitive trends",
      "Feed competitive insights into strategy and pre-call orchestration"
    ],
    "columns": [
      {
        "name": "hcp_id",
        "description": "Healthcare provider identifier. Foreign key to healthcare_data.hcp_id. Used to analyze competitive dynamics at the individual HCP level.",
        "foreign_key": "healthcare_data.hcp_id"
      },
      {
        "name": "territory_id",
        "description": "Sales territory identifier (e.g., US-MN-N). Used to aggregate and compare competitive pressure across territories."
      },
      {
        "name": "market_share_percent",
        "description": "Our brand’s market share percentage for the relevant therapy area at the HCP level. Values range from 0 to 100."
      },
      {
        "name": "competitor_market_share",
        "description": "Leading competitor’s market share percentage for the same HCP and therapy area. Used to assess relative competitive position."
      },
      {
        "name": "comp_trx_share_28d",
        "description": "Competitor prescription share over the most recent 28-day window, representing short-term competitive dominance."
      },
      {
        "name": "share_shift_percent",
        "description": "Absolute change in market share compared to the previous period. Positive values indicate share gain; negative values indicate loss."
      },
      {
        "name": "comp_share_28d_delta",
        "description": "Change in competitor market share over the last 28 days. Primary indicator of rising or declining competitive pressure."
      },
      {
        "name": "comp_detail_60d_cnt",
        "description": "Number of competitor sales detailing interactions with the HCP in the last 60 days. Acts as a leading indicator of competitive influence."
      },
      {
        "name": "comp_sample_60d_cnt",
        "description": "Number of competitor product samples provided to the HCP in the last 60 days. High values correlate with increased switching risk."
      },
      {
        "name": "comp_event_90d_cnt",
        "description": "Count of competitor-sponsored events attended by the HCP in the last 90 days, indicating educational and promotional exposure."
      },
      {
        "name": "drug_id",
        "description": "Unique identifier for the competitor or reference drug associated with the competitive signal."
      },
      {
        "name": "drug_name",
        "description": "Generic name of the competitor drug used to anchor competitive insights clinically."
      },
      {
        "name": "brand_name",
        "description": "Commercial brand name of the competitor drug referenced in the competitive analysis."
      },
      {
        "name": "manufacturer",
        "description": "Manufacturer of the competitor drug, used to attribute competitive activity to specific companies."
      },
      {
        "name": "drug_category",
        "description": "Drug class or mechanism of action (e.g., GLP-1, SGLT2). Used for class-level competitive reasoning."
      },
      {
        "name": "therapy_area",
        "description": "Disease or therapy area associated with the drug and competitive signals (e.g., Diabetes)."
      }
    ]
  }' `
  --tags "Key=Name,Value=sales-copilot"
_______________________________________________________________________________________________________________________________
# Below SSM parameter is with @' '@ in value, so that it tells PowerShell: “treat everything as raw text”

aws ssm put-parameter `
  --name "SC_COMPETATIVE_SCHEMA_COLUMNS" `
  --type "String" `
  --value @'
{
  "table_name": "competitive_data",
  "description": "Stores competitive market share, momentum, and activity signals at the HCP and territory level. This table supports competitive analysis for pre-call preparation by identifying share shifts, competitor pressure drivers, and affected products within a therapy area. Used by the CompetitiveAgent to generate explainable competitive insights without performing ranking or territory prioritization.",
  "use_cases": [
    "Analyze competitor market share vs our brand for a given HCP",
    "Detect recent competitive share shifts and momentum",
    "Identify drivers of competitive pressure such as detailing, sampling, and events",
    "Provide product- and therapy-specific competitive context for pre-call intelligence",
    "Support territory-level aggregation of competitive trends",
    "Feed competitive insights into strategy and pre-call orchestration"
  ],
  "columns": [
    {
      "name": "hcp_id",
      "description": "Healthcare provider identifier. Foreign key to healthcare_data.hcp_id. Used to analyze competitive dynamics at the individual HCP level.",
      "foreign_key": "healthcare_data.hcp_id"
    },
    {
      "name": "territory_id",
      "description": "Sales territory identifier (e.g., US-MN-N). Used to aggregate and compare competitive pressure across territories."
    },
    {
      "name": "market_share_percent",
      "description": "Our brand’s market share percentage for the relevant therapy area at the HCP level. Values range from 0 to 100."
    },
    {
      "name": "competitor_market_share",
      "description": "Leading competitor’s market share percentage for the same HCP and therapy area. Used to assess relative competitive position."
    },
    {
      "name": "comp_trx_share_28d",
      "description": "Competitor prescription share over the most recent 28-day window, representing short-term competitive dominance."
    },
    {
      "name": "share_shift_percent",
      "description": "Absolute change in market share compared to the previous period. Positive values indicate share gain; negative values indicate loss."
    },
    {
      "name": "comp_share_28d_delta",
      "description": "Change in competitor market share over the last 28 days. Primary indicator of rising or declining competitive pressure."
    },
    {
      "name": "comp_detail_60d_cnt",
      "description": "Number of competitor sales detailing interactions with the HCP in the last 60 days. Acts as a leading indicator of competitive influence."
    },
    {
      "name": "comp_sample_60d_cnt",
      "description": "Number of competitor product samples provided to the HCP in the last 60 days. High values correlate with increased switching risk."
    },
    {
      "name": "comp_event_90d_cnt",
      "description": "Count of competitor-sponsored events attended by the HCP in the last 90 days, indicating educational and promotional exposure."
    },
    {
      "name": "drug_id",
      "description": "Unique identifier for the competitor or reference drug associated with the competitive signal."
    },
    {
      "name": "drug_name",
      "description": "Generic name of the competitor drug used to anchor competitive insights clinically."
    },
    {
      "name": "brand_name",
      "description": "Commercial brand name of the competitor drug referenced in the competitive analysis."
    },
    {
      "name": "manufacturer",
      "description": "Manufacturer of the competitor drug, used to attribute competitive activity to specific companies."
    },
    {
      "name": "drug_category",
      "description": "Drug class or mechanism of action (e.g., GLP-1, SGLT2). Used for class-level competitive reasoning."
    },
    {
      "name": "therapy_area",
      "description": "Disease or therapy area associated with the drug and competitive signals (e.g., Diabetes)."
    }
  ]
}
'@ `
  --tags "Key=Name,Value=sales-copilot"
_______________________________________________________________________________________________________________________________


aws ssm put-parameter `
    --name "SC_MASTER_VIEW_NAME" `
    --value "master_hcp_kpi_view" `
    --type String `
    --tags "Key=Name,Value=sales-copilot"