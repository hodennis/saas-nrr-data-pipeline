WITH monthly_movements AS (
    SELECT 
        DATE_TRUNC('month', close_date) AS report_month,
        SUM(CASE WHEN opp_type = 'New Business' THEN amount ELSE 0 END) AS new_mrr,
        SUM(CASE WHEN opp_type = 'Upgrade' THEN amount ELSE 0 END) AS expansion_mrr,
        SUM(CASE WHEN opp_type = 'Downgrade' THEN amount ELSE 0 END) AS contraction_mrr,
        SUM(CASE WHEN opp_type = 'Churn' THEN amount ELSE 0 END) AS churn_mrr
    FROM sf_opportunities
    GROUP BY 1
),

running_totals AS (
    SELECT 
        report_month,
        new_mrr,
        expansion_mrr,
        contraction_mrr,
        churn_mrr,
        (new_mrr + expansion_mrr + contraction_mrr + churn_mrr) AS net_mrr_change,
        COALESCE(
            SUM(new_mrr + expansion_mrr + contraction_mrr + churn_mrr) 
            OVER (ORDER BY report_month ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0
        ) AS starting_mrr
    FROM monthly_movements
)

SELECT 
    report_month,
    starting_mrr,
    new_mrr,
    expansion_mrr,
    contraction_mrr,
    churn_mrr,
    (starting_mrr + net_mrr_change) AS ending_mrr,
    -- NRR Formula: (Starting MRR + Expansion - Contraction - Churn) / Starting MRR
    CASE 
        WHEN starting_mrr = 0 THEN NULL 
        ELSE ROUND((((starting_mrr + expansion_mrr + contraction_mrr + churn_mrr) / starting_mrr) * 100)::NUMERIC, 2) 
    END AS nrr_percentage
FROM running_totals
ORDER BY report_month;
