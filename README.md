# Farmccity Advanced Database Portfolio

This repository contains five practical database portfolios built around Farm Commerce City (Farmccity), a fictional marketplace connecting produce buyers with farmers. The work explores relational database design, query optimization, transactions, NoSQL document modelling, and distributed databases.

## Portfolio contents

1. [Database Design and Modelling](./portfolio-1-database-design/README.md)  
   PostgreSQL schema, relationships, constraints, normalization, and sample records.
2. [Query Processing and Optimisation](./portfolio-2-query-optimisation/README.md)  
   Query plans and index comparisons using a synthetic PostgreSQL workload.
3. [Transactions and Concurrency](./portfolio-3-transactions-concurrency/README.md)  
   Rollback, row locking, and a concurrent inventory reservation exercise.
4. [NoSQL Data Modelling with MongoDB](./portfolio-4-nosql/README.md)  
   Embedded marketplace order documents, CRUD examples, and an aggregation.
5. [Distributed Databases with MongoDB Replica Sets](./portfolio-5-distributed-database/README.md)  
   A three-member local replica set with secondary reads and failover evidence.

The final report and reflection are provided separately as a Word document in the named submission folder.

## Case study rules

- One buyer order may contain items from several farmers.
- An order has one simulated buyer payment and separate farmer payouts.
- The marketplace uses NGN and applies a 1% commission to each farmer's subtotal.
- Payment and payout records are coursework examples. They do not move real money.

## Tools used

- PostgreSQL 18 for Portfolios 1 to 3
- MongoDB Server and `mongosh` for Portfolio 4
- MongoDB Server 9.0 running three local instances for Portfolio 5
- Git for version control and progressive portfolio commits

Portfolio 5 runs natively on Windows and does not require Docker or WSL. Its local MongoDB data is stored in an ignored `data` directory and is not included in the repository.

## Getting started

Start with Portfolio 1 and follow the practical instructions in each portfolio README. The SQL scripts and MongoDB scripts should be run in the order described in their documentation. Some data-generation scripts are intentionally one-time scripts; read their notes before running them again.

Each portfolio includes its own evidence folder and records the observed results. Review each README for prerequisites, commands, expected output, and cleanup instructions.

## Repository structure

```text
portfolio-1-database-design/
portfolio-2-query-optimisation/
portfolio-3-transactions-concurrency/
portfolio-4-nosql/
portfolio-5-distributed-database/
Ogenyi_Joy_301907483_FINAL_REPORT.docx
```

## AI use

Copilot assistance in VS Code was used to help draft database scripts, queries, and documentation. The practical database exercises were run and their outputs were reviewed and documented.
