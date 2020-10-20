#############################
# Elasticsearch related
#############################
variable "elasticsearch_host" {
  description = "Elasticsearch endpoint used to submit index, search, and data upload requests"
}

variable "elasticsearch_port" {
  description = "Elasticsearch service port"
}

variable "artifacts_base_path" {
  description = "Base path to output file artifacts. Use `get_terragrunt_dir()` with an `extra_argument` to provide this value"
  default     = "./"
}

#############################
# Fluentd related
#############################

variable "fluentd_match" {
  description = "Tags that fluentd should output to S3 and Elasticsearch"
}

variable "fluentd_port" {
  description = "Port on the Docker image in which the HTTP interface is exposed"
  default     = 4224
}

variable "logs_local_store_enabled" {
  description = "Enable to store copy of logs on the local machine"
  default     = false
}

#############################
# S3 Logging related
#############################

variable "logs_s3_bucket_name" {
  description = "Name of S3 bucket to store logs for long term archival"
}

variable "logs_s3_enabled" {
  description = "Enable to log to S3"
  default     = true
}

variable "logs_s3_abort_incomplete_days" {
  description = "Specifies the number of days after initiating a multipart upload when the multipart upload must be completed."
  default     = 7
}

variable "logs_s3_ia_transition_days" {
  description = "Number of days before logs are transitioned to IA. Must be > 30 days"
  default     = 90
}

variable "logs_s3_glacier_transition_days" {
  description = "Number of days before logs are transitioned to IA. Must be > var.logs_s3_ia_transition_days + 30 days"
  default     = 365
}

variable "logs_s3_policy" {
  description = "Name of the IAM policy to provision for write access to the bucket"
  default     = "LogsS3WriteNew"
}

variable "logs_s3_storage_class" {
  description = "Default storage class to store logs in S3. Choose from `STANDARD`, `REDUCED_REDUNDANCY` or `STANDARD_IA`"
  default     = "STANDARD"
}

variable "tags" {
  description = "Tags to apply to resources"

  default = {
    Terraform = "true"
  }
}
