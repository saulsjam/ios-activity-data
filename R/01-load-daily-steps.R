# Purpose:
#   Extract daily step counts from healthdb_secure.sqlite.
#
# Notes:
#   - Steps are identified by samples.data_type = 7
#   - samples is joined to quantity_samples on data_id
#   - Step intervals are assigned to a local calendar date based on start_date
#   - Aggregation to daily totals is intentional and reversible; finer-grained
#     views (e.g., hourly) may be derived in separate scripts

library(DBI)
library(RSQLite)

db_path <-  Sys.getenv("HEALTHDB_PATH")
stopifnot(nzchar(db_path))

con <- dbConnect(SQLite(), dbname = db_path)
on.exit(dbDisconnect(con), add = TRUE)

steps_daily <- dbGetQuery(con,"
  SELECT
    date(DATETIME(s.start_date + 978307200, 'unixepoch', 'localtime')) AS date,
    SUM(qs.quantity) AS steps
    FROM samples s
    JOIN quantity_samples qs
      ON s.data_id = qs.data_id
    WHERE s.data_type = 7
      AND s.end_date > s.start_date
    GROUP BY date
    ORDER BY date DESC
                          ")

dir.create("data", showWarnings = FALSE)

write.csv(steps_daily, "data/steps_daily.csv", row.names = FALSE)
