# Portfolio 2: Query Processing and Optimisation

## Case study

This portfolio continues the Farm Commerce City (Farmccity) marketplace from Portfolio 1. The PostgreSQL database is `farmccity_db`, and monetary values use NGN.

## Objective

Compare a buyer order-history query before and after indexing. Record query results and execution plans, then explain whether the change improved the query and why.

## Test data

The test data script adds 100 synthetic buyers, 1,000 orders, and 2,000 order items. It also adds the matching payment, farmer payout, and delivery rows so the generated orders follow the marketplace rules. The original Portfolio 1 sample order remains in the database.

Run [`generate_test_data.sql`](./generate_test_data.sql) once, after Portfolio 1 has been loaded. The script does not delete or replace existing records. In PowerShell, run it from this folder:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d farmccity_db -W -v ON_ERROR_STOP=1 -f "generate_test_data.sql"
```

The final result should show 100 generated buyers, 1,000 orders, 2,000 order items, 1,000 payments, and 2,000 farmer payouts. Do not run the script a second time.

## Query workload

The buyer order-history query in [`queries.sql`](./queries.sql) searches by buyer and sorts the results by date. Run it before adding indexes and record the `EXPLAIN (ANALYZE, BUFFERS)` output. The first test used a composite index on `(buyer_id, order_date DESC)`, but the planner still chose a bitmap heap scan and a sort. Its observed execution time was 1.218 ms, compared with 0.873 ms before indexing. This is evidence that an index can add overhead on a small table.

The current [`indexes.sql`](./indexes.sql) replaces that index with a covering index that also includes the columns selected by the buyer-history query. It runs `VACUUM (ANALYZE)` so PostgreSQL can consider an index-only scan. Run the same query again and record what the planner actually chooses. Do not force PostgreSQL to use the index. The same query file includes a produce sales summary for query results.

## Observed results

The captured plans show three stages:

| Test | Plan for the buyer-history query | Execution time |
|---|---|---:|
| Before an index | Sequential scan on `orders`, followed by a sort | 0.873 ms |
| Initial composite index | Bitmap heap scan, followed by a sort | 1.218 ms |
| Covering composite index | Index-only scan with 0 heap fetches and no sort | 0.296 ms |

In the captured run, the covering-index query took about 66% less time than the baseline. The first index still needed heap access and a sort, and its captured time was slower than the baseline. The covering index stores the selected columns, supports the requested order, and allowed PostgreSQL to avoid those steps.

These are measurements from a small synthetic dataset and one captured run. Cache state and timing variation can affect the results, so the plan change is also important evidence. The produce summary returned 3,005 kg of tomatoes with NGN 5,409,000 in gross sales, and 1,502 crates of yam with NGN 3,755,000 in gross sales. The buyer-history query returned the same 10 orders before and after indexing.

## Evidence checklist

- [x] Query results for buyer order history and a produce sales summary
- [x] Execution plan before adding indexes
- [x] Index definition and execution plan after adding indexes
- [x] Short comparison of elapsed time and plan changes
- [x] Screenshots or saved query output in `Evidence/`

## AI use note

Copilot assistance in VS Code was used to draft the synthetic data script, query workload, index options, and performance notes. The scripts were run in PostgreSQL 18, and the query results and execution plans were reviewed.

## Practical notes

Run the before-index query and save its result and plan before creating any new index. Run `ANALYZE` before comparing plans. Keep the database, query parameters, and PostgreSQL settings the same for both measurements.
