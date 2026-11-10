// Farmccity Portfolio 4 document reads and aggregation.

const farmccity = db.getSiblingDB("farmccity_nosql");

print("Buyer order history:");
printjson(
  farmccity.orders.find(
    { buyerId: "buyer-001" },
    {
      _id: 1,
      createdAt: 1,
      status: 1,
      currency: 1,
      items: 1,
      delivery: 1,
      payment: 1,
      farmerPayouts: 1,
      deliveries: 1
    }
  ).sort({ createdAt: -1 }).toArray()
);

print("Gross sales by farmer and produce:");
printjson(
  farmccity.orders.aggregate([
    { $unwind: "$items" },
    {
      $group: {
        _id: {
          farmerId: "$items.farmerId",
          farmName: "$items.farmName",
          productName: "$items.productName",
          unit: "$items.unit"
        },
        quantitySold: { $sum: "$items.quantity" },
        grossSales: { $sum: "$items.lineTotal" }
      }
    },
    { $sort: { grossSales: -1 } }
  ]).toArray()
);
