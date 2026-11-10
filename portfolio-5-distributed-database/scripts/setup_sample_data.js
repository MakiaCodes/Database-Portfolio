const farmccity = db.getSiblingDB("farmccity_ha");

farmccity.orders.updateOne(
  { _id: "p5-order-001" },
  {
    $setOnInsert: {
      buyerName: "Ada Okafor",
      status: "paid",
      currency: "NGN",
      items: [
        {
          productName: "Tomatoes",
          farmName: "Green Valley Farms",
          quantity: NumberDecimal("5.000"),
          unit: "kg",
          lineTotal: NumberDecimal("9000.00")
        },
        {
          productName: "Yam",
          farmName: "Sunrise Produce Farm",
          quantity: NumberDecimal("2.000"),
          unit: "crate",
          lineTotal: NumberDecimal("5000.00")
        }
      ],
      createdAt: new Date()
    }
  },
  {
    upsert: true,
    writeConcern: { w: "majority" }
  }
);

print("Sample order written through the replica-set connection.");
printjson(farmccity.orders.findOne({ _id: "p5-order-001" }));
