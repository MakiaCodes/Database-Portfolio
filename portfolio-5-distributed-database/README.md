# Portfolio 5: Distributed Databases with MongoDB Replica Sets

## Case study

This portfolio continues the Farm Commerce City (Farmccity) marketplace. Portfolio 4 modeled its documents in MongoDB. This portfolio runs a three-member MongoDB replica set directly on Windows to demonstrate replication, secondary reads, and primary election after a member failure.

## Objective

Use multiple database nodes to demonstrate how a distributed database keeps copies of data, serves a secondary read, and elects a new primary when the current primary becomes unavailable. This is a local learning setup, not a production deployment or cloud benchmark.

## Architecture

Three `mongod` processes run on the same computer, each with a separate data directory and port: `27018`, `27019`, and `27020`. The replica set uses the loopback address `127.0.0.1`, so the nodes are not exposed to the local network. The existing MongoDB Windows service, which uses port `27017`, can remain running.

The first member has a higher election priority to make it the preferred primary, but always check the reported status rather than assuming which node is primary. The three instances share one computer, so this exercise demonstrates replica-set behavior, not protection from computer or disk failure.

## Files

- `scripts/initiate_replica_set.js` initializes the replica set. Run it once for fresh data directories.
- `scripts/show_status.js` prints the replica-set member states and checks for three members and one primary.
- `scripts/setup_sample_data.js` writes a sample Farmccity order with majority write concern.
- `scripts/verify_secondary_read.js` reads the sample order using secondary read preference and confirms the responding member is a secondary.
- `.gitignore` keeps local MongoDB data out of Git.

## Requirements and safety

MongoDB Server and `mongosh` must be installed. These instructions use the existing MongoDB Server 9.0 installation at `C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe`. The scripts use `mongosh` from the PowerShell `PATH`.

The three instances have no authentication configured and are intended only for local coursework. They bind to `127.0.0.1`. Do not change the bind address to expose them to the internet or use this setup for production data.

## Practical steps

Open PowerShell and change to this portfolio folder:

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-5-distributed-database"
```

### 1. Check ports and create data folders

Confirm nothing else is listening on ports `27018`, `27019`, or `27020`:

```powershell
Get-NetTCPConnection -LocalPort 27018,27019,27020 -State Listen -ErrorAction SilentlyContinue
```

If the command returns a listener, do not start an instance on that port. Resolve the conflict first. Create separate database and log folders:

```powershell
New-Item -ItemType Directory -Force ".\data\mongo1", ".\data\mongo2", ".\data\mongo3", ".\data\logs" | Out-Null
```

The `data` folder is excluded from Git by `.gitignore`.

### 2. Start the three MongoDB instances

Open three separate PowerShell windows. In each window, change to the Portfolio 5 folder and run the matching command below. Each `mongod` stays in the foreground in its window. Leave all three running.

**Window 1:**

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-5-distributed-database"
& "C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet farmccity-rs --bind_ip 127.0.0.1 --port 27018 --dbpath ".\data\mongo1" --logpath ".\data\logs\mongo1.log" --logappend
```

