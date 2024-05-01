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
    default     = "testsecretkeykey"
}

variable "internal_api_key" {
    type        = string
    description = "The Internal API Key."
    default     = "testsecret"
}

job "budibase" {

  datacenters = ["dc1"]

  type        = "service"

  group "budibase" {

    network {
        port "app" { to = 80 }
    }

    task "app" {

        driver = "docker"
        config {
            image = "budibase/budibase:latest"
            ports = ["app"]
        }
        env {
            JWT_SECRET = "${var.jwt_secret}"
            MINIO_ACCESS_KEY = "${var.minio_access_key}"
            MINIO_SECRET_KEY = "${var.minio_secret_key}"
            REDIS_PASSWORD = "${var.redis_pass}"
            COUCHDB_USER = "${var.couch_db_user}"
            COUCHDB_PASSWORD = "${var.couch_db_pass}"
            INTERNAL_API_KEY = "${var.internal_api_key}"
        }
    }
  } 
}
