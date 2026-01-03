# iOS Activity Data

## Goal
Explore relationships between iOS activity data (step count and device usage) using data extracted from local backups.

## Data Sources & Extraction
Step count data originate from Apple Health and were obtained via an encrypted local iOS backup. The Health database (`healthdb_secure.sqlite`) was exported using iPhone Backup Extractor by Reincubate and serves as the raw data source for this project.

### Known artifact: HealthKit backfill spikes (late 2018)
The extracted daily step series occasionally contains missing calendar day(s) with by an unusually large step total on the last day before the missing day(s). This matches Apple Health’s “backfill” behavior after periods when the device was not recording/syncing normally: steps accrued over multiple days can appear as a lumped total in the raw samples, while the Health app UI redistributes them across days.
For trend plots and downstream correlation analysis, we flag any day where the next observed date is more than 1 day later (`gap_days` > 1) as a gap-anchor day and exclude those rows from analysis. We also export both data/steps_daily_flagged.csv and data/steps_daily_clean.csv for transparency and reproducibility.

## Status
- Extraction of raw step count data from an encrypted iOS Health database is complete.
- Step samples have been identified (`samples.data_type = 7`) and validated via lifetime step-count sanity checks (~29.3M steps over ~10 years).
- Daily step aggregation logic has been defined and justified based on interval-length diagnostics and timezone considerations.
- Daily steps exported to csv.
- Analysis in R pending.
- Screen Time data feasibility remains under investigation.


## Open Questions
- Whether Screen Time data can be extracted with comparable granularity.
- How to align step data timestamps with device usage metrics.

## Milestones
- 2025-12-27: Health data extraction + schema discovery complete (see notes/healthdb-schema-discovery.md)
- 2025-12-29: Identified step samples as `samples.data_type = 7` and validated via lifetime step total sanity check (≈29.3M).
- 2026-01-02: Investigated late-2018 step outliers; identified multi-day HealthKit backfill behavior via missing calendar days. Added gap-detection logic (`gap_days`, `is_gap_anchor`) and exported flagged vs cleaned daily step datasets