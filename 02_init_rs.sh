#!/bin/bash

DB_NAME="test"

mongo localhost:27018/$DB_NAME --eval 'rs.initiate({_id:"rs0",configsvr:true,members:[{_id:0,host:"localhost:27018"}]})'
mongo localhost:27019/$DB_NAME --eval 'rs.initiate({_id:"rs1",members:[{_id:0,host:"localhost:27019"},{_id:1,host:"localhost:27020"}]})'
mongo localhost:27021/$DB_NAME --eval 'rs.initiate({_id:"rs2",members:[{_id:0,host:"localhost:27021"},{_id:1,host:"localhost:27022"}]})'
