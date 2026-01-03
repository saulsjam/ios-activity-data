# 03-plot-daily-steps.R
# Purpose: plot daily step counts from cleaned CSV.

steps_daily <- read.csv("data/steps_daily_clean.csv", stringsAsFactors = FALSE)
steps_daily$date  <- as.Date(steps_daily$date)
steps_daily$steps <- as.numeric(steps_daily$steps)

# 30-day rolling average (centered)
steps_daily$steps_30d_avg <- as.numeric(
  stats::filter(steps_daily$steps, rep(1/30, 30), sides = 2)
)

dir.create("charts", showWarnings = FALSE)

png("charts/steps_daily_timeseries_clean.png", width = 1200, height = 700)

plot(
  steps_daily$date, steps_daily$steps,
  type = "l",
  xlab = "Date",
  ylab = "Steps",
  main = "Daily Steps (gap-anchor days excluded)"
)

lines(steps_daily$date, steps_daily$steps_30d_avg, lwd = 2)

legend(
  "topright",
  legend = c("Daily steps", "30-day average"),
  lwd = c(1, 2),
  bty = "n"
)

dev.off()
