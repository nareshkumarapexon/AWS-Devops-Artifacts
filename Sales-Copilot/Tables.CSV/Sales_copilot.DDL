-- ============================================================================
-- TABLE 1: healthcare_data (200 rows, 27 columns)
-- Core HCP profile data with clinical priorities and engagement metrics
-- ============================================================================
CREATE TABLE healthcare_data (
    hcp_id VARCHAR(20) NOT NULL,
    doctor_first_name VARCHAR(50) NOT NULL,
    doctor_last_name VARCHAR(50) NOT NULL,
    hco_id VARCHAR(20) NOT NULL,
    territory_id VARCHAR(20) NOT NULL,
    as_of_date DATE NOT NULL,
    specialty_primary VARCHAR(100) NOT NULL,
    subspecialty VARCHAR(100),
    practice_setting VARCHAR(100),
    years_in_practice INTEGER,
    hco_type VARCHAR(50),
    hco_size_bucket VARCHAR(20),
    hospital_affiliation_flag BOOLEAN,
    kol_flag BOOLEAN,
    scheduled_calls_next_7d_cnt INTEGER,
    -- New columns for enhanced profiling
    clinical_priority_1 VARCHAR(100),
    clinical_priority_2 VARCHAR(100),
    clinical_priority_3 VARCHAR(100),
    preferred_contact_method VARCHAR(50),
    preferred_contact_time VARCHAR(50),
    peer_influence_score DECIMAL(3,2),
    peer_network_hcp_ids VARCHAR(1000),
    recent_publications_topics VARCHAR(500),
    digital_engagement_score DECIMAL(3,2),
    last_interaction_date DATE,
    last_interaction_type VARCHAR(50),
    last_interaction_outcome VARCHAR(50),
    PRIMARY KEY (hcp_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (hcp_id, territory_id, specialty_primary);

COMMENT ON TABLE healthcare_data IS 'Core HCP profile data with clinical priorities, peer networks, and engagement metrics';

-- ============================================================================
-- TABLE 2: hcp_user_mapping (200 rows, 3 columns)
-- Maps HCPs to sales representatives by territory
-- ============================================================================
CREATE TABLE hcp_user_mapping (
    user_id VARCHAR(20) NOT NULL,
    hcp_id VARCHAR(20) NOT NULL,
    territory_id VARCHAR(20) NOT NULL,
    PRIMARY KEY (hcp_id, user_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (hcp_id, user_id);

COMMENT ON TABLE hcp_user_mapping IS 'Maps HCPs to sales representatives for territory management';

-- ============================================================================
-- TABLE 3: prescribing_trends (200 rows, 16 columns)
-- Prescription behavior and trends for all HCPs
-- ============================================================================
CREATE TABLE prescribing_trends (
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(250) NOT NULL,
    trx_7d INTEGER,
    trx_28d INTEGER,
    trx_90d INTEGER,
    nrx_7d INTEGER,
    nrx_28d INTEGER,
    nrx_90d INTEGER,
    nbrx_28d INTEGER,
    trx_28d_wow_pct DECIMAL(6,4),
    trx_90d_qoq_pct DECIMAL(6,4),
    nbrx_28d_rate DECIMAL(6,4),
    adoption_stage_ordinal INTEGER,
    gap_to_goal_28d INTEGER,
    potential_uplift_index DECIMAL(6,4),
    churn_risk_score DECIMAL(6,4),
    receptivity_score DECIMAL(5,2),
    PRIMARY KEY (hcp_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (hcp_id, adoption_stage_ordinal);

COMMENT ON TABLE prescribing IS 'Prescription behavior, trends, and predictive scores for HCPs';

-- ============================================================================
-- TABLE 4: formulary_mart (200 rows, 29 columns)
-- Payer access and formulary information for HCPs
-- ============================================================================
CREATE TABLE formulary_mart (
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(100) NOT NULL,
    territory_id VARCHAR(20) NOT NULL,
    access_snapshot_datetime TIMESTAMP NOT NULL,
    recent_formulary_change_30d VARCHAR(100),
    current_coverage_tier_overall VARCHAR(50),
    prior_auth_requirement VARCHAR(50),
    step_therapy_requirement VARCHAR(50),
    copay_status_median_usd DECIMAL(10,2),
    patient_mix_top3_summary VARCHAR(200),
    access_alert_severity VARCHAR(20),
    prior_auth_required_flag BOOLEAN,
    step_therapy_required_flag BOOLEAN,
    patient_copay_median_90d DECIMAL(10,2),
    access_change_14d_flag BOOLEAN,
    access_policy_change_7d_flag BOOLEAN,
    payer_contract_change_30d_flag BOOLEAN,
    formulary_tier_score INTEGER,
    payer_top1_share_pct DECIMAL(6,4),
    payer_top3_share_pct DECIMAL(6,4),
    access_friction_index DECIMAL(6,4),
    physician_id VARCHAR(20),
    product_id VARCHAR(20),
    insurance_plan VARCHAR(100),
    is_covered BOOLEAN,
    tier_status VARCHAR(50),
    prior_auth_required BOOLEAN,
    step_therapy_required BOOLEAN,
    copay_amount DECIMAL(10,2),
    last_updated DATE,
    PRIMARY KEY (hcp_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (hcp_id, territory_id, product_id);

COMMENT ON TABLE formulary_mart IS 'Payer access, formulary status, and coverage information for HCPs';

-- ============================================================================
-- TABLE 5: voice_to_crm (160 rows, 10 columns)
-- Call transcripts and summaries (80% HCP coverage)
-- ============================================================================
CREATE TABLE voice_to_crm (
    call_id VARCHAR(20) NOT NULL,
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(255) NOT NULL,
    territory_id VARCHAR(20) NOT NULL,
    call_datetime_local TIMESTAMP NOT NULL,
    call_duration_minutes INTEGER,
    transcript_text VARCHAR(65535),
    structured_call_summary VARCHAR(5000),
    key_topics_tags VARCHAR(500),
    objection_categories VARCHAR(200),
    compliance_redaction_flag BOOLEAN,
    PRIMARY KEY (call_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (call_datetime_local, hcp_id);

COMMENT ON TABLE voice_to_crm IS 'Call transcripts, summaries, and compliance flags from HCP interactions';

-- ============================================================================
-- TABLE 6: history_mart (160 rows, 28 columns)
-- Interaction history with sentiment, samples, and materials
-- ============================================================================
CREATE TABLE history_mart (
    call_id VARCHAR(20) NOT NULL,
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(100) NOT NULL,
    territory_id VARCHAR(20) NOT NULL,
    call_date DATE NOT NULL,
    interaction_type VARCHAR(50),
    topic_discussed VARCHAR(200),
    objection_raised VARCHAR(200),
    materials_shared VARCHAR(200),
    outcome VARCHAR(200),
    followup_flag VARCHAR(10),
    opened_moa_email_flag VARCHAR(10),
    clicked_kol_video_flag VARCHAR(10),
    clicked_campaign_link_flag VARCHAR(10),
    formulary_update_30d_flag VARCHAR(10),
    formulary_update_summary VARCHAR(200),
    created_at TIMESTAMP NOT NULL,
    -- New columns for sentiment and samples
    sentiment_score DECIMAL(3,2),
    relationship_trajectory VARCHAR(50),
    call_success_indicator VARCHAR(50),
    samples_distributed_qty INTEGER,
    samples_product_id VARCHAR(20),
    samples_product_name VARCHAR(100),
    rep_id VARCHAR(20),
    material_id VARCHAR(20),
    material_type VARCHAR(50),
    material_target_objection VARCHAR(200),
    PRIMARY KEY (call_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id),
    FOREIGN KEY (call_id) REFERENCES voice_to_crm(call_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (call_date, hcp_id, rep_id);

COMMENT ON TABLE history_mart IS 'Detailed interaction history with sentiment analysis, sample distribution, and materials shared';

-- ============================================================================
-- TABLE 7: call_action_items (160 rows, 14 columns)
-- Follow-up actions with sample tracking
-- ============================================================================
CREATE TABLE call_action_items (
    call_id VARCHAR(20) NOT NULL,
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(255) NOT NULL,
    action_items_json VARCHAR(5000),
    primary_action_type VARCHAR(100),
    task_due_date DATE,
    task_owner_role VARCHAR(100),
    sample_request_qty INTEGER,
    hub_referral_flag VARCHAR(10),
    calendar_block_minutes INTEGER,
    priority_score INTEGER,
    -- New columns for sample tracking
    sample_product_id VARCHAR(20),
    sample_product_name VARCHAR(100),
    sample_inventory_available INTEGER,
    sample_commitment_fulfilled VARCHAR(10),
    PRIMARY KEY (call_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id),
    FOREIGN KEY (call_id) REFERENCES voice_to_crm(call_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (task_due_date, hcp_id, primary_action_type);

COMMENT ON TABLE call_action_items IS 'Follow-up actions and tasks with sample inventory tracking';

-- ============================================================================
-- TABLE 8: followup_events (80 rows, 24 columns)
-- Automated follow-up events with compliance tracking (50% of calls)
-- ============================================================================
CREATE TABLE followup_events (
    call_id VARCHAR(20) NOT NULL,
    hcp_id VARCHAR(20) NOT NULL,
    hcp_name VARCHAR(255) NOT NULL,
    followup_template_id VARCHAR(20),
    followup_email_subject VARCHAR(500),
    followup_email_body VARCHAR(65535),
    mi_request_flag BOOLEAN,
    mi_response_template_id VARCHAR(20),
    compliance_approval_status VARCHAR(50),
    compliance_rule_ids VARCHAR(100),
    compliance_evidence VARCHAR(1000),
    redaction_required BOOLEAN,
    redaction_segments VARCHAR(200),
    automated_send_allowed BOOLEAN,
    human_review_required BOOLEAN,
    escalation_team VARCHAR(50),
    escalated_at TIMESTAMP,
    resolved_by VARCHAR(100),
    resolution_notes VARCHAR(1000),
    provenance_key VARCHAR(50),
    created_by VARCHAR(20),
    followup_sent_datetime TIMESTAMP,
    send_status VARCHAR(50),
    sla_met_flag BOOLEAN,
    region VARCHAR(20),
    scheduled_followup_call_date DATE,
    PRIMARY KEY (call_id),
    FOREIGN KEY (hcp_id) REFERENCES healthcare_data(hcp_id),
    FOREIGN KEY (call_id) REFERENCES voice_to_crm(call_id)
)
DISTSTYLE KEY
DISTKEY (hcp_id)
SORTKEY (followup_sent_datetime, compliance_approval_status);

COMMENT ON TABLE followup_events IS 'Automated follow-up events with compliance approval workflow and escalation tracking';

-- ============================================================================
-- INDEXES for Query Performance
-- ============================================================================

-- Healthcare data indexes
CREATE INDEX idx_healthcare_specialty ON healthcare_data(specialty_primary);
CREATE INDEX idx_healthcare_territory ON healthcare_data(territory_id);
CREATE INDEX idx_healthcare_kol ON healthcare_data(kol_flag) WHERE kol_flag = TRUE;

-- Prescribing indexes
CREATE INDEX idx_prescribing_adoption ON prescribing(adoption_stage_ordinal);
CREATE INDEX idx_prescribing_churn ON prescribing(churn_risk_score);

-- Voice to CRM indexes
CREATE INDEX idx_voice_datetime ON voice_to_crm(call_datetime_local);
CREATE INDEX idx_voice_territory ON voice_to_crm(territory_id);

-- History mart indexes
CREATE INDEX idx_history_date ON history_mart(call_date);
CREATE INDEX idx_history_rep ON history_mart(rep_id);
CREATE INDEX idx_history_trajectory ON history_mart(relationship_trajectory);
CREATE INDEX idx_history_samples ON history_mart(samples_distributed_qty) WHERE samples_distributed_qty > 0;

-- Call action items indexes
CREATE INDEX idx_action_due_date ON call_action_items(task_due_date);
CREATE INDEX idx_action_type ON call_action_items(primary_action_type);
CREATE INDEX idx_action_owner ON call_action_items(task_owner_role);

-- Followup events indexes
CREATE INDEX idx_followup_status ON followup_events(compliance_approval_status);
CREATE INDEX idx_followup_send_status ON followup_events(send_status);
CREATE INDEX idx_followup_escalation ON followup_events(escalation_team) WHERE escalation_team != 'None';
 