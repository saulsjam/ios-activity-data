# 03-plot-daily-steps.R
# Purpose: plot daily step counts (faint points) + rolling average (bold line)
# from cleaned CSV.

library(ggplot2)

steps_daily <- read.csv("data/steps_daily_clean.csv", stringsAsFactors = FALSE)
steps_daily$date  <- as.Date(steps_daily$date)
steps_daily$steps <- as.numeric(steps_daily$steps)

dir.create("charts", showWarnings = FALSE)

# ---- Rolling average time series ----
window_days <- 90

# Centered rolling average (will be NA at the ends)
steps_daily$steps_roll_avg <- as.numeric(
  stats::filter(steps_daily$steps, rep(1 / window_days, window_days), sides = 2)
)

out_file <- sprintf("charts/steps_daily_timeseries_%dd.png", window_days)

p <- ggplot(steps_daily, aes(x = date)) +
  # background: daily steps as faint dots
  geom_point(aes(y = steps), alpha = 0.15, size = 0.8) +
  # foreground: rolling average as bold line
  geom_line(aes(y = steps_roll_avg), linewidth = 1.2, na.rm = TRUE) +
  labs(
    title = "Daily Steps with 90-Day Rolling Average",
    subtitle = "Cleaned data; Gap-anchor days excluded",
    x = "Date",
    y = "Steps"
  ) +
  theme_minimal(base_size = 12)

ggsave(out_file, plot = p, width = 12, height = 7, dpi = 150)

# ---- Histogram of daily steps ----

bin_width <- 1000

median_steps = median(steps_daily$steps, na.rm = TRUE)

p_hist <- ggplot(steps_daily, aes(x = steps)) +
  geom_histogram(
    binwidth = bin_width,
    boundary = 0,
    fill = "grey70",
    color = "grey40"
  ) +
  geom_vline(
    xintercept = median_steps,
    linewidth = 1
  ) +
  annotate(
    "text",
    x = median_steps,
    y = Inf,
    label = paste0("Median = ", median_steps),
    vjust = 3.5,
    hjust = -0.1,
    size = 3.5
  ) +
  labs(
    title = "Distribution of Daily Step Counts",
    subtitle = "Cleaned data; Gap-anchor days excluded",
    x = "Steps per day",
    y = "Number of days"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  sprintf("charts/steps_daily_histogram_b%d.png", bin_width) ,
  plot = p_hist,
  width = 10,
  height = 6,
  dpi = 150
)


# ---- Seasonality: average daily steps by month-of-year (all years pooled) ----

# Month-of-year as an ordered factor (Jan ... Dec)
steps_daily$month_name <- factor(
  format(steps_daily$date, "%b"),
  levels = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"),
  ordered = TRUE
)


p_season_box <- ggplot(steps_daily, aes(x = month_name, y = steps)) +
  geom_boxplot(outlier.alpha = 0.3, width = 0.7) +
  labs(
    title = "Daily Step Counts by Month of Year",
    subtitle = "All years pooled; Cleaned data; Gap-anchor days excluded",
    x = "Month",
    y = "Steps per day"
  ) +
  theme_minimal(base_size = 12)

ggsave(
  "charts/steps_seasonality_boxplot_month_of_year.png",
  plot = p_season_box,
  width = 10,
  height = 6,
  dpi = 150
)