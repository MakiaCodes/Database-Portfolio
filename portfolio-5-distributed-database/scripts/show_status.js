const status = rs.status();
const members = status.members.map((member) => ({
  name: member.name,
  state: member.stateStr,
  health: member.health
}));

printjson({
  replicaSet: status.set,
  members: members
});

if (members.length !== 3 || members.filter((member) => member.state === "PRIMARY").length !== 1) {
  throw new Error("Expected three replica-set members and exactly one primary.");
}
