CREATE TABLE competitive_data (
    -- Identity & Context
    hcp_id                     VARCHAR(50)   NOT NULL,
    hcp_name                   VARCHAR(255)   NOT NULL,
    territory_id               VARCHAR(50)   NOT NULL,

    -- Market Share & Momentum
    market_share_percent       DOUBLE PRECISION,   -- 0–100
    competitor_market_share    DOUBLE PRECISION,   -- 0–100
    comp_trx_share_28d         DOUBLE PRECISION,   -- 0–100
    share_shift_percent        DOUBLE PRECISION,   -- typically -10 to +10
    comp_share_28d_delta       DOUBLE PRECISION,   -- normalized (0–1) or percent (-100 to +100)

    -- Competitive Activity Signals
    comp_detail_60d_cnt        INTEGER DEFAULT 0,
    comp_sample_60d_cnt        INTEGER DEFAULT 0,
    comp_event_90d_cnt         INTEGER DEFAULT 0,

    -- Product & Clinical Context
    drug_id                    VARCHAR(50),
    drug_name                  VARCHAR(100),
    brand_name                 VARCHAR(100),
    manufacturer               VARCHAR(100),
    drug_category              VARCHAR(50),
    therapy_area               VARCHAR(50)
)
DISTSTYLE AUTO
SORTKEY (territory_id, hcp_id);
 