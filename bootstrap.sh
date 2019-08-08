#!/bin/bash


# set up redis sentinels

declare -a sentinel_hostnames=("redis-sentinel_redis-sentinel1_1" "redis-sentinel_redis-sentinel2_1" "redis-sentinel_redis-sentinel3_1")

master_ip="$(docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-sentinel_redis-a_1)"

for i in "${sentinel_hostnames[@]}"
do
    echo "setting $i as sentinel for $master_ip"
    docker exec $i redis-cli -p 26379 sentinel monitor mymaster $master_ip 6379 2
    docker exec $i redis-cli -p 26379 sentinel set mymaster down-after-milliseconds 5000
    docker exec $i redis-cli -p 26379 sentinel set mymaster failover-timeout 30000
done

# create API key

echo "creating key API key"
curl http://localhost:8080/tyk/keys/testkey \
  -H 'x-tyk-authorization: 352d20ee67be67f6340b4c0605b044b7' \
  -d '{
	"last_check": 0,
	"certificate": null,
	"allowance": 1000,
	"hmac_enabled": false,
	"hmac_string": "",
	"basic_auth_data": {
		"password": ""
	},
	"rate": 1000,
	"per": 60,
	"expires": 0,
	"quota_max": 1000,
	"quota_renews": 1545018259,
	"quota_remaining": 1000,
	"quota_renewal_rate": 3600,
	"access_rights": {
		"1": {
			"api_id": "1",
			"api_name": "Tyk Test API",
			"versions": ["Default"],
			"allowed_urls": []
		}
	},
	"apply_policy_id": "",
	"apply_policies": [],
	"tags": [],
	"jwt_data": {
		"secret": ""
	},
	"meta_data": {},
	"alias": ""
}'

echo "Test API call: curl http://localhost:8080/tyk-api-test/get -H 'authorization: testkey'"