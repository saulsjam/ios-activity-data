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

Step samples are interval-based and vary in duration. Diagnostic checks show:
- Average interval length ≈ 6 minutes.
- Intervals longer than 15 minutes are rare (22 samples total).
- A small number of very long intervals exist (multi-day), likely due to device sync or restore artifacts.

A minority of step samples cross calendar-day boundaries when converted to local
time. These samples account for ~277k steps, representing <1% of total lifetime
steps (~29.3M).

While proportional allocation across calendar days is conceptually appealing, its benefit is limited by the absence of per-sample timezone metadata. Because step timestamps are stored in absolute time and converted using a single assumed timezone, travel introduces uncertainty that outweighs sub-day allocation refinements.

Given the rarity of long intervals, the small fraction of cross-midnight steps,
and timezone ambiguity, daily aggregation assigns step samples to the calendar
day corresponding to their `start_date` after local-time conversion. 

Daily step totals can be reproduced by summing `quantity_samples.quantity`
grouped by the local calendar date derived from `samples.start_date`
(after Apple → Unix epoch conversion). This aggregation matches Health app
daily totals on most days; discrepancies occur primarily on days with
activity near midnight.


## Remaining questions

