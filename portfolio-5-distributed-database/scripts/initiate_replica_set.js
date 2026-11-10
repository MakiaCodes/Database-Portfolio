const config = {
  _id: "farmccity-rs",
  members: [
    { _id: 0, host: "127.0.0.1:27018", priority: 2 },
    { _id: 1, host: "127.0.0.1:27019", priority: 1 },
    { _id: 2, host: "127.0.0.1:27020", priority: 1 }
  ]
};

printjson(rs.initiate(config));
