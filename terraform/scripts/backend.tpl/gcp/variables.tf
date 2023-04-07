variable "gcp_project" {
  type        = string
  description = "GCP project name"
}

variable "cloud_region" {
  type        = string
  description = "GCP region"
}

variable "bucket_name" {
  type        = string
  description = "The name of the Google Storage Bucket to create"
}