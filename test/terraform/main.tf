# ============================================================================ #
#                                     Setup                                    #
# ============================================================================ #

module "common" {
  source        = "git::https://github.com/Ontracon/tfm-cloud-commons.git?ref=v1.0.2"
  cloud_region  = var.cloud_region
  global_config = var.global_config
  custom_tags   = var.custom_tags
  custom_name   = var.custom_name
}
resource "random_pet" "test" {
  length = var.length
}