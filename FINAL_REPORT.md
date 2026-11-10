# Farmccity Advanced Database Portfolio: Final Report and Reflection

## Introduction

This portfolio follows Farm Commerce City (Farmccity), a fictional online marketplace where buyers order produce from multiple farmers. The work explores how different database concepts support the same business: relational design, query optimization, transaction safety, document storage, and replication. PostgreSQL was used for the first three portfolios, and MongoDB was used for the NoSQL and distributed database exercises.

The marketplace rules were kept consistent throughout. An order can contain produce from several farmers, the buyer makes one simulated payment, and each participating farmer has a separate payout and delivery record. The marketplace uses NGN and applies a 1% commission to each farmer's subtotal. Payments and payouts in the coursework are sample database records only. They do not connect to a payment provider or transfer money.

## What I implemented

### Relational design and normalization

In Portfolio 1, I designed and implemented a PostgreSQL schema with separate tables for buyers, farmers, categories, products, listings, orders, order items, payments, farmer payouts, and deliveries. Primary and foreign keys connect the records, while uniqueness, check constraints, and status values protect important business rules.

The design keeps buyer and farmer profiles separate from order records. Order items preserve the unit and price used at checkout, so later listing changes do not rewrite order history. This made the relational model suitable for structured data with clear relationships and rules. The schema and implementation details are documented in the [Portfolio 1 README](./portfolio-1-database-design/README.md).

### Query processing and optimization

Portfolio 2 compared a buyer order-history query before and after indexing. The test data included 100 generated buyers, 1,000 orders, and 2,000 order items, alongside the original sample order.

The baseline query used a sequential scan and sort and recorded 0.873 ms. The first composite index produced a bitmap heap scan and still needed a sort. Its recorded time, 1.218 ms, was slower than the baseline. A covering index on the buyer and order date, including the selected order columns, allowed an index-only scan with no heap fetches and no sort. That run recorded 0.296 ms, about 66% less than the baseline.

The result taught me not to assume that adding an index automatically improves a query. The query plan helped explain why the initial index did not help and why the covering index performed better in that run. The timings came from a small dataset and individual measurements, so they are useful evidence for this exercise, not a general performance guarantee. This was the most challenging portfolio for me because interpreting the changing plans and deciding what the evidence actually showed took careful comparison. The query workload and observations are in the [Portfolio 2 README](./portfolio-2-query-optimisation/README.md).

### Transactions and concurrency

Portfolio 3 used a dedicated test listing with one kilogram available. A rollback exercise reduced the quantity inside a transaction, then showed that `ROLLBACK` restored it to 1.000 kg.

For the concurrency test, two PostgreSQL sessions tried to reserve the same last unit. Session A locked the listing row using `SELECT ... FOR UPDATE` and committed its reservation. Session B waited for the lock, then saw that the quantity was 0.000. Its guarded update returned no rows, preventing the stock from becoming negative. The listing was reset after the test. This showed me how transactions and row locks help protect shared inventory when requests overlap. The test and its evidence are documented in the [Portfolio 3 README](./portfolio-3-transactions-concurrency/README.md).

### MongoDB document modelling

In Portfolio 4, I created a MongoDB model with buyer, farmer, listing, and order collections. The sample order embeds its items, delivery destination, payment, farmer payouts, and delivery statuses in a single document. This supports reading an order and its history together, while the separate listings collection holds current inventory and prices.

The sample setup reported one buyer, two farmers, two listings, and one order. The aggregation returned 5 kg of tomatoes with NGN 9,000 in gross sales for Green Valley Farms and 2 crates of yam with NGN 5,000 for Sunrise Produce Farm. A separate CRUD exercise created, updated, and deleted a test document. Compared with the relational design, embedding makes a complete order convenient to retrieve, but duplicates some farmer and product details. The [Portfolio 4 README](./portfolio-4-nosql/README.md) includes the design discussion and evidence.

### Replication and failover

Portfolio 5 used three MongoDB Server processes running locally on Windows, each with a separate data directory and port. Docker could not run because of a WSL issue, so I used the MongoDB installation already on the computer instead. The replica set started with port 27018 as primary and ports 27019 and 27020 as secondaries.

I wrote a sample order through the replica-set connection and read it from a secondary, confirming that the returned order had replicated. When I stopped the primary at 27018, port 27019 was elected primary while 27020 remained secondary. After 27018 restarted, all three members were healthy. The higher-priority 27018 member became primary again. This practical test demonstrated replication and failover, but all three processes ran on one computer, so it did not protect against that computer or its disk failing. The full steps and evidence are in the [Portfolio 5 README](./portfolio-5-distributed-database/README.md).

## Reflection and future improvements

Across the portfolios, I learned that database design choices depend on the data, business rules, and access patterns. Relational normalization helped keep marketplace records consistent. Query plans provided better evidence than guessing about index performance. Transactions and row locks made the stock reservation behavior visible under concurrency. MongoDB showed how embedding can simplify order-history reads, while replication showed how a distributed database can keep data available after one member stops.

My preferred approach for this marketplace is a combination: PostgreSQL for orders, payments, and other records that benefit from structured relationships and constraints, with MongoDB where flexible order documents are useful. The right balance would depend on actual application requirements and how the data is read and updated.

If I continued the project, I would add automated application-level tests and run a larger, repeatable query benchmark. Repeating measurements would help separate a consistent improvement from timing variation. I would also add application-level checks for business rules that span multiple tables, such as ensuring the payment equals the order total and that each payout belongs to a farmer with items in that order. The coursework exercises record payment and payout data for demonstration only; a real marketplace would need secure payment integration, stronger access controls, backups, monitoring, and recovery procedures.

## Use of AI

Copilot assistance in VS Code was used to help draft database scripts, query examples, and documentation. I ran the practical exercises in PostgreSQL and MongoDB, reviewed the query outputs and execution plans, and captured the evidence included with the portfolios.
