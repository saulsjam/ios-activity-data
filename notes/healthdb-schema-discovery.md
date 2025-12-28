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


- Created an encrypted local iOS backup and used iPhone Backup Extractor to confirm that Health data is present. 
- Identified and exported healthdb_secure.sqlite, which is a SQLite database file containing years of HealthKit data. Its size (~177 MB) strongly indicates it holds raw, historical samples like step counts, not just summaries. 
- Opened that file in DB Browser for SQLite and confirmed it contains a full database schema: tables, indexes, views, triggers.
- Discovered: quantity_samples, which stores numeric values (quantity) keyed by data_id objects, which acts as a hub table with identifiers, provenance, and creation timestamps data_provenances, which describes where data came from (device, source, OS version), not what the data is a samples table that includes start_date and end_date, meaning it likely represents time-bounded Health samples. Along the way, the key conceptual shift was learning to use SQL not just on data tables, but on the schema itself.
- Learned that: sqlite_master is a system table provided by SQLite, not a separate file. Each row in sqlite_master describes a database object (table, index, view, trigger). The sql column literally stores the original CREATE TABLE / CREATE INDEX / CREATE VIEW statements Querying sqlite_master is a way to inspect the structure of an unknown database, similar to searching through source code That explains why queries like: SELECT name, sql FROM sqlite_master WHERE type = 'table' AND sql LIKE '%start_date%'; work: they are text searches over table definitions, not data queries.
- Conceptually, the model you now have is: The step values live in quantity_samples The time intervals live in samples Tables are connected via shared identifiers like data_id The remaining task is to identify how Apple encodes what kind of quantity each sample represents (steps vs distance vs calories), which is done indirectly via identifiers rather than a plainly named “steps” table At this point, feasibility is fully confirmed. You have the data, you understand the schema-discovery strategy, and the remaining work is careful, targeted joining and decoding—not guesswork.