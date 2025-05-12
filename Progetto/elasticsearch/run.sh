#!/bin/bash

echo "Starting Elasticsearch in background..."
/usr/local/bin/docker-entrypoint.sh &

echo $'\n'Waiting for Elasticsearch to start...
until curl -u elastic:$ELASTIC_PASSWORD -s http://localhost:9200/_cluster/health | grep -q '"status":"green"'; do
    sleep 5
done

echo $'\n'Elasticsearch is ready!$'\n'Setting password for kibana_system user ...
curl -u elastic:$ELASTIC_PASSWORD -X POST "http://localhost:9200/_security/user/kibana_system/_password" -H "Content-Type: application/json" -d "{\"password\": \"$KIBANA_SYSTEM_PASSWORD\"}"
echo $'\n'Password for kibana_system user set successfully!

# Prevent the script from exiting
echo $'\n'Keeping the container alive...
tail -f /dev/null
