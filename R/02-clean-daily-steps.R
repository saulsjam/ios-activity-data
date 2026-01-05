# 02-clean-daily-steps.R
# Purpose: flag and remove HealthKit backfill "gap-anchor" days; write cleaned CSVs.
# Input:
#   data/steps_daily.csv
# Outputs:
#   data/steps_daily_flagged.csv
#   data/steps_daily_clean.csv
# Notes:
#   Gap-anchor days are defined as the final recorded date preceding a multi-day
#   gap in observations; these days accumulate steps over the gap and bias
#   distributional and time-series statistics.

steps_daily <- read.csv("data/steps_daily.csv", stringsAsFactors = FALSE)
steps_daily$date  <- as.Date(steps_daily$date)
steps_daily$steps <- as.numeric(steps_daily$steps)

# Ensure chronological order
steps_daily <- steps_daily[order(steps_daily$date), ]

# Lead date + gap length
steps_daily$next_date <- c(steps_daily$date[-1], NA)
steps_daily$gap_days  <- as.integer(steps_daily$next_date - steps_daily$date)

# Gap-anchor days: the day immediately before a multi-day gap
steps_daily$is_gap_anchor <- !is.na(steps_daily$gap_days) & steps_daily$gap_days > 1

# Missing calendar days (total)
total_missing_days <- sum(steps_daily$gap_days[steps_daily$gap_days > 1] - 1, na.rm = TRUE)

# Cleaned dataset for plotting/trend analysis
steps_daily_clean <- subset(steps_daily, !is_gap_anchor, select = c(date, steps))

dir.create("data", showWarnings = FALSE)
write.csv(steps_daily, "data/steps_daily_flagged.csv", row.names = FALSE)
write.csv(steps_daily_clean, "data/steps_daily_clean.csv", row.names = FALSE)

cat("Rows (raw):   ", nrow(steps_daily), "\n")
cat("Rows (clean): ", nrow(steps_daily_clean), "\n")
cat("Gap-anchor days dropped:", sum(steps_daily$is_gap_anchor, na.rm = TRUE), "\n")
cat("Total missing calendar days detected:", total_missing_days, "\n")