**Window 2:**

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-5-distributed-database"
& "C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet farmccity-rs --bind_ip 127.0.0.1 --port 27019 --dbpath ".\data\mongo2" --logpath ".\data\logs\mongo2.log" --logappend
```

**Window 3:**

```powershell
Set-Location "C:\Users\Admin\Desktop\MAKIA\Advanced_Database_Portfolio\Database-Portfolio\portfolio-5-distributed-database"
& "C:\Program Files\MongoDB\Server\9.0\bin\mongod.exe" --replSet farmccity-rs --bind_ip 127.0.0.1 --port 27020 --dbpath ".\data\mongo3" --logpath ".\data\logs\mongo3.log" --logappend
```

If MongoDB reports an error, stop and resolve it before moving on. Do not close the three windows while running the exercises.

### 3. Initialize the replica set

From a fourth PowerShell window in the Portfolio 5 folder, run this once for fresh data directories:

```powershell
mongosh "mongodb://127.0.0.1:27018/admin?directConnection=true" --quiet --file ".\scripts\initiate_replica_set.js"
```

Wait about 10 to 20 seconds for the election, then check status:

```powershell
mongosh "mongodb://127.0.0.1:27018,127.0.0.1:27019,127.0.0.1:27020/admin?replicaSet=farmccity-rs" --quiet --file ".\scripts\show_status.js"
```

The output should report three healthy members: one `PRIMARY` and two `SECONDARY`. Save a screenshot.

### 4. Write the sample order through the replica set

```powershell
mongosh "mongodb://127.0.0.1:27018,127.0.0.1:27019,127.0.0.1:27020/farmccity_ha?replicaSet=farmccity-rs" --quiet --file ".\scripts\setup_sample_data.js"
```

The script writes one Farmccity order with majority write concern. Save a screenshot showing the order.

### 5. Read the order from a secondary

Use the status output to choose a member currently listed as `SECONDARY`. This example uses port `27019`. If a different member is secondary, replace the port with that member's port:

```powershell
mongosh "mongodb://127.0.0.1:27019/farmccity_ha?directConnection=true&readPreference=secondary" --quiet --file ".\scripts\verify_secondary_read.js"
```

The output should show `isSecondary: true` and the replicated order. If replication has not caught up yet, wait a few seconds and run the read again. Save a screenshot.

### 6. Observe primary failover

Check which instance is `PRIMARY` in the status output. Stop only that instance by pressing `Ctrl+C` in its PowerShell window. For example, if the primary is on port `27018`, stop Window 1. Leave the other two instances running.

Wait about 10 to 20 seconds for an election, then check status through either surviving member:

```powershell
mongosh "mongodb://127.0.0.1:27019,127.0.0.1:27020/admin?replicaSet=farmccity-rs" --quiet --file ".\scripts\show_status.js"
```

If you stopped a different instance, use the two ports still running. The status should show one primary, one secondary, and one member down. Save a screenshot.

Restart the stopped instance by running its original `mongod` command again in its PowerShell window. Wait for it to rejoin, then run the status command using all three ports. The member with the higher election priority may become primary again after it rejoins. Check and record the status you actually observe, including three healthy members. Save a screenshot.

### 7. Stop the instances

When finished, press `Ctrl+C` in each of the three `mongod` windows. The local database files remain in the ignored `data` folder and can be reused for a later run. To remove the data, first stop all three instances, then remove only this portfolio's `data` folder:

```powershell
Remove-Item ".\data" -Recurse
```

This permanently removes the three local test databases and logs. You do not need to remove them to finish the portfolio.

## Concepts demonstrated

- Replication keeps copies of data on multiple replica-set members.
- A primary accepts writes, and secondary members replicate committed changes.
- A majority write concern waits for acknowledgment from a majority of voting members.
- A read preference can direct a query to a secondary when slightly stale data is acceptable.
- If the primary becomes unavailable, the remaining voting members can elect another primary.
- A three-member replica set can elect a primary after one member fails because two members remain available.
- Election priority can affect which member becomes primary after a previously stopped node rejoins.
- Replication improves availability but is not a substitute for backups. The three local instances also share the same computer, so this exercise does not protect against computer or disk failure.

## Observed results

The replica set initialized with `127.0.0.1:27018` as primary and `27019` and `27020` as secondaries. The Farmccity sample order was written through the replica-set connection with majority write concern. A direct read from `27019` confirmed `isSecondary: true` and returned the replicated order.

After the primary at `27018` was stopped, `27019` became primary and `27020` remained secondary. When `27018` restarted, all three members were healthy again. Because `27018` has a higher election priority, it became primary again, and the other members returned to secondary state.

## Evidence checklist

- [x] [Replica-set status with all three instances healthy after restoration](./Evidence/REPLICA%20SET%20RESTORED.png)
- [x] [Sample order written through the replica set](./Evidence/Screenshot%202026-11-10%20150631.png)
- [x] [Secondary read showing `isSecondary: true`](./Evidence/Screenshot%202026-11-10%20150851.png)
- [x] [Failover status showing `27019` as primary while `27018` was unavailable](./Evidence/Screenshot%202026-11-10%20151534.png)
- [x] Restored status confirms the stopped member rejoined and all three members are healthy.
- [x] The architecture, concepts, observed failover, majority writes, and single-computer limitations are discussed above.

The results above reflect the observed run. Election time may vary. If an instance does not start or a command fails, save the error and investigate before claiming failover succeeded.

## AI use note

Copilot assistance in VS Code was used to draft the replica-set scripts and documentation. Run the practical steps and verify the node states and query output on your own Windows installation.
