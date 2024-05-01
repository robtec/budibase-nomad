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
        port "redis" { to = 6379 }
        port "couchdb" { to = 5984 }
        port "app" { to = 4002 }
        port "worker" { to = 4003 }
        port "minio" { to = 9000 }
    }

    task "app" {

        driver = "docker"
        config {
            image = "budibase/budibase:latest"
            ports = ["app"]
        }
        env {
            SELF_HOSTED=1
            COUCH_DB_URL = "http://${var.couch_db_user}:${var.couch_db_pass}@${NOMAD_ADDR_couchdb}"
            WORKER_URL = "http://${NOMAD_ADDR_worker}"
            MINIO_URL = "http://${NOMAD_ADDR_minio}"
            MINIO_ACCESS_KEY = "${var.minio_access_key}"
            MINIO_SECRET_KEY = "${var.minio_secret_key}"
            INTERNAL_API_KEY = "${var.internal_api_key}"
            BUDIBASE_ENVIRONMENT = "${var.budibase_env}"
            PORT = 4002
            API_ENCRYPTION_KEY = "${var.api_enc_key}"
            JWT_SECRET = "${var.jwt_secret}"
            LOG_LEVEL = "info"
            ENABLE_ANALYTICS = "true"
            REDIS_URL = "${NOMAD_ADDR_redis}"
            REDIS_PASSWORD = "${var.redis_pass}"
            BB_ADMIN_USER_EMAIL = "${BB_ADMIN_USER_EMAIL}"
            BB_ADMIN_USER_PASSWORD = "${BB_ADMIN_USER_PASSWORD}"
            PLUGINS_DIR = "${PLUGINS_DIR}"
            OFFLINE_MODE = "${OFFLINE_MODE}"
        }
    }
  } 
}
