const connection = db.getMongo();
connection.setReadPref("secondary");

const farmccity = db.getSiblingDB("farmccity_ha");
const order = farmccity.orders.findOne({ _id: "p5-order-001" });
const hello = connection.getDB("admin").runCommand({ hello: 1 });

printjson({
  connectedMember: hello.me,
  isSecondary: hello.secondary,
  replicatedOrder: order
});

if (!hello.secondary) {
  throw new Error("The read did not run on a secondary member.");
}

if (!order) {
  throw new Error("The sample order was not found on the secondary.");
}
