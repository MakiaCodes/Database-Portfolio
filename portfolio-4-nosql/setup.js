// Farmccity Portfolio 4 sample documents.
// Upserts keep this setup safe to rerun without duplicating sample records.

const farmccity = db.getSiblingDB("farmccity_nosql");

farmccity.orders.createIndex({ buyerId: 1, createdAt: -1 });
farmccity.listings.createIndex({ productId: 1, status: 1 });

farmccity.buyers.updateOne(
  { _id: "buyer-001" },
  {
    $setOnInsert: {
      fullName: "Ada Okafor",
      email: "ada.okafor@example.com",
      phone: "+2348000000101"
    }
  },
  { upsert: true }
);

farmccity.farmers.updateOne(
  { _id: "farmer-001" },
  {
    $setOnInsert: {
      farmName: "Green Valley Farms",
      contactName: "Hawa Bello",
      email: "hawa@greenvalley.example"
    }
  },
  { upsert: true }
);

farmccity.farmers.updateOne(
  { _id: "farmer-002" },
  {
    $setOnInsert: {
      farmName: "Sunrise Produce Farm",
      contactName: "Ikenna Obi",
      email: "ikenna@sunrise.example"
    }
  },
  { upsert: true }
);

farmccity.listings.updateOne(
  { _id: "listing-001" },
  {
    $setOnInsert: {
      farmerId: "farmer-001",
      productId: "product-tomatoes",
      productName: "Tomatoes",
      category: "Vegetables",
      availableQuantity: NumberDecimal("95.000"),
      unit: "kg",
      unitPrice: NumberDecimal("1800.00"),
      currency: "NGN",
      status: "active"
    }
  },
  { upsert: true }
);

farmccity.listings.updateOne(
  { _id: "listing-002" },
  {
    $setOnInsert: {
      farmerId: "farmer-002",
      productId: "product-yam",
      productName: "Yam",
      category: "Tubers",
      availableQuantity: NumberDecimal("48.000"),
      unit: "crate",
      unitPrice: NumberDecimal("2500.00"),
      currency: "NGN",
      status: "active"
    }
  },
  { upsert: true }
);

farmccity.orders.updateOne(
  { _id: "order-001" },
  {
    $setOnInsert: {
      buyerId: "buyer-001",
      createdAt: ISODate("2026-01-15T10:00:00Z"),
      status: "paid",
      currency: "NGN",
      delivery: {
        addressLine: "14 Market Road",
        city: "Abeokuta",
        region: "Ogun",
        countryCode: "NG"
      },
      items: [
        {
          listingId: "listing-001",
          productId: "product-tomatoes",
          productName: "Tomatoes",
          farmerId: "farmer-001",
          farmName: "Green Valley Farms",
          quantity: NumberDecimal("5.000"),
          unit: "kg",
          unitPrice: NumberDecimal("1800.00"),
          lineTotal: NumberDecimal("9000.00")
        },
        {
          listingId: "listing-002",
          productId: "product-yam",
          productName: "Yam",
          farmerId: "farmer-002",
          farmName: "Sunrise Produce Farm",
          quantity: NumberDecimal("2.000"),
          unit: "crate",
          unitPrice: NumberDecimal("2500.00"),
          lineTotal: NumberDecimal("5000.00")
        }
      ],
      payment: {
        amount: NumberDecimal("14000.00"),
        status: "paid",
        paidAt: ISODate("2026-01-15T10:05:00Z")
      },
      farmerPayouts: [
        {
          farmerId: "farmer-001",
          farmName: "Green Valley Farms",
          grossAmount: NumberDecimal("9000.00"),
          commissionRate: NumberDecimal("0.0100"),
          commissionAmount: NumberDecimal("90.00"),
          netAmount: NumberDecimal("8910.00"),
          status: "paid"
        },
        {
          farmerId: "farmer-002",
          farmName: "Sunrise Produce Farm",
          grossAmount: NumberDecimal("5000.00"),
          commissionRate: NumberDecimal("0.0100"),
          commissionAmount: NumberDecimal("50.00"),
          netAmount: NumberDecimal("4950.00"),
          status: "paid"
        }
      ],
      deliveries: [
        { farmerId: "farmer-001", status: "pending" },
        { farmerId: "farmer-002", status: "pending" }
      ]
    }
  },
  { upsert: true }
);

print("Farmccity MongoDB setup complete.");
printjson({
  buyers: farmccity.buyers.countDocuments(),
  farmers: farmccity.farmers.countDocuments(),
  listings: farmccity.listings.countDocuments(),
  orders: farmccity.orders.countDocuments()
});
