variable "couch_db_user" {
    type        = string
    description = "The Couch DB Username."
    default     = "micky"
}

variable "couch_db_pass" {
    type        = string
    description = "The Couch DB Password."
    default     = "mouse"
}

variable "redis_pass" {
    type        = string
    description = "The Redis Password."
    default     = "duckduckduck"
}

variable "api_enc_key" {
    type        = string
    description = "The API Encryption Key."
    default     = "testsecret"
}

variable "jwt_secret" {
    type        = string
    description = "The JWT Secret."
    default     = "testsecret"
}

variable "minio_access_key" {
    type        = string
    description = "The Minio Access Key."
    default     = "testsecret"
}

variable "minio_secret_key" {
    type        = string
    description = "The Minio Secret Key."
    default     = "testsecret"
}

variable "internal_api_key" {
    type        = string
    description = "The Internal API Key."
    default     = "testsecret"
}

variable "budibase_env" {
    type        = string
    description = "The Budibase Env."
    default     = "PRODUCTION"
}

variable "cluster_port" {
    type        = number
    description = "Cluster port."
    default     = 10000
}

job "budibase" {

  datacenters = ["dc1"]

  type        = "service"

  group "budibase" {

    volume "minio-data" {
        type      = "host"
        read_only = false
        source    = "minio-data"
    }

    volume "couchdb-data" {
        type      = "host"
        read_only = false
        source    = "couchdb-data"
    }

    volume "redis-data" {
        type      = "host"
        read_only = false
        source    = "redis-data"
    }

    network {
        port "proxy" { to = var.cluster_port }
    }

    task "app" {

        driver = "docker"
        config {
            image = "budibase/apps"
        }
        env {
            SELF_HOSTED=1
            COUCH_DB_URL = "http://${var.couch_db_user}:${var.couch_db_pass}@couchdb:5984"
            WORKER_URL = "http://worker:4003"
            MINIO_URL = "http://minio:9000"
            MINIO_ACCESS_KEY = "${var.minio_access_key}"
            MINIO_SECRET_KEY = "${var.minio_secret_key}"
            INTERNAL_API_KEY = "${var.internal_api_key}"
            BUDIBASE_ENVIRONMENT = "${var.budibase_env}"
            PORT = 4002
            API_ENCRYPTION_KEY = "${var.api_enc_key}"
            JWT_SECRET = "${var.jwt_secret}"
            LOG_LEVEL = "info"
            ENABLE_ANALYTICS = "true"
            REDIS_URL = "redis:6379"
            REDIS_PASSWORD = "${var.redis_pass}"
            BB_ADMIN_USER_EMAIL = "${BB_ADMIN_USER_EMAIL}"
            BB_ADMIN_USER_PASSWORD = "${BB_ADMIN_USER_PASSWORD}"
            PLUGINS_DIR = "${PLUGINS_DIR}"
            OFFLINE_MODE = "${OFFLINE_MODE}"
        }
    }

    task "worker" {

        driver = "docker"
        config {
            image = "budibase/worker"
        }
        env {
            SELF_HOSTED=1
            PORT = 4003
            CLUSTER_PORT = "${var.cluster_port}"
            COUCH_DB_URL = "http://${var.couch_db_user}:${var.couch_db_pass}@couchdb:5984"
            WORKER_URL = "http://worker:4003"
            MINIO_URL = "http://minio:9000"
            MINIO_ACCESS_KEY = "${var.minio_access_key}"
            MINIO_SECRET_KEY = "${var.minio_secret_key}"
            INTERNAL_API_KEY = "${var.internal_api_key}"
            BUDIBASE_ENVIRONMENT = "${var.budibase_env}"
            API_ENCRYPTION_KEY = "${var.api_enc_key}"
            JWT_SECRET = "${var.jwt_secret}"
            LOG_LEVEL = "info"
            ENABLE_ANALYTICS = "true"
            REDIS_URL = "redis:6379"
            REDIS_PASSWORD = "${var.redis_pass}"
            BB_ADMIN_USER_EMAIL = "${BB_ADMIN_USER_EMAIL}"
            BB_ADMIN_USER_PASSWORD = "${BB_ADMIN_USER_PASSWORD}"
            PLUGINS_DIR = "${PLUGINS_DIR}"
            OFFLINE_MODE = "${OFFLINE_MODE}"
        }
    }

    task "minio" {
    
        driver = "docker"
        lifecycle {
            hook = "prestart"
            sidecar = true
        }
        config {
            image = "minio/minio"
            args = ["server", "/data"]

            mount {
                type = "volume"
                target = "/data"
                source = "minio-data"
            }
        }
        env {
            MINIO_ACCESS_KEY = "${var.minio_access_key}"
            MINIO_SECRET_KEY = "${var.minio_secret_key}"
            MINIO_BROWSER = "off"
        }
    }

    task "proxy" {
    
        driver = "docker"
        config {
            image = "budibase/proxy"
            ports = ["proxy"]
        }
        env {
            PROXY_RATE_LIMIT_WEBHOOKS_PER_SECOND = 10
            PROXY_RATE_LIMIT_API_PER_SECOND = 20
            APPS_UPSTREAM_URL = "http://app:4002"
            WORKER_UPSTREAM_URL = "http://worker:4003"
            MINIO_UPSTREAM_URL = "http://minio:9000"
            COUCHDB_UPSTREAM_URL = "http://couchdb:5984"
            WATCHTOWER_UPSTREAM_URL = "http://watchtower:8080"
            RESOLVER = "127.0.0.11"
        }
    }

    task "couchdb" {
    
        driver = "docker"
        lifecycle {
            hook = "prestart"
            sidecar = true
        }
        config {
            image = "budibase/couchdb"

            mount {
                type = "volume"
                target = "/opt/couchdb/data"
                source = "couchdb-data"
            }
        }
        env {
            COUCHDB_PASSWORD = "${var.couch_db_pass}"
            COUCHDB_USER = "${var.couch_db_user}"
        }
    }

    task "redis" {
    
        driver = "docker"
        lifecycle {
            hook = "prestart"
            sidecar = true
        }
        config {
            image = "redis"

            command = "--requirepass ${var.redis_pass}"

            mount {
                type = "volume"
                target = "/data"
                source = "redis-data"
            }
        }
    }
  } 
}
