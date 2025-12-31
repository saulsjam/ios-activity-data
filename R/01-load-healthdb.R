steps_check <- dbGetQuery(con, "
  SELECT
    COUNT(*) AS n_rows,
    MIN(s.start_date) AS min_start_date,
    MAX(s.start_date) AS max_start_date,
    SUM(qs.quantity) AS total_steps
  FROM samples s
  JOIN quantity_samples qs
    ON s.data_id = qs.data_id
  WHERE data_type = 7
")

steps_check
