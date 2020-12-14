#!/bin/bash

mongos --port 30000 --bind_ip localhost --configdb rs0/localhost:27018
