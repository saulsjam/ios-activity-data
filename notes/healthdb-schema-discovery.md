# HealthDB schema discovery

## Context
This document summarizes the investigation of `healthdb_secure.sqlite` to
understand how Apple HealthKit step count data is structured and how it can be
queried reliably.

## Established findings

The file `healthdb_secure.sqlite` is a large (~177 MB) SQLite database containing
raw historical HealthKit samples rather than only aggregated summaries. Its size
and table count indicate years of retained data.

Step-related values are stored as numeric quantities in the `quantity_samples`
table. These values are not meaningful in isolation and must be interpreted in
relation to time-bounded samples.

Temporal boundaries (start and end timestamps) are stored in the `samples`
table, indicating that HealthKit records measurements over intervals rather than
instantaneous points.

Schema inspection was performed via the SQLite system table `sqlite_master`, which stores the CREATE statements for tables, indexes, views, and triggers. Querying this table using a targeted text search over CREATE statements:

```sql
SELECT name, sql
FROM sqlite_master
WHERE type = 'table'
  AND sql LIKE '%start_date%';
```

enabled targeted discovery of timestamp columns and candidate tables without relying on undocumented schema references.

Step samples are identified by `samples.data_type = 7`. This was inferred by (a) integer-valued quantities, (b) high frequency among sample types, and (c) a lifetime SUM(quantity) of 29,327,899 steps across ~10 years (~8k/day), which is consistent with expected totals.

Join path: `samples (data_id, start_date, end_date, data_type)` joins to `quantity_samples (data_id, quantity, ...)` on `data_id`.

## Remaining questions

- How are `samples.start_date` and `samples.end_date` encoded for day-level aggregation?
- Are other `sample.data_type` values relevant to my analysis and do they need to be decoded?