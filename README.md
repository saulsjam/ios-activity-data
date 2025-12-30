# iOS Activity Data

## Goal
Explore relationships between iOS activity data (step count and device usage) using data extracted from local backups.

## Data Sources & Extraction
Step count data originate from Apple Health and were obtained via an encrypted local iOS backup. The Health database (`healthdb_secure.sqlite`) was exported using iPhone Backup Extractor by Reincubate and serves as the raw data source for this project.

## Status
- Extraction of raw step count data from an encrypted iOS Health database is complete.
- Step samples have been identified (`samples.data_type = 7`) and validated via lifetime step-count sanity checks (~29.3M steps over ~10 years).
- Daily step aggregation logic has been defined and justified based on interval-length diagnostics and timezone considerations.
- Data loading and analysis in R are pending.
- Screen Time data feasibility remains under investigation.


## Open Questions
- Whether Screen Time data can be extracted with comparable granularity.
- How to align step data timestamps with device usage metrics.

## Milestones
- 2025-12-27: Health data extraction + schema discovery complete (see notes/healthdb-schema-discovery.md)
- 2025-12-29: Identified step samples as `samples.data_type = 7` and validated via lifetime step total sanity check (≈29.3M).