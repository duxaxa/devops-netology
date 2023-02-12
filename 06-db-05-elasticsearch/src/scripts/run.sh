#!/usr/bin/env bash

docker network create elasticsearch_network

docker run \
-d \
--name elasticsearch \
--net elasticsearch_network \
-p 9200:9200 \
-p 9300:9300 \
-v data:/var/lib/data \
duxaxa/elasticsearch:7.17.9