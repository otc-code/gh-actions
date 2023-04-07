# define GCP region

variable "cloud_region" {
  type        = string
  description = "GCP region"
}

variable "bucket_name" {
  type        = string
  description = "The name of the Google Storage Bucket to create"
}