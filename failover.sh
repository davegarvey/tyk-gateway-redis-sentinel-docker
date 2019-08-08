#!/bin/bash

REDIS_INSTANCE="a"

if [ "$1" != "" ]; then
  REDIS_INSTANCE=$1
fi

CONTAINER_NAME="redis-sentinel_redis-${REDIS_INSTANCE}_1"

echo "setting $CONTAINER_NAME to sleep for 30 seconds"

docker exec $CONTAINER_NAME redis-cli -p 6379 DEBUG sleep 30