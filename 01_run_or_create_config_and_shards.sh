#!/bin/bash

mkdir -p "$(pwd)/store"
cd "$(pwd)/store" || exit
ROOT=$(pwd)

mkdir -p logs
mkdir -p shard/11
mkdir -p shard/12
mkdir -p shard/21
mkdir -p shard/22
mkdir -p config

LOG_CONFIG="$ROOT/logs/config.log"
LOG_SHARD_11="$ROOT/logs/shard11.log"
LOG_SHARD_12="$ROOT/logs/shard12.log"
LOG_SHARD_21="$ROOT/logs/shard21.log"
LOG_SHARD_22="$ROOT/logs/shard22.log"

mongod --configsvr --replSet rs0 --bind_ip localhost --port 27018 --dbpath "$ROOT/config" --logpath "$LOG_CONFIG" --fork

mongod --shardsvr --replSet rs1 --bind_ip localhost --port 27019 --dbpath "$ROOT/shard/11" --logpath "$LOG_SHARD_11" --fork
mongod --shardsvr --replSet rs1 --bind_ip localhost --port 27020 --dbpath "$ROOT/shard/12" --logpath "$LOG_SHARD_12" --fork
mongod --shardsvr --replSet rs2 --bind_ip localhost --port 27021 --dbpath "$ROOT/shard/21" --logpath "$LOG_SHARD_21" --fork
mongod --shardsvr --replSet rs2 --bind_ip localhost --port 27022 --dbpath "$ROOT/shard/22" --logpath "$LOG_SHARD_22" --fork
