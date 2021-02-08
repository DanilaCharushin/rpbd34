#!/bin/bash

DB_NAME="test"

mongo localhost:30000/$DB_NAME --eval '
sh.status()

db.phones.getShardDistribution()
for(let i=0;i<1000;i++){
  db.phones.insert({
    number:1,
    type_id:"1"
  })
}
db.phones.getShardDistribution()
'