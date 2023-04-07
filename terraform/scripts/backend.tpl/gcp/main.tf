provider "google" {
  region  = var.cloud_region
  project = "otc-plattform"
}

# Create a GCS Bucket
resource "google_storage_bucket" "tf-bucket" {
  name          = var.bucket_name
  location      = var.cloud_region
  force_destroy = true
  versioning {
    enabled = true
  }
  public_access_prevention = "enforced"
}
