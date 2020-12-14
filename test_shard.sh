#!/bin/bash

DB_NAME="test"

mongo localhost:30000/$DB_NAME --eval '
sh.status()

db.addresses.getShardDistribution()
for(let i=0;i<1000;i++){db.addresses.insert({place:"1",postcode:1})}
db.addresses.getShardDistribution()

db.phones.getShardDistribution()
for(let i=0;i<1000;i++){
  db.phones.insert({
    number:1,
    type_id: [
      "5fd485a957d4aa659617a2da",
      "5fd485a957d4aa659617a2db",
      "5fd485a957d4aa659617a2d9"
    ][Math.floor(Math.random()*3)]
  })
}
db.phones.getShardDistribution()
'