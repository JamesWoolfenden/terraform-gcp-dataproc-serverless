variable "batch_id" {
  type        = string
  description = "ID of the Dataproc Serverless batch (4-63 chars, lowercase letters, numbers and hyphens)"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,61}[a-z0-9]$", var.batch_id))
    error_message = "var.batch_id must be 4-63 characters of lowercase letters, numbers and hyphens, starting and ending with a letter or number"
  }
}

variable "region" {
  type        = string
  description = "Region the batch (and session template) run in"

  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "var.region must be a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "CMEK key used to encrypt workload persistent disks and data; must be in the same region as the workload"

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }

  validation {
    condition     = can(regex("/locations/${var.region}/", var.kms_key_name))
    error_message = "var.kms_key_name must be a KMS key in the same location as var.region"
  }
}

variable "subnetwork" {
  type        = string
  description = "Self-link or URI of the subnetwork the workload runs on. It must have Private Google Access enabled (workloads get internal IPs only)"

  validation {
    condition     = length(trimspace(var.subnetwork)) > 0
    error_message = "var.subnetwork must be a non-empty string"
  }
}

variable "service_account" {
  type        = string
  description = "Email of the service account the workload runs as; granted roles/dataproc.worker. Must not be the default Compute Engine SA"

  validation {
    condition     = length(trimspace(var.service_account)) > 0 && !can(regex("(-compute@developer|@appspot)\\.gserviceaccount\\.com$", var.service_account))
    error_message = "var.service_account must be a non-empty service account email and must not be a default GCP service account (Compute Engine or App Engine)"
  }
}

variable "runtime_version" {
  type        = string
  description = "Dataproc Serverless runtime version to pin to, so upgrades happen deliberately rather than by picking up GCP's default"
  default     = "2.2"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+(\\.[0-9]+)?$", var.runtime_version))
    error_message = "var.runtime_version must be a runtime version such as \"2.2\""
  }
}

variable "spark_properties" {
  type        = map(string)
  description = "Spark properties applied to the workload runtime"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.spark_properties : length(trimspace(k)) > 0])
    error_message = "var.spark_properties keys must be non-empty strings"
  }
}

variable "ttl" {
  type        = string
  description = "Maximum duration (e.g. \"3600s\") the workload may run before it is terminated"
  default     = "3600s"

  validation {
    condition     = can(regex("^[0-9]+s$", var.ttl))
    error_message = "var.ttl must be a duration string like \"3600s\""
  }
}

variable "staging_bucket" {
  type        = string
  description = "Name of a GCS bucket for workload dependencies and config. Null lets Dataproc use its per-project default bucket"
  default     = null

  validation {
    condition     = var.staging_bucket == null || can(regex("^[a-z0-9][a-z0-9._-]{1,61}[a-z0-9]$", var.staging_bucket))
    error_message = "var.staging_bucket must be null or a bucket name (not a gs:// URI)"
  }
}

variable "network_tags" {
  type        = list(string)
  description = "Network tags applied to workload VMs, used to target firewall rules"
  default     = []

  validation {
    condition     = alltrue([for t in var.network_tags : can(regex("^[a-z]([-a-z0-9]{0,61}[a-z0-9])?$", t))])
    error_message = "var.network_tags must be valid GCE network tags (lowercase letters, numbers and hyphens)"
  }
}

variable "spark_batch" {
  type = object({
    main_class    = string
    jar_file_uris = list(string)
    args          = optional(list(string), [])
    file_uris     = optional(list(string), [])
    archive_uris  = optional(list(string), [])
  })
  description = "Spark batch definition: main class and the jars holding it"

  validation {
    condition     = length(trimspace(var.spark_batch.main_class)) > 0
    error_message = "var.spark_batch.main_class must be a non-empty string"
  }

  validation {
    condition     = length(var.spark_batch.jar_file_uris) > 0 && alltrue([for u in var.spark_batch.jar_file_uris : can(regex("^(gs|file)://", u))])
    error_message = "var.spark_batch.jar_file_uris must contain at least one gs:// or file:// URI"
  }
}

variable "session_template" {
  type = object({
    name         = string
    kernel       = optional(string, "PYTHON")
    display_name = optional(string)
    idle_ttl     = optional(string, "1800s")
  })
  description = "Optional interactive (Jupyter) session template sharing the batch's CMEK, network and service account settings. Null to create none"
  default     = null

  validation {
    condition     = var.session_template == null || can(regex("^[a-z0-9][a-z0-9-]{2,61}[a-z0-9]$", try(var.session_template.name, "")))
    error_message = "var.session_template.name must be 4-63 characters of lowercase letters, numbers and hyphens"
  }

  validation {
    condition     = var.session_template == null || contains(["PYTHON", "SCALA"], try(var.session_template.kernel, ""))
    error_message = "var.session_template.kernel must be PYTHON or SCALA"
  }

  validation {
    condition     = var.session_template == null || can(regex("^[0-9]+s$", try(var.session_template.idle_ttl, "")))
    error_message = "var.session_template.idle_ttl must be a duration string like \"1800s\""
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the batch and session template for cost allocation and ownership tracking"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.labels : can(regex("^[a-z0-9_-]{1,63}$", k)) && can(regex("^[a-z0-9_-]{0,63}$", v))])
    error_message = "var.labels keys and values must be lowercase letters, numbers, underscores, or dashes (GCP label constraints)"
  }
}
