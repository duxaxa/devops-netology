#!/usr/bin/env bash

docker compose down
docker compose up -d
sleep 10
docker exec -u postgres -it postgres-13 psql -c "DROP DATABASE test_database"
docker exec -u postgres -it postgres-13 psql -c "CREATE DATABASE test_database"
docker exec -u postgres -it postgres-13 psql -f /pgbackup/test_dump.sql -d test_database
