#!/bin/bash

DB_NAME="test"

mongo localhost:30000/$DB_NAME --eval '
sh.addShard("rs1/localhost:27019,localhost:27020");
sh.addShard("rs2/localhost:27021,localhost:27022");
sh.enableSharding("test");
db.createCollection("phones");
db.createCollection("users");
db.createCollection("phone_types");
db.phones.createIndex({"_id":"hashed"});
db.users.createIndex({"_id":"hashed"});
db.phone_types.createIndex({"_id":"hashed"});
sh.shardCollection("test.phones",{"_id":"hashed"});
sh.shardCollection("test.users",{"_id":"hashed"});
sh.shardCollection("test.phone_types",{"_id":"hashed"});
'
