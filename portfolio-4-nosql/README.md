# Portfolio 4: NoSQL Data Modelling with MongoDB

## Case study

This portfolio continues the Farm Commerce City (Farmccity) marketplace. Portfolio 1 uses PostgreSQL tables for buyers, farmers, listings, orders, items, payments, payouts, and deliveries. This portfolio models the same marketplace using MongoDB documents.

## Objective

Design a document structure around the marketplace's access patterns, load sample records, run document queries and an aggregation, and compare the trade-offs with the relational design.

## Document design

The database has four collections:

- `buyers` stores buyer profile records.
- `farmers` stores farmer profile records.
- `listings` stores the farmer's currently available produce and price.
- `orders` stores one order as a document. Its line items, delivery destination, payment, farmer payouts, and delivery statuses are embedded in that document.

The order embeds snapshots of product, farmer, unit, and price details. This keeps the information needed to display the order together, even if a listing's current price or a buyer's saved address changes later. The order also contains separate payout and delivery records for each participating farmer.

The model duplicates some values, such as a farmer's name in an order item and payout. This supports order-history reads without joining multiple collections, but it means changes to current farmer or product profiles do not automatically rewrite historical orders. Embedding the order details also makes a single order straightforward to read and update as one document. By contrast, frequently changing listing inventory remains in the separate `listings` collection.

## Files

- `setup.js` creates indexes and inserts the sample buyer, farmers, listings, and multi-farmer order. It uses upserts and is safe to run again.
- `queries.js` reads the buyer's order history and aggregates produce quantity and gross sales by farmer and product.
- `crud_demo.js` demonstrates create, read, update, and delete on one specifically named test document in a separate `p4_crud_demo` collection.

## Practical steps

You need MongoDB Server and `mongosh` installed and available in PowerShell. These scripts use the local MongoDB connection at `mongodb://localhost:27017`. They do not use or change your PostgreSQL database.

Open PowerShell and change to this portfolio folder:

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-4-nosql"
```

### 1. Load the sample documents

```powershell
mongosh "mongodb://localhost:27017/farmccity_nosql" --file "setup.js"
```

The final summary should report one buyer, two farmers, two listings, and one order. Running the setup again should not add duplicate sample documents.

### 2. Run the document queries

```powershell
mongosh "mongodb://localhost:27017/farmccity_nosql" --file "queries.js"
```

The first result should show the buyer's order with both farmers' items and the embedded payment and delivery information. The aggregation should return one result per farmer and produce, with the corresponding quantity and gross sales.

### 3. Demonstrate CRUD

```powershell
mongosh "mongodb://localhost:27017/farmccity_nosql" --file "crud_demo.js"
```

The script inserts a test record, reads it, updates it, reads the updated value, and deletes that same test record. It does not modify the marketplace sample data.

## Expected aggregation results

The sample order contains 5 kg of tomatoes from Green Valley Farms at NGN 1,800 per kg, and 2 crates of yam from Sunrise Produce Farm at NGN 2,500 per crate. The aggregation should calculate NGN 9,000 and NGN 5,000 in gross sales respectively.

## Comparison with PostgreSQL

The PostgreSQL design stores order items, payment, payouts, and deliveries in separate related tables. MongoDB embeds these records in an order document because the marketplace often reads the complete order as a unit. Embedding makes that read direct and preserves the order's historical snapshots, but it duplicates profile values and can make independently changing embedded records less convenient.

The examples use a small dataset to demonstrate document structure and query behavior. They are not a performance benchmark, and no performance improvement is claimed.

## Observed results

The setup script reported one buyer, two farmers, two listings, and one order. The order export and Compass screenshot show the order's items, payment, delivery destination, payouts, and delivery statuses in a single document.

The aggregation returned 5.000 kg of tomatoes and NGN 9,000.00 in gross sales for Green Valley Farms, and 2.000 crates of yam and NGN 5,000.00 in gross sales for Sunrise Produce Farm. The CRUD demonstration showed the test record being created, updated, and deleted.

## Evidence checklist

- [x] Setup completed with the expected collection counts: one buyer, two farmers, two listings, and one order
- [x] [Exported order document](./Evidence/farmccity_nosql.orders.json) and [MongoDB Compass screenshot](./Evidence/Screenshot%202026-11-10%20104840.png) showing the embedded order data
- [x] [Aggregation screenshot](./Evidence/Screenshot%202026-11-10%20105714.png) showing gross sales for both farmers
- [x] [CRUD demonstration screenshot](./Evidence/Screenshot%202026-11-10%20105331.png) showing create, update, and the final delete
- [x] Comparison with PostgreSQL explains when embedding helps and what data duplication costs

The output and evidence above are from the MongoDB run for this portfolio.

## AI use note

Copilot assistance in VS Code was used to draft the MongoDB sample documents, queries, and documentation. Run the scripts and verify their output in your local MongoDB environment.
