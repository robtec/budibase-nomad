# budibase-nomad

Client Config
```
client {
    host_volume "minio-data" {
        path = "/opt/minio/data/"
        read_only = false
    }

    host_volume "redis-data" {
        path = "/opt/redis/data/"
        read_only = false
    }

    host_volume "couchdb-data" {
        path = "/opt/couchdb/data/"
        read_only = false
    }
}

plugin "docker" {
  config {
    volumes {
      enabled      = true
    }
  }
}
```
