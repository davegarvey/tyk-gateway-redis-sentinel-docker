# Tyk Gateway with Redis Sentinel in Docker

This repo provides a working example of the Tyk Gateway using Redis Sentinel for high availability.

The Redis Sentinel deployment is 1 master with 2 replicas and 3 sentinels. There is also a HAProxy instance which proxies the Gateway's connection to Redis.

The Redis Sentinels monitor the status of the Redis instances and will automatically start the failover process if the master is down.

The HAProxy monitors the status of the Redis instances and will automatically target the instance with is reported as master.

## Get started

1. Create the containers, volumes and network using Docker Compose:

        docker-compose up
   
   This will start outputting the logs into the terminal window.
   
   The Gateway is configured to map port 8080 to the host, so make sure you're not already running a container on this port.

2. In a new terminal window, update the scripts to be executable:

        chmod +x *.sh
        
3. Bootstrap the installation:

        ./bootstrap.sh
   
   This script configures the Redis Sentinel instances and creates a test API key which can be used to check if the API Gateway is working ok.
   
   The Sentinal instances are configures to mark a host as failed after 5 seconds and have a failover timeout of 30 seconds. The 3 instances require a quorum of 2 in order to failover a failed master.

## Using the install

Once the install is bootstrapped you can try the following sequence of commands to see how it behaves in the event of a failover.

1. Test that all is ok to begin with:

        curl http://localhost:8080/tyk-api-test/get -H 'authorization: testkey'

    This should return a typical HTTPbin JSON response.

2. Cause a failover:

        ./failover.sh

    This will instruct the 'redis-a' instance, which is the initial master, to not respond for 30 seconds.

    The Sentinels will detect that the master has failed and will failover to one of the replicas.

    The HA proxy will detect that a new master Redis is available and will direct the Gateway's Redis connection to the new master.

    The failed Redis will return after 30 seconds and will be reassigned as a replica.

3. Check that the API request still works:

        curl http://localhost:8080/tyk-api-test/get -H 'authorization: testkey'

    When the replica which became the master failed over it had a copy of the master data, so this enables the Gateway to continue authenticating API requests using the 'testkey'.
    
### Failover script

The `failover.sh` script is used to conveniently cause a Redis instance to be marked as failing. By default it will target instance 'a', but can be used to target other instances by passing a parameter e.g. `./failover.sh b` which will target the 'b' instance.

The script instructs the Redis instance to sleep for 30 seconds which is enough time for the Sentinels to mark it as failed and failover to occur.
