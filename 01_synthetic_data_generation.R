library(tidyverse)
library(lubridate)

set.seed(123)

num_accounts <- 500
accounts <- tibble(
  account_id = paste0("001", sprintf("%05d", 1:num_accounts)),
  company_name = paste("Company", 1:num_accounts),
  industry = sample(c("Healthcare", "Tech", "Finance", "Retail"), num_accounts, replace = TRUE),
  signup_date = sample(seq(as.Date('2022-01-01'), as.Date('2023-12-31'), by="day"), num_accounts, replace = TRUE)
)

opps_new <- accounts %>%
  mutate(
    opp_id = paste0("006", sprintf("%05d", row_number())),
    opp_type = "New Business",
    close_date = signup_date,
    amount = round(runif(n(), 500, 5000), 2)
  ) %>%
  select(opp_id, account_id, opp_type, close_date, amount)

opps_events <- opps_new %>%
  sample_n(300) %>% # 300 accounts get an event
  mutate(
    opp_id = paste0("006_evt", row_number()),
    close_date = close_date + days(sample(90:365, n(), replace = TRUE)),
    opp_type = sample(c("Upgrade", "Downgrade", "Churn"), n(), replace = TRUE, prob = c(0.5, 0.3, 0.2)),
    # Upgrades add 20-50%, Downgrades lose 20-50%, Churn zeros out
    amount = case_when(
      opp_type == "Upgrade" ~ round(amount * runif(n(), 0.2, 0.5), 2),
      opp_type == "Downgrade" ~ round(amount * -runif(n(), 0.2, 0.5), 2),
      opp_type == "Churn" ~ -amount # Technically, churn cancels the entire MRR
    )
  )

salesforce_opps <- bind_rows(opps_new, opps_events)

write_csv(accounts, "sf_accounts.csv")
write_csv(salesforce_opps, "sf_opportunities.csv")
