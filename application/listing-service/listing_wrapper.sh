#!/bin/bash
export LISTING_PORT=8000
export LISTING_ADDR=0.0.0.0
export DB_URL=mongodb.service.consul
export DB_PORT=27017
export DB_USER=${username}
export DB_PW=${password}
/usr/bin/node /opt/listing-service/server.js
