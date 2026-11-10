// Demonstrate CRUD using one dedicated record in a separate test collection.

const demo = db.getSiblingDB("farmccity_nosql").p4_crud_demo;

demo.updateOne(
  { _id: "portfolio-4-crud-example" },
  { $set: { note: "Original test value" } },
  { upsert: true }
);
print("Create:");
printjson(demo.findOne({ _id: "portfolio-4-crud-example" }));

demo.updateOne(
  { _id: "portfolio-4-crud-example" },
  { $set: { note: "Updated test value" } }
);
print("Update and read:");
printjson(demo.findOne({ _id: "portfolio-4-crud-example" }));

demo.deleteOne({ _id: "portfolio-4-crud-example" });
print("Delete:");
printjson(demo.findOne({ _id: "portfolio-4-crud-example" }));
