# AWS variables
variable "cloud_region" {
  type = string
}


variable "s3_bucket_name" {
  type    = string
  default = ""
}

variable "dynamodb_table_name" {
  type    = string
  default = ""
}
