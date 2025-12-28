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

## Remaining questions

- How step count samples are distinguished from other quantity types
- Which identifier or join path encodes the HealthKit data type
- Whether provenance tables are required for correct filtering