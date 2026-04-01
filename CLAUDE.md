# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

An R-based analysis pipeline for Apple Health step count data extracted from an iOS backup (2016–2025). The project is a completed capstone for the Google Data Analytics Certificate.

## Running the Pipeline

Scripts must be run in order from the project root in an R session (or RStudio with the `.Rproj` open):

```r
source("R/01-load-daily-steps.R")   # Extract from SQLite → data/steps_daily.csv
source("R/02-clean-daily-steps.R")  # Flag/remove anomalies → steps_daily_flagged.csv, steps_daily_clean.csv
source("R/03-plot-daily-steps.R")   # Generate charts → charts/*.png
```

To compile the final report:
```r
rmarkdown::render("report/James_Sauls_SQL_R_Data_Analysis_Sample.Rmd")
```

## External Dependency

Script `01` requires access to the raw SQLite database. The path is set via `.Renviron` (not committed):

```
HEALTHDB_PATH=/path/to/healthdb_secure.sqlite
```

Scripts `02` and `03` only need the CSVs in `data/`, so they can run without the database.

## Architecture

**Data flow:** `healthdb_secure.sqlite` → `01` → `steps_daily.csv` → `02` → `steps_daily_flagged.csv` + `steps_daily_clean.csv` → `03` → `charts/*.png`

**Key domain concept — gap-anchor days:** HealthKit backfills step counts onto the last day before a multi-day recording gap, inflating those values. Script `02` detects these by computing `gap_days` between consecutive dates and flags/excludes any day where `gap_days > 1`. This is the central data quality decision in the project; the flagged CSV preserves them for transparency.

**SQLite schema:** Steps are `data_type = 7` in the `samples` table, joined to `quantity_samples` on `data_id`. Timestamps use Apple's epoch (Unix + 978307200). Full schema notes are in `notes/healthdb-schema-discovery.md`.

## Key Parameters (in `03-plot-daily-steps.R`)

- `window_days = 90` — rolling average window (centered, 2-sided)
- `bin_width = 1000` — histogram bin width in steps
