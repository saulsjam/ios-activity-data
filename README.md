# iOS Activity Data

## Project Goal
Analyze long-run patterns and variability in daily step counts recorded by Apple Health, using data extracted from a local iOS backup. This project serves as a capstone analysis emphasizing reproducible data extraction, cleaning, and visualization.

## Data Sources
Daily step data originate from Apple Health and were extracted from an encrypted local iOS backup. The Health database (`healthdb_secure.sqlite`) was exported using iPhone Backup Extractor (Reincubate) and serves as the raw data source. Raw Health data are not committed to this repository; all analysis is performed on derived CSV files.

## Known Data Artifact: HealthKit Backfill
The extracted daily step series contains occasional anomalously large values associated with missing calendar days, consistent with Apple Health’s backfill behavior after periods without normal recording or syncing. To avoid bias in summary statistics and trend visualization, days immediately preceding multi-day gaps (“gap-anchor” days) are flagged and excluded from analysis. Both flagged and cleaned daily datasets are exported for transparency and reproducibility.

## Analysis Pipeline
This repository is organized as a linear, reproducible pipeline:

1. **01-load-daily-steps.R**  
   Extract daily step totals from the Health SQLite database and write `data/steps_daily.csv`.

2. **02-clean-daily-steps.R**  
   Identify and flag gap-anchor days; write both diagnostic and cleaned datasets
   (`data/steps_daily_flagged.csv`, `data/steps_daily_clean.csv`).

3. **03-plot-daily-steps.R**  
   Generate descriptive visualizations of cleaned daily steps, including a time series
   with rolling mean, a histogram with median reference, and month-of-year boxplots.

Running these scripts in order reproduces all analysis artifacts in the repository.

## Outputs
- Cleaned daily step dataset (`data/steps_daily_clean.csv`)
- Time-series plot with rolling mean
- Histogram of daily steps with median reference
- Month-of-year boxplots summarizing seasonal variability

## Project Status
The step-count analysis pipeline is complete and serves as the capstone deliverable for the Google Data Analytics Certificate. Exploration of Screen Time data remains a potential extension but is not required to reproduce or interpret the current results.

## Milestones
- 2025-12-27: Health data extraction and schema discovery complete (see `notes/healthdb-schema-discovery.md`)
- 2025-12-29: Identified step samples (`samples.data_type = 7`) and validated lifetime step totals (~29.3M)
- 2026-01-02: Identified and addressed HealthKit backfill artifacts via gap-anchor detection
- 2026-01-04: Finalized cleaned datasets and visualizations
