#!/bin/bash

mongoimport --host localhost:30000 --db test --collection phone_types --file dump/phone_types.json --jsonArray
mongoimport --host localhost:30000 --db test --collection phones --file dump/phones.json --jsonArray
mongoimport --host localhost:30000 --db test --collection users --file dump/users.json --jsonArray
