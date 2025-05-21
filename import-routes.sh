#\!/bin/bash

# Create a shell script to import routes from the YAML file
ETCDCTL_API=3 etcdctl --endpoints=http://etcd:2379 put /apisix/routes/1 '{
  "uri": "/api/*",
  "plugins": {
    "key-auth": {
      "header": "X-API-Key",
      "key": "secret-api-key"
    }
  },
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "mock-api:8080": 1
    }
  }
}'

ETCDCTL_API=3 etcdctl --endpoints=http://etcd:2379 put /apisix/routes/2 '{
  "uri": "/public/*",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "mock-api:8080": 1
    }
  }
}'
