# Portfolio 3: Transactions and Concurrency

## Case study

This portfolio continues the Farm Commerce City (Farmccity) marketplace from Portfolios 1 and 2. It uses the existing PostgreSQL database, `farmccity_db`.

## Objective

Demonstrate transaction atomicity and prevent two concurrent checkouts from reserving the same last unit of produce. The practical exercise uses a dedicated test listing, so it does not change the existing sample or performance data.

## Transaction and concurrency scenario

The test listing begins with one kilogram available. Each database session attempts to reserve that unit. The reservation transaction locks the listing row with `SELECT ... FOR UPDATE`, then decreases stock only when at least one unit remains.

Run the same reservation script in two database sessions. The second session should wait while the first holds the row lock. After the first session commits, the second session should see that no stock remains. Its guarded update should return no rows. Roll back that second transaction.

The separate rollback exercise decreases stock inside a transaction, then rolls the transaction back. The stock should remain unchanged, demonstrating that an uncommitted change can be undone.

## Files

- `prepare_test_listing.sql` creates one dedicated farmer, product, category, and listing for the exercise. It is safe to run again and does not reset a listing that already exists.
- `rollback_demo.sql` demonstrates rolling back a stock change.
- `reservation_session_a.sql` and `reservation_session_b.sql` contain the same reservation statements for use in separate sessions. Each script leaves its transaction open so you can control when it commits or rolls back.
- `reset_test_listing.sql` restores the test listing to one kilogram after both sessions have ended. Do not run it while either session has an open transaction.

## Practical steps

Run these commands from the Portfolio 3 folder in PowerShell. Use your existing PostgreSQL installation and `farmccity_db`.

### 1. Create the test listing

First change to the Portfolio 3 folder:

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-3-transactions-concurrency"
```

Then run:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d farmccity_db -W -v ON_ERROR_STOP=1 -f "prepare_test_listing.sql"
```

Confirm the output shows one test listing with an available quantity of `1.000`. This setup does not require or change a database password.

### 2. Demonstrate rollback

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d farmccity_db -W
```

At the `farmccity_db` prompt, run the rollback exercise. Replace the example path with the actual location of this repository:

```text
\i 'C:/Users/Admin/Desktop/MAKIA/Advanced_Database_Portfolio/Database-Portfolio/portfolio-3-transactions-concurrency/rollback_demo.sql'
```

The final query should still show `1.000` available. Take a screenshot of the update and rollback output, then exit with `\q`.

### 3. Demonstrate concurrent reservations

Open two separate PowerShell windows. In each, connect to the database using the same `psql.exe` connection command above. Keep both database sessions open.

In the first database session, run:

```text
\i 'C:/Users/Admin/Desktop/MAKIA/Advanced_Database_Portfolio/Database-Portfolio/portfolio-3-transactions-concurrency/reservation_session_a.sql'
```

The script locks the test listing and decreases its stock, but does not commit. Leave this session open.

In the second database session, run:

```text
\i 'C:/Users/Admin/Desktop/MAKIA/Advanced_Database_Portfolio/Database-Portfolio/portfolio-3-transactions-concurrency/reservation_session_b.sql'
```

This session should wait on the row lock. Return to the first session and enter:

```sql
COMMIT;
```

The second session should then finish. Its `SELECT ... FOR UPDATE` should show `0.000` available, and its guarded `UPDATE` should return no rows. In the second session, enter:

```sql
ROLLBACK;
```

Check the listing quantity from either session. It should be `0.000`, not a negative value. Exit both sessions with `\q`.

### 4. Reset the test listing

After both sessions have ended, run:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\psql.exe" -h localhost -U postgres -d farmccity_db -W -v ON_ERROR_STOP=1 -f "reset_test_listing.sql"
```

Confirm that the test listing is back to `1.000` available. This makes the exercise repeatable.

## What to explain

- `BEGIN` starts a transaction. The stock change is not permanent until `COMMIT`.
- `ROLLBACK` undoes a transaction's uncommitted changes.
- `SELECT ... FOR UPDATE` locks the selected listing row so another transaction cannot reserve it at the same time.
- The condition `available_quantity >= 1` prevents stock from becoming negative.
- At PostgreSQL's `READ COMMITTED` isolation level, the waiting transaction sees the value committed by the first transaction when it proceeds.
- These scripts demonstrate inventory reservation in the database only. They do not create an order, charge a buyer, or move money.

## Observed results

The test listing was created with `1.000 kg` available. In the rollback exercise, the quantity changed to `0.000` inside the transaction and returned to `1.000` after `ROLLBACK`.

During the concurrency exercise, Session A reserved the available unit and held its transaction open. Session B waited on the listing row lock. After Session A committed, Session B saw `0.000` available, and its guarded update returned zero rows. The final check showed `0.000`, confirming the stock did not become negative. After both sessions ended, the reset script restored the listing to `1.000 kg`.

## Evidence checklist

- [x] [Setup and rollback output](./Evidence/Screenshot%202026-11-10%20100852.png) shows the test listing setup and the quantity returning to `1.000` after rollback.
- [x] [Before commit](./Evidence/Before%20COMMIT.png) shows Session A holding the reservation while Session B is waiting.
- [x] [After commit](./Evidence/After%20COMMIT.png) shows Session B seeing `0.000` and its guarded update returning zero rows.
- [x] Final stock check reported `0.000`, so the quantity did not become negative.
- [x] Reset output reported listing `5` at `1.000 kg`.
- [x] The row lock makes concurrent reservations wait, and the guarded update prevents stock from becoming negative.

The reset result was confirmed after the screenshots above. If you repeat the practical exercise, save a screenshot of the reset output in `Evidence/` as well.

## AI use note

Copilot assistance in VS Code was used to draft the transaction examples and documentation. The scripts are intended to be run and verified in PostgreSQL 18 as part of the practical work.
