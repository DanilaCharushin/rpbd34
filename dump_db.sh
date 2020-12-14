#!/bin/bash

mongoexport --host localhost:30000 --db test --collection phone_types --out dump/phone_types.json --jsonArray --pretty
mongoexport --host localhost:30000 --db test --collection phones --out dump/phones.json --jsonArray --pretty
mongoexport --host localhost:30000 --db test --collection users --out dump/users.json --jsonArray --pretty
