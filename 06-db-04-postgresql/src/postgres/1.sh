#!/usr/bin/env bash

docker exec -u postgres -it postgres-13 dropdb -f --if-exists test_database
docker exec -u postgres -it postgres-13 psql -c "CREATE DATABASE test_database"
docker exec -u postgres -it postgres-13 psql -d test_database -f /pgbackup/test_dump.sql
docker exec -u postgres -it postgres-13 psql -d test_database -f /pgbackup/recreate-table-with-partitions-v2.sql
docker exec -u postgres -it postgres-13 pg_dump -d test_database -F p -b -f /pgbackup/test_database.dmp
