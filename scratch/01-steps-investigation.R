# scratch/00-steps-investigation.R
# Purpose: interactive scratchpad for investigating step-data quirks.
# Not part of the reproducible pipeline.

steps_daily <- read.csv("data/steps_daily.csv", stringsAsFactors = FALSE)
steps_daily$date <- as.Date(steps_daily$date)
steps_daily$steps <- as.numeric(steps_daily$steps)

# Grab summaries to investigate
summary(steps_daily$steps)
length(steps_daily$steps)
sum(is.na(steps_daily$steps))

# identify large outliers
sort(steps_daily$steps, decreasing = TRUE)[1:10]
steps_daily[order(steps_daily$steps, decreasing = TRUE)[1:10], ]

# investigate a range
steps_range <- subset(
  steps_daily,
  date >= as.Date("2018-11-01") & date < as.Date("2019-01-01")
)
plot(steps_range$date, recent$steps, type = "l")
lines(steps_range$date, recent$steps_7d_avg, lwd = 2)
View(steps_range)

# missing dates discovery
full_dates <- seq(
  from = min(steps_daily$date),
  to   = max(steps_daily$date),
  by   = "day"
)

missing_dates <- setdiff(full_dates, steps_daily$date)

missing_dates

length(missing_dates)

# identify length of gaps
steps_daily <- steps_daily[order(steps_daily$date), ]

steps_daily$next_date <- c(steps_daily$date[-1], NA)
steps_daily$gap_days <- as.integer(steps_daily$next_date - steps_daily$date)

steps_daily[steps_daily$gap_days > 1, ]

sum(steps_daily$gap_days[steps_daily$gap_days>1], na.rm = TRUE)